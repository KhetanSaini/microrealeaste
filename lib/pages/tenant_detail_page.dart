import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:microrealeaste/database/data_service.dart';
import 'package:microrealeaste/database/models/tenant.dart';
import 'package:microrealeaste/database/models/property.dart';
import 'package:microrealeaste/database/models/rent_payment.dart';
import 'package:microrealeaste/database/models/maintenance_request.dart';
import 'package:microrealeaste/widgets/tabbed_section.dart';

class TenantDetailPage extends StatefulWidget {
  final Tenant tenant;

  const TenantDetailPage({super.key, required this.tenant});

  @override
  State<TenantDetailPage> createState() => _TenantDetailPageState();
}

class _TenantDetailPageState extends State<TenantDetailPage> {
  Property? _property;
  List<RentPayment> _payments = [];
  List<MaintenanceRequest> _maintenanceRequests = [];
  late Tenant _tenant;
  bool _editingTenantInfo = false;
  String? _selectedPaymentId;
  String? _selectedMaintenanceRequestId;

  @override
  void initState() {
    super.initState();
    _tenant = widget.tenant;
    _loadData();
  }

  void _loadData() {
    setState(() {
      _property = DataService.getPropertyById(widget.tenant.propertyId);
      _payments = DataService.getPaymentsByTenant(widget.tenant.id);
      _maintenanceRequests = DataService.getRequestsByTenant(widget.tenant.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(widget.tenant.name),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'delete':
                  _deleteTenant();
                  break;
                case 'contact':
                  _contactTenant();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'contact',
                child: Row(
                  children: [
                    Icon(Icons.phone),
                    SizedBox(width: 8),
                    Text('Contact'),
                  ],
                ),
              ),
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
          Tab(text: 'Payments'),
          Tab(text: 'Maintenance'),
        ],
        children: [
          _buildDetailsTab(),
          _buildPaymentsTab(),
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
          // Tenant Info Card
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.1)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _editingTenantInfo
                  ? _TenantInfoEditForm(
                      tenant: _tenant,
                      onSave: (updated) {
                        setState(() {
                          _tenant = updated;
                          _editingTenantInfo = false;
                        });
                      },
                      onCancel: () => setState(() => _editingTenantInfo = false),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                              child: Text(
                                _tenant.name.split(' ').map((e) => e[0]).take(2).join(),
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _tenant.name,
                                    style: theme.textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _tenant.email,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit),
                              tooltip: 'Edit Tenant Info',
                              onPressed: () {
                                setState(() {
                                  _editingTenantInfo = true;
                                });
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow('Phone', _tenant.phone, Icons.phone),
                        _buildInfoRow('Property', _property?.name ?? 'Unknown', Icons.home),
                        _buildInfoRow('Rent Amount', NumberFormat.currency(symbol: '\$').format(_tenant.rentAmount), Icons.attach_money),
                        _buildInfoRow('Move-in Date', DateFormat('MMM dd, yyyy').format(_tenant.moveInDate), Icons.calendar_today),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 16),
          // Property Info Card
          if (_property != null) ...[
            Text(
              'Property Information',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.1)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _property!.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow('Address', _property!.fullAddress, Icons.location_on),
                    _buildInfoRow('Type', _property!.propertyTypeDisplayName, Icons.apartment),
                    _buildInfoRow('Bedrooms', '${_property!.bedrooms}', Icons.bed),
                    _buildInfoRow('Bathrooms', '${_property!.bathrooms}', Icons.bathtub),
                    if (_property!.squareFeet != null)
                      _buildInfoRow('Square Feet', '${_property!.squareFeet!.toInt()}', Icons.square_foot),
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

  Widget _buildPaymentsTab() {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        // Add payment button
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _addPayment,
              icon: const Icon(Icons.add),
              label: const Text('Add Payment'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
        // Payment list or empty state
        Expanded(
          child: _payments.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.payment_outlined,
                        size: 64,
                        color: theme.colorScheme.onSurface.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No payment history',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _payments.length,
                  itemBuilder: (context, index) {
                    final payment = _payments[index];
                    return _buildPaymentCard(payment);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildPaymentCard(RentPayment payment) {
    final theme = Theme.of(context);
    Color statusColor;
    String statusText;
    final isSelected = _selectedPaymentId == payment.id;
    
    switch (payment.status) {
      case PaymentStatus.paid:
        statusColor = theme.colorScheme.secondary;
        statusText = 'PAID';
        break;
      case PaymentStatus.overdue:
        statusColor = theme.colorScheme.error;
        statusText = 'OVERDUE';
        break;
      case PaymentStatus.upcoming:
        statusColor = theme.colorScheme.primary;
        statusText = 'UPCOMING';
        break;
      case PaymentStatus.pending:
        statusColor = theme.colorScheme.tertiary;
        statusText = 'PENDING';
        break;
    }
    
    return GestureDetector(
      onDoubleTap: () {
        setState(() {
          _selectedPaymentId = payment.id;
        });
      },
      onLongPress: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Payment'),
            content: const Text('Are you sure you want to delete this payment?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  await DataService.deleteRentPayment(payment.id);
                  _loadData();
                  if (mounted) Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Payment deleted')),
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
        elevation: isSelected ? 4 : 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outline.withOpacity(0.1),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      NumberFormat.currency(symbol: '\$').format(payment.amount),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Due: ${DateFormat('MMM dd, yyyy').format(payment.dueDate)}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    if (payment.paidDate != null)
                      Text(
                        'Paid: ${DateFormat('MMM dd, yyyy').format(payment.paidDate!)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusText,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
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
    final isSelected = _selectedMaintenanceRequestId == request.id;

    return GestureDetector(
      onDoubleTap: () {
        setState(() {
          _selectedMaintenanceRequestId = request.id;
        });
      },
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
        elevation: isSelected ? 4 : 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outline.withOpacity(0.1),
            width: isSelected ? 2 : 1,
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
                    '${_getPriorityDisplayName(request.priority)} Priority',
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
            ],
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
        backgroundColor = theme.colorScheme.tertiary.withOpacity(0.1);
        textColor = theme.colorScheme.tertiary;
        break;
      case MaintenanceStatus.inProgress:
        backgroundColor = theme.colorScheme.primary.withOpacity(0.1);
        textColor = theme.colorScheme.primary;
        break;
      case MaintenanceStatus.completed:
        backgroundColor = theme.colorScheme.secondary.withOpacity(0.1);
        textColor = theme.colorScheme.secondary;
        break;
      case MaintenanceStatus.cancelled:
        backgroundColor = theme.colorScheme.error.withOpacity(0.1);
        textColor = theme.colorScheme.error;
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

  Color _getPriorityColor(MaintenancePriority priority) {
    final theme = Theme.of(context);
    switch (priority) {
      case MaintenancePriority.urgent:
        return theme.colorScheme.error;
      case MaintenancePriority.high:
        return theme.colorScheme.tertiary;
      case MaintenancePriority.medium:
        return theme.colorScheme.primary;
      case MaintenancePriority.low:
        return theme.colorScheme.secondary;
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


  void _deleteTenant() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Tenant'),
        content: Text('Are you sure you want to delete ${widget.tenant.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await DataService.deleteTenant(widget.tenant.id);
              if (mounted) {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context, true); // Go back to tenant list and signal refresh
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _contactTenant() {
    // TODO: Implement contact functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Contact ${widget.tenant.name} at ${widget.tenant.phone}')),
    );
  }

  void _addMaintenanceRequest() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    MaintenancePriority selectedPriority = MaintenancePriority.medium;

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
                    labelText: 'Issue Title',
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
                    tenantId: widget.tenant.id,
                    propertyId: widget.tenant.propertyId,
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
                      const SnackBar(content: Text('Maintenance request submitted successfully')),
                    );
                  }
                }
              },
              child: const Text('Submit Request'),
            ),
          ],
        ),
      ),
    );
  }

  void _addPayment() {
    final amountController = TextEditingController();
    final notesController = TextEditingController();
    DateTime? dueDate;
    DateTime? paidDate;
    PaymentStatus selectedStatus = PaymentStatus.paid;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Payment'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text('Due Date: ' + (dueDate != null ? DateFormat('MMM dd, yyyy').format(dueDate!) : 'Not set')),
                    ),
                    TextButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: dueDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) setState(() => dueDate = picked);
                      },
                      child: const Text('Pick'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text('Paid Date: ' + (paidDate != null ? DateFormat('MMM dd, yyyy').format(paidDate!) : 'Not set')),
                    ),
                    TextButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: paidDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) setState(() => paidDate = picked);
                      },
                      child: const Text('Pick'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<PaymentStatus>(
                  value: selectedStatus,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                  ),
                  items: PaymentStatus.values
                      .map((status) => DropdownMenuItem(
                            value: status,
                            child: Text(status.name),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedStatus = value ?? PaymentStatus.paid;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes (optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
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
                final amount = double.tryParse(amountController.text.trim()) ?? 0;
                if (amount <= 0 || dueDate == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a valid amount and due date.')),
                  );
                  return;
                }
                final newPayment = RentPayment(
                  id: const Uuid().v4(),
                  tenantId: widget.tenant.id,
                  amount: amount,
                  dueDate: dueDate!,
                  paidDate: paidDate,
                  status: selectedStatus,
                  notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
                );
                await DataService.addRentPayment(newPayment);
                _loadData();
                if (mounted) Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Payment added successfully')),
                );
              },
              child: const Text('Add Payment'),
            ),
          ],
        ),
      ),
    );
  }
}

// Inline edit form for tenant info
class _TenantInfoEditForm extends StatefulWidget {
  final Tenant tenant;
  final void Function(Tenant) onSave;
  final VoidCallback onCancel;
  const _TenantInfoEditForm({required this.tenant, required this.onSave, required this.onCancel});
  @override
  State<_TenantInfoEditForm> createState() => _TenantInfoEditFormState();
}
class _TenantInfoEditFormState extends State<_TenantInfoEditForm> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController rentAmountController;
  late DateTime moveInDate;
  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.tenant.name);
    emailController = TextEditingController(text: widget.tenant.email);
    phoneController = TextEditingController(text: widget.tenant.phone);
    rentAmountController = TextEditingController(text: widget.tenant.rentAmount.toString());
    moveInDate = widget.tenant.moveInDate;
  }
  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    rentAmountController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Column(
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
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(onPressed: widget.onCancel, child: const Text('Cancel')),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                final updated = widget.tenant.copyWith(
                  name: nameController.text,
                  email: emailController.text,
                  phone: phoneController.text,
                  rentAmount: double.tryParse(rentAmountController.text) ?? widget.tenant.rentAmount,
                  moveInDate: moveInDate,
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
