import 'package:dorm_of_decents/data/models/meal_response.dart';
import 'package:dorm_of_decents/data/services/api/meal.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class MealState extends Equatable {
  const MealState();

  @override
  List<Object> get props => [];
}

class MealInitial extends MealState {
  const MealInitial();
}

class MealLoading extends MealState {
  const MealLoading();
}

class MealLoaded extends MealState {
  final MealResponse mealResponse;

  const MealLoaded({required this.mealResponse});

  @override
  List<Object> get props => [mealResponse];
}

class MealError extends MealState {
  final String message;

  const MealError({required this.message});

  @override
  List<Object> get props => [message];
}

class MealEmpty extends MealState {
  const MealEmpty();

  @override
  List<Object> get props => [];
}

class MealCubit extends Cubit<MealState> {
  MealCubit() : super(const MealInitial());

  Future<void> fetchMeals() async {
    try {
      // Emit loading state
      emit(const MealLoading());

      // Fetch meals from API (automatically uses Supabase token)
      final mealApi = MealApi();
      final mealResponse = await mealApi.fetchMeals();

      if (mealResponse.meals.isEmpty) {
        emit(const MealEmpty());
      } else {
        emit(MealLoaded(mealResponse: mealResponse));
      }
    } catch (e) {
      emit(MealError(message: e.toString()));
    }
  }

  Future<void> refreshMeals() async {
    try {
      // Emit loading state to show shimmer
      emit(const MealLoading());

      // Fetch meals from API (automatically uses Supabase token)
      final mealApi = MealApi();
      final mealResponse = await mealApi.fetchMeals();

      if (mealResponse.meals.isEmpty) {
        emit(const MealEmpty());
      } else {
        emit(MealLoaded(mealResponse: mealResponse));
      }
    } catch (e) {
      emit(MealError(message: e.toString()));
    }
  }
}
