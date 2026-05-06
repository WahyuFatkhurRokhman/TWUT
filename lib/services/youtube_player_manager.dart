import 'package:flutter/foundation.dart';
import 'package:music_player/services/player_manager.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:music_player/models/yt_song.dart';
import 'package:music_player/models/constant/YT_TYPE.dart';

class YoutubePlayerManager implements PlayerManager {
  static final YoutubePlayerManager _instance =
  YoutubePlayerManager._internal();

  factory YoutubePlayerManager() => _instance;

  YoutubePlayerManager._internal();

  YoutubePlayerController? _controller;
  YoutubePlayerController? get controller => _controller;

  @override final isPlaying = ValueNotifier(false);
  @override final position  = ValueNotifier(Duration.zero);
  @override final duration  = ValueNotifier(Duration.zero);

  final currentYtSong = ValueNotifier<YtSong?>(null);

  final queue = <YtSong>[];
  int _queueIndex = -1;

  void Function()? onTrackComplete;

  bool _isCompletedCalled = false;

  // =========================
  // CONTROLLER
  // =========================
  void _initController(String videoId) {
    if (_controller == null) {
      _controller = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(autoPlay: true),
      );

      _controller!.addListener(_onUpdate);
    } else {
      _controller!.load(videoId);
    }
  }

  void _onUpdate() {
    final c = _controller;
    if (c == null) return;

    isPlaying.value = c.value.isPlaying;
    position.value  = c.value.position;
    duration.value  = c.metadata.duration;

    if (c.value.playerState == PlayerState.ended) {
      if (!_isCompletedCalled) {
        _isCompletedCalled = true;
        onTrackComplete?.call();
      }
    } else {
      _isCompletedCalled = false;
    }
  }

  // =========================
  // QUEUE
  // =========================
  void loadQueue(List<YtSong> songs, {int startIndex = 0}) {
    queue
      ..clear()
      ..addAll(songs);
    _queueIndex = startIndex;
  }

  YtSong? get currentSong =>
      (_queueIndex >= 0 && _queueIndex < queue.length)
          ? queue[_queueIndex]
          : null;

  bool get hasNext => _queueIndex < queue.length - 1;
  bool get hasPrev => _queueIndex > 0;

  // =========================
  // CONTROL (implements PlayerManager)
  // =========================
  @override
  Future<void> play() async {
    final song = currentSong;
    if (song == null || song.type != YT_TYPE.VIDEO) return;

    currentYtSong.value = song;
    _initController(song.id);
  }

  @override
  Future<void> pause() async {
    _controller?.pause();
  }

  @override
  Future<void> resume() async {
    _controller?.play();
  }

  @override
  Future<void> seek(Duration pos) async {
    _controller?.seekTo(pos);
  }

  @override
  Future<void> stop() async {
    _controller?.pause();
    _controller?.seekTo(Duration.zero);

    isPlaying.value = false;
    position.value  = Duration.zero;
    duration.value  = Duration.zero;
    currentYtSong.value = null;
  }

  // =========================
  // NAVIGATION
  // =========================
  Future<void> next() async {
    if (hasNext) {
      _queueIndex++;
      await play();
    }
  }

  Future<void> previous() async {
    if (hasPrev) {
      _queueIndex--;
      await play();
    }
  }

  void setIndex(int i) {
    if (i >= 0 && i < queue.length) {
      _queueIndex = i;
    }
  }

  // =========================
  // DISPOSE
  // =========================
  @override
  void dispose() {
    _controller?.removeListener(_onUpdate);
    _controller?.dispose();
    _controller = null;

    isPlaying.dispose();
    position.dispose();
    duration.dispose();
    currentYtSong.dispose();
  }
}