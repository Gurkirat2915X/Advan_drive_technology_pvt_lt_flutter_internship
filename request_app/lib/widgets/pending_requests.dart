import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:request_app/providers/requests_provider.dart';
import 'package:request_app/screens/receiver/request_approval.dart';
import 'package:request_app/services/socket.dart';
import 'package:request_app/theme.dart';

class PendingRequests extends ConsumerWidget {
  const PendingRequests({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SocketService().setRef(ref);

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final allRequests = ref.watch(requestsProvider);

    final pendingRequests = allRequests
        .where(
          (request) =>
              request.status.toLowerCase() == 'pending' ||
              request.status.toLowerCase() == 'partially_fulfilled',
        )
        .toList();

    return Container(
      color: colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.pending_actions,
                    color: colorScheme.onPrimaryContainer,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Requests Requiring Action',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${pendingRequests.length} request${pendingRequests.length != 1 ? 's' : ''} awaiting review or completion',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onPrimaryContainer.withOpacity(
                              0.8,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: pendingRequests.isEmpty
                  ? _buildEmptyState(colorScheme, theme)
                  : _buildRequestsList(pendingRequests, colorScheme, theme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.task_alt, size: 48, color: colorScheme.primary),
          ),
          const SizedBox(height: 24),
          Text(
            'No Pending Requests',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'All caught up! No requests are currently pending your approval.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRequestsList(
    List<dynamic> pendingRequests,
    ColorScheme colorScheme,
    ThemeData theme,
  ) {
    return ListView.separated(
      itemCount: pendingRequests.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final request = pendingRequests[index];
        return _buildRequestCard(context, request, colorScheme, theme);
      },
    );
  }

  Widget _buildRequestCard(
    BuildContext context,
    dynamic request,
    ColorScheme colorScheme,
    ThemeData theme,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => RequestApprovalScreen(request: request),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        request.name ?? 'Unnamed Request',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.warningLight.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'PENDING',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppTheme.warningDark,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Text(
                  'User ID: ${request.userId}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 8),
                Text(
                  'Created: ${_formatDate(request.createdAt)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 18,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${request.items.length} item${request.items.length != 1 ? 's' : ''}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Status: ${request.status}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.touch_app,
                        size: 18,
                        color: colorScheme.secondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Tap to review and approve',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSecondaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: colorScheme.secondary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
