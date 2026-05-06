import 'package:flutter/foundation.dart';
import 'package:music_player/models/constant/PLAYBACK_SOURCE.dart';
import 'package:music_player/models/constant/REPEAT_MODE.dart';
import 'package:music_player/models/group_music.dart';
import 'package:music_player/models/song.dart';
import 'package:music_player/models/yt_song.dart';
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


  PlayQueue get queue => local.queue;

  ValueNotifier<Song?> get currentSong => local.currentSong;

  ValueNotifier<YtSong?> get currentYtSong => youtube.currentYtSong;

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

  // ── LOCAL playback ────────────────────────────────────────────────────────
  Future<void> playLocalGroup(GroupMusic group, {int startIndex = 0}) async {
    await _stopOther(PlaybackSource.local);
    activeSource.value = PlaybackSource.local;

    local.queue.addFolder(group);
    local.queue.setIndex(startIndex);
    await local.play();
  }

  Future<void> playLocalSong(Song song) async {
    await _stopOther(PlaybackSource.local);
    activeSource.value = PlaybackSource.local;

    local.queue.addSong(song);
    await local.play();
  }

  Future<void> playFromQueue() async => local.play();

  // ── YOUTUBE playback ──────────────────────────────────────────────────────
  Future<void> playYtSong(YtSong song) async {
    await _stopOther(PlaybackSource.youtube);
    activeSource.value = PlaybackSource.youtube;

    youtube.loadQueue([song]);
    await youtube.play();
  }

  Future<void> playYtQueue(List<YtSong> songs, {int startIndex = 0}) async {
    await _stopOther(PlaybackSource.youtube);
    activeSource.value = PlaybackSource.youtube;

    youtube.loadQueue(songs, startIndex: startIndex);
    await youtube.play();
  }

  Future<void> toggle() async {
    _active.isPlaying.value ? await _active.pause() : await _active.resume();
  }

  Future<void> pause()  async => _active.pause();
  Future<void> resume() async => _active.resume();
  Future<void> seekTo(Duration pos) => _active.seek(pos);

  Future<void> seek(Duration pos) => seekTo(pos);

  Future<void> playAt(int index) async {
    local.queue.setIndex(index);
    await local.play();
  }

  Future<void> playNext() async {
    if (activeSource.value == PlaybackSource.local) {
      if (local.queue.isLast) {
        local.queue.setIndex(0);
      } else {
        local.queue.next();
      }
      await local.play();
    } else {
      if (!youtube.hasNext) youtube.setIndex(0);
      else youtube.next();
      await youtube.play();
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
    } else {
      if (!youtube.hasPrev) youtube.setIndex(youtube.queue.length - 1);
      else youtube.previous();
      await youtube.play();
    }
  }

  Future<void> stopAndClearCurrent() async {
    await _active.stop();
    activeSource.value = PlaybackSource.local;
  }

  Future<void> setVolume(double value) async {
    volume.value = value.clamp(0.0, 1.0);
    await local.setVolume(volume.value);
  }

  void toggleRepeatMode() {
    switch (repeatMode.value) {
      case REPEAT_MODE.OFF: repeatMode.value = REPEAT_MODE.ALL;  break;
      case REPEAT_MODE.ALL: repeatMode.value = REPEAT_MODE.ONE;  break;
      case REPEAT_MODE.ONE: repeatMode.value = REPEAT_MODE.OFF;  break;
    }
  }

  void toggleShuffle() => local.queue.toggleShuffle();

  // ── internal ──────────────────────────────────────────────────────────────
  Future<void> _stopOther(PlaybackSource next) async {
    if (activeSource.value != next) await _active.stop();
  }

  void _handleLocalTrackComplete() {
    switch (repeatMode.value) {
      case REPEAT_MODE.ONE:
        local.play();
        break;
      case REPEAT_MODE.ALL:
        if (local.queue.isLast) local.queue.setIndex(0);
        else local.queue.next();
        local.play();
        break;
      case REPEAT_MODE.OFF:
        if (!local.queue.isLast) {
          local.queue.next();
          local.play();
        }
        break;
    }
  }

  void _handleYoutubeTrackComplete() {
    switch (repeatMode.value) {
      case REPEAT_MODE.ONE:
        youtube.play();
        break;
      case REPEAT_MODE.ALL:
        if (!youtube.hasNext) youtube.setIndex(0);
        else youtube.next();
        youtube.play();
        break;
      case REPEAT_MODE.OFF:
        if (youtube.hasNext) {
          youtube.next();
          youtube.play();
        }
        break;
    }
  }

  void dispose() {
    local.dispose();
    youtube.dispose();
    activeSource.dispose();
    repeatMode.dispose();
    volume.dispose();
  }
}