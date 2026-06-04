import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import 'package:music_player/models/constant/YT_TYPE.dart';
import 'package:music_player/models/yt_song.dart';
import 'package:music_player/services/player_manager.dart';

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

  /// Expose controller so the widget layer can attach it
  YoutubePlayerController get controller {
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

      // Cek track complete
      if (playerState == PlayerState.ended) {
        _stopPolling();
        isPlaying.value = false;
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

    try {
      debugPrint("YoutubePlayerManager: play ${song.title} (${song.id})");

      // Load video ID ke controller
      // youtube_player_iframe akan otomatis play setelah load
      await controller.loadVideoById(videoId: song.id);

      _startPolling();
    } catch (e) {
      debugPrint("YoutubePlayerManager play error: $e");
    }
  }

  // =====================================================
  // CONTROLS
  // =====================================================

  @override
  Future<void> pause() async {
    try {
      await _controller?.pauseVideo();
      isPlaying.value = false;
    } catch (_) {}
  }

  @override
  Future<void> resume() async {
    try {
      await _controller?.playVideo();
      isPlaying.value = true;
    } catch (_) {}
  }

  @override
  Future<void> seek(Duration pos) async {
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
    try {
      await _controller?.stopVideo();
    } catch (_) {}

    isPlaying.value = false;
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

    try {
      _controller?.close();
      _controller = null;
    } catch (_) {}

    isPlaying.dispose();
    position.dispose();
    duration.dispose();
    currentYtSong.dispose();
  }
}