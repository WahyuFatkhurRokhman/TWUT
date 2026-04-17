import 'package:flutter/foundation.dart';
import 'package:music_player/models/group_music.dart';
import '../models/song.dart';

class PlayQueue {
  static final PlayQueue _instance = PlayQueue._internal();
  factory PlayQueue() => _instance;
  PlayQueue._internal();

  final ValueNotifier<List<Song>> _queue = ValueNotifier([]);
  final ValueNotifier<int> _currentIndex = ValueNotifier(-1);

  ValueListenable<List<Song>> get queue => _queue;
  ValueListenable<int> get currentIndex => _currentIndex;

  List<Song> get songs => _queue.value;
  int get index => _currentIndex.value;

  // 🎵 Set dari folder (replace semua)
  void addFolder(GroupMusic folder) {
    _queue.value = List.from(folder.songs);
    _currentIndex.value = _queue.value.isNotEmpty ? 0 : -1;
  }


  // 🎵 Tambah 1 lagu (append)
  void addSong(Song song) {
    final list = List<Song>.from(_queue.value);
    list.add(song);

    _queue.value = list;

    if (_currentIndex.value == -1) {
      _currentIndex.value = 0;
    }
  }

  // Ubah urutan lagu
  void reorder(int oldIndex, int newIndex) {
    final list = List<Song>.from(_queue.value);

    if (newIndex > oldIndex) newIndex--;

    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);

    _queue.value = list;

    // update currentIndex biar tetap sinkron
    if (_currentIndex.value == oldIndex) {
      _currentIndex.value = newIndex;
    } else if (oldIndex < _currentIndex.value &&
        newIndex >= _currentIndex.value) {
      _currentIndex.value--;
    } else if (oldIndex > _currentIndex.value &&
        newIndex <= _currentIndex.value) {
      _currentIndex.value++;
    }
  }


  // 🎯 Set index manual (biar aman)
  void setIndex(int i) {
    if (i >= 0 && i < _queue.value.length) {
      _currentIndex.value = i;
    }
  }

  // 🎧 Lagu aktif
  Song? get currentSong {
    if (_currentIndex.value < 0 || _currentIndex.value >= _queue.value.length) {
      return null;
    }
    return _queue.value[_currentIndex.value];
  }

  // ⏭ Next
  void next() {
    if (_currentIndex.value < _queue.value.length - 1) {
      _currentIndex.value++;
    }
  }

  // ⏮ Previous
  void previous() {
    if (_currentIndex.value > 0) {
      _currentIndex.value--;
    }
  }

  // 🧹 Clear queue
  void clear() {
    _queue.value = [];
    _currentIndex.value = -1;
  }

  void removeAt(int index) {
    final list = List<Song>.from(_queue.value);

    if (index < 0 || index >= list.length) return;

    final isRemovingCurrent = index == _currentIndex.value;

    list.removeAt(index);
    _queue.value = list;

    if (list.isEmpty) {
      _currentIndex.value = -1;
      return;
    }

    if (isRemovingCurrent) {
      if (index < list.length) {
        _currentIndex.value = index;
      } else {
        _currentIndex.value = list.length - 1;
      }
      return;
    }

    if (index < _currentIndex.value) {
      _currentIndex.value--;
    }
  }

  bool get isEmpty => _queue.value.isEmpty;


  bool get isLast =>
      _queue.value.isNotEmpty &&
          _currentIndex.value == _queue.value.length - 1;

  bool get isFirst =>
      _queue.value.isNotEmpty &&
          _currentIndex.value == 0;
}