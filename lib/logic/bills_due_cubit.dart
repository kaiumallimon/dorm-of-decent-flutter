import 'package:dorm_of_decents/data/models/bills_due_response.dart';
import 'package:dorm_of_decents/data/services/api/bills_due.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class BillsDueState extends Equatable {
  @override
  List<Object?> get props => [];
}

class BillsDueInitial extends BillsDueState {}

class BillsDueLoading extends BillsDueState {}

class BillsDueLoaded extends BillsDueState {
  final BillsDueResponse billsDueResponse;

  BillsDueLoaded({required this.billsDueResponse});

  @override
  List<Object?> get props => [billsDueResponse];
}

class BillsDueFailure extends BillsDueState {
  final String error;

  BillsDueFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

class BillsDueCubit extends Cubit<BillsDueState> {
  BillsDueCubit() : super(BillsDueInitial());

  Future<void> fetchBillsDue() async {
    emit(BillsDueLoading());

    try {
      final billsDueApi = BillsDueApi();
      final billsDueResponse = await billsDueApi.fetchBillsDue();
      emit(BillsDueLoaded(billsDueResponse: billsDueResponse));
    } catch (e) {
      emit(BillsDueFailure(error: e.toString()));
    }
  }

  Future<void> refreshBillsDue() async {
    emit(BillsDueLoading());

    try {
      final billsDueApi = BillsDueApi();
      final billsDueResponse = await billsDueApi.fetchBillsDue();
      emit(BillsDueLoaded(billsDueResponse: billsDueResponse));
    } catch (e) {
      emit(BillsDueFailure(error: e.toString()));
    }
  }
}
