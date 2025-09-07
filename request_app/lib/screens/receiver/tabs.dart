import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:request_app/providers/auth_provider.dart';
import 'package:request_app/providers/network_provider.dart';
import 'package:request_app/screens/completed_request.dart';
import 'package:request_app/screens/login.dart';
import 'package:request_app/screens/receiver/reassigned.dart';
import 'package:request_app/services/socket.dart';
import 'package:request_app/widgets/pending_requests.dart';

class ReceiverTabs extends ConsumerWidget {
  const ReceiverTabs({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Ensure socket service has the latest ref to prevent expiration issues
    SocketService().setRef(ref);
    
    final isConnected = ref.watch(networkProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return DefaultTabController(
      length: 3, 
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.primary,
                  colorScheme.primary.withOpacity(0.8),
                ],
              ),
            ),
          ),
          title: Row(
            children: [
              Icon(Icons.dashboard, color: colorScheme.onPrimary, size: 24),
              const SizedBox(width: 8),
              Text(
                "Receiver Dashboard",
                style: TextStyle(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
              const Spacer(),
              // Network status indicator
              if (!isConnected)
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorScheme.onPrimary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colorScheme.onPrimary.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.wifi_off, color: colorScheme.onPrimary, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        'Offline',
                        style: TextStyle(color: colorScheme.onPrimary, fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              IconButton(
                icon: Icon(Icons.logout, color: colorScheme.onPrimary),
                onPressed: () {
                  ref.read(authProvider.notifier).logout();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const LoginScreen())
                  );
                },
              )
            ],
          ),
          bottom: TabBar(
            indicatorColor: colorScheme.onPrimary,
            indicatorWeight: 3,
            labelColor: colorScheme.onPrimary,
            unselectedLabelColor: colorScheme.onPrimary.withOpacity(0.7),
            labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400, fontSize: 12),
            tabs: const [
              Tab(
                icon: Icon(Icons.pending_actions),
                text: "Pending",
              ),
              Tab(
                icon: Icon(Icons.swap_horiz),
                text: "Reassigned",
              ),
              Tab(
                icon: Icon(Icons.check_circle),
                text: "Completed",
              )
            ],
          ),
        ),
        body: Column(
          children: [
            // Network status banner at the top
            if (!isConnected)
              Container(
                decoration: BoxDecoration(
                  color: colorScheme.error,
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.shadow.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Row(
                  children: [
                    Icon(Icons.wifi_off, color: colorScheme.onError, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'No Internet Connection - Data may not be up to date',
                        style: TextStyle(color: colorScheme.onError, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            // Tab content with proper background
            Expanded(
              child: Container(
                color: colorScheme.surface,
                child: TabBarView(
                  children: [
                    const PendingRequests(),
                    const ReassignedScreen(),
                    const CompletedRequest(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
