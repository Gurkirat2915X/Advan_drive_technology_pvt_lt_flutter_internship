import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:request_app/models/user.dart';
import 'package:request_app/providers/auth_provider.dart';
import 'package:request_app/services/api.dart';


class ReceiversProvider extends StateNotifier<List<Map<String, String>>> {
  ReceiversProvider() : super([]);

  Future<void> loadReceivers(User user, WidgetRef ref) async {
    try {
      state = await getReceivers(user);
    } catch (error) {
      print('Failed to load receivers: $error');
      await ref.read(authProvider.notifier).logout();
      throw Exception("Failed to load receivers");
    }
  }
}

final receiversProvider = StateNotifierProvider<ReceiversProvider, List<Map<String, String>>>(
  (ref) => ReceiversProvider(),
);
