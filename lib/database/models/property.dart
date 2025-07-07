enum PropertyType { apartment, house, commercial, condo, townhouse, other }
enum PropertyStatus { available, occupied, maintenance, unavailable }

class Property {
  final String id;
  final String organizationId;
  final String landlordId;
  final String name;
  final String description;
  final PropertyType propertyType;
  final String address;
  final String city;
  final String state;
  final String zipCode;
  final String country;
  final double? latitude;
  final double? longitude;
  final int bedrooms;
  final int bathrooms;
  final double? squareFeet;
  final double? lotSize;
  final int? yearBuilt;
  final int parkingSpaces;
  final List<String> amenities;
  final double? marketValue;
  final double? purchasePrice;
  final PropertyStatus propertyStatus;
  final List<String> images;
  final DateTime createdAt;
  final DateTime updatedAt;

  Property({
    required this.id,
    required this.organizationId,
    required this.landlordId,
    required this.name,
    required this.description,
    required this.propertyType,
    required this.address,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.country,
    this.latitude,
    this.longitude,
    required this.bedrooms,
    required this.bathrooms,
    this.squareFeet,
    this.lotSize,
    this.yearBuilt,
    this.parkingSpaces = 0,
    this.amenities = const [],
    this.marketValue,
    this.purchasePrice,
    this.propertyStatus = PropertyStatus.available,
    this.images = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organizationId': organizationId,
      'landlordId': landlordId,
      'name': name,
      'description': description,
      'propertyType': propertyType.name,
      'address': address,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'squareFeet': squareFeet,
      'lotSize': lotSize,
      'yearBuilt': yearBuilt,
      'parkingSpaces': parkingSpaces,
      'amenities': amenities,
      'marketValue': marketValue,
      'purchasePrice': purchasePrice,
      'propertyStatus': propertyStatus.name,
      'images': images,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['id'],
      organizationId: json['organizationId'],
      landlordId: json['landlordId'],
      name: json['name'],
      description: json['description'],
      propertyType: PropertyType.values.firstWhere((e) => e.name == json['propertyType']),
      address: json['address'],
      city: json['city'],
      state: json['state'],
      zipCode: json['zipCode'],
      country: json['country'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      bedrooms: json['bedrooms'],
      bathrooms: json['bathrooms'],
      squareFeet: json['squareFeet']?.toDouble(),
      lotSize: json['lotSize']?.toDouble(),
      yearBuilt: json['yearBuilt'],
      parkingSpaces: json['parkingSpaces'] ?? 0,
      amenities: List<String>.from(json['amenities'] ?? []),
      marketValue: json['marketValue']?.toDouble(),
      purchasePrice: json['purchasePrice']?.toDouble(),
      propertyStatus: PropertyStatus.values.firstWhere((e) => e.name == json['propertyStatus']),
      images: List<String>.from(json['images'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Property copyWith({
    String? id,
    String? organizationId,
    String? landlordId,
    String? name,
    String? description,
    PropertyType? propertyType,
    String? address,
    String? city,
    String? state,
    String? zipCode,
    String? country,
    double? latitude,
    double? longitude,
    int? bedrooms,
    int? bathrooms,
    double? squareFeet,
    double? lotSize,
    int? yearBuilt,
    int? parkingSpaces,
    List<String>? amenities,
    double? marketValue,
    double? purchasePrice,
    PropertyStatus? propertyStatus,
    List<String>? images,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Property(
      id: id ?? this.id,
      organizationId: organizationId ?? this.organizationId,
      landlordId: landlordId ?? this.landlordId,
      name: name ?? this.name,
      description: description ?? this.description,
      propertyType: propertyType ?? this.propertyType,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      zipCode: zipCode ?? this.zipCode,
      country: country ?? this.country,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      bedrooms: bedrooms ?? this.bedrooms,
      bathrooms: bathrooms ?? this.bathrooms,
      squareFeet: squareFeet ?? this.squareFeet,
      lotSize: lotSize ?? this.lotSize,
      yearBuilt: yearBuilt ?? this.yearBuilt,
      parkingSpaces: parkingSpaces ?? this.parkingSpaces,
      amenities: amenities ?? this.amenities,
      marketValue: marketValue ?? this.marketValue,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      propertyStatus: propertyStatus ?? this.propertyStatus,
      images: images ?? this.images,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get fullAddress => '$address, $city, $state $zipCode';
  
  String get propertyTypeDisplayName {
    switch (propertyType) {
      case PropertyType.apartment:
        return 'Apartment';
      case PropertyType.house:
        return 'House';
      case PropertyType.commercial:
        return 'Commercial';
      case PropertyType.condo:
        return 'Condo';
      case PropertyType.townhouse:
        return 'Townhouse';
      case PropertyType.other:
        return 'Other';
    }
  }

  String get statusDisplayName {
    switch (propertyStatus) {
      case PropertyStatus.available:
        return 'Available';
      case PropertyStatus.occupied:
        return 'Occupied';
      case PropertyStatus.maintenance:
        return 'Under Maintenance';
      case PropertyStatus.unavailable:
        return 'Unavailable';
    }
  }
}
