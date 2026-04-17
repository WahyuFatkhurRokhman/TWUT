import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:music_player/models/constant/REPEAT_MODE.dart';
import '../models/song.dart';
import 'play_queue.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  final AudioPlayer _player = AudioPlayer();
  final PlayQueue queue = PlayQueue();

  final currentSong = ValueNotifier<Song?>(null);
  final isPlaying = ValueNotifier(false);
  final position = ValueNotifier(Duration.zero);
  final duration = ValueNotifier(Duration.zero);
  final volume = ValueNotifier(1.0);
  final repeatMode = ValueNotifier(REPEAT_MODE.OFF);

  bool _initialized = false;
  bool _queueEnded = false;

  void init() {
    if (_initialized) return;
    _initialized = true;

    _player.onDurationChanged.listen((d) {
      duration.value = d;
    });

    _player.onPositionChanged.listen((p) {
      position.value = p;
    });

    _player.setVolume(volume.value);

    _player.onPlayerComplete.listen((_) async {
      position.value = Duration.zero;

      final mode = repeatMode.value;

      // repeat satu lagu
      if (mode == REPEAT_MODE.ONE) {
        await playFromQueue();
        return;
      }

      // queue kosong
      if (queue.isEmpty) {
        await stopAndClearCurrent();
        return;
      }


      // lagu terakhir selesai
      if (queue.isLast) {
        if (mode == REPEAT_MODE.ALL) {
          queue.setIndex(0);
          await playFromQueue();
          return;
        }

        await _player.stop();
        isPlaying.value = false;
        _queueEnded = true;
        return;
      }

      // lanjut next
      queue.next();
      await playFromQueue();
    });
  }

  Future<void> playFromQueue() async {
    if (queue.isEmpty) {
      await stopAndClearCurrent();
      return;
    }

    final song = queue.currentSong;
    if (song == null) return;

    await _playSong(song);
  }

  // ===============================
  // CORE PLAY
  // ===============================
  Future<void> _playSong(Song song) async {
    final file = File(song.path);
    final metadata = readMetadata(file, getImage: true);

    final newSong = Song(
      path: song.path,
      title: metadata.title ?? song.title,
      artist: metadata.artist ?? 'Unknown Artist',
      album: metadata.album ?? 'Unknown Album',
      artwork: metadata.pictures.isNotEmpty
          ? metadata.pictures.first.bytes
          : null,
    );

    currentSong.value = newSong;

    await _player.stop();
    await _player.play(DeviceFileSource(song.path));

    isPlaying.value = true;
    _queueEnded = false;
  }

  Future<void> stopAndClearCurrent() async {
    await _player.stop();

    currentSong.value = null;
    isPlaying.value = false;
    position.value = Duration.zero;
    duration.value = Duration.zero;

    _queueEnded = false;
  }

  Future<void> toggle() async {
    // sedang play -> pause
    if (isPlaying.value) {
      await _player.pause();
      isPlaying.value = false;
      return;
    }

    // queue selesai
    if (_queueEnded) {
      if (repeatMode.value == REPEAT_MODE.ALL) {
        queue.setIndex(0);
      }

      await playFromQueue();
      return;
    }

    // belum ada lagu
    if (currentSong.value == null) {
      await playFromQueue();
      return;
    }

    // resume pause
    await _player.resume();
    isPlaying.value = true;
  }

  Future<void> playAt(int index) async {
    queue.setIndex(index);
    await playFromQueue();
  }

  Future<void> playNext() async {
    if (queue.isEmpty) return;

    if (queue.isLast) {
      if(queue.shuffleMode.value){
        queue.refreshShuffle();
        queue.setIndex(1);
      }else{
        queue.setIndex(0);
      }
    }else  {
      queue.next();
    }

    await playFromQueue();
  }

  Future<void> playPrevious() async {
    if (queue.isEmpty) return;

    if (queue.isFirst) {
      queue.setIndex(queue.songs.length - 1);
    } else {
      queue.previous();
    }

    await playFromQueue();
  }

  Future<void> seek(int sec) async {
    await _player.seek(Duration(seconds: sec));
  }

  Future<void> setVolume(double value) async {
    volume.value = value.clamp(0.0, 1.0);
    await _player.setVolume(volume.value);
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

  void dispose() {
    _player.dispose();
  }
}