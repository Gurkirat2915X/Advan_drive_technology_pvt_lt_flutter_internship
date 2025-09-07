import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class NetworkService {
  static final NetworkService _instance = NetworkService._internal();
  factory NetworkService() => _instance;
  NetworkService._internal();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  bool _isConnected = true;
  bool get isConnected => _isConnected;

  final _connectionStreamController = StreamController<bool>.broadcast();
  Stream<bool> get connectionStream => _connectionStreamController.stream;

  Future<void> initialize() async {
    await _checkConnectivity();

    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      _updateConnectionStatus(results);
    });
  }

  Future<void> _checkConnectivity() async {
    try {
      final List<ConnectivityResult> results = await _connectivity
          .checkConnectivity();
      _updateConnectionStatus(results);
    } catch (e) {
      debugPrint('Error checking connectivity: $e');
      _isConnected = false;
      _connectionStreamController.add(_isConnected);
    }
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    final bool wasConnected = _isConnected;
    _isConnected =
        results.isNotEmpty &&
        results.any((result) => result != ConnectivityResult.none);

    debugPrint('Network connectivity changed: $_isConnected');

    if (wasConnected != _isConnected) {
      _connectionStreamController.add(_isConnected);
    }
  }

  Future<bool> hasInternetConnection() async {
    try {
      final List<ConnectivityResult> results = await _connectivity
          .checkConnectivity();
      return results.isNotEmpty &&
          results.any((result) => result != ConnectivityResult.none);
    } catch (e) {
      debugPrint('Error checking internet connection: $e');
      return false;
    }
  }

  void dispose() {
    _connectivitySubscription?.cancel();
    _connectionStreamController.close();
  }
}
