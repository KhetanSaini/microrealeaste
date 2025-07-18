/// Lease model for lease management
class Lease {
  final String id;
  final String propertyId;
  final String tenantId;
  final DateTime startDate;
  final DateTime endDate;
  final double rentAmount;
  final double securityDeposit;
  final bool digitallySigned;
  final bool autoRenew;
  final List<String> documentUrls;

  Lease({
    required this.id,
    required this.propertyId,
    required this.tenantId,
    required this.startDate,
    required this.endDate,
    required this.rentAmount,
    required this.securityDeposit,
    this.digitallySigned = false,
    this.autoRenew = false,
    this.documentUrls = const [],
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'propertyId': propertyId,
    'tenantId': tenantId,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'rentAmount': rentAmount,
    'securityDeposit': securityDeposit,
    'digitallySigned': digitallySigned,
    'autoRenew': autoRenew,
    'documentUrls': documentUrls,
  };

  factory Lease.fromJson(Map<String, dynamic> json) => Lease(
    id: json['id'],
    propertyId: json['propertyId'],
    tenantId: json['tenantId'],
    startDate: DateTime.parse(json['startDate']),
    endDate: DateTime.parse(json['endDate']),
    rentAmount: (json['rentAmount'] as num).toDouble(),
    securityDeposit: (json['securityDeposit'] as num).toDouble(),
    digitallySigned: json['digitallySigned'] ?? false,
    autoRenew: json['autoRenew'] ?? false,
    documentUrls: List<String>.from(json['documentUrls'] ?? []),
  );
} 