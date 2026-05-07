import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import 'package:music_player/models/constant/YT_TYPE.dart';
import 'package:music_player/models/yt_song.dart';
import 'package:music_player/services/player_manager.dart';

class YoutubePlayerManager implements PlayerManager {
  static final YoutubePlayerManager _instance =
  YoutubePlayerManager._internal();

  factory YoutubePlayerManager() => _instance;

  YoutubePlayerManager._internal() {
    _initListeners();
  }

  // =====================================================
  // PLAYER
  // =====================================================

  // Lazy-initialized to avoid MissingPluginException during startup
  // (platform channels may not be ready when the singleton is first created)
  AudioPlayer? _playerInstance;

  AudioPlayer get _player {
    _playerInstance ??= AudioPlayer();
    return _playerInstance!;
  }

  final YoutubeExplode _yt = YoutubeExplode();

  dynamic get controller => null;

  bool _isDisposed = false;

  // =====================================================
  // VALUE NOTIFIER
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
    if (_queueIndex < 0 || _queueIndex >= queue.length) {
      return null;
    }
    return queue[_queueIndex];
  }

  bool get hasNext => _queueIndex < queue.length - 1;

  bool get hasPrev => _queueIndex > 0;

  // =====================================================
  // INIT LISTENER
  // =====================================================

  void _initListeners() {
    _player.playingStream.listen((playing) {
      if (_isDisposed) return;
      isPlaying.value = playing;
    });

    _player.positionStream.listen((pos) {
      if (_isDisposed) return;
      position.value = pos;
    });

    _player.durationStream.listen((dur) {
      if (_isDisposed) return;
      duration.value = dur ?? Duration.zero;
    });

    _player.playerStateStream.listen((state) {
      if (_isDisposed) return;
      if (state.processingState == ProcessingState.completed) {
        onTrackComplete?.call();
      }
    });
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
  // RESOLVE AUDIO URL
  // =====================================================

  Future<String?> _resolveAudioUrl(String videoId) async {
    try {
      debugPrint("Resolve YT Audio: $videoId");

      final manifest =
      await _yt.videos.streamsClient.getManifest(videoId);

      final streams = manifest.audioOnly.sortByBitrate();

      if (streams.isEmpty) {
        debugPrint("No audio stream found");
        return null;
      }

      final url = streams.last.url.toString();
      debugPrint("Audio URL resolved");
      return url;
    } catch (e) {
      debugPrint("YT Resolve Error: $e");
      return null;
    }
  }

  // =====================================================
  // PLAY
  // =====================================================

  @override
  Future<void> play() async {
    final song = currentSong;

    if (song == null) return;

    if (song.type != YT_TYPE.VIDEO) {
      debugPrint("Unsupported YT type");
      return;
    }

    currentYtSong.value = song;

    try {
      debugPrint("Play: ${song.title}");

      final url = await _resolveAudioUrl(song.id);

      if (url == null) {
        debugPrint("Failed resolve URL");
        return;
      }

      // STOP CURRENT
      await _player.stop();

      // LOAD NEW
      await _player.setAudioSource(
        AudioSource.uri(Uri.parse(url)),
      );

      // PLAY
      await _player.play();
    } catch (e) {
      debugPrint("YT Play Error: $e");
    }
  }

  // =====================================================
  // CONTROL
  // =====================================================

  @override
  Future<void> pause() async {
    try {
      await _player.pause();
    } catch (_) {}
  }

  @override
  Future<void> resume() async {
    try {
      await _player.play();
    } catch (_) {}
  }

  @override
  Future<void> seek(Duration pos) async {
    try {
      await _player.seek(pos);
    } catch (_) {}
  }

  @override
  Future<void> stop() async {
    try {
      await _player.stop();
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

    try {
      // Use nullable ref — safe even if _player was never accessed
      await _playerInstance?.dispose();
      _playerInstance = null;
    } catch (_) {}

    _yt.close();

    isPlaying.dispose();
    position.dispose();
    duration.dispose();
    currentYtSong.dispose();
  }
}