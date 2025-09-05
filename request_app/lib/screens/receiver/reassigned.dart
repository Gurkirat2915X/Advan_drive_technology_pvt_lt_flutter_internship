import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:request_app/providers/auth_provider.dart';
import 'package:request_app/providers/reassigned_provider.dart';
import 'package:request_app/models/item.dart';

class ReassignedScreen extends ConsumerStatefulWidget {
  const ReassignedScreen({super.key});

  @override
  ConsumerState<ReassignedScreen> createState() => _ReassignedScreenState();
}

class _ReassignedScreenState extends ConsumerState<ReassignedScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadReassignedItems();
  }

  Future<void> _loadReassignedItems() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final user = ref.read(authProvider);
      await ref.read(reassignedProvider.notifier).loadReassigned(user, ref);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load reassigned items: $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final reassignedItems = ref.watch(reassignedProvider);

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (reassignedItems.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_return,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No Reassigned Items',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'No items have been reassigned to you yet.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadReassignedItems,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: reassignedItems.length,
        itemBuilder: (context, index) {
          final item = reassignedItems[index];
          return _buildItemCard(context, item);
        },
      ),
    );
  }

  Widget _buildItemCard(BuildContext context, Item item) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with item name and status
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.assignment_return, size: 14, color: Colors.orange.shade700),
                      const SizedBox(width: 4),
                      Text(
                        'REASSIGNED',
                        style: TextStyle(
                          color: Colors.orange.shade700,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Item details
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.category, size: 16, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Type: ${item.type}',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.numbers, size: 16, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Quantity: ${item.quantity}',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  if (item.requestName != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.folder, size: 16, color: theme.colorScheme.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Request: ${item.requestName}',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (item.originalReceiver != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.person, size: 16, color: theme.colorScheme.secondary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Original Receiver: ${item.originalReceiver}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            
            // Notes section if available
            if (item.notes != null && item.notes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.note, size: 16, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Reassignment Notes:',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.notes!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.blue.shade800,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 12),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _acceptReassignment(item),
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('Accept'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _rejectReassignment(item),
                    icon: const Icon(Icons.close, size: 16),
                    label: const Text('Reject'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _acceptReassignment(Item item) async {
    try {
      final user = ref.read(authProvider);
      await ref.read(reassignedProvider.notifier).acceptReassignment(user, item.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Accepted reassignment for ${item.name}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to accept reassignment: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _rejectReassignment(Item item) async {
    try {
      final user = ref.read(authProvider);
      await ref.read(reassignedProvider.notifier).rejectReassignment(user, item.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Rejected reassignment for ${item.name}'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to reject reassignment: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}