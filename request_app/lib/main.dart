import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:request_app/providers/auth_provider.dart';
import 'package:request_app/providers/network_provider.dart';
import 'package:request_app/screens/end_user/tabs.dart';
import 'package:request_app/screens/login.dart';
import 'package:request_app/screens/receiver/tabs.dart';
import 'package:request_app/screens/splash.dart';
import 'package:request_app/services/socket.dart';
import 'package:request_app/theme.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isInitialized) {
        ref.read(authProvider.notifier).loadUserData(ref);
        _isInitialized = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Request App',
      themeMode: ThemeMode.system,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: Consumer(
        builder: (context, ref, child) {
          final user = ref.watch(authProvider);
          ref.watch(networkProvider);
          if (user.isLoading) {
            return const SplashScreen();
          }

          SocketService().connectToServer(ref: ref);

          Widget mainContent;
          if (user.role == 'receiver') {
            mainContent = const ReceiverTabs();
          } else if (user.role == 'end_user') {
            mainContent = const EndUserTabs();
          } else {
            mainContent = const LoginScreen();
          }

          return mainContent;
        },
      ),
    );
  }
}
