import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:request_app/models/request.dart';
import 'package:request_app/models/user.dart';
import 'package:request_app/providers/auth_provider.dart';
import 'package:request_app/services/api.dart' as api;

class RequestsProvider extends StateNotifier<List<Request>> {
  RequestsProvider() : super([]);

  Future<void> loadRequests(User user, WidgetRef ref) async {
    try {
      final newRequests = await api.getRequests(user);
      state = newRequests;
    } catch (error) {
      print('Failed to load requests: $error');
      await ref.read(authProvider.notifier).logout();
      throw Exception("Failed to load requests");
    }
  }

  void refreshRequests(User user, WidgetRef ref) {
    loadRequests(user, ref);
  }

  Future<void> updateRequest(User user, Request request) async {
    try{
      final updatedRequest = await api.updateRequest(user, request);
      // Update the request in the state
      state = state.map((r) => r.id == request.id ? updatedRequest : r).toList();
    } catch (error){
      print("Failed to update Req: $error" );
      throw Exception("Failed to update");
    }
  }

  Future<void> updateRequestWithReassignments(User user, Request request, List<Map<String, dynamic>> itemStates) async {
    try{
      final updatedRequest = await api.updateRequestWithReassignments(user, request, itemStates);
      // Update the request in the state
      state = state.map((r) => r.id == request.id ? updatedRequest : r).toList();
    } catch (error){
      print("Failed to update Req: $error" );
      throw Exception("Failed to update");
    }
  }

  Future addRequest(Request request, User user, WidgetRef ref) async {
    try {
      final newRequest = await api.createRequest(user, request);
      print('Request added: $newRequest');
      print(state == [...state, newRequest]);
      state = [...state, newRequest];
    } catch (error) {
      print('Failed to add request: $error');
      throw Exception('Failed to add request');
    }
  }
}

final requestsProvider = StateNotifierProvider<RequestsProvider, List<Request>>(
  (ref) {
    return RequestsProvider();
  },
);
