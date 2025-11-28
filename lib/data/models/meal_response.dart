import 'package:equatable/equatable.dart';

class MealResponse extends Equatable {
  final bool success;
  final List<Meal> meals;

  const MealResponse({required this.success, required this.meals});

  factory MealResponse.fromJson(Map<String, dynamic> json) {
    var mealsJson = json['data'] as List;
    List<Meal> mealsList = mealsJson
        .map((mealJson) => Meal.fromJson(mealJson))
        .toList();

    return MealResponse(success: json['success'], meals: mealsList);
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'meals': meals.map((meal) => meal.toJson()).toList(),
    };
  }

  /// Calculate total meals for all members
  double get overallMeals {
    return meals.fold(0.0, (sum, meal) => sum + meal.mealCount);
  }

  /// Calculate total number of entries
  int get totalEntries => meals.length;

  /// Calculate meal totals grouped by member
  Map<String, MemberMealTotal> get mealTotalsByMember {
    final Map<String, MemberMealTotal> totals = {};

    for (final meal in meals) {
      final userId = meal.userId;
      final userName = meal.profiles.name;

      if (totals.containsKey(userId)) {
        totals[userId] = totals[userId]!.copyWith(
          totalMeals: totals[userId]!.totalMeals + meal.mealCount,
          entries: totals[userId]!.entries + 1,
        );
      } else {
        totals[userId] = MemberMealTotal(
          userId: userId,
          userName: userName,
          totalMeals: meal.mealCount,
          entries: 1,
        );
      }
    }

    return totals;
  }

  /// Get sorted list of member totals (by total meals descending)
  List<MemberMealTotal> get sortedMemberTotals {
    final totals = mealTotalsByMember.values.toList();
    totals.sort((a, b) => b.totalMeals.compareTo(a.totalMeals));
    return totals;
  }

  @override
  List<Object?> get props => [success, meals];
}

/// Model for member meal totals
class MemberMealTotal extends Equatable {
  final String userId;
  final String userName;
  final double totalMeals;
  final int entries;

  const MemberMealTotal({
    required this.userId,
    required this.userName,
    required this.totalMeals,
    required this.entries,
  });

  MemberMealTotal copyWith({
    String? userId,
    String? userName,
    double? totalMeals,
    int? entries,
  }) {
    return MemberMealTotal(
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      totalMeals: totalMeals ?? this.totalMeals,
      entries: entries ?? this.entries,
    );
  }

  @override
  List<Object?> get props => [userId, userName, totalMeals, entries];
}

class Meal extends Equatable {
  final String id;
  final double mealCount;
  final DateTime date;
  final DateTime createdAt;
  final String userId;
  final String monthId;
  final MealProfile profiles;

  const Meal({
    required this.id,
    required this.mealCount,
    required this.date,
    required this.createdAt,
    required this.userId,
    required this.monthId,
    required this.profiles,
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      id: json['id'],
      mealCount: (json['meal_count'] as num).toDouble(),
      date: DateTime.parse(json['date']),
      createdAt: DateTime.parse(json['created_at']),
      userId: json['user_id'],
      monthId: json['month_id'],
      profiles: MealProfile.fromJson(json['profiles']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'meal_count': mealCount,
      'date': date.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'user_id': userId,
      'month_id': monthId,
      'profiles': profiles.toJson(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    mealCount,
    date,
    createdAt,
    userId,
    monthId,
    profiles,
  ];
}

class MealProfile extends Equatable {
  final String id;
  final String name;
  const MealProfile({required this.id, required this.name});

  factory MealProfile.fromJson(Map<String, dynamic> json) {
    return MealProfile(id: json['id'], name: json['name']);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }

  @override
  List<Object?> get props => [id, name];
}
