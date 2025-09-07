import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:request_app/models/user.dart";
import "package:request_app/providers/item_types_provider.dart";
import "package:request_app/providers/reassigned_provider.dart";
import "package:request_app/providers/receivers_provider.dart";
import "package:request_app/providers/requests_provider.dart";
import "package:request_app/services/api.dart";
import "package:request_app/services/storage.dart";

class AuthProvider extends StateNotifier<User> {
  AuthProvider() : super(User.loading());

  void loadUserData(WidgetRef ref) async {
    // Start with loading state
    state = User.loading();
    
    User loadedUser = await loadUserFromStorage();
    if (loadedUser.token.isNotEmpty) {
      bool valid = await isLoggedIn(loadedUser);
      if (valid) {
        print("ok");
        try {
          await ref
              .read(requestsProvider.notifier)
              .loadRequests(loadedUser, ref);
        } catch (e) {
          print('Failed to load requests: $e');
        }
        try {
          await ref
              .read(receiversProvider.notifier)
              .loadReceivers(loadedUser, ref);
        } catch (e) {
          print('Failed to load receivers: $e');
        }
        try {
          await ref
              .read(itemTypesProvider.notifier)
              .loadItemTypes(loadedUser, ref);
        } catch (e) {
          print('Failed to load item types: $e');
        }
        if(loadedUser.role == 'receiver'){
          print("receiver");
          try {
            await ref.read(reassignedProvider.notifier).loadReassigned(loadedUser, ref);
          } catch (e) {
            print('Failed to load receiver profile: $e');
          }
        }
        state = loadedUser;
      } else {
        state = User.empty();
        await clearUserFromStorage();
      }
    } else {
      // No stored user, set to empty (not loading)
      state = User.empty();
    }
  }

  Future<bool> login(String username, String password, WidgetRef ref) async {
    try {
      User currentUser = await loginUser(username, password);
      try {
        await ref
            .read(requestsProvider.notifier)
            .loadRequests(currentUser, ref);
      } catch (e) {
        print('Failed to load requests: $e');
      }
      try {
        await ref
            .read(receiversProvider.notifier)
            .loadReceivers(currentUser, ref);
      } catch (e) {
        print('Failed to load receivers: $e');
      }
      try {
        await ref
            .read(itemTypesProvider.notifier)
            .loadItemTypes(currentUser, ref);
      } catch (e) {
        print('Failed to load item types: $e');
      }
      print("saved");
      await saveUserToStorage(currentUser);
      state = currentUser;
      return true;
    } catch (e) {
      print('Login error: $e');
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
