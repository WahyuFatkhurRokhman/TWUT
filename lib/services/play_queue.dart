import 'dart:math';

import 'package:flutter/foundation.dart';

import 'package:music_player/models/group_music.dart';
import 'package:music_player/models/now_playing_media.dart';
import 'package:music_player/models/song.dart';
import 'package:music_player/models/yt_song.dart';

class PlayQueue {
  PlayQueue();

  final ValueNotifier<List<NowPlayingMedia>>
  _queue = ValueNotifier([]);

  final ValueNotifier<int>
  _currentIndex = ValueNotifier(-1);

  // =========================
  // SHUFFLE
  // =========================

  final ValueNotifier<bool>
  shuffleMode = ValueNotifier(false);

  final Random _random = Random();

  List<int> _shuffleOrder = [];

  int _shufflePointer = 0;

  // =========================
  // GETTER
  // =========================

  ValueListenable<List<NowPlayingMedia>>
  get queue => _queue;

  ValueListenable<int>
  get currentIndex => _currentIndex;

  List<NowPlayingMedia> get songs =>
      _queue.value;

  int get index =>
      _currentIndex.value;

  // =========================
  // ADD LOCAL FOLDER
  // =========================

  void addFolder(GroupMusic folder) {
    final medias = folder.songs
        .map((song) => song.toNowPlaying())
        .toList();

    _queue.value = medias;

    if (_queue.value.isEmpty) {
      _currentIndex.value = -1;
      return;
    }

    _currentIndex.value = 0;

    refreshShuffle();
  }

  // =========================
  // REPLACE WITH SINGLE SONG
  // (clear queue lama, isi dengan 1 lagu)
  // =========================

  void replaceWithSong(Song song) {
    _queue.value = [song.toNowPlaying()];
    _currentIndex.value = 0;
    refreshShuffle();
  }

  // =========================
  // ADD LOCAL SONG (append)
  // =========================

  void addSong(Song song) {
    final list = List<NowPlayingMedia>.from(_queue.value);

    list.add(song.toNowPlaying());

    _queue.value = list;

    if (_currentIndex.value == -1) {
      _currentIndex.value = 0;
    }

    refreshShuffle();
  }

  // =========================
  // ADD YOUTUBE SONG
  // =========================

  void addYtSong(YtSong song) {
    final list = List<NowPlayingMedia>.from(_queue.value);

    list.add(song.toNowPlaying());

    _queue.value = list;

    if (_currentIndex.value == -1) {
      _currentIndex.value = 0;
    }

    refreshShuffle();
  }

  // =========================
  // LOAD YOUTUBE QUEUE
  // =========================

  void loadYtQueue(
      List<YtSong> songs, {
        int startIndex = 0,
      }) {
    _queue.value = songs
        .map((e) => e.toNowPlaying())
        .toList();

    if (_queue.value.isEmpty) {
      _currentIndex.value = -1;
      return;
    }

    _currentIndex.value = startIndex;

    refreshShuffle();
  }

  // =========================
  // SHUFFLE
  // =========================

  void toggleShuffle() {
    shuffleMode.value = !shuffleMode.value;

    if (shuffleMode.value) {
      _generateShuffleOrder();
    } else {
      _shuffleOrder.clear();
      _shufflePointer = 0;
    }
  }

  void refreshShuffle() {
    if (shuffleMode.value) {
      _generateShuffleOrder();
    }
  }

  void _generateShuffleOrder() {
    if (_queue.value.isEmpty) {
      _shuffleOrder = [];
      _shufflePointer = 0;
      return;
    }

    _shuffleOrder = List.generate(
      _queue.value.length,
          (i) => i,
    );

    _shuffleOrder.shuffle(_random);

    final current = _currentIndex.value;

    if (current >= 0 && current < _queue.value.length) {
      _shuffleOrder.remove(current);
      _shuffleOrder.insert(0, current);
      _shufflePointer = 1;
    } else {
      _shufflePointer = 0;
    }
  }

  // =========================
  // NAVIGATION
  // =========================

  void next() {
    if (_queue.value.isEmpty) return;

    if (shuffleMode.value) {
      if (_shufflePointer >= _shuffleOrder.length) {
        _generateShuffleOrder();
      }

      if (_shuffleOrder.isEmpty) return;

      _currentIndex.value = _shuffleOrder[_shufflePointer];
      _shufflePointer++;
      return;
    }

    if (_currentIndex.value < _queue.value.length - 1) {
      _currentIndex.value++;
    }
  }

  void previous() {
    if (_queue.value.isEmpty) return;

    if (shuffleMode.value) {
      if (_shufflePointer <= 1) return;

      _shufflePointer -= 2;
      _currentIndex.value = _shuffleOrder[_shufflePointer];
      _shufflePointer++;
      return;
    }

    if (_currentIndex.value > 0) {
      _currentIndex.value--;
    }
  }

  void setIndex(int i) {
    if (i >= 0 && i < _queue.value.length) {
      _currentIndex.value = i;

      if (shuffleMode.value) {
        final pos = _shuffleOrder.indexOf(i);
        if (pos != -1) {
          _shufflePointer = pos + 1;
        }
      }
    }
  }

  // =========================
  // REORDER
  // =========================

  void reorder(int oldIndex, int newIndex) {
    final list = List<NowPlayingMedia>.from(_queue.value);

    if (newIndex > oldIndex) newIndex--;

    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);

    _queue.value = list;

    if (_currentIndex.value == oldIndex) {
      _currentIndex.value = newIndex;
    } else if (oldIndex < _currentIndex.value &&
        newIndex >= _currentIndex.value) {
      _currentIndex.value--;
    } else if (oldIndex > _currentIndex.value &&
        newIndex <= _currentIndex.value) {
      _currentIndex.value++;
    }

    refreshShuffle();
  }

  // =========================
  // REMOVE
  // =========================

  void removeAt(int index) {
    final list = List<NowPlayingMedia>.from(_queue.value);

    if (index < 0 || index >= list.length) return;

    final isRemovingCurrent = index == _currentIndex.value;

    list.removeAt(index);
    _queue.value = list;

    if (list.isEmpty) {
      _currentIndex.value = -1;
      refreshShuffle();
      return;
    }

    if (isRemovingCurrent) {
      _currentIndex.value = index < list.length ? index : list.length - 1;
    } else if (index < _currentIndex.value) {
      _currentIndex.value--;
    }

    refreshShuffle();
  }

  // =========================
  // CLEAR
  // =========================

  void clear() {
    _queue.value = [];
    _currentIndex.value = -1;
    _shuffleOrder.clear();
    _shufflePointer = 0;
  }

  // =========================
  // GET CURRENT
  // =========================

  NowPlayingMedia? get currentMedia {
    if (_currentIndex.value < 0 ||
        _currentIndex.value >= _queue.value.length) {
      return null;
    }

    return _queue.value[_currentIndex.value];
  }

  // =========================
  // STATE
  // =========================

  bool get isEmpty => _queue.value.isEmpty;

  bool get isLast {
    if (_queue.value.isEmpty) return false;

    if (shuffleMode.value) {
      return _shufflePointer >= _shuffleOrder.length;
    }

    return _currentIndex.value == _queue.value.length - 1;
  }

  bool get isFirst {
    if (_queue.value.isEmpty) return false;

    if (shuffleMode.value) {
      return _shufflePointer <= 1;
    }

    return _currentIndex.value == 0;
  }

  // =========================
  // DISPOSE
  // =========================

  void dispose() {
    _queue.dispose();
    _currentIndex.dispose();
    shuffleMode.dispose();
  }
}