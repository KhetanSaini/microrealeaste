enum MaintenancePriority { low, medium, high, urgent }
enum MaintenanceStatus { pending, inProgress, completed, cancelled }

class MaintenanceRequest {
  final String id;
  final String tenantId;
  final String propertyId;
  final String title;
  final String description;
  final MaintenancePriority priority;
  final MaintenanceStatus status;
  final DateTime createdDate;
  final DateTime? completedDate;
  final String? notes;
  final List<String> images;

  MaintenanceRequest({
    required this.id,
    required this.tenantId,
    required this.propertyId,
    required this.title,
    required this.description,
    required this.priority,
    required this.status,
    required this.createdDate,
    this.completedDate,
    this.notes,
    this.images = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenantId': tenantId,
      'propertyId': propertyId,
      'title': title,
      'description': description,
      'priority': priority.name,
      'status': status.name,
      'createdDate': createdDate.toIso8601String(),
      'completedDate': completedDate?.toIso8601String(),
      'notes': notes,
      'images': images,
    };
  }

  factory MaintenanceRequest.fromJson(Map<String, dynamic> json) {
    return MaintenanceRequest(
      id: json['id'],
      tenantId: json['tenantId'],
      propertyId: json['propertyId'],
      title: json['title'],
      description: json['description'],
      priority: MaintenancePriority.values.firstWhere((e) => e.name == json['priority']),
      status: MaintenanceStatus.values.firstWhere((e) => e.name == json['status']),
      createdDate: DateTime.parse(json['createdDate']),
      completedDate: json['completedDate'] != null ? DateTime.parse(json['completedDate']) : null,
      notes: json['notes'],
      images: List<String>.from(json['images'] ?? []),
    );
  }

  MaintenanceRequest copyWith({
    String? id,
    String? tenantId,
    String? propertyId,
    String? title,
    String? description,
    MaintenancePriority? priority,
    MaintenanceStatus? status,
    DateTime? createdDate,
    DateTime? completedDate,
    String? notes,
    List<String>? images,
  }) {
    return MaintenanceRequest(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      propertyId: propertyId ?? this.propertyId,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      createdDate: createdDate ?? this.createdDate,
      completedDate: completedDate ?? this.completedDate,
      notes: notes ?? this.notes,
      images: images ?? this.images,
    );
  }

  int get daysSinceCreated => DateTime.now().difference(createdDate).inDays;
}