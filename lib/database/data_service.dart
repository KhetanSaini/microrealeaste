import 'package:flutter/foundation.dart';
import 'package:microrealeaste/database/models/maintenance_request.dart';
import 'package:microrealeaste/database/models/rent_payment.dart';
import 'package:microrealeaste/database/models/tenant.dart';
import 'package:microrealeaste/database/models/property.dart';
import 'package:microrealeaste/database/models/user.dart';
import 'package:microrealeaste/database/models/organization.dart';
import 'package:uuid/uuid.dart';
import 'storage_service.dart';

class DataService {
  static const _uuid = Uuid();

  static List<Tenant> _tenants = [];
  static List<RentPayment> _rentPayments = [];
  static List<MaintenanceRequest> _maintenanceRequests = [];
  static List<Property> _properties = [];
  static List<User> _users = [];
  static List<Organization> _organizations = [];

  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    _tenants = await StorageService.getTenants();
    _rentPayments = await StorageService.getRentPayments();
    _maintenanceRequests = await StorageService.getMaintenanceRequests();
    _properties = await StorageService.getProperties();
    _users = await StorageService.getUsers();
    _organizations = await StorageService.getOrganizations();

    // Add sample data if none exists (DEBUG MODE ONLY)
    if (kDebugMode && (_tenants.isEmpty || _properties.isEmpty)) {
      await _addSampleData();
    }

    _isInitialized = true;
  }

  /// Adds sample data for development and testing purposes.
  /// This method is only called in debug mode and will not be executed in production builds.
  static Future<void> _addSampleData() async {
    // Sample tenants
    final sampleTenants = [
      Tenant(
        id: _uuid.v4(),
        name: 'Sarah Johnson',
        email: 'sarah.johnson@email.com',
        phone: '(555) 123-4567',
        propertyId: 'apt-101',
        rentAmount: 1200.0,
        moveInDate: DateTime(2023, 6, 1),
      ),
      Tenant(
        id: _uuid.v4(),
        name: 'Michael Chen',
        email: 'michael.chen@email.com',
        phone: '(555) 234-5678',
        propertyId: 'apt-202',
        rentAmount: 1500.0,
        moveInDate: DateTime(2023, 8, 15),
      ),
      Tenant(
        id: _uuid.v4(),
        name: 'Emily Rodriguez',
        email: 'emily.rodriguez@email.com',
        phone: '(555) 345-6789',
        propertyId: 'apt-303',
        rentAmount: 1100.0,
        moveInDate: DateTime(2024, 1, 1),
      ),
      Tenant(
        id: _uuid.v4(),
        name: 'David Thompson',
        email: 'david.thompson@email.com',
        phone: '(555) 456-7890',
        propertyId: 'apt-104',
        rentAmount: 1350.0,
        moveInDate: DateTime(2023, 12, 1),
      ),
    ];

    _tenants = sampleTenants;
    await StorageService.saveTenants(_tenants);

    // Sample rent payments
    final now = DateTime.now();
    final samplePayments = <RentPayment>[];

    for (int i = 0; i < _tenants.length; i++) {
      final tenant = _tenants[i];

      // Current month payment
      samplePayments.add(RentPayment(
        id: _uuid.v4(),
        tenantId: tenant.id,
        amount: tenant.rentAmount,
        dueDate: DateTime(now.year, now.month, 1),
        status: i % 3 == 0 ? PaymentStatus.overdue :
        i % 3 == 1 ? PaymentStatus.paid : PaymentStatus.upcoming,
        paidDate: i % 3 == 1 ? DateTime(now.year, now.month, 2) : null,
      ));

      // Previous month payment
      final prevMonth = DateTime(now.year, now.month - 1, 1);
      samplePayments.add(RentPayment(
        id: _uuid.v4(),
        tenantId: tenant.id,
        amount: tenant.rentAmount,
        dueDate: prevMonth,
        status: PaymentStatus.paid,
        paidDate: DateTime(prevMonth.year, prevMonth.month, 3),
      ));
    }

    _rentPayments = samplePayments;
    await StorageService.saveRentPayments(_rentPayments);

    // Sample maintenance requests
    final sampleRequests = [
      MaintenanceRequest(
        id: _uuid.v4(),
        tenantId: _tenants[0].id,
        propertyId: _tenants[0].propertyId,
        title: 'Leaky Faucet in Kitchen',
        description: 'The kitchen faucet has been dripping constantly for the past week. It\'s getting worse and wasting water.',
        priority: MaintenancePriority.medium,
        status: MaintenanceStatus.pending,
        createdDate: DateTime.now().subtract(const Duration(days: 3)),
      ),
      MaintenanceRequest(
        id: _uuid.v4(),
        tenantId: _tenants[1].id,
        propertyId: _tenants[1].propertyId,
        title: 'Air Conditioning Not Working',
        description: 'The AC unit stopped working yesterday. It\'s getting really hot in the apartment.',
        priority: MaintenancePriority.urgent,
        status: MaintenanceStatus.inProgress,
        createdDate: DateTime.now().subtract(const Duration(days: 1)),
      ),
      MaintenanceRequest(
        id: _uuid.v4(),
        tenantId: _tenants[2].id,
        propertyId: _tenants[2].propertyId,
        title: 'Broken Light Fixture',
        description: 'The light fixture in the living room fell and broke. Need replacement.',
        priority: MaintenancePriority.high,
        status: MaintenanceStatus.completed,
        createdDate: DateTime.now().subtract(const Duration(days: 7)),
        completedDate: DateTime.now().subtract(const Duration(days: 2)),
      ),
      MaintenanceRequest(
        id: _uuid.v4(),
        tenantId: _tenants[3].id,
        propertyId: _tenants[3].propertyId,
        title: 'Window Screen Repair',
        description: 'The window screen in the bedroom has a tear and needs to be fixed.',
        priority: MaintenancePriority.low,
        status: MaintenanceStatus.pending,
        createdDate: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ];

    _maintenanceRequests = sampleRequests;
    await StorageService.saveMaintenanceRequests(_maintenanceRequests);

    // Sample organization
    final sampleOrganization = Organization(
      id: _uuid.v4(),
      name: 'MicroRealEstate Demo',
      description: 'Demo organization for property management',
      address: '123 Business St, City, State 12345',
      phoneNumber: '(555) 000-0000',
      email: 'admin@microrealestate.demo',
      subscriptionPlan: SubscriptionPlan.premium,
      createdAt: DateTime.now().subtract(const Duration(days: 365)),
      updatedAt: DateTime.now(),
    );

    _organizations = [sampleOrganization];
    await StorageService.saveOrganizations(_organizations);

    // Sample properties
    final sampleProperties = [
      Property(
        id: 'apt-101',
        organizationId: sampleOrganization.id,
        landlordId: 'landlord-1',
        name: 'Sunset Apartments - Unit 101',
        description: 'Beautiful 2-bedroom apartment with city view',
        propertyType: PropertyType.apartment,
        address: '456 Sunset Blvd',
        city: 'Los Angeles',
        state: 'CA',
        zipCode: '90028',
        country: 'USA',
        bedrooms: 2,
        bathrooms: 1,
        squareFeet: 850.0,
        parkingSpaces: 1,
        amenities: ['Pool', 'Gym', 'Laundry'],
        marketValue: 450000.0,
        propertyStatus: PropertyStatus.occupied,
        images: [],
        createdAt: DateTime.now().subtract(const Duration(days: 200)),
        updatedAt: DateTime.now(),
      ),
      Property(
        id: 'apt-202',
        organizationId: sampleOrganization.id,
        landlordId: 'landlord-1',
        name: 'Sunset Apartments - Unit 202',
        description: 'Spacious 3-bedroom apartment with balcony',
        propertyType: PropertyType.apartment,
        address: '456 Sunset Blvd',
        city: 'Los Angeles',
        state: 'CA',
        zipCode: '90028',
        country: 'USA',
        bedrooms: 3,
        bathrooms: 2,
        squareFeet: 1200.0,
        parkingSpaces: 2,
        amenities: ['Pool', 'Gym', 'Laundry', 'Balcony'],
        marketValue: 650000.0,
        propertyStatus: PropertyStatus.occupied,
        images: [],
        createdAt: DateTime.now().subtract(const Duration(days: 180)),
        updatedAt: DateTime.now(),
      ),
      Property(
        id: 'apt-303',
        organizationId: sampleOrganization.id,
        landlordId: 'landlord-1',
        name: 'Sunset Apartments - Unit 303',
        description: 'Cozy 1-bedroom apartment, perfect for singles',
        propertyType: PropertyType.apartment,
        address: '456 Sunset Blvd',
        city: 'Los Angeles',
        state: 'CA',
        zipCode: '90028',
        country: 'USA',
        bedrooms: 1,
        bathrooms: 1,
        squareFeet: 650.0,
        parkingSpaces: 1,
        amenities: ['Pool', 'Gym', 'Laundry'],
        marketValue: 350000.0,
        propertyStatus: PropertyStatus.occupied,
        images: [],
        createdAt: DateTime.now().subtract(const Duration(days: 150)),
        updatedAt: DateTime.now(),
      ),
      Property(
        id: 'apt-104',
        organizationId: sampleOrganization.id,
        landlordId: 'landlord-1',
        name: 'Sunset Apartments - Unit 104',
        description: 'Ground floor 2-bedroom with patio access',
        propertyType: PropertyType.apartment,
        address: '456 Sunset Blvd',
        city: 'Los Angeles',
        state: 'CA',
        zipCode: '90028',
        country: 'USA',
        bedrooms: 2,
        bathrooms: 1,
        squareFeet: 900.0,
        parkingSpaces: 1,
        amenities: ['Pool', 'Gym', 'Laundry', 'Patio'],
        marketValue: 480000.0,
        propertyStatus: PropertyStatus.occupied,
        images: [],
        createdAt: DateTime.now().subtract(const Duration(days: 120)),
        updatedAt: DateTime.now(),
      ),
    ];

    _properties = sampleProperties;
    await StorageService.saveProperties(_properties);

    // Sample users
    final sampleUsers = [
      User(
        id: 'landlord-1',
        email: 'landlord@microrealestate.demo',
        firstName: 'John',
        lastName: 'Landlord',
        phoneNumber: '(555) 111-1111',
        role: UserRole.landlord,
        organizationId: sampleOrganization.id,
        isActive: true,
        emailVerified: true,
        createdAt: DateTime.now().subtract(const Duration(days: 365)),
        updatedAt: DateTime.now(),
      ),
    ];

    _users = sampleUsers;
    await StorageService.saveUsers(_users);
  }

  // Tenant CRUD operations
  static List<Tenant> get tenants => List.from(_tenants);

  static Future<void> addTenant(Tenant tenant) async {
    _tenants.add(tenant);
    await StorageService.saveTenants(_tenants);
  }

  static Future<void> updateTenant(Tenant tenant) async {
    final index = _tenants.indexWhere((t) => t.id == tenant.id);
    if (index != -1) {
      _tenants[index] = tenant;
      await StorageService.saveTenants(_tenants);
    }
  }

  static Future<void> deleteTenant(String tenantId) async {
    _tenants.removeWhere((t) => t.id == tenantId);
    _rentPayments.removeWhere((p) => p.tenantId == tenantId);
    _maintenanceRequests.removeWhere((r) => r.tenantId == tenantId);

    await StorageService.saveTenants(_tenants);
    await StorageService.saveRentPayments(_rentPayments);
    await StorageService.saveMaintenanceRequests(_maintenanceRequests);
  }

  // Rent payment CRUD operations
  static List<RentPayment> get rentPayments => List.from(_rentPayments);

  static Future<void> addRentPayment(RentPayment payment) async {
    _rentPayments.add(payment);
    await StorageService.saveRentPayments(_rentPayments);
  }

  static Future<void> updateRentPayment(RentPayment payment) async {
    final index = _rentPayments.indexWhere((p) => p.id == payment.id);
    if (index != -1) {
      _rentPayments[index] = payment;
      await StorageService.saveRentPayments(_rentPayments);
    }
  }

  static Future<void> deleteRentPayment(String paymentId) async {
    _rentPayments.removeWhere((p) => p.id == paymentId);
    await StorageService.saveRentPayments(_rentPayments);
  }

  // Maintenance request CRUD operations
  static List<MaintenanceRequest> get maintenanceRequests => List.from(_maintenanceRequests);

  static Future<void> addMaintenanceRequest(MaintenanceRequest request) async {
    _maintenanceRequests.add(request);
    await StorageService.saveMaintenanceRequests(_maintenanceRequests);
  }

  static Future<void> updateMaintenanceRequest(MaintenanceRequest request) async {
    final index = _maintenanceRequests.indexWhere((r) => r.id == request.id);
    if (index != -1) {
      _maintenanceRequests[index] = request;
      await StorageService.saveMaintenanceRequests(_maintenanceRequests);
    }
  }

  static Future<void> deleteMaintenanceRequest(String requestId) async {
    _maintenanceRequests.removeWhere((r) => r.id == requestId);
    await StorageService.saveMaintenanceRequests(_maintenanceRequests);
  }

  // Helper methods
  static Tenant? getTenantById(String tenantId) {
    try {
      return _tenants.firstWhere((t) => t.id == tenantId);
    } catch (e) {
      return null;
    }
  }

  static User? getUserById(String userId) {
    try {
      return _users.firstWhere((u) => u.id == userId);
    } catch (e) {
      return null;
    }
  }

  static List<RentPayment> getPaymentsByTenant(String tenantId) {
    return _rentPayments.where((p) => p.tenantId == tenantId).toList();
  }

  static List<MaintenanceRequest> getRequestsByTenant(String tenantId) {
    return _maintenanceRequests.where((r) => r.tenantId == tenantId).toList();
  }

  // Property CRUD operations
  static List<Property> get properties => List.from(_properties);

  // User CRUD operations
  static List<User> get users => List.from(_users);

  static Future<void> addUser(User user) async {
    _users.add(user);
    await StorageService.saveUsers(_users);
  }

  static Future<void> updateUser(User user) async {
    final index = _users.indexWhere((u) => u.id == user.id);
    if (index != -1) {
      _users[index] = user;
      await StorageService.saveUsers(_users);
    }
  }

  static Future<void> deleteUser(String userId) async {
    _users.removeWhere((u) => u.id == userId);
    await StorageService.saveUsers(_users);
  }

  static Future<void> clearAllData() async {
    _tenants.clear();
    _rentPayments.clear();
    _maintenanceRequests.clear();
    _properties.clear();
    _users.clear();
    _organizations.clear();

    await StorageService.saveTenants(_tenants);
    await StorageService.saveRentPayments(_rentPayments);
    await StorageService.saveMaintenanceRequests(_maintenanceRequests);
    await StorageService.saveProperties(_properties);
    await StorageService.saveUsers(_users);
    await StorageService.saveOrganizations(_organizations);
  }

  static Future<void> addProperty(Property property) async {
    _properties.add(property);
    await StorageService.saveProperties(_properties);
  }

  static Future<void> updateProperty(Property property) async {
    final index = _properties.indexWhere((p) => p.id == property.id);
    if (index != -1) {
      _properties[index] = property;
      await StorageService.saveProperties(_properties);
    }
  }

  static Future<void> deleteProperty(String propertyId) async {
    _properties.removeWhere((p) => p.id == propertyId);
    _tenants.removeWhere((t) => t.propertyId == propertyId);
    _rentPayments.removeWhere((p) => _tenants.any((t) => t.id == p.tenantId && t.propertyId == propertyId));
    _maintenanceRequests.removeWhere((r) => r.propertyId == propertyId);

    await StorageService.saveProperties(_properties);
    await StorageService.saveTenants(_tenants);
    await StorageService.saveRentPayments(_rentPayments);
    await StorageService.saveMaintenanceRequests(_maintenanceRequests);
  }

  // Organization CRUD operations
  static List<Organization> get organizations => List.from(_organizations);

  static Future<void> addOrganization(Organization organization) async {
    _organizations.add(organization);
    await StorageService.saveOrganizations(_organizations);
  }

  static Future<void> updateOrganization(Organization organization) async {
    final index = _organizations.indexWhere((o) => o.id == organization.id);
    if (index != -1) {
      _organizations[index] = organization;
      await StorageService.saveOrganizations(_organizations);
    }
  }

  // Additional helper methods
  static Property? getPropertyById(String propertyId) {
    try {
      return _properties.firstWhere((p) => p.id == propertyId);
    } catch (e) {
      return null;
    }
  }

  static List<Property> getPropertiesByOrganization(String organizationId) {
    return _properties.where((p) => p.organizationId == organizationId).toList();
  }

  static List<Tenant> getTenantsByProperty(String propertyId) {
    return _tenants.where((t) => t.propertyId == propertyId).toList();
  }

  static List<MaintenanceRequest> getRequestsByProperty(String propertyId) {
    return _maintenanceRequests.where((r) => r.propertyId == propertyId).toList();
  }

  static Organization? getOrganizationById(String organizationId) {
    try {
      return _organizations.firstWhere((o) => o.id == organizationId);
    } catch (e) {
      return null;
    }
  }
}