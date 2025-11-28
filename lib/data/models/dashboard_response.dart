import 'package:equatable/equatable.dart';

class DashboardResponse extends Equatable {
  final DashboardMonth? month;
  final List<DashboardMeal> meals;
  final List<DashboardExpense> expenses;
  final int memberCount;
  final List<UserMealBreakdown> userMealBreakdown;

  const DashboardResponse({
    required this.month,
    required this.meals,
    required this.expenses,
    required this.memberCount,
    required this.userMealBreakdown,
  });

  // Computed properties
  double get totalExpenses =>
      expenses.fold<double>(0.0, (sum, e) => sum + e.amount);

  double get totalMeals =>
      meals.fold<double>(0.0, (sum, m) => sum + m.mealCount);

  double get mealRate => totalMeals > 0 ? totalExpenses / totalMeals : 0.0;

  int get daysActive {
    if (meals.isEmpty) return 0;
    final uniqueDates = meals.map((m) => m.date).toSet();
    return uniqueDates.length;
  }

  double get avgMealsPerPerson =>
      memberCount > 0 ? totalMeals / memberCount : 0.0;

  double get dailyExpenseAverage =>
      daysActive > 0 ? totalExpenses / daysActive : 0.0;

  int get totalTransactions => expenses.length;

  double get expensesPerDay =>
      daysActive > 0 ? totalTransactions / daysActive.toDouble() : 0.0;

  // Calculate week-over-week trend
  double get weeklyTrend {
    if (meals.isEmpty) return 0.0;

    final now = DateTime.now();
    final lastWeekStart = now.subtract(const Duration(days: 7));
    final previousWeekStart = now.subtract(const Duration(days: 14));

    final lastWeekMeals = meals
        .where((m) {
          final date = DateTime.parse(m.date);
          return date.isAfter(lastWeekStart);
        })
        .fold<double>(0.0, (sum, m) => sum + m.mealCount);

    final previousWeekMeals = meals
        .where((m) {
          final date = DateTime.parse(m.date);
          return date.isAfter(previousWeekStart) &&
              date.isBefore(lastWeekStart);
        })
        .fold<double>(0.0, (sum, m) => sum + m.mealCount);

    if (previousWeekMeals == 0) return 0.0;
    return ((lastWeekMeals - previousWeekMeals) / previousWeekMeals) * 100;
  }

  // Get top meal consumers
  List<TopConsumer> get topMealConsumers {
    final userMeals = <String, TopConsumer>{};

    for (var breakdown in userMealBreakdown) {
      if (userMeals.containsKey(breakdown.userId)) {
        userMeals[breakdown.userId]!.addMeals(breakdown.mealCount);
      } else {
        userMeals[breakdown.userId] = TopConsumer(
          userId: breakdown.userId,
          name: breakdown.profiles.name,
          totalMeals: breakdown.mealCount,
          totalAmount: 0,
          transactionCount: 0,
        );
      }
    }

    final consumers = userMeals.values.toList()
      ..sort((a, b) => b.totalMeals.compareTo(a.totalMeals));

    // Calculate percentages
    for (var consumer in consumers) {
      consumer.percentage = totalMeals > 0
          ? (consumer.totalMeals / totalMeals) * 100
          : 0;
      consumer.cost = consumer.totalMeals * mealRate;
    }

    return consumers.take(5).toList();
  }

  // Get top contributors (by expenses)
  List<TopContributor> get topContributors {
    final userExpenses = <String, TopContributor>{};

    for (var expense in expenses) {
      if (userExpenses.containsKey(expense.addedBy)) {
        userExpenses[expense.addedBy]!.addExpense(expense.amount);
      } else {
        userExpenses[expense.addedBy] = TopContributor(
          userId: expense.addedBy,
          name: expense.profiles.name,
          totalAmount: expense.amount,
          transactionCount: 1,
        );
      }
    }

    final contributors = userExpenses.values.toList()
      ..sort((a, b) => b.totalAmount.compareTo(a.totalAmount));

    // Calculate percentages
    for (var contributor in contributors) {
      contributor.percentage = totalExpenses > 0
          ? (contributor.totalAmount / totalExpenses) * 100
          : 0;
    }

    return contributors.take(5).toList();
  }

  // Get expenses by category
  Map<String, double> get expensesByCategory {
    final categories = <String, double>{};
    for (var expense in expenses) {
      categories[expense.category] =
          (categories[expense.category] ?? 0) + expense.amount;
    }
    return categories;
  }

  // Get recent expenses (last 10)
  List<DashboardExpense> get recentExpenses {
    return expenses.take(10).toList();
  }

  // Projected total for the month
  double get projectedTotal {
    if (month == null || daysActive == 0) return totalExpenses;

    final startDate = DateTime.parse(month!.startDate);
    final endDate = DateTime.parse(month!.endDate);
    final totalDays = endDate.difference(startDate).inDays + 1;

    return (totalExpenses / daysActive) * totalDays;
  }

  factory DashboardResponse.fromJson(Map<String, dynamic> json) {
    return DashboardResponse(
      month: json['month'] != null
          ? DashboardMonth.fromJson(json['month'])
          : null,
      meals: (json['meals'] as List? ?? [])
          .map((m) => DashboardMeal.fromJson(m))
          .toList(),
      expenses: (json['expenses'] as List? ?? [])
          .map((e) => DashboardExpense.fromJson(e))
          .toList(),
      memberCount: json['memberCount'] ?? 0,
      userMealBreakdown: (json['userMealBreakdown'] as List? ?? [])
          .map((u) => UserMealBreakdown.fromJson(u))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'month': month?.toJson(),
      'meals': meals.map((m) => m.toJson()).toList(),
      'expenses': expenses.map((e) => e.toJson()).toList(),
      'memberCount': memberCount,
      'userMealBreakdown': userMealBreakdown.map((u) => u.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [
    month,
    meals,
    expenses,
    memberCount,
    userMealBreakdown,
  ];
}

class DashboardMonth extends Equatable {
  final String id;
  final String name;
  final String startDate;
  final String endDate;
  final String status;
  final String createdAt;

  const DashboardMonth({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.createdAt,
  });

  factory DashboardMonth.fromJson(Map<String, dynamic> json) {
    return DashboardMonth(
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

class DashboardMeal extends Equatable {
  final String userId;
  final double mealCount;
  final String date;

  const DashboardMeal({
    required this.userId,
    required this.mealCount,
    required this.date,
  });

  factory DashboardMeal.fromJson(Map<String, dynamic> json) {
    return DashboardMeal(
      userId: json['user_id'] ?? '',
      mealCount: (json['meal_count'] as num).toDouble(),
      date: json['date'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'user_id': userId, 'meal_count': mealCount, 'date': date};
  }

  @override
  List<Object?> get props => [userId, mealCount, date];
}

class DashboardExpense extends Equatable {
  final String id;
  final double amount;
  final String category;
  final String date;
  final String description;
  final String addedBy;
  final ExpenseProfile profiles;

  const DashboardExpense({
    required this.id,
    required this.amount,
    required this.category,
    required this.date,
    required this.description,
    required this.addedBy,
    required this.profiles,
  });

  factory DashboardExpense.fromJson(Map<String, dynamic> json) {
    return DashboardExpense(
      id: json['id'] ?? '',
      amount: (json['amount'] as num).toDouble(),
      category: json['category'] ?? '',
      date: json['date'] ?? '',
      description: json['description'] ?? '',
      addedBy: json['added_by'] ?? '',
      profiles: ExpenseProfile.fromJson(json['profiles'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'category': category,
      'date': date,
      'description': description,
      'added_by': addedBy,
      'profiles': profiles.toJson(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    amount,
    category,
    date,
    description,
    addedBy,
    profiles,
  ];
}

class ExpenseProfile extends Equatable {
  final String name;

  const ExpenseProfile({required this.name});

  factory ExpenseProfile.fromJson(Map<String, dynamic> json) {
    return ExpenseProfile(name: json['name'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'name': name};
  }

  @override
  List<Object?> get props => [name];
}

class UserMealBreakdown extends Equatable {
  final String userId;
  final double mealCount;
  final MealBreakdownProfile profiles;

  const UserMealBreakdown({
    required this.userId,
    required this.mealCount,
    required this.profiles,
  });

  factory UserMealBreakdown.fromJson(Map<String, dynamic> json) {
    return UserMealBreakdown(
      userId: json['user_id'] ?? '',
      mealCount: (json['meal_count'] as num).toDouble(),
      profiles: MealBreakdownProfile.fromJson(json['profiles'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'meal_count': mealCount,
      'profiles': profiles.toJson(),
    };
  }

  @override
  List<Object?> get props => [userId, mealCount, profiles];
}

class MealBreakdownProfile extends Equatable {
  final String name;

  const MealBreakdownProfile({required this.name});

  factory MealBreakdownProfile.fromJson(Map<String, dynamic> json) {
    return MealBreakdownProfile(name: json['name'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'name': name};
  }

  @override
  List<Object?> get props => [name];
}

// Helper classes for computed data
class TopConsumer {
  final String userId;
  final String name;
  double totalMeals;
  double percentage;
  double cost;
  final int transactionCount;

  TopConsumer({
    required this.userId,
    required this.name,
    required this.totalMeals,
    required double totalAmount,
    required this.transactionCount,
  }) : percentage = 0,
       cost = 0;

  void addMeals(double meals) {
    totalMeals += meals;
  }
}

class TopContributor {
  final String userId;
  final String name;
  double totalAmount;
  int transactionCount;
  double percentage;

  TopContributor({
    required this.userId,
    required this.name,
    required this.totalAmount,
    required this.transactionCount,
  }) : percentage = 0;

  void addExpense(double amount) {
    totalAmount += amount;
    transactionCount++;
  }
}
