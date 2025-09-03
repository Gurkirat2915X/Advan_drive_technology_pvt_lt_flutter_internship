import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:request_app/providers/auth_provider.dart';
import 'package:request_app/providers/receivers_provider.dart';
import 'package:request_app/providers/requests_provider.dart';
import 'package:request_app/screens/end_user/tabs.dart';
import 'package:request_app/screens/login.dart';
import 'package:request_app/screens/receiver/home.dart';
import 'package:request_app/screens/splash.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> initializeData(ref) async {
      await ref.read(authProvider.notifier).loadUserData();
      await ref.read(requestsProvider.notifier).loadRequests(ref);
      await ref.read(receiversProvider.notifier).loadReceivers(ref);
    }

    return MaterialApp(
      title: 'Request App',
      themeMode: ThemeMode.system,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: FutureBuilder(
        future: initializeData(ref),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreen();
          } else if (snapshot.hasError) {
            print(snapshot.error);
            return const Scaffold(body: Center(child: Text('Error occurred')));
          } else {
            return Consumer(
              builder: (context, ref, child) {
                final user = ref.watch(authProvider);
                if (user.role == 'receiver') {
                  return const ReceiverHomeScreen();
                } else if (user.role == 'end_user') {
                  return const EndUserTabs();
                } else {
                  return const LoginScreen();
                }
              },
            );
          }
        },
      ),
    );
  }
}
