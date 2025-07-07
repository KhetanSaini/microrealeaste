enum PaymentStatus { paid, overdue, upcoming, pending }

class RentPayment {
  final String id;
  final String tenantId;
  final double amount;
  final DateTime dueDate;
  final DateTime? paidDate;
  final PaymentStatus status;
  final String? notes;

  RentPayment({
    required this.id,
    required this.tenantId,
    required this.amount,
    required this.dueDate,
    this.paidDate,
    required this.status,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenantId': tenantId,
      'amount': amount,
      'dueDate': dueDate.toIso8601String(),
      'paidDate': paidDate?.toIso8601String(),
      'status': status.name,
      'notes': notes,
    };
  }

  factory RentPayment.fromJson(Map<String, dynamic> json) {
    return RentPayment(
      id: json['id'],
      tenantId: json['tenantId'],
      amount: json['amount'].toDouble(),
      dueDate: DateTime.parse(json['dueDate']),
      paidDate: json['paidDate'] != null ? DateTime.parse(json['paidDate']) : null,
      status: PaymentStatus.values.firstWhere((e) => e.name == json['status']),
      notes: json['notes'],
    );
  }

  RentPayment copyWith({
    String? id,
    String? tenantId,
    double? amount,
    DateTime? dueDate,
    DateTime? paidDate,
    PaymentStatus? status,
    String? notes,
  }) {
    return RentPayment(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      amount: amount ?? this.amount,
      dueDate: dueDate ?? this.dueDate,
      paidDate: paidDate ?? this.paidDate,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }

  bool get isOverdue =>
      status != PaymentStatus.paid &&
          DateTime.now().isAfter(dueDate);

  int get daysOverdue =>
      isOverdue ? DateTime.now().difference(dueDate).inDays : 0;
}