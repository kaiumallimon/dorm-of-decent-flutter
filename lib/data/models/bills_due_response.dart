import 'package:dorm_of_decents/data/models/expense_response.dart';
import 'package:equatable/equatable.dart';

class BillsDueResponse extends Equatable {
  final ExpenseMonth? month;
  final List<BillDue> bills;
  final List<BillPayment> billPayments;
  final List<ProfileDue> profiles;

  const BillsDueResponse({
    this.month,
    required this.bills,
    required this.billPayments,
    required this.profiles,
  });

  factory BillsDueResponse.fromJson(Map<String, dynamic> json) {
    return BillsDueResponse(
      month: json['month'] != null ? ExpenseMonth.fromJson(json['month']) : null,
      bills: (json['bills'] as List<dynamic>?)
          ?.map((bill) => BillDue.fromJson(bill as Map<String, dynamic>))
          .toList() ?? [],
      billPayments: (json['billPayments'] as List<dynamic>?)
          ?.map((payment) => BillPayment.fromJson(payment as Map<String, dynamic>))
          .toList() ?? [],
      profiles: (json['profiles'] as List<dynamic>?)
          ?.map((profile) => ProfileDue.fromJson(profile as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  @override
  List<Object?> get props => [month, bills, billPayments, profiles];
}

class BillDue extends Equatable {
  final String id;
  final String billType;
  final double amount;
  final String paidBy;

  const BillDue({
    required this.id,
    required this.billType,
    required this.amount,
    required this.paidBy,
  });

  factory BillDue.fromJson(Map<String, dynamic> json) {
    return BillDue(
      id: json['id'] as String,
      billType: json['bill_type'] as String,
      amount: (json['amount'] is int)
          ? (json['amount'] as int).toDouble()
          : (json['amount'] as double? ?? 0.0),
      paidBy: json['paid_by'] as String,
    );
  }

  @override
  List<Object?> get props => [id, billType, amount, paidBy];
}

class BillPayment extends Equatable {
  final String billId;
  final String paidBy;
  final double amount;
  final BillPaymentBills bills;

  const BillPayment({
    required this.billId,
    required this.paidBy,
    required this.amount,
    required this.bills,
  });

  factory BillPayment.fromJson(Map<String, dynamic> json) {
    return BillPayment(
      billId: json['bill_id'] as String,
      paidBy: json['paid_by'] as String,
      amount: (json['amount'] is int)
          ? (json['amount'] as int).toDouble()
          : (json['amount'] as double? ?? 0.0),
      bills: BillPaymentBills.fromJson(json['bills'] as Map<String, dynamic>),
    );
  }

  @override
  List<Object?> get props => [billId, paidBy, amount, bills];
}

class BillPaymentBills extends Equatable {
  final String paidBy;
  final String monthId;

  const BillPaymentBills({
    required this.paidBy,
    required this.monthId,
  });

  factory BillPaymentBills.fromJson(Map<String, dynamic> json) {
    return BillPaymentBills(
      paidBy: json['paid_by'] as String,
      monthId: json['month_id'] as String,
    );
  }

  @override
  List<Object?> get props => [paidBy, monthId];
}

class ProfileDue extends Equatable {
  final String id;
  final String name;
  final String? phone;
  final String role;
  final bool isActive;

  const ProfileDue({
    required this.id,
    required this.name,
    this.phone,
    required this.role,
    required this.isActive,
  });

  factory ProfileDue.fromJson(Map<String, dynamic> json) {
    return ProfileDue(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String?,
      role: json['role'] as String? ?? 'member',
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  @override
  List<Object?> get props => [id, name, phone, role, isActive];
}
