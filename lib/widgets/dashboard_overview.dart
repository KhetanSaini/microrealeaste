import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../providers/app_providers.dart';
import '../database/models/rent_payment.dart';
import '../database/models/maintenance_request.dart';
import '../database/models/property.dart';
import 'stat_card.dart';

class DashboardOverview extends ConsumerWidget {
  const DashboardOverview({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tenants = ref.watch(tenantsProvider);
    final properties = ref.watch(propertiesProvider);
    final rentPayments = ref.watch(rentPaymentsProvider);
    final maintenanceRequests = ref.watch(maintenanceRequestsProvider);

    // Calculate statistics
    final totalProperties = properties.length;
    final occupiedProperties = properties.where((p) => p.propertyStatus == PropertyStatus.occupied).length;
    final availableProperties = properties.where((p) => p.propertyStatus == PropertyStatus.available).length;
    
    final totalTenants = tenants.length;
    final totalMonthlyRent = tenants.fold(0.0, (sum, tenant) => sum + tenant.rentAmount);
    
    final overduePayments = rentPayments.where((p) => p.isOverdue).length;
    final paidThisMonth = rentPayments.where((p) => 
      p.status == PaymentStatus.paid && 
      p.paidDate != null &&
      p.paidDate!.month == DateTime.now().month &&
      p.paidDate!.year == DateTime.now().year
    ).length;
    
    final pendingMaintenance = maintenanceRequests.where((r) => 
      r.status != MaintenanceStatus.completed
    ).length;
    final urgentMaintenance = maintenanceRequests.where((r) => 
      r.priority == MaintenancePriority.urgent && 
      r.status != MaintenanceStatus.completed
    ).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
            ],
          ),
        ),

        // Statistics Grid
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              // First Row - Properties and Tenants
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      title: 'Total Properties',
                      value: totalProperties.toString(),
                      icon: Icons.apartment,
                      color: theme.colorScheme.primary,
                      subtitle: '$occupiedProperties occupied, $availableProperties available',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      title: 'Total Tenants',
                      value: totalTenants.toString(),
                      icon: Icons.people,
                      color: theme.colorScheme.secondary,
                      subtitle: 'Active tenants',
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Second Row - Financial
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      title: 'Monthly Rent',
                      value: '\$${totalMonthlyRent.toStringAsFixed(0)}',
                      icon: Icons.attach_money,
                      color: Colors.green,
                      subtitle: 'Total monthly income',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      title: 'Overdue Payments',
                      value: overduePayments.toString(),
                      icon: Icons.warning,
                      color: Colors.orange,
                      subtitle: 'Requires attention',
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Third Row - Maintenance
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      title: 'Pending Maintenance',
                      value: pendingMaintenance.toString(),
                      icon: Icons.build,
                      color: Colors.blue,
                      subtitle: '$urgentMaintenance urgent',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      title: 'Paid This Month',
                      value: paidThisMonth.toString(),
                      icon: Icons.check_circle,
                      color: Colors.green,
                      subtitle: 'Successful payments',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Quick Actions
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quick Actions',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildQuickActionCard(
                      context,
                      'Add Property',
                      Icons.add_home,
                      theme.colorScheme.primary,
                      () => _showComingSoon(context, 'Add Property'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickActionCard(
                      context,
                      'Add Tenant',
                      Icons.person_add,
                      theme.colorScheme.secondary,
                      () => _showComingSoon(context, 'Add Tenant'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildQuickActionCard(
                      context,
                      'Record Payment',
                      Icons.payment,
                      Colors.green,
                      () => _showComingSoon(context, 'Record Payment'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickActionCard(
                      context,
                      'Maintenance',
                      Icons.build,
                      Colors.blue,
                      () => _showComingSoon(context, 'Maintenance'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Recent Activity
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Recent Activity',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildRecentActivityList(context, ref),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivityList(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final recentPayments = ref.watch(rentPaymentsProvider)
        .where((p) => p.paidDate != null)
        .toList()
      ..sort((a, b) => b.paidDate!.compareTo(a.paidDate!));
    
    final recentMaintenance = ref.watch(maintenanceRequestsProvider)
        .where((r) => r.status == MaintenanceStatus.completed)
        .toList()
      ..sort((a, b) => (b.completedDate ?? DateTime.now()).compareTo(a.completedDate ?? DateTime.now()));

    final allActivities = <Map<String, dynamic>>[];
    
    // Add recent payments
    for (final payment in recentPayments.take(3)) {
      allActivities.add({
        'type': 'payment',
        'title': 'Rent payment received',
        'subtitle': '\$${payment.amount.toStringAsFixed(0)}',
        'date': payment.paidDate!,
        'icon': Icons.payment,
        'color': Colors.green,
      });
    }
    
    // Add recent maintenance
    for (final maintenance in recentMaintenance.take(3)) {
      allActivities.add({
        'type': 'maintenance',
        'title': 'Maintenance completed',
        'subtitle': maintenance.title,
        'date': maintenance.completedDate ?? DateTime.now(),
        'icon': Icons.build,
        'color': Colors.blue,
      });
    }
    
    // Sort by date
    allActivities.sort((a, b) => b['date'].compareTo(a['date']));
    
    if (allActivities.isEmpty) {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.1)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Icon(
                Icons.history,
                size: 48,
                color: theme.colorScheme.onSurface.withOpacity(0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'No recent activity',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Recent payments and maintenance activities will appear here',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.1)),
      ),
      child: Column(
        children: allActivities.take(5).map((activity) {
          return ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: activity['color'].withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                activity['icon'],
                color: activity['color'],
                size: 20,
              ),
            ),
            title: Text(
              activity['title'],
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              activity['subtitle'],
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            trailing: Text(
              _formatDate(activity['date']),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature feature coming soon!'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
} 