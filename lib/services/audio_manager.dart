import 'package:flutter/foundation.dart';
import 'package:music_player/data/database.dart';
import 'package:music_player/models/constant/PLAYBACK_SOURCE.dart';
import 'package:music_player/models/constant/REPEAT_MODE.dart';
import 'package:music_player/models/group_music.dart';
import 'package:music_player/models/song.dart';
import 'package:music_player/models/yt_song.dart';
import 'package:music_player/models/now_playing_media.dart';
import 'package:music_player/services/history_play_local_song.dart';

import 'package:music_player/services/local_player_manager.dart';
import 'package:music_player/services/play_queue.dart';
import 'package:music_player/services/player_manager.dart';
import 'package:music_player/services/youtube_player_manager.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  final local = LocalPlayerManager();
  final youtube = YoutubePlayerManager();
  late final HistoryPlayLocalSong _history;

  final activeSource = ValueNotifier(PlaybackSource.local);
  final repeatMode = ValueNotifier(REPEAT_MODE.OFF);
  final volume = ValueNotifier(1.0);
  final currentMedia = ValueNotifier<NowPlayingMedia?>(null);

  // Central Notifiers untuk UI yang konsisten
  final isPlaying = ValueNotifier(false);
  final position = ValueNotifier(Duration.zero);
  final duration = ValueNotifier(Duration.zero);

  // Getters
  PlayQueue get queue => local.queue;
  ValueNotifier<Song?> get currentSong => local.currentSong;
  PlayerManager get _active => activeSource.value == PlaybackSource.local ? local : youtube;

  void init() {
    _history = HistoryPlayLocalSong(AppDatabase());
    local.init();
    local.onTrackComplete = _handleLocalTrackComplete;
    youtube.onTrackComplete = _handleYoutubeTrackComplete;

    _setupSync(local);
    _setupSync(youtube);
  }

  void _setupSync(PlayerManager manager) {
    manager.isPlaying.addListener(() {
      if (_active == manager) isPlaying.value = manager.isPlaying.value;
    });
    manager.position.addListener(() {
      if (_active == manager) position.value = manager.position.value;
    });
    manager.duration.addListener(() {
      if (_active == manager) duration.value = manager.duration.value;
    });
  }

  // ======================================
  // INTERNAL HELPERS
  // ======================================

  Future<void> _stopOther(PlaybackSource next) async {
    if (activeSource.value != next) {
      await _active.stop();
    }
  }

  void _syncState() {
    if (activeSource.value == PlaybackSource.local) {
      currentMedia.value = local.currentSong.value?.toNowPlaying();
    } else {
      currentMedia.value = youtube.currentYtSong.value?.toNowPlaying();
    }
    isPlaying.value = _active.isPlaying.value;
    position.value = _active.position.value;
    duration.value = _active.duration.value;
  }

  // ======================================
  // LOCAL (FITUR GRUP & QUEUE KEMBALI)
  // ======================================

  Future<void> playLocalGroup(GroupMusic group, {int startIndex = 0}) async {
    await _stopOther(PlaybackSource.local);
    activeSource.value = PlaybackSource.local;
    local.queue.addFolder(group);
    local.queue.setIndex(startIndex);
    await local.play();
    _syncState();
  }

  Future<void> playPlaylist(List<Song> songs, {bool shuffle = false, int? playlistId}) async {
    await _stopOther(PlaybackSource.local);
    activeSource.value = PlaybackSource.local;

    // Load songs into queue
    local.queue.loadSongs(songs);

    if (shuffle) {
      if (!local.queue.shuffleMode.value) {
        local.queue.toggleShuffle();
      }
      local.queue.setIndex(0); // Shuffle will handle reordering
    } else {
      if (local.queue.shuffleMode.value) {
        local.queue.toggleShuffle();
      }
      local.queue.setIndex(0);
    }

    // Add to history if a playlistId is provided
    if (playlistId != null) {
      await _history.addPlaylist(playlistId);
    }

    await local.play();
    _syncState();
  }

  Future<void> playLocalSong(Song song) async {
    await _stopOther(PlaybackSource.local);
    activeSource.value = PlaybackSource.local;
    local.queue.replaceWithSong(song);
    _history.addSong(song);
    await local.play();
    _syncState();
  }

  Future<void> playAt(int index) async {
    if (activeSource.value != PlaybackSource.local) {
      await _stopOther(PlaybackSource.local);
      activeSource.value = PlaybackSource.local;
    }
    local.queue.setIndex(index);
    await local.play();
    _syncState();
  }

  // ======================================
  // YOUTUBE (SINGLE PLAYER ONLY)
  // ======================================

  Future<void> playYtSong(YtSong song) async {
    await _stopOther(PlaybackSource.youtube);
    activeSource.value = PlaybackSource.youtube;
    youtube.loadQueue([song]); // Hanya 1 lagu
    await youtube.play();
    _syncState();
  }

  // ======================================
  // CONTROLS
  // ======================================

  Future<void> toggle() async => isPlaying.value ? await _active.pause() : await _active.resume();
  Future<void> pause() async => _active.pause();
  Future<void> resume() async => _active.resume();
  Future<void> seek(Duration pos) async => _active.seek(pos);

  Future<void> playNext() async {
    if (activeSource.value == PlaybackSource.local) {
      local.queue.isLast ? local.queue.setIndex(0) : local.queue.next();
      await local.play();
    } else {
      // YouTube tidak ada next/prev karena single player
      await youtube.stop();
      currentMedia.value = null;
    }
    _syncState();
  }

  Future<void> playPrevious() async {
    if (activeSource.value == PlaybackSource.local) {
      local.queue.isFirst ? local.queue.setIndex(local.queue.songs.length - 1) : local.queue.previous();
      await local.play();
      _syncState();
    }
  }

  Future<void> stopAndClearCurrent() async {
    await _active.stop();
    currentMedia.value = null;
    isPlaying.value = false;
    position.value = Duration.zero;
    duration.value = Duration.zero;
  }

  void _handleLocalTrackComplete() {
    if (repeatMode.value == REPEAT_MODE.ONE) {
      local.play();
    } else if (repeatMode.value == REPEAT_MODE.ALL || !local.queue.isLast) {
      playNext();
    }
    
    // Add current song to history when track completes
    final current = local.currentSong.value;
    if (current != null) {
      _history.addSong(current);
    }
  }

  void _handleYoutubeTrackComplete() {
    if (repeatMode.value == REPEAT_MODE.ONE) {
      youtube.play();
    } else {
      stopAndClearCurrent();
    }
  }

  void setVolume(double val) {
    volume.value = val;
    local.setVolume(val);
  }

  void toggleRepeatMode() {
    final modes = REPEAT_MODE.values;
    repeatMode.value = modes[(repeatMode.value.index + 1) % modes.length];
  }
}
