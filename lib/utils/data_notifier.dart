import 'package:flutter/material.dart';

class _CustomNotifier extends ChangeNotifier {
  void notify() {
    notifyListeners();
  }
}

class DataNotifier {
  // Singleton instance
  static final DataNotifier _instance = DataNotifier._internal();

  factory DataNotifier() {
    return _instance;
  }

  DataNotifier._internal();

  // Notifiers
  final _CustomNotifier _historyNotifier = _CustomNotifier();
  final _CustomNotifier _playlistNotifier = _CustomNotifier();

  ChangeNotifier get historyNotifier => _historyNotifier;
  ChangeNotifier get playlistNotifier => _playlistNotifier;

  void notifyHistoryChanged() {
    _historyNotifier.notify();
  }

  void notifyPlaylistChanged() {
    _playlistNotifier.notify();
  }
}
