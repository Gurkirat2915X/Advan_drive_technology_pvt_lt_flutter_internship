import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:request_app/providers/auth_provider.dart';
import 'package:request_app/providers/network_provider.dart';
import 'package:request_app/screens/end_user/tabs.dart';
import 'package:request_app/screens/login.dart';
import 'package:request_app/screens/receiver/tabs.dart';
import 'package:request_app/screens/splash.dart';
import 'package:request_app/services/socket.dart';
import 'package:request_app/widgets/network_status_widget.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});
  
  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  bool _isRetrying = false;

  Future<void> initializeData() async {
    ref.read(authProvider.notifier).loadUserData(ref);
  }

  void _retryInitialization() async {
    setState(() {
      _isRetrying = true;
    });
    
    try {
      await initializeData();
    } catch (e) {
      // Error will be handled by FutureBuilder
    } finally {
      setState(() {
        _isRetrying = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Request App',
      themeMode: ThemeMode.system,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: FutureBuilder(
        key: ValueKey(_isRetrying), // Force rebuild on retry
        future: initializeData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreen();
          } else if (snapshot.hasError) {
            return _buildErrorScreen(snapshot.error);
          } else {
            return Consumer(
              builder: (context, ref, child) {
                final user = ref.watch(authProvider);
                // Initialize network provider
                ref.watch(networkProvider);
                
                // Use singleton instance
                SocketService().connectToServer(ref: ref);
                
                Widget mainContent;
                if (user.role == 'receiver') {
                  mainContent = const ReceiverTabs();
                } else if (user.role == 'end_user') {
                  mainContent = const EndUserTabs();
                } else {
                  mainContent = const LoginScreen();
                }
                
                return NetworkStatusWidget(child: mainContent);
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildErrorScreen(Object? error) {
    return Scaffold(
      body: Consumer(
        builder: (context, ref, child) {
          final isConnected = ref.watch(networkProvider);
          
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isConnected ? Icons.error : Icons.wifi_off,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isConnected ? 'Error Loading App' : 'No Internet Connection',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isConnected 
                        ? 'An error occurred while loading the app. Please try again.'
                        : 'Please check your internet connection and try again.',
                    style: const TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _isRetrying ? null : _retryInitialization,
                    icon: _isRetrying 
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.refresh),
                    label: Text(_isRetrying ? 'Retrying...' : 'Try Again'),
                  ),
                  if (!isConnected) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: const Text(
                        'The app will automatically retry when your connection is restored.',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                  if (isConnected) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.wifi, color: Colors.green, size: 16),
                          SizedBox(width: 8),
                          Text(
                            'Connection restored! You can try again now.',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
