import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:audio_metadata_reader/audio_metadata_reader.dart';
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

  bool _initialized = false;

  void init() {
    if (_initialized) return;
    _initialized = true;

    _player.onDurationChanged.listen((d) => duration.value = d);
    _player.onPositionChanged.listen((p) => position.value = p);

    _player.onPlayerComplete.listen((_) async {
      position.value = Duration.zero;

      if (queue.isLast) {
        await _player.stop();
        isPlaying.value = false;
      } else {
        await playNext();
      }
    });
  }

  // 🎵 Play dari queue
  Future<void> playFromQueue() async {
    final song = queue.currentSong;
    if (song == null) return;

    await _playSong(song);
  }

  // 🔥 Core play
  Future<void> _playSong(Song song) async {
    if (currentSong.value?.path == song.path && isPlaying.value) return;

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
  }

  // ⏯ Toggle
  Future<void> toggle() async {
    if (isPlaying.value) {
      await _player.pause();
    } else {
      await _player.resume();
    }
    isPlaying.value = !isPlaying.value;
  }

  // ⏭ Next
  Future<void> playNext() async {
    if (queue.isLast) return;
    queue.next();
    await playFromQueue();
  }

  // ⏮ Previous
  Future<void> playPrevious() async {
    if (queue.isFirst) return;
    queue.previous();
    await playFromQueue();
  }

  // ⏩ Seek
  Future<void> seek(int sec) async {
    await _player.seek(Duration(seconds: sec));
  }

  void dispose() {
    _player.dispose();
  }
}