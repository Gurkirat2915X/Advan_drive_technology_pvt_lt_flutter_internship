import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:request_app/models/request.dart';
import 'package:request_app/providers/auth_provider.dart';
import 'package:request_app/services/api.dart';

class RequestsProvider extends StateNotifier<List<Request>> {
  RequestsProvider() : super([]);

  Future<void> loadRequests(WidgetRef ref) async {
    try {
      state = await getRequests(ref.read(authProvider));
    } catch (error) {
      print('Failed to load requests $error');
      ref.read(authProvider.notifier).logout();
    }
  }

  void addRequest(Request request) {
    state = [...state, request];
  }
}

final requestsProvider = StateNotifierProvider<RequestsProvider, List<Request>>(
  (ref) {
    return RequestsProvider();
  },
);
