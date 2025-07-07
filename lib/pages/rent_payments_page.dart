import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../database/data_service.dart';
import '../database/models/rent_payment.dart';
import '../database/models/tenant.dart';
import '../widgets/framework_page.dart';

class RentPaymentsPage extends StatefulWidget {
  const RentPaymentsPage({super.key});

  @override
  State<RentPaymentsPage> createState() => _RentPaymentsPageState();
}

class _RentPaymentsPageState extends State<RentPaymentsPage> with TickerProviderStateMixin {
  List<RentPayment> _payments = [];
  List<Tenant> _tenants = [];
  bool _isLoading = true;
  String _selectedFilter = 'all';
  late AnimationController _animationController;
  int _selectedTenantTab = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _loadData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await DataService.initialize();
    setState(() {
      _payments = DataService.rentPayments;
      _tenants = DataService.tenants;
      _isLoading = false;
    });
    _animationController.forward();
  }

  Future<void> _refreshData() async {
    await _loadData();
  }

  List<RentPayment> get _filteredPayments {
    List<RentPayment> filtered = _payments;
    // Filter by tenant tab
    if (_selectedTenantTab > 0 && _selectedTenantTab - 1 < _tenants.length) {
      final tenantId = _tenants[_selectedTenantTab - 1].id;
      filtered = filtered.where((p) => p.tenantId == tenantId).toList();
    }
    // Filter by status
    switch (_selectedFilter) {
      case 'overdue':
        return filtered.where((p) => p.isOverdue).toList();
      case 'paid':
        return filtered.where((p) => p.status == PaymentStatus.paid).toList();
      case 'upcoming':
        return filtered.where((p) => p.status == PaymentStatus.upcoming).toList();
      default:
        return filtered;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_isLoading) {
      return FrameworkPage(
        title: 'Rent Payments',
        actions: [
          IconButton(
            icon: Icon(
              Icons.add,
              color: theme.colorScheme.primary,
            ),
            onPressed: () => _showAddPaymentDialog(),
          ),
        ],
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      );
    }
    return DefaultTabController(
      length: _tenants.length + 1,
      initialIndex: _selectedTenantTab,
      child: Builder(
        builder: (context) {
          return FrameworkPage(
            title: 'Rent Payments',
            actions: [
              IconButton(
                icon: Icon(
                  Icons.add,
                  color: theme.colorScheme.primary,
                ),
                onPressed: () => _showAddPaymentDialog(),
              ),
            ],
            slivers: [
              SliverToBoxAdapter(
                child: TabBar(
                  isScrollable: true,
                  onTap: (index) {
                    setState(() => _selectedTenantTab = index);
                  },
                  tabs: [
                    const Tab(text: 'All'),
                    ..._tenants.map((tenant) => Tab(text: tenant.name)).toList(),
                  ],
                ),
              ),
              SliverToBoxAdapter(child: _buildFilterChips()),
              SliverToBoxAdapter(child: _buildStatsRow()),
              if (_filteredPayments.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildEmptyState(),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildPaymentCard(_filteredPayments[index], isTablet: false),
                    childCount: _filteredPayments.length,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterChips() {
    final theme = Theme.of(context);
    final filters = [
      {'key': 'all', 'label': 'All'},
      {'key': 'overdue', 'label': 'Overdue'},
      {'key': 'paid', 'label': 'Paid'},
      {'key': 'upcoming', 'label': 'Upcoming'},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((filter) {
            final isSelected = _selectedFilter == filter['key'];
            return Container(
              margin: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(
                  filter['label']!,
                  style: TextStyle(
                    color: isSelected
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedFilter = filter['key']!;
                  });
                },
                backgroundColor: theme.colorScheme.surface,
                selectedColor: theme.colorScheme.primary,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outline.withOpacity(0.3),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    final theme = Theme.of(context);
    final totalAmount = _payments.fold<double>(0, (sum, p) => sum + p.amount);
    final paidAmount = _payments
        .where((p) => p.status == PaymentStatus.paid)
        .fold<double>(0, (sum, p) => sum + p.amount);
    final overdueAmount = _payments
        .where((p) => p.isOverdue)
        .fold<double>(0, (sum, p) => sum + p.amount);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Total',
              NumberFormat.currency(symbol: ' 4').format(totalAmount),
              theme.colorScheme.primary,
              Icons.account_balance_wallet_outlined,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Collected',
              NumberFormat.currency(symbol: ' 4').format(paidAmount),
              theme.colorScheme.secondary,
              Icons.check_circle_outline,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Overdue',
              NumberFormat.currency(symbol: ' 4').format(overdueAmount),
              theme.colorScheme.error,
              Icons.warning_outlined,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
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
                Icons.payment_outlined,
                size: 64,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Payments Found',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _selectedFilter == 'all'
                  ? 'No rent payments have been recorded yet.'
                  : 'No payments match the selected filter.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _showAddPaymentDialog(),
              icon: const Icon(Icons.add),
              label: const Text('Record Payment'),
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

  Widget _buildPaymentCard(RentPayment payment, {bool isTablet = false}) {
    final theme = Theme.of(context);
    final tenant = _tenants.firstWhere(
          (t) => t.id == payment.tenantId,
      orElse: () => Tenant(
        id: '',
        name: 'Unknown Tenant',
        email: '',
        phone: '',
        propertyId: '',
        rentAmount: 0,
        moveInDate: DateTime.now(),
      ),
    );

    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (payment.status) {
      case PaymentStatus.paid:
        statusColor = theme.colorScheme.secondary;
        statusIcon = Icons.check_circle;
        statusText = 'Paid';
        break;
      case PaymentStatus.overdue:
        statusColor = theme.colorScheme.error;
        statusIcon = Icons.warning;
        statusText = 'Overdue';
        break;
      case PaymentStatus.upcoming:
        statusColor = theme.colorScheme.tertiary;
        statusIcon = Icons.schedule;
        statusText = 'Upcoming';
        break;
      case PaymentStatus.pending:
        statusColor = theme.colorScheme.primary;
        statusIcon = Icons.hourglass_empty;
        statusText = 'Pending';
        break;
    }

    if (payment.isOverdue && payment.status != PaymentStatus.paid) {
      statusColor = theme.colorScheme.error;
      statusIcon = Icons.warning;
      statusText = '${payment.daysOverdue}d Overdue';
    }

    final borderRadius = isTablet ? 20.0 : 16.0;
    final padding = isTablet ? 24.0 : 20.0;
    final marginBottom = isTablet ? 20.0 : 16.0;

    return GestureDetector(
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
      child: SizedBox(
        height: 160,
        child: Card(
          elevation: 0,
          margin: EdgeInsets.only(bottom: marginBottom),
          color: theme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            side: BorderSide(
              color: theme.colorScheme.outline.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: InkWell(
            onTap: () => _showPaymentDetails(payment, tenant),
            borderRadius: BorderRadius.circular(borderRadius),
            child: Container(
              padding: EdgeInsets.all(padding),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(borderRadius),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    statusColor.withOpacity(0.05),
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
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          statusIcon,
                          color: statusColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tenant.name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              tenant.propertyId,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
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
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Amount',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                          Text(
                            NumberFormat.currency(symbol: ' 4').format(payment.amount),
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Due Date',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                          Text(
                            DateFormat('MMM d, yyyy').format(payment.dueDate),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (payment.paidDate != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            color: theme.colorScheme.secondary,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Paid on ${DateFormat('MMM d, yyyy').format(payment.paidDate!)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.secondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showPaymentDetails(RentPayment payment, Tenant tenant) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.8,
        minChildSize: 0.4,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.outline.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  children: [
                    Text(
                      'Payment Details',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildDetailRow('Tenant', tenant.name, Icons.person_outline),
                    _buildDetailRow('Property', tenant.propertyId, Icons.location_on_outlined),
                    _buildDetailRow(
                      'Amount',
                      NumberFormat.currency(symbol: ' 4').format(payment.amount),
                      Icons.attach_money,
                    ),
                    _buildDetailRow(
                      'Due Date',
                      DateFormat('MMMM d, yyyy').format(payment.dueDate),
                      Icons.calendar_today_outlined,
                    ),
                    if (payment.paidDate != null)
                      _buildDetailRow(
                        'Paid Date',
                        DateFormat('MMMM d, yyyy').format(payment.paidDate!),
                        Icons.check_circle_outline,
                      ),
                    if (payment.notes != null)
                      _buildDetailRow('Notes', payment.notes!, Icons.note_outlined),
                    const SizedBox(height: 24),
                    if (payment.status != PaymentStatus.paid)
                      ElevatedButton.icon(
                        onPressed: () => _markAsPaid(payment),
                        icon: const Icon(Icons.check),
                        label: const Text('Mark as Paid'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.secondary,
                          foregroundColor: theme.colorScheme.onSecondary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: theme.colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface,
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

  void _showAddPaymentDialog() {
    final theme = Theme.of(context);

    String? selectedTenantId;
    final amountController = TextEditingController();
    final notesController = TextEditingController();
    DateTime selectedDueDate = DateTime.now();
    DateTime? selectedPaidDate;
    PaymentStatus selectedStatus = PaymentStatus.upcoming;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: theme.colorScheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Record Payment',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedTenantId,
                  decoration: InputDecoration(
                    labelText: 'Select Tenant',
                    prefixIcon: Icon(Icons.person_outline, color: theme.colorScheme.primary),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: _tenants.map((tenant) {
                    return DropdownMenuItem(
                      value: tenant.id,
                      child: Text('${tenant.name} - ${tenant.propertyId}'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedTenantId = value;
                      if (value != null) {
                        final tenant = _tenants.firstWhere((t) => t.id == value);
                        amountController.text = tenant.rentAmount.toString();
                      }
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    prefixIcon: Icon(Icons.attach_money, color: theme.colorScheme.primary),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<PaymentStatus>(
                  value: selectedStatus,
                  decoration: InputDecoration(
                    labelText: 'Status',
                    prefixIcon: Icon(Icons.info_outline, color: theme.colorScheme.primary),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: PaymentStatus.values.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(status.name.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedStatus = value!;
                      if (value == PaymentStatus.paid) {
                        selectedPaidDate = DateTime.now();
                      } else {
                        selectedPaidDate = null;
                      }
                    });
                  },
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDueDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (date != null) {
                      setState(() => selectedDueDate = date);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: theme.colorScheme.outline),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today_outlined, color: theme.colorScheme.primary),
                        const SizedBox(width: 16),
                        Text(
                          'Due Date: ${DateFormat('MMM d, yyyy').format(selectedDueDate)}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (selectedStatus == PaymentStatus.paid) ...[
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: selectedPaidDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() => selectedPaidDate = date);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: theme.colorScheme.outline),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle_outline, color: theme.colorScheme.secondary),
                          const SizedBox(width: 16),
                          Text(
                            'Paid Date: ${DateFormat('MMM d, yyyy').format(selectedPaidDate ?? DateTime.now())}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                TextField(
                  controller: notesController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Notes (Optional)',
                    prefixIcon: Icon(Icons.note_outlined, color: theme.colorScheme.primary),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (selectedTenantId != null && amountController.text.isNotEmpty) {
                  final payment = RentPayment(
                    id: const Uuid().v4(),
                    tenantId: selectedTenantId!,
                    amount: double.parse(amountController.text),
                    dueDate: selectedDueDate,
                    paidDate: selectedPaidDate,
                    status: selectedStatus,
                    notes: notesController.text.isNotEmpty ? notesController.text : null,
                  );

                  await DataService.addRentPayment(payment);
                  Navigator.pop(context);
                  _refreshData();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
              child: const Text('Record'),
            ),
          ],
        ),
      ),
    );
  }

  void _markAsPaid(RentPayment payment) async {
    final updatedPayment = payment.copyWith(
      status: PaymentStatus.paid,
      paidDate: DateTime.now(),
    );

    await DataService.updateRentPayment(updatedPayment);
    Navigator.pop(context);
    _refreshData();
  }
}