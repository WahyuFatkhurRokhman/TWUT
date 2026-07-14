import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _connectionStreamController = StreamController<bool>.broadcast();

  Stream<bool> get connectionStream => _connectionStreamController.stream;

  ConnectivityService() {
    _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      _checkStatus(results);
    });
    _initStatus();
  }

  Future<void> _initStatus() async {
    final results = await _connectivity.checkConnectivity();
    _checkStatus(results);
  }

  void _checkStatus(List<ConnectivityResult> results) {
    // If any connection type is found, consider it online.
    // Note: connectivity_plus 6.x returns a list of results.
    final isConnected = !results.contains(ConnectivityResult.none);
    _connectionStreamController.add(isConnected);
  }

  void dispose() {
    _connectionStreamController.close();
  }
}
