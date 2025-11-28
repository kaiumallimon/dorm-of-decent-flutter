import 'package:dorm_of_decents/data/models/dashboard_response.dart';
import 'package:dorm_of_decents/data/models/expense_response.dart';
import 'package:dorm_of_decents/data/services/api/dashboard.dart';
import 'package:dorm_of_decents/data/services/storage/user_storage.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardEmpty extends DashboardState {
  final String message;

  const DashboardEmpty(this.message);

  @override
  List<Object?> get props => [message];
}

class DashboardLoaded extends DashboardState {
  final DashboardResponse dashboardResponse;

  const DashboardLoaded({required this.dashboardResponse});

  @override
  List<Object?> get props => [dashboardResponse];
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError(this.message);

  @override
  List<Object?> get props => [message];
}

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit() : super(DashboardInitial());

  final DashboardApi _dashboardApi = DashboardApi();

  Future<void> fetchDashboardData() async {
    try {
      emit(DashboardLoading());

      final dashboardResponse = await _dashboardApi.fetchDashboardData();

      if (dashboardResponse.month == null) {
        emit(const DashboardEmpty('No active month found'));
        return;
      }

      emit(DashboardLoaded(dashboardResponse: dashboardResponse));
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }

  Future<void> refreshDashboardData() async {
    await fetchDashboardData();
  }
}
