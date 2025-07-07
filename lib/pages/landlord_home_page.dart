import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:microrealeaste/widgets/dashboard_overview.dart';
import 'package:microrealeaste/providers/app_providers.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:microrealeaste/widgets/framework_page.dart';

class LanlordHomePage extends HookConsumerWidget {
  const LanlordHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isLoading = ref.watch(isLoadingProvider);
    final tenants = ref.watch(tenantsProvider);
    final properties = ref.watch(propertiesProvider);
    final rentPayments = ref.watch(rentPaymentsProvider);
    final maintenanceRequests = ref.watch(maintenanceRequestsProvider);

    // Set isLoadingProvider to false when all data is loaded
    useEffect(() {
      if (isLoading && tenants.isNotEmpty && properties.isNotEmpty && rentPayments.isNotEmpty && maintenanceRequests.isNotEmpty) {
        Future.microtask(() => ref.read(isLoadingProvider.notifier).state = false);
      }
      return null;
    }, [isLoading, tenants, properties, rentPayments, maintenanceRequests]);

    if (isLoading) {
      return Scaffold(
        backgroundColor: theme.colorScheme.surface,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Loading Property Data...',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return FrameworkPage(
      title: 'Home',
      actions: [
        IconButton(
          icon: Icon(
            Icons.notifications_outlined,
            color: theme.colorScheme.onSurface,
          ),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Notifications feature coming soon!'),
              ),
            );
          },
        ),
      ],
      slivers: [
        const SliverToBoxAdapter(child: DashboardOverview()),
        const SliverToBoxAdapter(child: SizedBox(height: 80)),
      ],
      // Optionally add floatingActionButton, background, etc. as needed
    );
  }
}