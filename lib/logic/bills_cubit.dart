import 'package:dorm_of_decents/data/models/bills.dart';
import 'package:dorm_of_decents/data/services/api/bills.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class BillsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class BillsInitial extends BillsState {
  @override
  List<Object?> get props => [];
}

class BillsLoading extends BillsState {
  @override
  List<Object?> get props => [];
}

class BillsLoaded extends BillsState {
  final BillsResponse billsResponse;

  BillsLoaded({required this.billsResponse});

  @override
  List<Object?> get props => [billsResponse];
}

class BillsFailure extends BillsState {
  final String error;

  BillsFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

class BillsCubit extends Cubit<BillsState> {
  BillsCubit() : super(BillsInitial());

  Future<void> fetchBills() async {
    emit(BillsLoading());

    try {
      final billsApi = BillsAPi();
      final billsResponse = await billsApi.fetchBills();
      emit(BillsLoaded(billsResponse: billsResponse));
    } catch (e) {
      emit(BillsFailure(error: e.toString()));
    }
  }

  Future<void> refreshBills() async {
    emit(BillsLoading());

    try {
      final billsApi = BillsAPi();
      final billsResponse = await billsApi.fetchBills();
      emit(BillsLoaded(billsResponse: billsResponse));
    } catch (e) {
      emit(BillsFailure(error: e.toString()));
    }
  }
}
