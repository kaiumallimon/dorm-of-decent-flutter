import 'package:dorm_of_decents/data/models/expense_response.dart';
import 'package:dorm_of_decents/data/services/api/expense.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class ExpenseState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ExpenseInitial extends ExpenseState {
  @override
  List<Object?> get props => [];
}

class ExpenseLoading extends ExpenseState {
  @override
  List<Object?> get props => [];
}

class ExpenseLoaded extends ExpenseState {
  final ExpenseResponse expenseResponse;

  ExpenseLoaded({required this.expenseResponse});

  @override
  List<Object?> get props => [expenseResponse];
}

class ExpenseFailure extends ExpenseState {
  final String error;

  ExpenseFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

class ExpenseCubit extends Cubit<ExpenseState> {
  ExpenseCubit() : super(ExpenseInitial());

  Future<void> fetchExpenses() async {
    emit(ExpenseLoading());

    try {
      final expenseApi = ExpenseApi();
      final expenseResponse = await expenseApi.fetchExpenses();
      emit(ExpenseLoaded(expenseResponse: expenseResponse));
    } catch (e) {
      emit(ExpenseFailure(error: e.toString()));
    }
  }

  Future<void> refreshExpenses() async {
    emit(ExpenseLoading());

    try {
      final expenseApi = ExpenseApi();
      final expenseResponse = await expenseApi.fetchExpenses();
      emit(ExpenseLoaded(expenseResponse: expenseResponse));
    } catch (e) {
      emit(ExpenseFailure(error: e.toString()));
    }
  }
}
