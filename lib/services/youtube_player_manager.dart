import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import 'package:music_player/models/constant/YT_TYPE.dart';
import 'package:music_player/models/yt_song.dart';
import 'package:music_player/services/player_manager.dart';
import 'package:music_player/utils/platform_util.dart';

class YoutubePlayerManager implements PlayerManager {
  static final YoutubePlayerManager _instance =
      YoutubePlayerManager._internal();

  factory YoutubePlayerManager() => _instance;

  YoutubePlayerManager._internal();

  // =====================================================
  // CONTROLLER
  // youtube_player_iframe controller — must be attached to
  // a YoutubePlayerScaffold / YoutubePlayer widget in the tree
  // =====================================================

  YoutubePlayerController? _controller;

  /// Expose controller so the widget layer can attach it.
  /// Hanya dipakai di Android — di Windows/Linux, youtube_player_iframe
  /// (berbasis webview_flutter) tidak punya implementasi resmi, sehingga
  /// controller ini tidak boleh diakses/dibangun di sana.
  YoutubePlayerController get controller {
    assert(
      PlatformUtil.isAndroid,
      'YoutubePlayerManager.controller hanya didukung di Android. '
      'Gunakan browser bawaan untuk Windows/Linux.',
    );
    _controller ??= YoutubePlayerController(
      params: const YoutubePlayerParams(
        showControls: false,
        showFullscreenButton: false,
        mute: false,
        loop: false,
      ),
    );
    return _controller!;
  }

  bool _isDisposed = false;

  Timer? _pollTimer;

  // =====================================================
  // VALUE NOTIFIERS
  // =====================================================

  @override
  final ValueNotifier<bool> isPlaying = ValueNotifier(false);

  @override
  final ValueNotifier<Duration> position = ValueNotifier(Duration.zero);

  @override
  final ValueNotifier<Duration> duration = ValueNotifier(Duration.zero);

  /// True selagi menunggu WebView siap dan/atau video sedang dimuat
  /// (dari tap play sampai video benar-benar mulai berjalan).
  @override
  final ValueNotifier<bool> isLoading = ValueNotifier(false);

  final ValueNotifier<YtSong?> currentYtSong = ValueNotifier(null);

  // =====================================================
  // QUEUE
  // =====================================================

  final List<YtSong> queue = [];
  int _queueIndex = -1;

  int get currentIndex => _queueIndex;

  void Function()? onTrackComplete;

  YtSong? get currentSong {
    if (_queueIndex < 0 || _queueIndex >= queue.length) return null;
    return queue[_queueIndex];
  }

  bool get hasNext => _queueIndex < queue.length - 1;

  bool get hasPrev => _queueIndex > 0;

  // =====================================================
  // POLLING — karena youtube_player_iframe tidak punya stream
  // untuk position/duration/isPlaying secara langsung
  // =====================================================

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(milliseconds: 500), (_) async {
      if (_isDisposed || _controller == null) return;
      await _pollState();
    });
  }

  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  Future<void> _pollState() async {
    try {
      final playerState = await _controller!.playerState;
      final pos = await _controller!.currentTime;
      final dur = await _controller!.duration;

      if (_isDisposed) return;

      final playing = playerState == PlayerState.playing;
      isPlaying.value = playing;
      position.value = Duration(milliseconds: (pos * 1000).round());
      duration.value = Duration(milliseconds: (dur * 1000).round());

      // Loading selesai begitu video mulai main atau sudah siap (paused),
      // tapi tetap dianggap loading selama masih buffering/unstarted/cued.
      if (playerState == PlayerState.playing ||
          playerState == PlayerState.paused) {
        isLoading.value = false;
      }

      // Cek track complete
      if (playerState == PlayerState.ended) {
        _stopPolling();
        isPlaying.value = false;
        isLoading.value = false;
        onTrackComplete?.call();
      }
    } catch (_) {
      // Controller belum siap / sedang dispose
    }
  }

  // =====================================================
  // QUEUE CONTROL
  // =====================================================

  void loadQueue(List<YtSong> songs, {int startIndex = 0}) {
    queue
      ..clear()
      ..addAll(songs);
    setIndex(startIndex);
  }

  void setIndex(int index) {
    if (index < 0 || index >= queue.length) return;
    _queueIndex = index;
  }

  // =====================================================
  // PLAY
  // =====================================================

  @override
  Future<void> play() async {
    final song = currentSong;
    if (song == null) return;

    if (song.type != YT_TYPE.VIDEO) {
      debugPrint("YoutubePlayerManager: tipe tidak didukung (${song.type})");
      return;
    }

    currentYtSong.value = song;
    isLoading.value = true;

    // Desktop (Windows/Linux) tidak punya implementasi webview yang stabil,
    // jadi diputar lewat browser bawaan OS saja.
    if (PlatformUtil.isDesktop) {
      await _playInExternalBrowser(song);
      return;
    }

    await _loadVideo(song);
  }

  /// Ganti setiap kali play() dipanggil, supaya safety-timeout dari
  /// permintaan lama tidak ikut mematikan isLoading punya video yang baru.
  int _loadToken = 0;

  Future<void> _loadVideo(YtSong song) async {
    final token = ++_loadToken;
    isLoading.value = true;

    try {
      debugPrint("YoutubePlayerManager: load ${song.title} (${song.id})");

      // youtube_player_iframe otomatis meng-antre perintah ini sampai
      // WebView & JS IFrame API siap, jadi aman dipanggil langsung
      // walau widget YoutubePlayer belum sempat ter-mount.
      await controller.loadVideoById(videoId: song.id);

      _startPolling();

      // Safety net: kalau dalam 20 detik video tetap tidak "playing"
      // (mis. video gagal dimuat / diblokir / tanpa koneksi), matikan
      // loading supaya UI tidak nyangkut selamanya.
      Future.delayed(const Duration(seconds: 20), () {
        if (_isDisposed || token != _loadToken) return;
        if (isLoading.value) {
          debugPrint(
            "YoutubePlayerManager: timeout menunggu video mulai, "
            "hentikan loading indicator",
          );
          isLoading.value = false;
        }
      });
    } catch (e) {
      debugPrint("YoutubePlayerManager _loadVideo error: $e");
      isLoading.value = false;
    }
  }

  // =====================================================
  // DESKTOP (WINDOWS / LINUX) — buka browser bawaan
  // =====================================================

  Future<void> _playInExternalBrowser(YtSong song) async {
    debugPrint(
      "YoutubePlayerManager: membuka browser bawaan untuk ${song.title} (${song.id})",
    );

    final uri = Uri.parse("https://www.youtube.com/watch?v=${song.id}");

    try {
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened) {
        debugPrint(
          "YoutubePlayerManager: gagal membuka browser untuk ${uri.toString()}",
        );
      }
      // Tidak ada kontrol/progress yang bisa dipantau karena video diputar
      // di luar aplikasi (di browser), jadi cukup tandai sebagai "playing"
      // lalu langsung selesai — kontrol play/pause/seek tidak berlaku di sini.
      isPlaying.value = opened;
      position.value = Duration.zero;
      duration.value = Duration.zero;
    } catch (e) {
      debugPrint("YoutubePlayerManager _playInExternalBrowser error: $e");
      isPlaying.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  // =====================================================
  // CONTROLS
  // =====================================================

  @override
  Future<void> pause() async {
    // Di desktop, video diputar di browser eksternal — tidak ada yang bisa
    // dikontrol dari sini.
    if (PlatformUtil.isDesktop) return;
    try {
      await _controller?.pauseVideo();
      isPlaying.value = false;
    } catch (_) {}
  }

  @override
  Future<void> resume() async {
    if (PlatformUtil.isDesktop) return;
    try {
      await _controller?.playVideo();
      isPlaying.value = true;
    } catch (_) {}
  }

  @override
  Future<void> seek(Duration pos) async {
    if (PlatformUtil.isDesktop) return;
    try {
      await _controller?.seekTo(
        seconds: pos.inMilliseconds / 1000.0,
        allowSeekAhead: true,
      );
    } catch (_) {}
  }

  @override
  Future<void> stop() async {
    _stopPolling();
    _loadToken++; // batalkan safety-timeout yang masih menunggu

    if (!PlatformUtil.isDesktop) {
      try {
        await _controller?.stopVideo();
      } catch (_) {}
    }

    isPlaying.value = false;
    isLoading.value = false;
    position.value = Duration.zero;
    duration.value = Duration.zero;
    currentYtSong.value = null;
  }

  Future<void> next() async {
    if (!hasNext) return;
    _queueIndex++;
    await play();
  }

  Future<void> previous() async {
    if (!hasPrev) return;
    _queueIndex--;
    await play();
  }

  // =====================================================
  // DISPOSE
  // =====================================================

  @override
  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;

    _stopPolling();

    if (!PlatformUtil.isDesktop) {
      try {
        _controller?.close();
      } catch (_) {}
    }
    _controller = null;

    isPlaying.dispose();
    isLoading.dispose();
    position.dispose();
    duration.dispose();
    currentYtSong.dispose();
  }
}
