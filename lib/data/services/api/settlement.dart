import 'package:dorm_of_decents/data/models/settlement_response.dart';
import 'package:dorm_of_decents/data/services/client/supabase_client.dart';

class SettlementApi {
  /// Fetches settlement data including active month, meals, expenses, and profiles
  Future<SettlementResponse> fetchSettlementData() async {
    try {
      final supabase = SupabaseService.client;

      // 1. Get active month
      final monthResponse = await supabase
          .from('months')
          .select('*')
          .eq('status', 'active')
          .maybeSingle();

      if (monthResponse == null) {
        return const SettlementResponse(
          month: null,
          meals: [],
          expenses: [],
          profiles: [],
        );
      }

      final monthId = monthResponse['id'];

      // 2. Fetch meals, expenses, and profiles in parallel
      final results = await Future.wait([
        supabase
            .from('meals')
            .select('user_id, meal_count')
            .eq('month_id', monthId),
        supabase
            .from('expenses')
            .select('amount, added_by')
            .eq('month_id', monthId),
        supabase.from('profiles').select('*'),
      ]);

      final mealsData = results[0] as List;
      final expensesData = results[1] as List;
      final profilesData = results[2] as List;

      return SettlementResponse.fromJson({
        'month': monthResponse,
        'meals': mealsData,
        'expenses': expensesData,
        'profiles': profilesData,
      });
    } catch (e) {
      throw Exception('Failed to fetch settlement data: ${e.toString()}');
    }
  }

  /// Calculate settlement amounts for each user
  Map<String, Map<String, dynamic>> calculateSettlement(
    SettlementResponse data,
  ) {
    if (data.month == null) {
      return {};
    }

    // Calculate total meals per person
    final Map<String, double> mealTotals = {};
    for (var meal in data.meals) {
      mealTotals[meal.userId] = (mealTotals[meal.userId] ?? 0) + meal.mealCount;
    }

    // Calculate total expenses paid by each person
    final Map<String, double> expenseTotals = {};
    for (var expense in data.expenses) {
      expenseTotals[expense.addedBy] =
          (expenseTotals[expense.addedBy] ?? 0) + expense.amount;
    }

    // Calculate total meals and total expenses
    final totalMeals = mealTotals.values.fold<double>(
      0,
      (sum, count) => sum + count,
    );
    final totalExpenses = expenseTotals.values.fold<double>(
      0,
      (sum, amount) => sum + amount,
    );

    if (totalMeals == 0) {
      return {};
    }

    // Calculate meal rate
    final mealRate = totalExpenses / totalMeals;

    // Calculate settlement for each person
    final Map<String, Map<String, dynamic>> settlements = {};

    for (var profile in data.profiles) {
      final userId = profile.id;
      final userName = profile.name;
      final mealsConsumed = mealTotals[userId] ?? 0;
      final expensesPaid = expenseTotals[userId] ?? 0;
      final owedAmount = mealsConsumed * mealRate;
      final balance = expensesPaid - owedAmount;

      settlements[userId] = {
        'name': userName,
        'meals_consumed': mealsConsumed,
        'expenses_paid': expensesPaid,
        'owed_amount': owedAmount,
        'balance': balance,
        'meal_rate': mealRate,
      };
    }

    return settlements;
  }
}
