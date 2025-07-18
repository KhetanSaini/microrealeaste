
import 'dart:convert';
import 'package:microrealeaste/database/data_service.dart';
import 'package:microrealeaste/database/models/maintenance_request.dart';
import 'package:microrealeaste/database/models/organization.dart';
import 'package:microrealeaste/database/models/property.dart';
import 'package:microrealeaste/database/models/rent_payment.dart';
import 'package:microrealeaste/database/models/tenant.dart';
import 'package:microrealeaste/database/models/user.dart';

class BackupService {
  /// Creates a JSON string containing all user data.
  static Future<String> createBackupJson() async {
    final backupData = {
      'organizations': DataService.organizations.map((o) => o.toJson()).toList(),
      'users': DataService.users.map((u) => u.toJson()).toList(),
      'properties': DataService.properties.map((p) => p.toJson()).toList(),
      'tenants': DataService.tenants.map((t) => t.toJson()).toList(),
      'rentPayments': DataService.rentPayments.map((p) => p.toJson()).toList(),
      'maintenanceRequests': DataService.maintenanceRequests.map((r) => r.toJson()).toList(),
    };

    // Using JsonEncoder for pretty printing the output JSON
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(backupData);
  }

  /// Restores data from a JSON string.
  static Future<void> restoreFromBackup(String jsonString) async {
    final backupData = jsonDecode(jsonString) as Map<String, dynamic>;

    // Clear all existing data before restoring
    await DataService.clearAllData();

    // Restore organizations
    if (backupData['organizations'] != null) {
      final organizations = (backupData['organizations'] as List)
          .map((item) => Organization.fromJson(item as Map<String, dynamic>))
          .toList();
      for (final organization in organizations) {
        await DataService.addOrganization(organization);
      }
    }

    // Restore users
    if (backupData['users'] != null) {
      final users = (backupData['users'] as List)
          .map((item) => User.fromJson(item as Map<String, dynamic>))
          .toList();
      for (final user in users) {
        await DataService.addUser(user);
      }
    }

    // Restore properties
    if (backupData['properties'] != null) {
      final properties = (backupData['properties'] as List)
          .map((item) => Property.fromJson(item as Map<String, dynamic>))
          .toList();
      for (final property in properties) {
        await DataService.addProperty(property);
      }
    }

    // Restore tenants
    if (backupData['tenants'] != null) {
      final tenants = (backupData['tenants'] as List)
          .map((item) => Tenant.fromJson(item as Map<String, dynamic>))
          .toList();
      for (final tenant in tenants) {
        await DataService.addTenant(tenant);
      }
    }

    // Restore rent payments
    if (backupData['rentPayments'] != null) {
      final rentPayments = (backupData['rentPayments'] as List)
          .map((item) => RentPayment.fromJson(item as Map<String, dynamic>))
          .toList();
      for (final payment in rentPayments) {
        await DataService.addRentPayment(payment);
      }
    }

    // Restore maintenance requests
    if (backupData['maintenanceRequests'] != null) {
      final maintenanceRequests = (backupData['maintenanceRequests'] as List)
          .map((item) => MaintenanceRequest.fromJson(item as Map<String, dynamic>))
          .toList();
      for (final request in maintenanceRequests) {
        await DataService.addMaintenanceRequest(request);
      }
    }
  }
}
