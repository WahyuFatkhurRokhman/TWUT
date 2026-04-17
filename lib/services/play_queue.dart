import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:music_player/models/group_music.dart';
import '../models/song.dart';

class PlayQueue {
  static final PlayQueue _instance = PlayQueue._internal();
  factory PlayQueue() => _instance;
  PlayQueue._internal();

  final ValueNotifier<List<Song>> _queue = ValueNotifier([]);
  final ValueNotifier<int> _currentIndex = ValueNotifier(-1);

  // shuffle mode
  final ValueNotifier<bool> shuffleMode = ValueNotifier(false);

  final Random _random = Random();

  List<int> _shuffleOrder = [];
  int _shufflePointer = 0;

  ValueListenable<List<Song>> get queue => _queue;
  ValueListenable<int> get currentIndex => _currentIndex;

  List<Song> get songs => _queue.value;
  int get index => _currentIndex.value;

  // ===============================
  // ADD
  // ===============================
  void addFolder(GroupMusic folder) {
    _queue.value = List.from(folder.songs);

    if (_queue.value.isEmpty) {
      _currentIndex.value = -1;
      return;
    }

    if (shuffleMode.value) {
      _generateShuffleOrder();
      _currentIndex.value = _shuffleOrder[0];
      _shufflePointer = 1;
    } else {
      _currentIndex.value = 0;
    }
  }

  void addSong(Song song) {
    final list = List<Song>.from(_queue.value);
    list.add(song);

    _queue.value = list;

    if (_currentIndex.value == -1) {
      _currentIndex.value = 0;
    }

    refreshShuffle();
  }

  // ===============================
  // SHUFFLE
  // ===============================
  void toggleShuffle() {
    shuffleMode.value = !shuffleMode.value;

    if (shuffleMode.value) {
      _generateShuffleOrder();

      if (_shuffleOrder.isNotEmpty) {
        _currentIndex.value = _shuffleOrder[0];
        _shufflePointer = 1;
      }
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

    _shuffleOrder = List.generate(_queue.value.length, (i) => i);
    _shuffleOrder.shuffle(_random);

    final current = _currentIndex.value;

    // kalau current valid, pindahkan ke posisi pertama
    if (current >= 0 && current < _queue.value.length) {
      _shuffleOrder.remove(current);
      _shuffleOrder.insert(0, current);
      _shufflePointer = 1; // next ambil setelah current
    } else {
      _shufflePointer = 0;
    }
  }

  // ===============================
  // NAVIGATION
  // ===============================
  void next() {
    if (_queue.value.isEmpty) return;

    if (shuffleMode.value) {
      if (_shufflePointer >= _shuffleOrder.length) return;

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
    }
  }

  // ===============================
  // REORDER
  // ===============================
  void reorder(int oldIndex, int newIndex) {
    final list = List<Song>.from(_queue.value);

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

  // ===============================
  // REMOVE
  // ===============================
  void removeAt(int index) {
    final list = List<Song>.from(_queue.value);

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
      if (index < list.length) {
        _currentIndex.value = index;
      } else {
        _currentIndex.value = list.length - 1;
      }
    } else if (index < _currentIndex.value) {
      _currentIndex.value--;
    }

    refreshShuffle();
  }

  // ===============================
  // CLEAR
  // ===============================
  void clear() {
    _queue.value = [];
    _currentIndex.value = -1;

    _shuffleOrder.clear();
    _shufflePointer = 0;
  }

  // ===============================
  // GETTERS
  // ===============================
  Song? get currentSong {
    if (_currentIndex.value < 0 ||
        _currentIndex.value >= _queue.value.length) {
      return null;
    }

    return _queue.value[_currentIndex.value];
  }

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
}