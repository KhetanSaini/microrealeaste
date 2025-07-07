import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:microrealeaste/database/models/maintenance_request.dart';
import 'package:microrealeaste/database/models/tenant.dart';


class MaintenanceCard extends StatelessWidget {
  final MaintenanceRequest request;
  final Tenant? tenant;
  final VoidCallback? onTap;
  final VoidCallback? onStatusUpdate;

  const MaintenanceCard({
    super.key,
    required this.request,
    this.tenant,
    this.onTap,
    this.onStatusUpdate,
  });

  Color _getStatusColor(BuildContext context) {
    final theme = Theme.of(context);
    switch (request.status) {
      case MaintenanceStatus.pending:
        return theme.colorScheme.tertiary;
      case MaintenanceStatus.inProgress:
        return theme.colorScheme.primary;
      case MaintenanceStatus.completed:
        return theme.colorScheme.secondary;
      case MaintenanceStatus.cancelled:
        return theme.colorScheme.error;
    }
  }

  Color _getPriorityColor(BuildContext context) {
    final theme = Theme.of(context);
    switch (request.priority) {
      case MaintenancePriority.low:
        return theme.colorScheme.secondary;
      case MaintenancePriority.medium:
        return theme.colorScheme.tertiary;
      case MaintenancePriority.high:
        return theme.colorScheme.primary;
      case MaintenancePriority.urgent:
        return theme.colorScheme.error;
    }
  }

  IconData _getPriorityIcon() {
    switch (request.priority) {
      case MaintenancePriority.low:
        return Icons.arrow_downward;
      case MaintenancePriority.medium:
        return Icons.horizontal_rule;
      case MaintenancePriority.high:
        return Icons.arrow_upward;
      case MaintenancePriority.urgent:
        return Icons.priority_high;
    }
  }

  String _getStatusText() {
    switch (request.status) {
      case MaintenanceStatus.pending:
        return 'Pending';
      case MaintenanceStatus.inProgress:
        return 'In Progress';
      case MaintenanceStatus.completed:
        return 'Completed';
      case MaintenanceStatus.cancelled:
        return 'Cancelled';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor(context);
    final priorityColor = _getPriorityColor(context);

    return Card(
      elevation: 0,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                statusColor.withOpacity(0.03),
                Colors.transparent,
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusText(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: priorityColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getPriorityIcon(),
                          size: 12,
                          color: priorityColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          request.priority.name.toUpperCase(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: priorityColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  if (onStatusUpdate != null)
                    IconButton(
                      icon: Icon(
                        Icons.more_vert,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                        size: 20,
                      ),
                      onPressed: onStatusUpdate,
                      style: IconButton.styleFrom(
                        minimumSize: const Size(32, 32),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                request.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                request.description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 16,
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    tenant?.name ?? 'Unknown Tenant',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    request.propertyId,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('MMM d').format(request.createdDate),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}