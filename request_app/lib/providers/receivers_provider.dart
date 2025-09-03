import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:request_app/providers/auth_provider.dart';
import 'package:request_app/services/api.dart';


class ReceiversProvider extends StateNotifier<List<Map<String, String>>> {
  ReceiversProvider() : super([]);

  Future<void> loadReceivers(WidgetRef ref) async {
    try{
      state = await getReceivers(ref.read(authProvider));
    }catch(error){
      print('Failed to load receivers $error');
      ref.read(authProvider.notifier).logout();
    }
  }
}

final receiversProvider = StateNotifierProvider<ReceiversProvider, List<Map<String, String>>>(
  (ref) => ReceiversProvider(),
);
