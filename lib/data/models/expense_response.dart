import 'package:equatable/equatable.dart';

class ExpenseResponse extends Equatable {
  final ExpenseMonth expenseMonth;
  final List<Expense> expenses;
  final UserData userData;

  const ExpenseResponse({
    required this.expenseMonth,
    required this.expenses,
    required this.userData,
  });

  factory ExpenseResponse.fromJson(Map<String, dynamic> json) {
    var expensesJson = json['expenses'] as List;
    List<Expense> expensesList = expensesJson
        .map((expenseJson) => Expense.fromJson(expenseJson))
        .toList();

    return ExpenseResponse(
      expenseMonth: ExpenseMonth.fromJson(json['month']),
      expenses: expensesList,
      userData: UserData.fromJson(json['user']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'month': expenseMonth.toJson(),
      'expenses': expenses.map((expense) => expense.toJson()).toList(),
      'user': userData.toJson(),
    };
  }

  @override
  List<Object?> get props => [expenseMonth, expenses, userData];
}

class UserData extends Equatable {
  final String id;
  final String email;
  final String fullName;

  const UserData({
    required this.id,
    required this.email,
    required this.fullName,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    final userMetadata = json['user_metadata'] as Map<String, dynamic>;

    return UserData(
      id: json['id'] as String,
      email: userMetadata['email'] as String,
      fullName: userMetadata['full_name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'email': email, 'full_name': fullName};
  }

  @override
  List<Object?> get props => [id, email, fullName];
}

class ExpenseMonth extends Equatable {
  final String id;
  final String monthName;
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  final DateTime createdAt;

  const ExpenseMonth({
    required this.id,
    required this.monthName,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.createdAt,
  });

  factory ExpenseMonth.fromJson(Map<String, dynamic> json) {
    return ExpenseMonth(
      id: json['id'],
      monthName: json['name'],
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': monthName,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    monthName,
    startDate,
    endDate,
    status,
    createdAt,
  ];
}

class Expense extends Equatable {
  final String id;
  final double amount;
  final String category;
  final String description;
  final DateTime date;
  final DateTime createdAt;
  final ExpenseProfile profiles;

  const Expense({
    required this.id,
    required this.amount,
    required this.category,
    required this.description,
    required this.date,
    required this.createdAt,
    required this.profiles,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'],
      amount: (json['amount'] as num).toDouble(),
      category: json['category'],
      description: json['description'] ?? '',
      date: DateTime.parse(json['date']),
      createdAt: DateTime.parse(json['created_at']),
      profiles: ExpenseProfile.fromJson(
        json['profiles'] as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'category': category,
      'description': description,
      'date': date.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'profiles': profiles.toJson(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    amount,
    category,
    description,
    date,
    createdAt,
    profiles,
  ];
}

class ExpenseProfile extends Equatable {
  final String id;
  final String name;
  const ExpenseProfile({required this.id, required this.name});

  factory ExpenseProfile.fromJson(Map<String, dynamic> json) {
    return ExpenseProfile(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }

  @override
  List<Object?> get props => [id, name];
}
