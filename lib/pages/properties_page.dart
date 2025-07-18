import 'package:flutter/material.dart';
import 'package:microrealeaste/database/data_service.dart';
import 'package:microrealeaste/database/models/property.dart';
import 'package:microrealeaste/pages/property_detail_page.dart';
import 'package:microrealeaste/widgets/framework_page.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:microrealeaste/providers/auth_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:microrealeaste/providers/app_providers.dart';

class PropertiesPage extends ConsumerStatefulWidget {
  const PropertiesPage({super.key});

  @override
  ConsumerState<PropertiesPage> createState() => _PropertiesPageState();
}

class _PropertiesPageState extends ConsumerState<PropertiesPage> {
  List<Property> _properties = [];
  List<Property> _filteredProperties = [];
  String _searchQuery = '';
  PropertyStatus? _statusFilter;
  PropertyType? _typeFilter;

  @override
  void initState() {
    super.initState();
    _loadProperties();
  }

  void _loadProperties() {
    setState(() {
      _properties = DataService.properties;
      _applyFilters();
    });
  }

  void _applyFilters() {
    _filteredProperties = _properties.where((property) {
      final matchesSearch = property.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          property.address.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          property.city.toLowerCase().contains(_searchQuery.toLowerCase());
      
      final matchesStatus = _statusFilter == null || property.propertyStatus == _statusFilter;
      final matchesType = _typeFilter == null || property.propertyType == _typeFilter;
      
      return matchesSearch && matchesStatus && matchesType;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = ref.watch(currentUserProvider);
    final currentOrgId = user?.currentOrganizationId;
    final canManageProperties = user?.canManageProperties ?? false;
    return Scaffold(
      floatingActionButton: canManageProperties
          ? FloatingActionButton.extended(
              onPressed: _showAddPropertyDialog,
              icon: const Icon(Icons.add),
              label: const Text('Add Property'),
            )
          : null,
      body: FrameworkPage(
        title: 'Properties',
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width > 900 ? 32 :
                          (MediaQuery.of(context).size.width > 600 ? 24 : 16),
                vertical: 16,
              ),
              child: Column(
                children: [
                  // Search bar
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Search properties...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                        _applyFilters();
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  // Filter chips
                  Row(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildFilterChip(
                                'All Status',
                                _statusFilter == null,
                                () => setState(() {
                                  _statusFilter = null;
                                  _applyFilters();
                                }),
                              ),
                              ...PropertyStatus.values.map((status) => _buildFilterChip(
                                status.name,
                                _statusFilter == status,
                                () => setState(() {
                                  _statusFilter = status;
                                  _applyFilters();
                                }),
                              )),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (_filteredProperties.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.home_outlined,
                      size: 64,
                      color: theme.colorScheme.onSurface.withOpacity(0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No properties found',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final property = _filteredProperties[index];
                  return _buildPropertyCard(property, isTablet: MediaQuery.of(context).size.width > 600);
                },
                childCount: _filteredProperties.length,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        backgroundColor: theme.colorScheme.surface,
        selectedColor: theme.colorScheme.primary.withOpacity(0.2),
        checkmarkColor: theme.colorScheme.primary,
        labelStyle: TextStyle(
          color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildPropertyCard(Property property, {bool isTablet = false}) {
    final theme = Theme.of(context);
    final tenants = DataService.getTenantsByProperty(property.id);
    final borderRadius = isTablet ? 20.0 : 16.0;
    final padding = isTablet ? 20.0 : 16.0;
    final user = ref.read(currentUserProvider);
    final canManageProperties = user?.canManageProperties ?? false;

    return GestureDetector(
      onLongPress: canManageProperties
          ? () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Property'),
                  content: const Text('Are you sure you want to delete this property?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () async {
                        await DataService.deleteProperty(property.id);
                        _loadProperties();
                        if (mounted) Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Property deleted')),
                        );
                      },
                      child: const Text('Delete', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            }
          : null,
      child: Card(
        margin: EdgeInsets.only(bottom: isTablet ? 16 : 12),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          side: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.1),
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
          onTap: () => _showPropertyDetails(property),
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            property.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            property.fullAddress,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusChip(property.propertyStatus),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildPropertyInfo(Icons.bed, '${property.bedrooms} bed'),
                    const SizedBox(width: 16),
                    _buildPropertyInfo(Icons.bathtub, '${property.bathrooms} bath'),
                    const SizedBox(width: 16),
                    if (property.squareFeet != null)
                      _buildPropertyInfo(Icons.square_foot, '${property.squareFeet!.toInt()} sq ft'),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.people,
                      size: 16,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${tenants.length} tenant${tenants.length != 1 ? 's' : ''}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      property.propertyTypeDisplayName,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
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

  Widget _buildPropertyInfo(IconData icon, String text) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(PropertyStatus status) {
    final theme = Theme.of(context);
    Color backgroundColor;
    Color textColor;
    
    switch (status) {
      case PropertyStatus.available:
        backgroundColor = Colors.green.withOpacity(0.1);
        textColor = Colors.green.shade700;
        break;
      case PropertyStatus.occupied:
        backgroundColor = Colors.blue.withOpacity(0.1);
        textColor = Colors.blue.shade700;
        break;
      case PropertyStatus.maintenance:
        backgroundColor = Colors.orange.withOpacity(0.1);
        textColor = Colors.orange.shade700;
        break;
      case PropertyStatus.unavailable:
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

  void _showPropertyDetails(Property property) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PropertyDetailPage(property: property),
      ),
    );
    if (result == true) {
      ref.read(propertiesProvider.notifier).refresh();
      ref.read(tenantsProvider.notifier).refresh();
      ref.read(rentPaymentsProvider.notifier).refresh();
      ref.read(maintenanceRequestsProvider.notifier).refresh();
      _loadProperties();
    }
  }

  void _showAddPropertyDialog() async {
    final theme = Theme.of(context);
    final currentUser = ref.read(currentUserProvider);
    final orgId = currentUser?.organizationId ?? 'org-demo';
    final landlordId = currentUser?.id ?? 'landlord-demo';
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final addressController = TextEditingController();
    final cityController = TextEditingController();
    final stateController = TextEditingController();
    final zipController = TextEditingController();
    final countryController = TextEditingController();
    final bedroomsController = TextEditingController();
    final bathroomsController = TextEditingController();
    final squareFeetController = TextEditingController();
    final yearBuiltController = TextEditingController();
    final parkingSpacesController = TextEditingController();
    final marketValueController = TextEditingController();
    final purchasePriceController = TextEditingController();
    PropertyType selectedType = PropertyType.apartment;
    PropertyStatus selectedStatus = PropertyStatus.available;
    List<String> amenities = [];
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add New Property'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                  onChanged: (type) => setState(() => selectedType = type!),
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
                        controller: zipController,
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
                const SizedBox(height: 12),
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
                const SizedBox(height: 12),
                DropdownButtonFormField<PropertyStatus>(
                  value: selectedStatus,
                  decoration: const InputDecoration(labelText: 'Property Status'),
                  items: PropertyStatus.values.map((status) => DropdownMenuItem(
                    value: status,
                    child: Text(status.name),
                  )).toList(),
                  onChanged: (status) => setState(() => selectedStatus = status!),
                ),
                const SizedBox(height: 12),
                // Amenities chips
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ...amenities.map((amenity) => Chip(
                      label: Text(amenity),
                      onDeleted: () => setState(() => amenities.remove(amenity)),
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
                          setState(() => amenities.add(amenity));
                        }
                      },
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
                final description = descriptionController.text.trim();
                final address = addressController.text.trim();
                final city = cityController.text.trim();
                final state = stateController.text.trim();
                final zip = zipController.text.trim();
                final country = countryController.text.trim();
                final bedrooms = int.tryParse(bedroomsController.text.trim()) ?? 0;
                final bathrooms = int.tryParse(bathroomsController.text.trim()) ?? 0;
                final squareFeet = double.tryParse(squareFeetController.text.trim());
                final yearBuilt = int.tryParse(yearBuiltController.text.trim());
                final parkingSpaces = int.tryParse(parkingSpacesController.text.trim()) ?? 0;
                final marketValue = double.tryParse(marketValueController.text.trim());
                final purchasePrice = double.tryParse(purchasePriceController.text.trim());
                if (name.isEmpty || address.isEmpty || city.isEmpty || state.isEmpty || zip.isEmpty || country.isEmpty || bedrooms <= 0 || bathrooms <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all required fields with valid values')),
                  );
                  return;
                }
                final newProperty = Property(
                  id: const Uuid().v4(),
                  organizationId: orgId,
                  landlordId: landlordId,
                  name: name,
                  description: description,
                  propertyType: selectedType,
                  address: address,
                  city: city,
                  state: state,
                  zipCode: zip,
                  country: country,
                  bedrooms: bedrooms,
                  bathrooms: bathrooms,
                  squareFeet: squareFeet,
                  yearBuilt: yearBuilt,
                  parkingSpaces: parkingSpaces,
                  amenities: amenities,
                  marketValue: marketValue,
                  purchasePrice: purchasePrice,
                  propertyStatus: selectedStatus,
                  images: const [],
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                );
                await DataService.addProperty(newProperty);
                _loadProperties();
                if (mounted) Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Property added successfully')),
                );
              },
              child: const Text('Add Property'),
            ),
          ],
        ),
      ),
    );
  }
}
