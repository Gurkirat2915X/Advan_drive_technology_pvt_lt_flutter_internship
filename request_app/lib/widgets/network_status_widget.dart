import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:request_app/providers/network_provider.dart';
import 'package:request_app/services/socket.dart';

class NetworkStatusWidget extends ConsumerWidget {
  final Widget child;
  const NetworkStatusWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    SocketService().setRef(ref);
    
    final isConnected = ref.watch(networkProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (isConnected) {
      return child;
    }

    return Column(
      children: [
        Container(
          width: double.infinity,
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
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 8,
            bottom: 8,
            left: 16,
            right: 16,
          ),
          child: Row(
            children: [
              Icon(Icons.wifi_off, color: colorScheme.onError, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'No Internet Connection',
                  style: TextStyle(
                    color: colorScheme.onError, 
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(child: child),
      ],
    );
  }
}

class NetworkAwareWidget extends ConsumerWidget {
  final Widget child;
  final Widget? offlineWidget;
  final VoidCallback? onRetry;

  const NetworkAwareWidget({
    super.key,
    required this.child,
    this.offlineWidget,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    SocketService().setRef(ref);
    
    final isConnected = ref.watch(networkProvider);

    if (!isConnected) {
      return offlineWidget ?? _buildDefaultOfflineWidget(context);
    }

    return child;
  }

  Widget _buildDefaultOfflineWidget(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.wifi_off,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'No Internet Connection',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Please check your connection and try again.',
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ],
      ),
    );
  }
}
