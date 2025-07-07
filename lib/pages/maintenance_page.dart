import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../database/data_service.dart';
import '../database/models/maintenance_request.dart';
import '../database/models/tenant.dart';
import '../widgets/maintenance_card.dart';
import '../widgets/framework_page.dart';

class MaintenancePage extends StatefulWidget {
  const MaintenancePage({super.key});

  @override
  State<MaintenancePage> createState() => _MaintenancePageState();
}

class _MaintenancePageState extends State<MaintenancePage> with TickerProviderStateMixin {
  List<MaintenanceRequest> _requests = [];
  List<Tenant> _tenants = [];
  bool _isLoading = true;
  String _selectedFilter = 'all';
  late AnimationController _animationController;

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
      _requests = DataService.maintenanceRequests;
      _tenants = DataService.tenants;
      _isLoading = false;
    });
    _animationController.forward();
  }

  Future<void> _refreshData() async {
    await _loadData();
  }

  List<MaintenanceRequest> get _filteredRequests {
    switch (_selectedFilter) {
      case 'pending':
        return _requests.where((r) => r.status == MaintenanceStatus.pending).toList();
      case 'inProgress':
        return _requests.where((r) => r.status == MaintenanceStatus.inProgress).toList();
      case 'completed':
        return _requests.where((r) => r.status == MaintenanceStatus.completed).toList();
      case 'urgent':
        return _requests.where((r) => r.priority == MaintenancePriority.urgent).toList();
      default:
        return _requests;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_isLoading) {
      return FrameworkPage(
        title: 'Maintenance',
        actions: [
          IconButton(
            icon: Icon(
              Icons.add,
              color: theme.colorScheme.primary,
            ),
            onPressed: () => _showAddRequestDialog(),
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
    return FrameworkPage(
      title: 'Maintenance',
      actions: [
        IconButton(
          icon: Icon(
            Icons.add,
            color: theme.colorScheme.primary,
          ),
          onPressed: () => _showAddRequestDialog(),
        ),
      ],
      slivers: [
        SliverToBoxAdapter(child: _buildFilterChips()),
        SliverToBoxAdapter(child: _buildStatsRow()),
        if (_filteredRequests.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: _buildEmptyState(),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: MaintenanceCard(
                  request: _filteredRequests[index],
                  tenant: _getTenantById(_filteredRequests[index].tenantId),
                  onTap: () => _showRequestDetails(_filteredRequests[index]),
                  onStatusUpdate: () => _showStatusUpdateDialog(_filteredRequests[index]),
                ),
              ),
              childCount: _filteredRequests.length,
            ),
          ),
      ],
    );
  }

  Widget _buildFilterChips() {
    final theme = Theme.of(context);
    final filters = [
      {'key': 'all', 'label': 'All'},
      {'key': 'pending', 'label': 'Pending'},
      {'key': 'inProgress', 'label': 'In Progress'},
      {'key': 'urgent', 'label': 'Urgent'},
      {'key': 'completed', 'label': 'Completed'},
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
    final pendingCount = _requests.where((r) => r.status == MaintenanceStatus.pending).length;
    final inProgressCount = _requests.where((r) => r.status == MaintenanceStatus.inProgress).length;
    final urgentCount = _requests.where((r) => r.priority == MaintenancePriority.urgent).length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Pending',
              pendingCount.toString(),
              theme.colorScheme.tertiary,
              Icons.hourglass_empty,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'In Progress',
              inProgressCount.toString(),
              theme.colorScheme.primary,
              Icons.build_outlined,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Urgent',
              urgentCount.toString(),
              theme.colorScheme.error,
              Icons.priority_high,
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
            style: theme.textTheme.titleLarge?.copyWith(
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
                Icons.build_outlined,
                size: 64,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _selectedFilter == 'all' ? 'No Maintenance Requests' : 'No Requests Found',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _selectedFilter == 'all'
                  ? 'All maintenance requests are up to date.'
                  : 'No requests match the selected filter.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _showAddRequestDialog(),
              icon: const Icon(Icons.add),
              label: const Text('Add Request'),
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

  void _showRequestDetails(MaintenanceRequest request) {
    final theme = Theme.of(context);
    final tenant = _getTenantById(request.tenantId);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
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
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            request.title,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => _showEditRequestDialog(request),
                          icon: Icon(
                            Icons.edit_outlined,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildDetailRow('Tenant', tenant?.name ?? 'Unknown', Icons.person_outline),
                    _buildDetailRow('Property', request.propertyId, Icons.location_on_outlined),
                    _buildDetailRow('Priority', request.priority.name.toUpperCase(), Icons.priority_high),
                    _buildDetailRow('Status', _getStatusText(request.status), Icons.info_outline),
                    _buildDetailRow(
                      'Created',
                      DateFormat('MMMM d, yyyy').format(request.createdDate),
                      Icons.calendar_today_outlined,
                    ),
                    if (request.completedDate != null)
                      _buildDetailRow(
                        'Completed',
                        DateFormat('MMMM d, yyyy').format(request.completedDate!),
                        Icons.check_circle_outline,
                      ),
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.colorScheme.outline.withOpacity(0.1),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.description_outlined,
                                color: theme.colorScheme.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 16),
                              Text(
                                'Description',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            request.description,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (request.notes != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.note_outlined,
                                  color: theme.colorScheme.secondary,
                                  size: 20,
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  'Notes',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: theme.colorScheme.secondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              request.notes!,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 24),
                    if (request.status != MaintenanceStatus.completed)
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _updateRequestStatus(request, MaintenanceStatus.inProgress),
                              icon: const Icon(Icons.play_arrow),
                              label: const Text('Start Work'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.primary,
                                foregroundColor: theme.colorScheme.onPrimary,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _updateRequestStatus(request, MaintenanceStatus.completed),
                              icon: const Icon(Icons.check),
                              label: const Text('Complete'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.secondary,
                                foregroundColor: theme.colorScheme.onSecondary,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
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

  void _showAddRequestDialog() {
    _showRequestFormDialog();
  }

  void _showEditRequestDialog(MaintenanceRequest request) {
    _showRequestFormDialog(request: request);
  }

  void _showRequestFormDialog({MaintenanceRequest? request}) {
    final theme = Theme.of(context);
    final isEditing = request != null;

    String? selectedTenantId = request?.tenantId;
    final titleController = TextEditingController(text: request?.title ?? '');
    final descriptionController = TextEditingController(text: request?.description ?? '');
    final notesController = TextEditingController(text: request?.notes ?? '');
    MaintenancePriority selectedPriority = request?.priority ?? MaintenancePriority.medium;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: theme.colorScheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            isEditing ? 'Edit Request' : 'Add Maintenance Request',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isEditing)
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
                      setState(() => selectedTenantId = value);
                    },
                  ),
                if (!isEditing) const SizedBox(height: 16),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    prefixIcon: Icon(Icons.title, color: theme.colorScheme.primary),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    prefixIcon: Icon(Icons.description_outlined, color: theme.colorScheme.primary),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<MaintenancePriority>(
                  value: selectedPriority,
                  decoration: InputDecoration(
                    labelText: 'Priority',
                    prefixIcon: Icon(Icons.priority_high, color: theme.colorScheme.primary),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: MaintenancePriority.values.map((priority) {
                    return DropdownMenuItem(
                      value: priority,
                      child: Text(priority.name.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => selectedPriority = value!);
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: notesController,
                  maxLines: 2,
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
                if ((selectedTenantId != null || isEditing) &&
                    titleController.text.isNotEmpty &&
                    descriptionController.text.isNotEmpty) {

                  final newRequest = isEditing
                      ? request!.copyWith(
                    title: titleController.text,
                    description: descriptionController.text,
                    priority: selectedPriority,
                    notes: notesController.text.isNotEmpty ? notesController.text : null,
                  )
                      : MaintenanceRequest(
                    id: const Uuid().v4(),
                    tenantId: selectedTenantId!,
                    propertyId: _getTenantById(selectedTenantId!)?.propertyId ?? '',
                    title: titleController.text,
                    description: descriptionController.text,
                    priority: selectedPriority,
                    status: MaintenanceStatus.pending,
                    createdDate: DateTime.now(),
                    notes: notesController.text.isNotEmpty ? notesController.text : null,
                  );

                  if (isEditing) {
                    await DataService.updateMaintenanceRequest(newRequest);
                  } else {
                    await DataService.addMaintenanceRequest(newRequest);
                  }

                  Navigator.pop(context);
                  _refreshData();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
              child: Text(isEditing ? 'Update' : 'Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showStatusUpdateDialog(MaintenanceRequest request) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Update Status',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...MaintenanceStatus.values.map((status) {
                    if (status == request.status) return const SizedBox.shrink();

                    return ListTile(
                      leading: Icon(
                        _getStatusIcon(status),
                        color: _getStatusColorForStatus(status, theme),
                      ),
                      title: Text(_getStatusText(status)),
                      onTap: () {
                        Navigator.pop(context);
                        _updateRequestStatus(request, status);
                      },
                    );
                  }),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getStatusIcon(MaintenanceStatus status) {
    switch (status) {
      case MaintenanceStatus.pending:
        return Icons.hourglass_empty;
      case MaintenanceStatus.inProgress:
        return Icons.build;
      case MaintenanceStatus.completed:
        return Icons.check_circle;
      case MaintenanceStatus.cancelled:
        return Icons.cancel;
    }
  }

  Color _getStatusColorForStatus(MaintenanceStatus status, ThemeData theme) {
    switch (status) {
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

  String _getStatusText(MaintenanceStatus status) {
    switch (status) {
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

  void _updateRequestStatus(MaintenanceRequest request, MaintenanceStatus newStatus) async {
    final updatedRequest = request.copyWith(
      status: newStatus,
      completedDate: newStatus == MaintenanceStatus.completed
          ? DateTime.now()
          : null,
    );

    await DataService.updateMaintenanceRequest(updatedRequest);
    _refreshData();
  }

  Tenant? _getTenantById(String tenantId) {
    try {
      return _tenants.firstWhere((t) => t.id == tenantId);
    } catch (e) {
      return null;
    }
  }
}