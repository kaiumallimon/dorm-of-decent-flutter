import 'package:equatable/equatable.dart';

class SettlementResponse extends Equatable {
  final SettlementMonth? month;
  final List<SettlementMeal> meals;
  final List<SettlementExpense> expenses;
  final List<SettlementProfile> profiles;

  const SettlementResponse({
    required this.month,
    required this.meals,
    required this.expenses,
    required this.profiles,
  });

  factory SettlementResponse.fromJson(Map<String, dynamic> json) {
    return SettlementResponse(
      month: json['month'] != null
          ? SettlementMonth.fromJson(json['month'])
          : null,
      meals: (json['meals'] as List)
          .map((m) => SettlementMeal.fromJson(m))
          .toList(),
      expenses: (json['expenses'] as List)
          .map((e) => SettlementExpense.fromJson(e))
          .toList(),
      profiles: (json['profiles'] as List)
          .map((p) => SettlementProfile.fromJson(p))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'month': month?.toJson(),
      'meals': meals.map((m) => m.toJson()).toList(),
      'expenses': expenses.map((e) => e.toJson()).toList(),
      'profiles': profiles.map((p) => p.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [month, meals, expenses, profiles];
}

class SettlementMonth extends Equatable {
  final String id;
  final String name;
  final String startDate;
  final String endDate;
  final String status;
  final String createdAt;

  const SettlementMonth({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.createdAt,
  });

  factory SettlementMonth.fromJson(Map<String, dynamic> json) {
    return SettlementMonth(
      id: json['id'],
      name: json['name'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      status: json['status'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'start_date': startDate,
      'end_date': endDate,
      'status': status,
      'created_at': createdAt,
    };
  }

  @override
  List<Object?> get props => [id, name, startDate, endDate, status, createdAt];
}

class SettlementMeal extends Equatable {
  final String userId;
  final double mealCount;

  const SettlementMeal({required this.userId, required this.mealCount});

  factory SettlementMeal.fromJson(Map<String, dynamic> json) {
    return SettlementMeal(
      userId: json['user_id'],
      mealCount: (json['meal_count'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'user_id': userId, 'meal_count': mealCount};
  }

  @override
  List<Object?> get props => [userId, mealCount];
}

class SettlementExpense extends Equatable {
  final double amount;
  final String addedBy;

  const SettlementExpense({required this.amount, required this.addedBy});

  factory SettlementExpense.fromJson(Map<String, dynamic> json) {
    return SettlementExpense(
      amount: (json['amount'] as num).toDouble(),
      addedBy: json['added_by'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'amount': amount, 'added_by': addedBy};
  }

  @override
  List<Object?> get props => [amount, addedBy];
}

class SettlementProfile extends Equatable {
  final String id;
  final String name;
  final String? phone;
  final String role;
  final String createdAt;

  const SettlementProfile({
    required this.id,
    required this.name,
    this.phone,
    required this.role,
    required this.createdAt,
  });

  factory SettlementProfile.fromJson(Map<String, dynamic> json) {
    return SettlementProfile(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      role: json['role'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'role': role,
      'created_at': createdAt,
    };
  }

  @override
  List<Object?> get props => [id, name, phone, role, createdAt];
}
