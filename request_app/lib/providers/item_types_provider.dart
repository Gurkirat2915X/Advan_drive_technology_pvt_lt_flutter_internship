import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:request_app/models/user.dart';
import 'package:request_app/providers/auth_provider.dart';
import 'package:request_app/services/api.dart';


class ItemTypesProvider extends StateNotifier<List<String>> {
  ItemTypesProvider() : super([]);

  Future<void> loadItemTypes(User user, WidgetRef ref) async {
    try {
      final newItemTypes = await getItemTypes(user);
      state = newItemTypes;
      print('Item types loaded: $state');
    } catch (error) {
      await ref.read(authProvider.notifier).logout();
      print('Failed to load item types: $error');
      throw Exception("Failed to load item types");
    }
  }

  void refreshItemTypes(User user, WidgetRef ref) {
    loadItemTypes(user, ref);
  }
}

final itemTypesProvider = StateNotifierProvider<ItemTypesProvider, List<String>>(
  (ref) => ItemTypesProvider(),
);
