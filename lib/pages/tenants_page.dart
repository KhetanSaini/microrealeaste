import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../database/data_service.dart';
import '../database/models/tenant.dart';
import '../database/models/maintenance_request.dart';
import 'tenant_detail_page.dart';
import 'package:microrealeaste/widgets/framework_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:microrealeaste/providers/app_providers.dart';
import '../database/models/property.dart';

class TenantsPage extends ConsumerStatefulWidget {
  const TenantsPage({super.key});

  @override
  ConsumerState<TenantsPage> createState() => _TenantsPageState();
}

class _TenantsPageState extends ConsumerState<TenantsPage> with TickerProviderStateMixin {
  List<Tenant> _tenants = [];
  bool _isLoading = true;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _loadTenants();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadTenants() async {
    await DataService.initialize();
    setState(() {
      _tenants = DataService.tenants;
      _isLoading = false;
    });
    _animationController.forward();
  }

  Future<void> _refreshTenants() async {
    await _loadTenants();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTenantDialog,
        child: const Icon(Icons.add),
        tooltip: 'Add Tenant',
      ),
      body: FrameworkPage(
        title: 'Tenants',
        slivers: [
          SliverToBoxAdapter(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isTablet = constraints.maxWidth > 600;
                final isLargeScreen = constraints.maxWidth > 900;

                double horizontalPadding;
                if (isLargeScreen) {
                  horizontalPadding = 32;
                } else if (isTablet) {
                  horizontalPadding = 24;
                } else {
                  horizontalPadding = 16;
                }

                return _isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: theme.colorScheme.primary,
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _refreshTenants,
                        color: theme.colorScheme.primary,
                        child: _tenants.isEmpty
                            ? _buildEmptyState()
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                padding: EdgeInsets.all(horizontalPadding),
                                itemCount: _tenants.length,
                                itemBuilder: (context, index) {
                                  return SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(1, 0),
                                      end: Offset.zero,
                                    ).animate(CurvedAnimation(
                                      parent: _animationController,
                                      curve: Interval(
                                        index * 0.1,
                                        (index * 0.1) + 0.3,
                                        curve: Curves.easeOutBack,
                                      ),
                                    )),
                                    child: _buildTenantCard(_tenants[index], isTablet: isTablet),
                                  );
                                },
                              ),
                      );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.people_outline,
                size: 64,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Tenants Yet',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first tenant to get started with property management.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _showAddTenantDialog(),
              icon: const Icon(Icons.add),
              label: const Text('Add Tenant'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTenantCard(Tenant tenant, {bool isTablet = false}) {
    final theme = Theme.of(context);
    final payments = DataService.getPaymentsByTenant(tenant.id);
    final overdueCount = payments.where((p) => p.isOverdue).length;
    final maintenanceCount = DataService.getRequestsByTenant(tenant.id)
        .where((r) => r.status != MaintenanceStatus.completed)
        .length;

    final borderRadius = isTablet ? 20.0 : 16.0;
    final padding = isTablet ? 24.0 : 20.0;
    final marginBottom = isTablet ? 20.0 : 16.0;

    return Container(
      margin: EdgeInsets.only(bottom: marginBottom),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          side: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.1),
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
          onTap: () => _showTenantDetails(tenant),
          onLongPress: () => _showDeleteTenantConfirmation(tenant),
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                      child: Text(
                        tenant.name.split(' ').map((n) => n[0]).take(2).join(),
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tenant.name,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            tenant.email,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: theme.colorScheme.onSurface.withOpacity(0.3),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoChip(
                        'Rent',
                        NumberFormat.currency(symbol: '\$').format(tenant.rentAmount),
                        Icons.attach_money,
                        theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInfoChip(
                        'Overdue',
                        overdueCount.toString(),
                        Icons.warning,
                        overdueCount > 0 ? theme.colorScheme.error : theme.colorScheme.outline,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInfoChip(
                        'Maintenance',
                        maintenanceCount.toString(),
                        Icons.build,
                        maintenanceCount > 0 ? theme.colorScheme.tertiary : theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, String value, IconData icon, Color color) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 16,
            color: color,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.labelLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  void _showTenantDetails(Tenant tenant) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TenantDetailPage(tenant: tenant),
      ),
    );
    if (result == true) {
      ref.read(tenantsProvider.notifier).refresh();
      ref.read(propertiesProvider.notifier).refresh();
      ref.read(rentPaymentsProvider.notifier).refresh();
      ref.read(maintenanceRequestsProvider.notifier).refresh();
      _loadTenants();
    }
  }

  void _showAddTenantDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final rentController = TextEditingController();
    final properties = DataService.properties;
    Property? selectedProperty = properties.isNotEmpty ? properties.first : null;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add New Tenant'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (properties.isNotEmpty) ...[
                  DropdownButtonFormField<Property>(
                    value: selectedProperty,
                    decoration: const InputDecoration(
                      labelText: 'Property',
                      border: OutlineInputBorder(),
                    ),
                    items: properties.map((property) => DropdownMenuItem(
                      value: property,
                      child: Text(property.name),
                    )).toList(),
                    onChanged: (property) => setState(() => selectedProperty = property),
                  ),
                  const SizedBox(height: 16),
                ],
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: rentController,
                  decoration: const InputDecoration(
                    labelText: 'Monthly Rent',
                    border: OutlineInputBorder(),
                    prefixText: '\$',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty &&
                    emailController.text.isNotEmpty &&
                    phoneController.text.isNotEmpty &&
                    rentController.text.isNotEmpty &&
                    selectedProperty != null) {
                  final newTenant = Tenant(
                    id: const Uuid().v4(),
                    name: nameController.text,
                    email: emailController.text,
                    phone: phoneController.text,
                    propertyId: selectedProperty!.id,
                    rentAmount: double.tryParse(rentController.text) ?? 0,
                    moveInDate: DateTime.now(),
                  );

                  await DataService.addTenant(newTenant);
                  await _loadTenants();

                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Tenant added successfully')),
                    );
                  }
                }
              },
              child: const Text('Add Tenant'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteTenantConfirmation(Tenant tenant) async {
    final theme = Theme.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text('Are you sure you want to delete tenant "${tenant.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              DataService.deleteTenant(tenant.id);
              if (mounted) {
                Navigator.pop(context, true);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Tenant "${tenant.name}" deleted successfully')),
                );
              }
              _loadTenants();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      ref.read(tenantsProvider.notifier).refresh();
      ref.read(propertiesProvider.notifier).refresh();
      ref.read(rentPaymentsProvider.notifier).refresh();
      ref.read(maintenanceRequestsProvider.notifier).refresh();
      _loadTenants();
    }
  }
}
