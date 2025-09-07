import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:request_app/models/user.dart';
import 'package:request_app/providers/auth_provider.dart';
import 'package:request_app/providers/requests_provider.dart';
import 'package:request_app/screens/end_user/new_request.dart';
import 'package:request_app/screens/end_user/request_detail.dart';
import 'package:request_app/screens/receiver/request_approval.dart';
import 'package:request_app/services/socket.dart';
import 'package:request_app/theme.dart';

class Requests extends ConsumerWidget {
  const Requests({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SocketService().setRef(ref);

    final User user = ref.watch(authProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final allRequests = ref.watch(requestsProvider);

    final requests = user.role == "end_user"
        ? allRequests
              .where(
                (request) =>
                    request.userId == user.id &&
                    request.status.toLowerCase() != 'approved' &&
                    request.status.toLowerCase() != 'completed',
              )
              .toList()
        : allRequests;

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
                    Icons.assignment_outlined,
                    color: colorScheme.onPrimaryContainer,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.role == "end_user"
                              ? 'My Active Requests'
                              : 'All Requests',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.role == "end_user"
                              ? 'Track your pending and in-progress requests'
                              : 'Review and manage all requests',
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

            if (user.role == "end_user") ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const NewRequestScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Create New Request'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            Expanded(
              child: requests.isEmpty
                  ? _buildEmptyState(context, theme, colorScheme, user.role)
                  : ListView.builder(
                      itemCount: requests.length,
                      itemBuilder: (context, index) {
                        final request = requests[index];
                        return _buildRequestCard(
                          context,
                          theme,
                          colorScheme,
                          request,
                          user.role,
                          ref,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildEmptyState(
  BuildContext context,
  ThemeData theme,
  ColorScheme colorScheme,
  String userRole,
) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: colorScheme.surfaceVariant.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.inbox_outlined,
            size: 64,
            color: colorScheme.outline,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          userRole == "end_user"
              ? 'No active requests'
              : 'No requests to review',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          userRole == "end_user"
              ? 'Create a new request or check the Completed tab for approved requests'
              : 'New requests will appear here for review',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface.withOpacity(0.5),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}

Widget _buildRequestCard(
  BuildContext context,
  ThemeData theme,
  ColorScheme colorScheme,
  dynamic request,
  String userRole,
  WidgetRef ref,
) {
  return Card(
    margin: const EdgeInsets.only(bottom: 12),
    elevation: 2,
    shadowColor: colorScheme.shadow.withOpacity(0.1),
    child: InkWell(
      borderRadius: BorderRadius.circular(12),
      splashColor: colorScheme.primary.withOpacity(0.1),
      highlightColor: colorScheme.primary.withOpacity(0.05),
      onTap: () {
        if (userRole == "receiver") {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => RequestApprovalScreen(request: request),
            ),
          );
        } else if (userRole == "end_user") {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => RequestDetailScreen(request: request),
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
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
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  _buildStatusChip(theme, colorScheme, request.status),
                  const SizedBox(width: 8),

                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios,
                      size: 12,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 16,
                    color: colorScheme.outline,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${request.items?.length ?? 0} items',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.schedule, size: 16, color: colorScheme.outline),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(request.createdAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),

              if (userRole == "receiver" &&
                  (request.status == 'pending' ||
                      request.status == 'partially_fulfilled')) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.touch_app, size: 16, color: colorScheme.primary),
                    const SizedBox(width: 4),
                    Text(
                      'Tap to review',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
              if (userRole == "end_user") ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Tap to view details',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _buildStatusChip(
  ThemeData theme,
  ColorScheme colorScheme,
  String status,
) {
  Color statusColor;
  IconData statusIcon;

  switch (status.toLowerCase()) {
    case 'pending':
      statusColor = AppTheme.warningLight;
      statusIcon = Icons.schedule;
      break;
    case 'approved':
      statusColor = AppTheme.successLight;
      statusIcon = Icons.check_circle;
      break;
    case 'completed':
      statusColor = AppTheme.successLight;
      statusIcon = Icons.task_alt;
      break;
    case 'rejected':
      statusColor = colorScheme.error;
      statusIcon = Icons.cancel;
      break;
    default:
      statusColor = AppTheme.infoLight;
      statusIcon = Icons.info;
  }

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: statusColor.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: statusColor.withOpacity(0.3)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(statusIcon, size: 14, color: statusColor),
        const SizedBox(width: 4),
        Text(
          status.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            color: statusColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}

String _formatDate(DateTime? date) {
  if (date == null) return 'Unknown';
  final now = DateTime.now();
  final difference = now.difference(date);

  if (difference.inDays > 0) {
    return '${difference.inDays}d ago';
  } else if (difference.inHours > 0) {
    return '${difference.inHours}h ago';
  } else if (difference.inMinutes > 0) {
    return '${difference.inMinutes}m ago';
  } else {
    return 'Just now';
  }
}
