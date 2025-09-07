import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:request_app/services/network_service.dart';

class NetworkProvider extends StateNotifier<bool> {
  NetworkProvider() : super(true) {
    _initialize();
  }

  final NetworkService _networkService = NetworkService();

  Future<void> _initialize() async {
    await _networkService.initialize();
    state = _networkService.isConnected;

    _networkService.connectionStream.listen((isConnected) {
      state = isConnected;
    });
  }

  Future<bool> checkConnection() async {
    final isConnected = await _networkService.hasInternetConnection();
    state = isConnected;
    return isConnected;
  }

  @override
  void dispose() {
    _networkService.dispose();
    super.dispose();
  }
}

final networkProvider = StateNotifierProvider<NetworkProvider, bool>((ref) {
  return NetworkProvider();
});
