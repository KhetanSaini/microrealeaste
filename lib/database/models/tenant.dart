class Tenant {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String propertyId;
  final double rentAmount;
  final DateTime moveInDate;
  final String? profileImage;

  Tenant({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.propertyId,
    required this.rentAmount,
    required this.moveInDate,
    this.profileImage,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'propertyId': propertyId,
      'rentAmount': rentAmount,
      'moveInDate': moveInDate.toIso8601String(),
      'profileImage': profileImage,
    };
  }

  factory Tenant.fromJson(Map<String, dynamic> json) {
    return Tenant(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      propertyId: json['propertyId'],
      rentAmount: json['rentAmount'].toDouble(),
      moveInDate: DateTime.parse(json['moveInDate']),
      profileImage: json['profileImage'],
    );
  }

  Tenant copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? propertyId,
    double? rentAmount,
    DateTime? moveInDate,
    String? profileImage,
  }) {
    return Tenant(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      propertyId: propertyId ?? this.propertyId,
      rentAmount: rentAmount ?? this.rentAmount,
      moveInDate: moveInDate ?? this.moveInDate,
      profileImage: profileImage ?? this.profileImage,
    );
  }
}