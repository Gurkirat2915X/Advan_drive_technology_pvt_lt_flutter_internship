import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:request_app/providers/requests_provider.dart';
import 'package:request_app/providers/auth_provider.dart';
import 'package:request_app/screens/end_user/request_detail.dart';
import 'package:request_app/services/socket.dart';
import 'package:request_app/theme.dart';

class CompletedRequest extends ConsumerWidget {
  const CompletedRequest({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SocketService().setRef(ref);

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final allRequests = ref.watch(requestsProvider);
    final user = ref.watch(authProvider);

    final completedRequests = allRequests.where((request) {
      final isCompleted =
          request.status.toLowerCase() == 'approved' ||
          request.status.toLowerCase() == 'completed';

      if (user?.role.toLowerCase() == 'enduser') {
        return isCompleted && request.userId == user.id;
      }

      return isCompleted;
    }).toList();

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
                    Icons.check_circle,
                    color: colorScheme.onPrimaryContainer,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Completed Requests',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${completedRequests.length} ${user?.role.toLowerCase() == 'enduser' ? 'completed' : 'processed'} request${completedRequests.length != 1 ? 's' : ''}',
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
              child: completedRequests.isEmpty
                  ? _buildEmptyState(
                      colorScheme,
                      theme,
                      user?.role.toLowerCase() == 'enduser',
                    )
                  : _buildRequestsList(
                      completedRequests,
                      colorScheme,
                      theme,
                      context,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    ColorScheme colorScheme,
    ThemeData theme,
    bool isEndUser,
  ) {
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
            child: Icon(
              Icons.history_outlined,
              size: 48,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Completed Requests',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isEndUser
                ? 'You haven\'t completed any requests yet.'
                : 'No requests have been completed yet.',
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
    List<dynamic> completedRequests,
    ColorScheme colorScheme,
    ThemeData theme,
    BuildContext context,
  ) {
    return ListView.separated(
      itemCount: completedRequests.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final request = completedRequests[index];
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
          splashColor: colorScheme.primary.withOpacity(0.1),
          highlightColor: colorScheme.primary.withOpacity(0.05),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => RequestDetailScreen(request: request),
              ),
            );
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
                          color: AppTheme.successLight.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'COMPLETED',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppTheme.successDark,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
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

                  Text(
                    'Request ID: ${request.id}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    '${request.items.length} item${request.items.length != 1 ? 's' : ''} requested',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface,
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
                          Icons.check_circle_outline,
                          size: 18,
                          color: AppTheme.successDark,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Request Completed',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
