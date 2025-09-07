import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/socket.dart';

/// A widget that ensures socket data synchronization
/// Add this widget to screens that need real-time data updates
class SocketDataSync extends ConsumerWidget {
  final Widget child;
  final bool autoRefresh;
  final Duration refreshInterval;

  const SocketDataSync({
    Key? key,
    required this.child,
    this.autoRefresh = false,
    this.refreshInterval = const Duration(minutes: 1),
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Ensure socket service has the latest ref
    SocketService().setRef(ref);

    // Optional: Set up auto-refresh
    if (autoRefresh) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _setupAutoRefresh();
      });
    }

    return child;
  }

  void _setupAutoRefresh() {
    // This could be enhanced with a proper timer if needed
    // For now, we rely on the socket service's built-in retry mechanism
  }
}

/// A convenient mixin for stateful widgets that need socket data sync
mixin SocketDataSyncMixin<T extends StatefulWidget> on State<T> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _ensureSocketSync();
      }
    });
  }

  void _ensureSocketSync() {
    // Force a data update when the widget is initialized
    SocketService().forceDataUpdate();
  }

  @override
  void dispose() {
    // Optional: Clear ref when disposing, but be careful not to affect other widgets
    super.dispose();
  }
}
