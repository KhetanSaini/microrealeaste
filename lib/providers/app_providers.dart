import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../database/data_service.dart';
import '../database/models/tenant.dart';
import '../database/models/property.dart';
import '../database/models/rent_payment.dart';
import '../database/models/maintenance_request.dart';

// Data providers
final tenantsProvider = StateNotifierProvider<TenantsNotifier, List<Tenant>>((ref) {
  return TenantsNotifier();
});

final propertiesProvider = StateNotifierProvider<PropertiesNotifier, List<Property>>((ref) {
  return PropertiesNotifier();
});

final rentPaymentsProvider = StateNotifierProvider<RentPaymentsNotifier, List<RentPayment>>((ref) {
  return RentPaymentsNotifier();
});

final maintenanceRequestsProvider = StateNotifierProvider<MaintenanceRequestsNotifier, List<MaintenanceRequest>>((ref) {
  return MaintenanceRequestsNotifier();
});

// Loading state provider
final isLoadingProvider = StateProvider<bool>((ref) => true);

// Selected navigation index provider
final selectedNavIndexProvider = StateProvider<int>((ref) => 0);

// State notifiers
class TenantsNotifier extends StateNotifier<List<Tenant>> {
  TenantsNotifier() : super([]) {
    _loadTenants();
  }

  Future<void> _loadTenants() async {
    await DataService.initialize();
    state = DataService.tenants;
  }

  Future<void> addTenant(Tenant tenant) async {
    await DataService.addTenant(tenant);
    state = DataService.tenants;
  }

  Future<void> updateTenant(Tenant tenant) async {
    await DataService.updateTenant(tenant);
    state = DataService.tenants;
  }

  Future<void> deleteTenant(String tenantId) async {
    await DataService.deleteTenant(tenantId);
    state = DataService.tenants;
  }

  Future<void> refresh() async {
    await _loadTenants();
  }
}

class PropertiesNotifier extends StateNotifier<List<Property>> {
  PropertiesNotifier() : super([]) {
    _loadProperties();
  }

  Future<void> _loadProperties() async {
    await DataService.initialize();
    state = DataService.properties;
  }

  Future<void> addProperty(Property property) async {
    await DataService.addProperty(property);
    state = DataService.properties;
  }

  Future<void> updateProperty(Property property) async {
    await DataService.updateProperty(property);
    state = DataService.properties;
  }

  Future<void> deleteProperty(String propertyId) async {
    await DataService.deleteProperty(propertyId);
    state = DataService.properties;
  }

  Future<void> refresh() async {
    await _loadProperties();
  }
}

class RentPaymentsNotifier extends StateNotifier<List<RentPayment>> {
  RentPaymentsNotifier() : super([]) {
    _loadPayments();
  }

  Future<void> _loadPayments() async {
    await DataService.initialize();
    state = DataService.rentPayments;
  }

  Future<void> addPayment(RentPayment payment) async {
    await DataService.addRentPayment(payment);
    state = DataService.rentPayments;
  }

  Future<void> updatePayment(RentPayment payment) async {
    await DataService.updateRentPayment(payment);
    state = DataService.rentPayments;
  }

  Future<void> deletePayment(String paymentId) async {
    await DataService.deleteRentPayment(paymentId);
    state = DataService.rentPayments;
  }

  Future<void> refresh() async {
    await _loadPayments();
  }
}

class MaintenanceRequestsNotifier extends StateNotifier<List<MaintenanceRequest>> {
  MaintenanceRequestsNotifier() : super([]) {
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    await DataService.initialize();
    state = DataService.maintenanceRequests;
  }

  Future<void> addRequest(MaintenanceRequest request) async {
    await DataService.addMaintenanceRequest(request);
    state = DataService.maintenanceRequests;
  }

  Future<void> updateRequest(MaintenanceRequest request) async {
    await DataService.updateMaintenanceRequest(request);
    state = DataService.maintenanceRequests;
  }

  Future<void> deleteRequest(String requestId) async {
    await DataService.deleteMaintenanceRequest(requestId);
    state = DataService.maintenanceRequests;
  }

  Future<void> refresh() async {
    await _loadRequests();
  }
}

// Computed providers
final overduePaymentsProvider = Provider<List<RentPayment>>((ref) {
  final payments = ref.watch(rentPaymentsProvider);
  return payments.where((payment) => payment.isOverdue).toList();
});

final pendingMaintenanceProvider = Provider<List<MaintenanceRequest>>((ref) {
  final requests = ref.watch(maintenanceRequestsProvider);
  return requests.where((request) => request.status != MaintenanceStatus.completed).toList();
});

final totalMonthlyRentProvider = Provider<double>((ref) {
  final tenants = ref.watch(tenantsProvider);
  return tenants.fold(0.0, (sum, tenant) => sum + tenant.rentAmount);
});

final occupiedPropertiesProvider = Provider<List<Property>>((ref) {
  final properties = ref.watch(propertiesProvider);
  return properties.where((property) => property.propertyStatus == PropertyStatus.occupied).toList();
});

final availablePropertiesProvider = Provider<List<Property>>((ref) {
  final properties = ref.watch(propertiesProvider);
  return properties.where((property) => property.propertyStatus == PropertyStatus.available).toList();
});

// Utility providers
final tenantsByPropertyProvider = Provider.family<List<Tenant>, String>((ref, propertyId) {
  final tenants = ref.watch(tenantsProvider);
  return tenants.where((tenant) => tenant.propertyId == propertyId).toList();
});

final paymentsByTenantProvider = Provider.family<List<RentPayment>, String>((ref, tenantId) {
  final payments = ref.watch(rentPaymentsProvider);
  return payments.where((payment) => payment.tenantId == tenantId).toList();
});

final requestsByTenantProvider = Provider.family<List<MaintenanceRequest>, String>((ref, tenantId) {
  final requests = ref.watch(maintenanceRequestsProvider);
  return requests.where((request) => request.tenantId == tenantId).toList();
});

final requestsByPropertyProvider = Provider.family<List<MaintenanceRequest>, String>((ref, propertyId) {
  final requests = ref.watch(maintenanceRequestsProvider);
  return requests.where((request) => request.propertyId == propertyId).toList();
});
