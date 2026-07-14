import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:flutter/foundation.dart';

import 'package:music_player/models/song.dart';
import 'package:music_player/services/play_queue.dart';
import 'package:music_player/services/player_manager.dart';

class LocalPlayerManager implements PlayerManager {
  final _player = AudioPlayer();

  // Bukan singleton — tiap LocalPlayerManager punya queue sendiri
  final queue = PlayQueue();

  @override final isPlaying = ValueNotifier(false);
  @override final position = ValueNotifier(Duration.zero);
  @override final duration = ValueNotifier(Duration.zero);
  @override final isLoading = ValueNotifier(false);

  final currentSong = ValueNotifier<Song?>(null);

  bool _queueEnded = false;
  bool _isSeeking = false;

  void Function()? onTrackComplete;

  void init() {
    _player.onDurationChanged.listen((d) => duration.value = d);
    _player.onPositionChanged.listen((p) => position.value = p);
    _player.onPlayerComplete.listen((_) async {
      if (_isSeeking) return;
      position.value = Duration.zero;
      _queueEnded = true;
      isPlaying.value = false;
      onTrackComplete?.call();
    });
  }

  @override
  Future<void> play() async {
    final media = queue.currentMedia;
    if (media == null) return;

    isLoading.value = true;
    try {
      // media.path adalah getter alias ke sourceId (file path)
      final filePath = media.path;
      final file = File(filePath);
      final metadata = readMetadata(file, getImage: true);

      currentSong.value = Song(
        path: filePath,
        title: metadata.title ?? media.title,
        artist: metadata.artist ?? 'Unknown Artist',
        album: metadata.album ?? 'Unknown Album',
        artwork: metadata.pictures.isNotEmpty
            ? metadata.pictures.first.bytes
            : null,
      );

      await _player.stop();
      await _player.play(DeviceFileSource(filePath));
      isPlaying.value = true;
      _queueEnded = false;
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Future<void> pause() async {
    await _player.pause();
    isPlaying.value = false;
  }

  @override
  Future<void> resume() async {
    await _player.resume();
    isPlaying.value = true;
  }

  @override
  Future<void> seek(Duration pos) async {
    final max = duration.value;
    if (max.inMilliseconds == 0) return;

    final safe = Duration(
      milliseconds: pos.inMilliseconds.clamp(0, max.inMilliseconds),
    );

    if (_queueEnded) {
      _queueEnded = false;
      final song = currentSong.value;
      if (song == null) return;
      await _player.play(DeviceFileSource(song.path));
      await _player.seek(safe);
      isPlaying.value = true;
      return;
    }

    _isSeeking = true;
    await _player.seek(safe);
    await Future.delayed(const Duration(milliseconds: 200));
    _isSeeking = false;
  }

  @override
  Future<void> stop() async {
    await _player.stop();
    currentSong.value = null;
    isPlaying.value = false;
    position.value = Duration.zero;
    duration.value = Duration.zero;
    _queueEnded = false;
  }

  Future<void> setVolume(double value) async {
    await _player.setVolume(value.clamp(0.0, 1.0));
  }

  @override
  void dispose() {
    _player.dispose();
    queue.dispose();
    isPlaying.dispose();
    position.dispose();
    duration.dispose();
    isLoading.dispose();
    currentSong.dispose();
  }
}