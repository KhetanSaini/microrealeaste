import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/tenant.dart';
import 'models/rent_payment.dart';
import 'models/maintenance_request.dart';
import 'models/property.dart';
import 'models/user.dart';
import 'models/organization.dart';

class StorageService {
  static const String _tenantsKey = 'tenants';
  static const String _paymentsKey = 'rent_payments';
  static const String _maintenanceKey = 'maintenance_requests';
  static const String _propertiesKey = 'properties';
  static const String _usersKey = 'users';
  static const String _organizationsKey = 'organizations';

  static Future<SharedPreferences> get _prefs async => await SharedPreferences.getInstance();

  // Tenant storage methods
  static Future<List<Tenant>> getTenants() async {
    final prefs = await _prefs;
    final tenantsJson = prefs.getString(_tenantsKey);
    if (tenantsJson == null) return [];

    final List<dynamic> decoded = jsonDecode(tenantsJson);
    return decoded.map((json) => Tenant.fromJson(json)).toList();
  }

  static Future<void> saveTenants(List<Tenant> tenants) async {
    final prefs = await _prefs;
    final encoded = jsonEncode(tenants.map((t) => t.toJson()).toList());
    await prefs.setString(_tenantsKey, encoded);
  }

  // Rent payment storage methods
  static Future<List<RentPayment>> getRentPayments() async {
    final prefs = await _prefs;
    final paymentsJson = prefs.getString(_paymentsKey);
    if (paymentsJson == null) return [];

    final List<dynamic> decoded = jsonDecode(paymentsJson);
    return decoded.map((json) => RentPayment.fromJson(json)).toList();
  }

  static Future<void> saveRentPayments(List<RentPayment> payments) async {
    final prefs = await _prefs;
    final encoded = jsonEncode(payments.map((p) => p.toJson()).toList());
    await prefs.setString(_paymentsKey, encoded);
  }

  // Maintenance request storage methods
  static Future<List<MaintenanceRequest>> getMaintenanceRequests() async {
    final prefs = await _prefs;
    final requestsJson = prefs.getString(_maintenanceKey);
    if (requestsJson == null) return [];

    final List<dynamic> decoded = jsonDecode(requestsJson);
    return decoded.map((json) => MaintenanceRequest.fromJson(json)).toList();
  }

  static Future<void> saveMaintenanceRequests(List<MaintenanceRequest> requests) async {
    final prefs = await _prefs;
    final encoded = jsonEncode(requests.map((r) => r.toJson()).toList());
    await prefs.setString(_maintenanceKey, encoded);
  }

  // Property storage methods
  static Future<List<Property>> getProperties() async {
    final prefs = await _prefs;
    final propertiesJson = prefs.getString(_propertiesKey);
    if (propertiesJson == null) return [];

    final List<dynamic> decoded = jsonDecode(propertiesJson);
    return decoded.map((json) => Property.fromJson(json)).toList();
  }

  static Future<void> saveProperties(List<Property> properties) async {
    final prefs = await _prefs;
    final encoded = jsonEncode(properties.map((p) => p.toJson()).toList());
    await prefs.setString(_propertiesKey, encoded);
  }

  // User storage methods
  static Future<List<User>> getUsers() async {
    final prefs = await _prefs;
    final usersJson = prefs.getString(_usersKey);
    if (usersJson == null) return [];

    final List<dynamic> decoded = jsonDecode(usersJson);
    return decoded.map((json) => User.fromJson(json)).toList();
  }

  static Future<void> saveUsers(List<User> users) async {
    final prefs = await _prefs;
    final encoded = jsonEncode(users.map((u) => u.toJson()).toList());
    await prefs.setString(_usersKey, encoded);
  }

  // Organization storage methods
  static Future<List<Organization>> getOrganizations() async {
    final prefs = await _prefs;
    final organizationsJson = prefs.getString(_organizationsKey);
    if (organizationsJson == null) return [];

    final List<dynamic> decoded = jsonDecode(organizationsJson);
    return decoded.map((json) => Organization.fromJson(json)).toList();
  }

  static Future<void> saveOrganizations(List<Organization> organizations) async {
    final prefs = await _prefs;
    final encoded = jsonEncode(organizations.map((o) => o.toJson()).toList());
    await prefs.setString(_organizationsKey, encoded);
  }

  // Clear all data
  static Future<void> clearAllData() async {
    final prefs = await _prefs;
    await prefs.remove(_tenantsKey);
    await prefs.remove(_paymentsKey);
    await prefs.remove(_maintenanceKey);
    await prefs.remove(_propertiesKey);
    await prefs.remove(_usersKey);
    await prefs.remove(_organizationsKey);
  }
}