import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:request_app/models/item.dart';
import 'package:request_app/models/user.dart';
import 'package:request_app/services/api.dart' as api;

class ReassignedProvider extends StateNotifier<List<Item>> {
  ReassignedProvider() : super([]);

  Future<void> loadReassigned(User user, WidgetRef ref) async {
    try {
      final newReassigned = await api.getReassignment(user);
      state = newReassigned;
      print('Reassigned items loaded: $state');
    } catch (error) {
      print('Failed to load reassigned items: $error');
      throw Exception("Failed to load reassigned items");
    }
  }

  void refreshReassigned(User user, WidgetRef ref) {
    loadReassigned(user, ref);
  }

  Future<void> acceptReassignment(User user, String itemId) async {
    try {
      await api.acceptReassignment(user, itemId);
      state = state.where((item) => item.id != itemId).toList();
    } catch (error) {
      print('Failed to accept reassignment: $error');
      throw Exception("Failed to accept reassignment");
    }
  }

  Future<void> rejectReassignment(User user, String itemId) async {
    try {
      await api.rejectReassignment(user, itemId);
      state = state.where((item) => item.id != itemId).toList();
    } catch (error) {
      print('Failed to reject reassignment: $error');
      throw Exception("Failed to reject reassignment");
    }
  }

  void removeReassigned(String itemId) {
    state = state.where((item) => item.id != itemId).toList();
  }
}

final reassignedProvider =
    StateNotifierProvider<ReassignedProvider, List<Item>>((ref) {
      return ReassignedProvider();
    });
