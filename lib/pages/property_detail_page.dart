import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:microrealeaste/database/data_service.dart';
import 'package:microrealeaste/database/models/property.dart';
import 'package:microrealeaste/database/models/tenant.dart';
import 'package:microrealeaste/database/models/maintenance_request.dart';
import 'package:microrealeaste/pages/tenant_detail_page.dart';
import 'package:microrealeaste/widgets/tabbed_section.dart';
import 'package:microrealeaste/providers/auth_provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class PropertyDetailPage extends ConsumerStatefulWidget {
  final Property property;

  const PropertyDetailPage({super.key, required this.property});

  @override
  ConsumerState<PropertyDetailPage> createState() => _PropertyDetailPageState();
}

class _PropertyDetailPageState extends ConsumerState<PropertyDetailPage> {
  List<Tenant> _tenants = [];
  List<MaintenanceRequest> _maintenanceRequests = [];
  late Property _property;
  bool _editingBasicInfo = false;
  bool _editingFinancial = false;
  bool _editingAmenities = false;

  @override
  void initState() {
    super.initState();
    _property = widget.property;
    _loadData();
  }

  void _loadData() {
    setState(() {
      _tenants = DataService.getTenantsByProperty(_property.id);
      _maintenanceRequests = DataService.getRequestsByProperty(_property.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = ref.read(currentUserProvider);
    final currentOrgId = user?.currentOrganizationId;
    final canManageProperties = user?.canManageProperties ?? false;
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(_property.name),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'delete':
                  _deleteProperty();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: TabbedSection(
        tabs: const [
          Tab(text: 'Details'),
          Tab(text: 'Tenants'),
          Tab(text: 'Maintenance'),
        ],
        children: [
          _buildDetailsTab(),
          _buildTenantsTab(),
          _buildMaintenanceTab(),
        ],
      ),
    );
  }

  Widget _buildDetailsTab() {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Property Images (placeholder)
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.image_outlined,
                    size: 48,
                    color: theme.colorScheme.onSurface.withOpacity(0.4),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Property Images',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Basic Info Card
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.1)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _editingBasicInfo
                  ? _BasicInfoEditForm(
                      property: _property,
                      onSave: (updated) {
                        setState(() {
                          _property = updated;
                          _editingBasicInfo = false;
                        });
                      },
                      onCancel: () => setState(() => _editingBasicInfo = false),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Property Information',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit),
                              tooltip: 'Edit Details',
                              onPressed: () {
                                setState(() {
                                  _editingBasicInfo = true;
                                });
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow('Type', _property.propertyTypeDisplayName, Icons.apartment),
                        _buildInfoRow('Status', _property.statusDisplayName, Icons.info),
                        _buildInfoRow('Address', _property.fullAddress, Icons.location_on),
                        _buildInfoRow('Bedrooms', '${_property.bedrooms}', Icons.bed),
                        _buildInfoRow('Bathrooms', '${_property.bathrooms}', Icons.bathtub),
                        if (_property.squareFeet != null)
                          _buildInfoRow('Square Feet', '${_property.squareFeet!.toInt()}', Icons.square_foot),
                        if (_property.yearBuilt != null)
                          _buildInfoRow('Year Built', '${_property.yearBuilt}', Icons.calendar_today),
                        _buildInfoRow('Parking Spaces', '${_property.parkingSpaces}', Icons.local_parking),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 16),
          // Financial Info Card
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.1)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _editingFinancial
                  ? _FinancialInfoEditForm(
                      property: _property,
                      onSave: (updated) {
                        setState(() {
                          _property = updated;
                          _editingFinancial = false;
                        });
                      },
                      onCancel: () => setState(() => _editingFinancial = false),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Financial Information',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit),
                              tooltip: 'Edit Financial',
                              onPressed: () {
                                setState(() {
                                  _editingFinancial = true;
                                });
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (_property.marketValue != null)
                          _buildInfoRow('Market Value', NumberFormat.currency(symbol: '\$').format(_property.marketValue), Icons.trending_up),
                        if (_property.purchasePrice != null)
                          _buildInfoRow('Purchase Price', NumberFormat.currency(symbol: '\$').format(_property.purchasePrice), Icons.attach_money),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 16),
          // Amenities Card
          if (_property.amenities.isNotEmpty || _editingAmenities) ...[
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.1)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _editingAmenities
                    ? _AmenitiesEditForm(
                        property: _property,
                        onSave: (updated) {
                          setState(() {
                            _property = updated;
                            _editingAmenities = false;
                          });
                        },
                        onCancel: () => setState(() => _editingAmenities = false),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Amenities',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit),
                                tooltip: 'Edit Amenities',
                                onPressed: () {
                                  setState(() {
                                    _editingAmenities = true;
                                  });
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _property.amenities.map((amenity) => Chip(
                              label: Text(amenity),
                              backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                              labelStyle: TextStyle(color: theme.colorScheme.primary),
                            )).toList(),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTenantsTab() {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        // Add tenant button
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _addTenant(),
              icon: const Icon(Icons.add),
              label: const Text('Add Tenant'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
        
        // Tenants list
        Expanded(
          child: _tenants.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 64,
                        color: theme.colorScheme.onSurface.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No tenants',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _tenants.length,
                  itemBuilder: (context, index) {
                    final tenant = _tenants[index];
                    return _buildTenantCard(tenant);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildTenantCard(Tenant tenant) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onLongPress: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Remove Tenant from Property'),
            content: const Text('Are you sure you want to remove this tenant from the property? This will not delete the tenant.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  final updatedTenant = tenant.copyWith(propertyId: '');
                  await DataService.updateTenant(updatedTenant);
                  _loadData();
                  if (mounted) Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Tenant removed from property')),
                  );
                },
                child: const Text('Remove', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.1)),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: CircleAvatar(
            backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
            child: Text(
              tenant.name.split(' ').map((e) => e[0]).take(2).join(),
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(
            tenant.name,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(tenant.email),
              Text(
                'Rent: ${NumberFormat.currency(symbol: '\$').format(tenant.rentAmount)}',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TenantDetailPage(tenant: tenant),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMaintenanceTab() {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        // Add maintenance request button
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _addMaintenanceRequest(),
              icon: const Icon(Icons.add),
              label: const Text('Add Maintenance Request'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
        
        // Maintenance requests list
        Expanded(
          child: _maintenanceRequests.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.build_outlined,
                        size: 64,
                        color: theme.colorScheme.onSurface.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No maintenance requests',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _maintenanceRequests.length,
                  itemBuilder: (context, index) {
                    final request = _maintenanceRequests[index];
                    return _buildMaintenanceCard(request);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildMaintenanceCard(MaintenanceRequest request) {
    final theme = Theme.of(context);

    return GestureDetector(
      onLongPress: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Maintenance Request'),
            content: const Text('Are you sure you want to delete this maintenance request?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  await DataService.deleteMaintenanceRequest(request.id);
                  _loadData();
                  if (mounted) Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Maintenance request deleted')),
                  );
                },
                child: const Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.1)),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showMaintenanceDetails(request),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        request.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    _buildStatusChip(request.status),
                  ],
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
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.flag,
                      size: 16,
                      color: _getPriorityColor(request.priority),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      ' ${_getPriorityDisplayName(request.priority)} Priority',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: _getPriorityColor(request.priority),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Created: ${DateFormat('MMM dd, yyyy').format(request.createdDate)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
                if (request.tenantId.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.person,
                        size: 16,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Tenant: ${_getTenantName(request.tenantId)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
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

  Widget _buildStatusChip(MaintenanceStatus status) {
    final theme = Theme.of(context);
    Color backgroundColor;
    Color textColor;
    
    switch (status) {
      case MaintenanceStatus.pending:
        backgroundColor = Colors.orange.withOpacity(0.1);
        textColor = Colors.orange.shade700;
        break;
      case MaintenanceStatus.inProgress:
        backgroundColor = Colors.blue.withOpacity(0.1);
        textColor = Colors.blue.shade700;
        break;
      case MaintenanceStatus.completed:
        backgroundColor = Colors.green.withOpacity(0.1);
        textColor = Colors.green.shade700;
        break;
      case MaintenanceStatus.cancelled:
        backgroundColor = Colors.red.withOpacity(0.1);
        textColor = Colors.red.shade700;
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }


  void _deleteProperty() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Property'),
        content: Text('Are you sure you want to delete ${_property.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await DataService.deleteProperty(_property.id);
              if (mounted) {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context, true); // Go back to property list and signal refresh
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _addTenant() async {
    // Get all tenants not already assigned to this property
    final allTenants = DataService.tenants;
    final propertyTenantIds = _tenants.map((t) => t.id).toSet();
    final availableTenants = allTenants.where((t) => t.propertyId != _property.id && !propertyTenantIds.contains(t.id)).toList();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Add Tenant'),
            content: SizedBox(
              width: 350,
              child: availableTenants.isEmpty
                  ? const Text('No available tenants. Create a new tenant instead.')
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: availableTenants.length,
                      itemBuilder: (context, index) {
                        final tenant = availableTenants[index];
                        return ListTile(
                          leading: CircleAvatar(
                            child: Text(tenant.name.split(' ').map((e) => e[0]).take(2).join()),
                          ),
                          title: Text(tenant.name),
                          subtitle: Text(tenant.email),
                          onTap: () async {
                            final updatedTenant = tenant.copyWith(propertyId: _property.id);
                            await DataService.updateTenant(updatedTenant);
                            _loadData();
                            if (mounted) Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Tenant "${tenant.name}" assigned to property.')),
                            );
                          },
                        );
                      },
                    ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showCreateTenantDialog();
                },
                child: const Text('Create New Tenant'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showCreateTenantDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final rentAmountController = TextEditingController();
    DateTime moveInDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Create New Tenant'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Phone'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: rentAmountController,
                  decoration: const InputDecoration(labelText: 'Rent Amount'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('Move-in Date:'),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: moveInDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() => moveInDate = picked);
                        }
                      },
                      child: Text(DateFormat('MMM dd, yyyy').format(moveInDate)),
                    ),
                  ],
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
                final name = nameController.text.trim();
                final email = emailController.text.trim();
                final phone = phoneController.text.trim();
                final rentAmount = double.tryParse(rentAmountController.text.trim()) ?? 0.0;
                if (name.isEmpty || email.isEmpty || phone.isEmpty || rentAmount <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all fields with valid values')),
                  );
                  return;
                }
                final newTenant = Tenant(
                  id: const Uuid().v4(),
                  name: name,
                  email: email,
                  phone: phone,
                  propertyId: _property.id,
                  rentAmount: rentAmount,
                  moveInDate: moveInDate,
                );
                await DataService.addTenant(newTenant);
                _loadData();
                if (mounted) Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tenant added successfully')),
                );
              },
              child: const Text('Add Tenant'),
            ),
          ],
        ),
      ),
    );
  }

  void _addMaintenanceRequest() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    MaintenancePriority selectedPriority = MaintenancePriority.medium;
    String? selectedTenantId;

    // Get tenants for this property
    final propertyTenants = _tenants;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Maintenance Request'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<MaintenancePriority>(
                  value: selectedPriority,
                  decoration: const InputDecoration(
                    labelText: 'Priority',
                    border: OutlineInputBorder(),
                  ),
                  items: MaintenancePriority.values
                      .map((priority) => DropdownMenuItem(
                            value: priority,
                            child: Text(_getPriorityDisplayName(priority)),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedPriority = value ?? MaintenancePriority.medium;
                    });
                  },
                ),
                const SizedBox(height: 16),
                if (propertyTenants.isNotEmpty)
                  DropdownButtonFormField<String>(
                    value: selectedTenantId,
                    decoration: const InputDecoration(
                      labelText: 'Tenant (Optional)',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('General Property Issue'),
                      ),
                      ...propertyTenants.map((tenant) => DropdownMenuItem(
                            value: tenant.id,
                            child: Text(tenant.name),
                          )),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedTenantId = value;
                      });
                    },
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
                if (titleController.text.isNotEmpty &&
                    descriptionController.text.isNotEmpty) {
                  // Create new maintenance request
                  final newRequest = MaintenanceRequest(
                    id: const Uuid().v4(),
                    tenantId: selectedTenantId ?? '', // Empty string for general property issues
                    propertyId: _property.id,
                    title: titleController.text,
                    description: descriptionController.text,
                    priority: selectedPriority,
                    status: MaintenanceStatus.pending,
                    createdDate: DateTime.now(),
                  );

                  // Add to data service
                  await DataService.addMaintenanceRequest(newRequest);

                  // Refresh the data
                  _loadData();

                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Maintenance request added successfully')),
                    );
                  }
                }
              },
              child: const Text('Add Request'),
            ),
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor(MaintenancePriority priority) {
    switch (priority) {
      case MaintenancePriority.urgent:
        return Colors.red;
      case MaintenancePriority.high:
        return Colors.orange;
      case MaintenancePriority.medium:
        return Colors.blue;
      case MaintenancePriority.low:
        return Colors.green;
    }
  }

  String _getPriorityDisplayName(MaintenancePriority priority) {
    switch (priority) {
      case MaintenancePriority.urgent:
        return 'Urgent';
      case MaintenancePriority.high:
        return 'High';
      case MaintenancePriority.medium:
        return 'Medium';
      case MaintenancePriority.low:
        return 'Low';
    }
  }

  String _getTenantName(String tenantId) {
    final tenant = _tenants.firstWhere(
      (t) => t.id == tenantId,
      orElse: () => _tenants.first,
    );
    return tenant.name;
  }

  void _showMaintenanceDetails(MaintenanceRequest request) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(request.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Description:',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(request.description),
            const SizedBox(height: 16),
            Text(
              'Priority: ${_getPriorityDisplayName(request.priority)}',
              style: TextStyle(
                color: _getPriorityColor(request.priority),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text('Status: ${request.status.name}'),
            const SizedBox(height: 8),
            Text('Created: ${DateFormat('MMM dd, yyyy').format(request.createdDate)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (request.status != MaintenanceStatus.completed)
            ElevatedButton(
              onPressed: () => _updateMaintenanceStatus(request),
              child: const Text('Update Status'),
            ),
        ],
      ),
    );
  }

  void _updateMaintenanceStatus(MaintenanceRequest request) {
    Navigator.pop(context); // Close details dialog

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: MaintenanceStatus.values.map((status) =>
            ListTile(
              title: Text(status.name),
              onTap: () async {
                final updatedRequest = MaintenanceRequest(
                  id: request.id,
                  tenantId: request.tenantId,
                  propertyId: request.propertyId,
                  title: request.title,
                  description: request.description,
                  priority: request.priority,
                  status: status,
                  createdDate: request.createdDate,
                );

                await DataService.updateMaintenanceRequest(updatedRequest);
                _loadData();

                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Status updated to ${status.name}')),
                  );
                }
              },
            ),
          ).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}

// Inline edit forms for each section
class _BasicInfoEditForm extends StatefulWidget {
  final Property property;
  final void Function(Property) onSave;
  final VoidCallback onCancel;
  const _BasicInfoEditForm({required this.property, required this.onSave, required this.onCancel});
  @override
  State<_BasicInfoEditForm> createState() => _BasicInfoEditFormState();
}
class _BasicInfoEditFormState extends State<_BasicInfoEditForm> {
  late TextEditingController nameController;
  late TextEditingController descriptionController;
  late TextEditingController addressController;
  late TextEditingController cityController;
  late TextEditingController stateController;
  late TextEditingController zipCodeController;
  late TextEditingController countryController;
  late TextEditingController bedroomsController;
  late TextEditingController bathroomsController;
  late TextEditingController squareFeetController;
  late TextEditingController yearBuiltController;
  late TextEditingController parkingSpacesController;
  PropertyType? selectedType;
  PropertyStatus? selectedStatus;
  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.property.name);
    descriptionController = TextEditingController(text: widget.property.description);
    addressController = TextEditingController(text: widget.property.address);
    cityController = TextEditingController(text: widget.property.city);
    stateController = TextEditingController(text: widget.property.state);
    zipCodeController = TextEditingController(text: widget.property.zipCode);
    countryController = TextEditingController(text: widget.property.country);
    bedroomsController = TextEditingController(text: widget.property.bedrooms.toString());
    bathroomsController = TextEditingController(text: widget.property.bathrooms.toString());
    squareFeetController = TextEditingController(text: widget.property.squareFeet?.toString() ?? '');
    yearBuiltController = TextEditingController(text: widget.property.yearBuilt?.toString() ?? '');
    parkingSpacesController = TextEditingController(text: widget.property.parkingSpaces.toString());
    selectedType = widget.property.propertyType;
    selectedStatus = widget.property.propertyStatus;
  }
  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    addressController.dispose();
    cityController.dispose();
    stateController.dispose();
    zipCodeController.dispose();
    countryController.dispose();
    bedroomsController.dispose();
    bathroomsController.dispose();
    squareFeetController.dispose();
    yearBuiltController.dispose();
    parkingSpacesController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Property Name'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: descriptionController,
          decoration: const InputDecoration(labelText: 'Description'),
          maxLines: 2,
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<PropertyType>(
          value: selectedType,
          decoration: const InputDecoration(labelText: 'Property Type'),
          items: PropertyType.values.map((type) => DropdownMenuItem(
            value: type,
            child: Text(type.name),
          )).toList(),
          onChanged: (type) => setState(() => selectedType = type),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: addressController,
          decoration: const InputDecoration(labelText: 'Address'),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: cityController,
                decoration: const InputDecoration(labelText: 'City'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: stateController,
                decoration: const InputDecoration(labelText: 'State'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: zipCodeController,
                decoration: const InputDecoration(labelText: 'Zip Code'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: countryController,
                decoration: const InputDecoration(labelText: 'Country'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: bedroomsController,
                decoration: const InputDecoration(labelText: 'Bedrooms'),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: bathroomsController,
                decoration: const InputDecoration(labelText: 'Bathrooms'),
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: squareFeetController,
                decoration: const InputDecoration(labelText: 'Square Feet'),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: yearBuiltController,
                decoration: const InputDecoration(labelText: 'Year Built'),
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: parkingSpacesController,
          decoration: const InputDecoration(labelText: 'Parking Spaces'),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(onPressed: widget.onCancel, child: const Text('Cancel')),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                final updated = widget.property.copyWith(
                  name: nameController.text,
                  description: descriptionController.text,
                  propertyType: selectedType,
                  address: addressController.text,
                  city: cityController.text,
                  state: stateController.text,
                  zipCode: zipCodeController.text,
                  country: countryController.text,
                  bedrooms: int.tryParse(bedroomsController.text) ?? widget.property.bedrooms,
                  bathrooms: int.tryParse(bathroomsController.text) ?? widget.property.bathrooms,
                  squareFeet: double.tryParse(squareFeetController.text),
                  yearBuilt: int.tryParse(yearBuiltController.text),
                  parkingSpaces: int.tryParse(parkingSpacesController.text) ?? widget.property.parkingSpaces,
                );
                widget.onSave(updated);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ],
    );
  }
}

class _FinancialInfoEditForm extends StatefulWidget {
  final Property property;
  final void Function(Property) onSave;
  final VoidCallback onCancel;
  const _FinancialInfoEditForm({required this.property, required this.onSave, required this.onCancel});
  @override
  State<_FinancialInfoEditForm> createState() => _FinancialInfoEditFormState();
}
class _FinancialInfoEditFormState extends State<_FinancialInfoEditForm> {
  late TextEditingController marketValueController;
  late TextEditingController purchasePriceController;
  @override
  void initState() {
    super.initState();
    marketValueController = TextEditingController(text: widget.property.marketValue?.toString() ?? '');
    purchasePriceController = TextEditingController(text: widget.property.purchasePrice?.toString() ?? '');
  }
  @override
  void dispose() {
    marketValueController.dispose();
    purchasePriceController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: marketValueController,
          decoration: const InputDecoration(labelText: 'Market Value'),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: purchasePriceController,
          decoration: const InputDecoration(labelText: 'Purchase Price'),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(onPressed: widget.onCancel, child: const Text('Cancel')),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                final updated = widget.property.copyWith(
                  marketValue: double.tryParse(marketValueController.text),
                  purchasePrice: double.tryParse(purchasePriceController.text),
                );
                widget.onSave(updated);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ],
    );
  }
}

class _AmenitiesEditForm extends StatefulWidget {
  final Property property;
  final void Function(Property) onSave;
  final VoidCallback onCancel;
  const _AmenitiesEditForm({required this.property, required this.onSave, required this.onCancel});
  @override
  State<_AmenitiesEditForm> createState() => _AmenitiesEditFormState();
}
class _AmenitiesEditFormState extends State<_AmenitiesEditForm> {
  late List<String> amenities;
  @override
  void initState() {
    super.initState();
    amenities = List<String>.from(widget.property.amenities);
  }
  void _addAmenity(String amenity) {
    setState(() {
      amenities.add(amenity);
    });
  }
  void _removeAmenity(String amenity) {
    setState(() {
      amenities.remove(amenity);
    });
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...amenities.map((amenity) => Chip(
                  label: Text(amenity),
                  onDeleted: () => _removeAmenity(amenity),
                )),
            ActionChip(
              label: const Text('Add Amenity'),
              onPressed: () async {
                final controller = TextEditingController();
                final amenity = await showDialog<String>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Add Amenity'),
                    content: TextField(
                      controller: controller,
                      decoration: const InputDecoration(labelText: 'Amenity'),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, controller.text),
                        child: const Text('Add'),
                      ),
                    ],
                  ),
                );
                if (amenity != null && amenity.isNotEmpty) {
                  _addAmenity(amenity);
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(onPressed: widget.onCancel, child: const Text('Cancel')),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                final updated = widget.property.copyWith(
                  amenities: amenities,
                );
                widget.onSave(updated);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ],
    );
  }
}
