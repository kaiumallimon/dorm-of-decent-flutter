import 'package:dorm_of_decents/data/models/settlement_response.dart';
import 'package:dorm_of_decents/data/services/api/settlement.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class SettlementState extends Equatable {
  const SettlementState();

  @override
  List<Object?> get props => [];
}

class SettlementInitial extends SettlementState {}

class SettlementLoading extends SettlementState {}

class SettlementEmpty extends SettlementState {
  final String message;

  const SettlementEmpty(this.message);

  @override
  List<Object?> get props => [message];
}

class SettlementLoaded extends SettlementState {
  final SettlementResponse settlementResponse;
  final Map<String, Map<String, dynamic>> settlements;

  const SettlementLoaded({
    required this.settlementResponse,
    required this.settlements,
  });

  @override
  List<Object?> get props => [settlementResponse, settlements];
}

class SettlementError extends SettlementState {
  final String message;

  const SettlementError(this.message);

  @override
  List<Object?> get props => [message];
}


class SettlementCubit extends Cubit<SettlementState> {
  SettlementCubit() : super(SettlementInitial());

  final SettlementApi _settlementApi = SettlementApi();

  Future<void> fetchSettlementData() async {
    try {
      emit(SettlementLoading());

      final settlementResponse = await _settlementApi.fetchSettlementData();

      if (settlementResponse.month == null) {
        emit(SettlementEmpty('No active month found'));
        return;
      }

      // Calculate settlements
      final settlements = _settlementApi.calculateSettlement(
        settlementResponse,
      );

      emit(
        SettlementLoaded(
          settlementResponse: settlementResponse,
          settlements: settlements,
        ),
      );
    } catch (e) {
      emit(SettlementError(e.toString()));
    }
  }

  Future<void> refreshSettlementData() async {
    await fetchSettlementData();
  }
}
