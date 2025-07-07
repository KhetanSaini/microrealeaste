enum UserRole { superAdmin, organizationAdmin, landlord, propertyManager, tenant, maintenanceStaff }

class User {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? phoneNumber;
  final UserRole role;
  final String? organizationId;
  final String? profilePhotoUrl;
  final bool isActive;
  final bool emailVerified;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phoneNumber,
    required this.role,
    this.organizationId,
    this.profilePhotoUrl,
    this.isActive = true,
    this.emailVerified = false,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'role': role.name,
      'organizationId': organizationId,
      'profilePhotoUrl': profilePhotoUrl,
      'isActive': isActive,
      'emailVerified': emailVerified,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      phoneNumber: json['phoneNumber'],
      role: UserRole.values.firstWhere((e) => e.name == json['role']),
      organizationId: json['organizationId'],
      profilePhotoUrl: json['profilePhotoUrl'],
      isActive: json['isActive'] ?? true,
      emailVerified: json['emailVerified'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  User copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    UserRole? role,
    String? organizationId,
    String? profilePhotoUrl,
    bool? isActive,
    bool? emailVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      organizationId: organizationId ?? this.organizationId,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      isActive: isActive ?? this.isActive,
      emailVerified: emailVerified ?? this.emailVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get fullName => '$firstName $lastName';
  
  String get roleDisplayName {
    switch (role) {
      case UserRole.superAdmin:
        return 'Super Admin';
      case UserRole.organizationAdmin:
        return 'Organization Admin';
      case UserRole.landlord:
        return 'Landlord';
      case UserRole.propertyManager:
        return 'Property Manager';
      case UserRole.tenant:
        return 'Tenant';
      case UserRole.maintenanceStaff:
        return 'Maintenance Staff';
    }
  }

  bool get canManageProperties => [
    UserRole.superAdmin,
    UserRole.organizationAdmin,
    UserRole.landlord,
    UserRole.propertyManager,
  ].contains(role);

  bool get canManageTenants => [
    UserRole.superAdmin,
    UserRole.organizationAdmin,
    UserRole.landlord,
    UserRole.propertyManager,
  ].contains(role);

  bool get canManagePayments => [
    UserRole.superAdmin,
    UserRole.organizationAdmin,
    UserRole.landlord,
    UserRole.propertyManager,
  ].contains(role);

  bool get canManageMaintenance => [
    UserRole.superAdmin,
    UserRole.organizationAdmin,
    UserRole.landlord,
    UserRole.propertyManager,
    UserRole.maintenanceStaff,
  ].contains(role);
}
