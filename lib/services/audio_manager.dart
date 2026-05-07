import 'package:flutter/foundation.dart';

import 'package:music_player/models/constant/PLAYBACK_SOURCE.dart';
import 'package:music_player/models/constant/REPEAT_MODE.dart';
import 'package:music_player/models/group_music.dart';
import 'package:music_player/models/song.dart';
import 'package:music_player/models/yt_song.dart';
import 'package:music_player/models/now_playing_media.dart';

import 'package:music_player/services/local_player_manager.dart';
import 'package:music_player/services/play_queue.dart';
import 'package:music_player/services/player_manager.dart';
import 'package:music_player/services/youtube_player_manager.dart';

import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();

  factory AudioManager() => _instance;

  AudioManager._internal();

  final local   = LocalPlayerManager();
  final youtube = YoutubePlayerManager();

  final activeSource = ValueNotifier(PlaybackSource.local);
  final repeatMode   = ValueNotifier(REPEAT_MODE.OFF);
  final volume       = ValueNotifier(1.0);

  final currentMedia = ValueNotifier<NowPlayingMedia?>(null);

  PlayQueue get queue => local.queue;

  ValueNotifier<Song?> get currentSong => local.currentSong;
  ValueNotifier<bool>     get isPlaying => _active.isPlaying;
  ValueNotifier<Duration> get position  => _active.position;
  ValueNotifier<Duration> get duration  => _active.duration;

  YoutubePlayerController? get ytController => youtube.controller;

  PlayerManager get _active =>
      activeSource.value == PlaybackSource.local ? local : youtube;

  void init() {
    local.init();
    local.onTrackComplete   = _handleLocalTrackComplete;
    youtube.onTrackComplete = _handleYoutubeTrackComplete;
  }

  // ======================================
  // LOCAL
  // ======================================

  Future<void> playLocalGroup(
      GroupMusic group, {
        int startIndex = 0,
      }) async {
    await _stopOther(PlaybackSource.local);
    activeSource.value = PlaybackSource.local;

    local.queue.addFolder(group);
    local.queue.setIndex(startIndex);

    await local.play();

    final song = local.currentSong.value;
    if (song != null) currentMedia.value = song.toNowPlaying();
  }

  Future<void> playLocalSong(Song song) async {
    await _stopOther(PlaybackSource.local);
    activeSource.value = PlaybackSource.local;

    local.queue.replaceWithSong(song);

    await local.play();

    final current = local.currentSong.value;
    if (current != null) currentMedia.value = current.toNowPlaying();
  }

  // ======================================
  // YOUTUBE
  // ======================================

  Future<void> playYtSong(YtSong song) async {
    await _stopOther(PlaybackSource.youtube);
    activeSource.value = PlaybackSource.youtube;

    youtube.loadQueue([song]);
    await youtube.play();

    currentMedia.value = song.toNowPlaying();
  }

  Future<void> playYtQueue(
      List<YtSong> songs, {
        int startIndex = 0,
      }) async {
    await _stopOther(PlaybackSource.youtube);
    activeSource.value = PlaybackSource.youtube;

    youtube.loadQueue(songs, startIndex: startIndex);
    await youtube.play();

    final yt = youtube.currentSong;
    if (yt != null) currentMedia.value = yt.toNowPlaying();
  }

  // ======================================
  // CONTROL
  // ======================================

  Future<void> toggle() async {
    _active.isPlaying.value
        ? await _active.pause()
        : await _active.resume();
  }

  Future<void> pause()  async => _active.pause();
  Future<void> resume() async => _active.resume();

  Future<void> seek(Duration pos) async => _active.seek(pos);

  Future<void> playNext() async {
    if (activeSource.value == PlaybackSource.local) {
      if (local.queue.isLast) {
        local.queue.setIndex(0);
      } else {
        local.queue.next();
      }

      await local.play();

      final song = local.currentSong.value;
      if (song != null) currentMedia.value = song.toNowPlaying();
    } else {
      if (!youtube.hasNext) {
        youtube.setIndex(0);
      } else {
        _updateYoutubeIndex(forward: true);
      }

      // FIX: selalu panggil play() setelah setIndex/next
      await youtube.play();

      final yt = youtube.currentSong;
      if (yt != null) currentMedia.value = yt.toNowPlaying();
    }
  }

  Future<void> playPrevious() async {
    if (activeSource.value == PlaybackSource.local) {
      if (local.queue.isFirst) {
        local.queue.setIndex(local.queue.songs.length - 1);
      } else {
        local.queue.previous();
      }

      await local.play();

      final song = local.currentSong.value;
      if (song != null) currentMedia.value = song.toNowPlaying();
    } else {
      if (!youtube.hasPrev) {
        youtube.setIndex(youtube.queue.length - 1);
      } else {
        _updateYoutubeIndex(forward: false);
      }

      // FIX: selalu panggil play() setelah setIndex/previous
      await youtube.play();

      final yt = youtube.currentSong;
      if (yt != null) currentMedia.value = yt.toNowPlaying();
    }
  }

  /// Play lagu berdasarkan index di queue (local)
  Future<void> playAt(int index) async {
    if (activeSource.value != PlaybackSource.local) {
      await _stopOther(PlaybackSource.local);
      activeSource.value = PlaybackSource.local;
    }

    local.queue.setIndex(index);
    await local.play();

    final song = local.currentSong.value;
    if (song != null) currentMedia.value = song.toNowPlaying();
  }

  /// Play dari queue yang sudah diset sebelumnya (local)
  Future<void> playFromQueue() async {
    await _stopOther(PlaybackSource.local);
    activeSource.value = PlaybackSource.local;

    await local.play();

    final song = local.currentSong.value;
    if (song != null) currentMedia.value = song.toNowPlaying();
  }


  /// Helper agar tidak double-increment/decrement saat next/previous
  void _updateYoutubeIndex({required bool forward}) {
    final current = youtube.queue.indexOf(youtube.currentSong!);
    final next = (current + (forward ? 1 : -1))
        .clamp(0, youtube.queue.length - 1);
    youtube.setIndex(next);
  }

  Future<void> stopAndClearCurrent() async {
    await _active.stop();
    currentMedia.value = null;
    activeSource.value = PlaybackSource.local;
  }

  Future<void> setVolume(double value) async {
    volume.value = value.clamp(0.0, 1.0);
    await local.setVolume(volume.value);
  }

  void toggleRepeatMode() {
    switch (repeatMode.value) {
      case REPEAT_MODE.OFF:
        repeatMode.value = REPEAT_MODE.ALL;
        break;
      case REPEAT_MODE.ALL:
        repeatMode.value = REPEAT_MODE.ONE;
        break;
      case REPEAT_MODE.ONE:
        repeatMode.value = REPEAT_MODE.OFF;
        break;
    }
  }

  void toggleShuffle() => local.queue.toggleShuffle();

  // ======================================
  // INTERNAL
  // ======================================

  Future<void> _stopOther(PlaybackSource next) async {
    if (activeSource.value != next) {
      await _active.stop();
    }
  }

  void _handleLocalTrackComplete() {
    switch (repeatMode.value) {
      case REPEAT_MODE.ONE:
        local.play();
        break;
      case REPEAT_MODE.ALL:
        playNext();
        break;
      case REPEAT_MODE.OFF:
        if (!local.queue.isLast) playNext();
        break;
    }
  }

  void _handleYoutubeTrackComplete() {
    switch (repeatMode.value) {
      case REPEAT_MODE.ONE:
        youtube.play();
        break;
      case REPEAT_MODE.ALL:
        playNext();
        break;
      case REPEAT_MODE.OFF:
        if (youtube.hasNext) playNext();
        break;
    }
  }



  void dispose() {
    local.dispose();
    youtube.dispose();
    activeSource.dispose();
    repeatMode.dispose();
    volume.dispose();
    currentMedia.dispose();
  }
}