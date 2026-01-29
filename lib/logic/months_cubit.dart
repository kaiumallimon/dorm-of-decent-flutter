import 'package:dorm_of_decents/data/models/expense_response.dart';
import 'package:dorm_of_decents/data/services/api/months.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class MonthsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class MonthsInitial extends MonthsState {}

class MonthsLoading extends MonthsState {}

class MonthsLoaded extends MonthsState {
  final List<ExpenseMonth> months;

  MonthsLoaded({required this.months});

  @override
  List<Object?> get props => [months];
}

class MonthsFailure extends MonthsState {
  final String error;

  MonthsFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

class MonthsCubit extends Cubit<MonthsState> {
  final MonthsApi _monthsApi = MonthsApi();

  MonthsCubit() : super(MonthsInitial());

  Future<void> fetchMonths() async {
    try {
      emit(MonthsLoading());
      final months = await _monthsApi.fetchMonths();
      emit(MonthsLoaded(months: months));
    } catch (e) {
      emit(MonthsFailure(error: e.toString()));
    }
  }

  Future<void> refreshMonths() async {
    try {
      final months = await _monthsApi.fetchMonths();
      emit(MonthsLoaded(months: months));
    } catch (e) {
      emit(MonthsFailure(error: e.toString()));
    }
  }
}