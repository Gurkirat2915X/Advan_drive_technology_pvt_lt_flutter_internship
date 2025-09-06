import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import "package:request_app/variables.dart" as variables;
import "package:request_app/providers/auth_provider.dart";
import "package:request_app/providers/requests_provider.dart";
import "package:request_app/providers/receivers_provider.dart";
import "package:request_app/providers/item_types_provider.dart";
import "package:request_app/providers/reassigned_provider.dart";
import "package:request_app/services/network_service.dart";

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  late IO.Socket socket;
  WidgetRef? _ref;
  bool _isUpdating = false;
  bool _isConnected = false;
  final NetworkService _networkService = NetworkService();

  void connectToServer({WidgetRef? ref}) async {
    if (_isConnected) {
      print('Socket already connected');
      if (ref != null) {
        _ref = ref;
      }
      return;
    }

    // Check network connectivity before connecting
    final hasConnection = await _networkService.hasInternetConnection();
    if (!hasConnection) {
      print('No internet connection, cannot connect to socket');
      return;
    }

    _ref = ref;
    socket = IO.io(variables.baseUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.connect();

    socket.onConnect((_) {
      print('Connected to server: ${socket.id}');
      _isConnected = true;
      socket.emit('join_room', 'general');
    });

    socket.on('message', (data) {
      print('Message received: $data');
      _handleDataUpdate(data);
    });

    socket.on('data_update', (data) {
      print('Data update received: $data');
      _handleDataUpdate(data);
    });

    socket.on('request_update', (data) {
      print('Request update received: $data');
      _handleDataUpdate(data);
    });

    socket.on('reassignment_update', (data) {
      print('Reassignment update received: $data');
      _handleDataUpdate(data);
    });

    socket.onDisconnect((_) {
      print('Disconnected from server');
      _isConnected = false;
      
      // Try to reconnect after a delay if network is available
      Future.delayed(const Duration(seconds: 3), () async {
        if (await _networkService.hasInternetConnection()) {
          print('Attempting to reconnect to socket...');
          connectToServer(ref: _ref);
        }
      });
    });
  }

  void _handleDataUpdate(dynamic data) async {
    if (_ref == null) {
      print('WidgetRef not available for data update');
      return;
    }

    if (_isUpdating) {
      print('Already updating data, skipping...');
      return;
    }

    _isUpdating = true;
    
    try {
      // Get current user
      final user = _ref!.read(authProvider);
      
      if (user.token.isEmpty) {
        print('User not authenticated, skipping data update');
        return;
      }

      print('Updating all provider data due to socket message...');

      // Update providers in a controlled manner to prevent UI conflicts
      final futures = <Future>[];

      // Update requests
      futures.add(
        _ref!.read(requestsProvider.notifier).loadRequests(user, _ref!).catchError((e) {
          print('Failed to update requests: $e');
        })
      );

      // Update receivers
      futures.add(
        _ref!.read(receiversProvider.notifier).loadReceivers(user, _ref!).catchError((e) {
          print('Failed to update receivers: $e');
        })
      );

      // Update item types
      futures.add(
        _ref!.read(itemTypesProvider.notifier).loadItemTypes(user, _ref!).catchError((e) {
          print('Failed to update item types: $e');
        })
      );

      // Update reassigned items (only for receivers)
      if (user.role == 'receiver') {
        futures.add(
          _ref!.read(reassignedProvider.notifier).loadReassigned(user, _ref!).catchError((e) {
            print('Failed to update reassigned items: $e');
          })
        );
      }

      // Wait for all updates to complete
      await Future.wait(futures);
      print('All provider data updated successfully');
      
    } catch (e) {
      print('Error updating provider data: $e');
    } finally {
      _isUpdating = false;
    }
  }

  void setRef(WidgetRef ref) {
    _ref = ref;
  }

  void sendMessage(String message) {
    socket.emit('message', message);
  }

  void disconnect() {
    if (_isConnected) {
      socket.disconnect();
      _isConnected = false;
    }
  }
}