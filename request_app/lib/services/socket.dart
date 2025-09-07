import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import "package:request_app/variables.dart" as variables;
import "package:request_app/providers/auth_provider.dart";
import "package:request_app/providers/requests_provider.dart";
import "package:request_app/providers/receivers_provider.dart";
import "package:request_app/providers/item_types_provider.dart";
import "package:request_app/providers/reassigned_provider.dart";
import "package:request_app/services/network_service.dart";
import 'dart:async';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  late IO.Socket socket;
  WidgetRef? _ref;
  bool _isUpdating = false;
  bool _isConnected = false;
  final NetworkService _networkService = NetworkService();
  
  // Queue for pending data updates
  final List<dynamic> _pendingUpdates = [];
  Timer? _retryTimer;
  
  // Callback for when ref becomes available
  Function(WidgetRef)? _onRefAvailable;

  void connectToServer({WidgetRef? ref}) async {
    // Always update ref when available
    if (ref != null) {
      _ref = ref;
      print('Updated WidgetRef in socket service');
      
      // Process any pending updates
      if (_pendingUpdates.isNotEmpty) {
        print('Processing ${_pendingUpdates.length} pending updates');
        final updates = List.from(_pendingUpdates);
        _pendingUpdates.clear();
        for (final update in updates) {
          _handleDataUpdate(update);
        }
      }
      
      // Call ref available callback if set
      if (_onRefAvailable != null) {
        _onRefAvailable!(ref);
      }
    }

    if (_isConnected) {
      print('Socket already connected');
      return;
    }

    // Check network connectivity before connecting
    final hasConnection = await _networkService.hasInternetConnection();
    if (!hasConnection) {
      print('No internet connection, cannot connect to socket');
      return;
    }

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
    // If ref is not available, queue the update for later
    if (_ref == null) {
      print('WidgetRef not available, queueing update for later');
      _pendingUpdates.add(data);
      _scheduleRetry();
      return;
    }

    // Check if ref is still valid before proceeding
    if (!_isRefValid()) {
      print('WidgetRef is no longer valid, queueing update for later');
      _pendingUpdates.add(data);
      _scheduleRetry();
      return;
    }

    if (_isUpdating) {
      print('Already updating data, queueing this update');
      _pendingUpdates.add(data);
      return;
    }

    _isUpdating = true;
    
    try {
      final user = _ref!.read(authProvider);
      
      if (user.token.isEmpty) {
        print('User not authenticated, skipping data update');
        return;
      }

      print('Updating all provider data due to socket message...');

      // Update providers in parallel for better performance
      await Future.wait([
        _updateRequests(user),
        _updateReceivers(user),
        _updateItemTypes(user),
        if (user.role == 'receiver') _updateReassigned(user),
      ], eagerError: false);

      print('All provider data updated successfully');
      
    } catch (e) {
      print('Error updating provider data: $e');
      // If there's an error, queue for retry
      _pendingUpdates.add(data);
      _scheduleRetry();
    } finally {
      _isUpdating = false;
    }
  }

  Future<void> _updateRequests(dynamic user) async {
    try {
      await _ref!.read(requestsProvider.notifier).loadRequests(user, _ref!);
    } catch (e) {
      print('Failed to update requests: $e');
    }
  }

  Future<void> _updateReceivers(dynamic user) async {
    try {
      await _ref!.read(receiversProvider.notifier).loadReceivers(user, _ref!);
    } catch (e) {
      print('Failed to update receivers: $e');
    }
  }

  Future<void> _updateItemTypes(dynamic user) async {
    try {
      await _ref!.read(itemTypesProvider.notifier).loadItemTypes(user, _ref!);
    } catch (e) {
      print('Failed to update item types: $e');
    }
  }

  Future<void> _updateReassigned(dynamic user) async {
    try {
      await _ref!.read(reassignedProvider.notifier).loadReassigned(user, _ref!);
    } catch (e) {
      print('Failed to update reassigned items: $e');
    }
  }

  void _scheduleRetry() {
    // Cancel existing timer
    _retryTimer?.cancel();
    
    // Schedule retry after 2 seconds
    _retryTimer = Timer(const Duration(seconds: 2), () {
      if (_ref != null && _isRefValid() && _pendingUpdates.isNotEmpty) {
        print('Retrying ${_pendingUpdates.length} pending updates');
        final updates = List.from(_pendingUpdates);
        _pendingUpdates.clear();
        for (final update in updates) {
          _handleDataUpdate(update);
        }
      }
    });
  }

  void setRef(WidgetRef ref) {
    _ref = ref;
    print('WidgetRef set in socket service');
    
    // Process any pending updates when ref becomes available
    if (_pendingUpdates.isNotEmpty) {
      print('Processing ${_pendingUpdates.length} pending updates after ref set');
      final updates = List.from(_pendingUpdates);
      _pendingUpdates.clear();
      for (final update in updates) {
        _handleDataUpdate(update);
      }
    }
  }

  void clearRef() {
    _ref = null;
    print('WidgetRef cleared from socket service');
  }

  void setRefAvailableCallback(Function(WidgetRef) callback) {
    _onRefAvailable = callback;
  }

  void clearRefAvailableCallback() {
    _onRefAvailable = null;
  }

  // Force data update - useful for manual refresh
  void forceDataUpdate() {
    if (_ref != null && _isRefValid()) {
      print('Forcing data update...');
      _handleDataUpdate({'type': 'manual_refresh'});
    } else {
      print('Cannot force data update - ref not available or invalid');
    }
  }

  // Get pending updates count for debugging
  int get pendingUpdatesCount => _pendingUpdates.length;

  // Check if socket is connected
  bool get isConnected => _isConnected;

  // Check if currently updating
  bool get isUpdating => _isUpdating;

  bool _isRefValid() {
    if (_ref == null) return false;
    try {
      // Try to read a simple provider to test if ref is still valid
      _ref!.read(authProvider);
      return true;
    } catch (e) {
      if (e.toString().contains('Cannot use "ref" after the widget was disposed')) {
        print('Ref is no longer valid, clearing it');
        _ref = null;
        return false;
      }
      // Other errors might still mean the ref is valid but there's another issue
      return true;
    }
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

  void dispose() {
    _retryTimer?.cancel();
    _pendingUpdates.clear();
    _onRefAvailable = null;
    if (_isConnected) {
      socket.disconnect();
    }
    _ref = null;
    _isConnected = false;
    _isUpdating = false;
    print('SocketService disposed');
  }
}