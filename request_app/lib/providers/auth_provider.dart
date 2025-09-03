import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:request_app/models/user.dart";
import "package:request_app/providers/receivers_provider.dart";
import "package:request_app/providers/requests_provider.dart";
import "package:request_app/services/api.dart";
import "package:request_app/services/storage.dart";

class AuthProvider extends StateNotifier<User> {
  AuthProvider() : super(User.empty());

  void loadUserData() async {
    User loadedUser = await loadUserFromStorage();
    if (loadedUser.token.isNotEmpty) {
      bool valid = await isLoggedIn(loadedUser);
      if (valid) {
        print("ok");
        state = loadedUser;
      } else {
        state = User.empty();
        await clearUserFromStorage();
      }
    }
  }

  Future<bool> login(String username, String password, WidgetRef ref) async {
    try {
      User currentUser = await loginUser(username, password);
      await ref.read(requestsProvider.notifier).loadRequests(ref);
      await ref.read(receiversProvider.notifier).loadReceivers(ref);
      print("saved");
      await saveUserToStorage(currentUser);
      state = currentUser;
  
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<void> logout() async {
    state = User.empty();
    await clearUserFromStorage();
  }
}

final authProvider = StateNotifierProvider<AuthProvider, User>((ref) {
  return AuthProvider();
});
