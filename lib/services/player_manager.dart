import 'package:flutter/foundation.dart';

abstract class PlayerManager {
  ValueNotifier<bool> get isPlaying;

  ValueNotifier<Duration> get position;

  ValueNotifier<Duration> get duration;

  ValueNotifier<bool> get isLoading;

  Future<void> play();

  Future<void> pause();

  Future<void> resume();

  Future<void> seek(Duration pos);

  Future<void> stop();

  void dispose();
}