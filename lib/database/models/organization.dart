enum SubscriptionPlan { free, basic, premium, enterprise }

class Organization {
  final String id;
  final String name;
  final String description;
  final String? logoUrl;
  final String address;
  final String? phoneNumber;
  final String? email;
  final SubscriptionPlan subscriptionPlan;
  final DateTime createdAt;
  final DateTime updatedAt;

  Organization({
    required this.id,
    required this.name,
    required this.description,
    this.logoUrl,
    required this.address,
    this.phoneNumber,
    this.email,
    this.subscriptionPlan = SubscriptionPlan.free,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'logoUrl': logoUrl,
      'address': address,
      'phoneNumber': phoneNumber,
      'email': email,
      'subscriptionPlan': subscriptionPlan.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Organization.fromJson(Map<String, dynamic> json) {
    return Organization(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      logoUrl: json['logoUrl'],
      address: json['address'],
      phoneNumber: json['phoneNumber'],
      email: json['email'],
      subscriptionPlan: SubscriptionPlan.values.firstWhere(
        (e) => e.name == json['subscriptionPlan'],
        orElse: () => SubscriptionPlan.free,
      ),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Organization copyWith({
    String? id,
    String? name,
    String? description,
    String? logoUrl,
    String? address,
    String? phoneNumber,
    String? email,
    SubscriptionPlan? subscriptionPlan,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Organization(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      logoUrl: logoUrl ?? this.logoUrl,
      address: address ?? this.address,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      subscriptionPlan: subscriptionPlan ?? this.subscriptionPlan,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get subscriptionDisplayName {
    switch (subscriptionPlan) {
      case SubscriptionPlan.free:
        return 'Free';
      case SubscriptionPlan.basic:
        return 'Basic';
      case SubscriptionPlan.premium:
        return 'Premium';
      case SubscriptionPlan.enterprise:
        return 'Enterprise';
    }
  }

  int get maxProperties {
    switch (subscriptionPlan) {
      case SubscriptionPlan.free:
        return 5;
      case SubscriptionPlan.basic:
        return 25;
      case SubscriptionPlan.premium:
        return 100;
      case SubscriptionPlan.enterprise:
        return -1; // Unlimited
    }
  }

  int get maxUsers {
    switch (subscriptionPlan) {
      case SubscriptionPlan.free:
        return 3;
      case SubscriptionPlan.basic:
        return 10;
      case SubscriptionPlan.premium:
        return 50;
      case SubscriptionPlan.enterprise:
        return -1; // Unlimited
    }
  }
}
