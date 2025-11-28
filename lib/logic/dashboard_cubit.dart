import 'package:dorm_of_decents/data/models/dashboard_response.dart';
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
  final String userName;

  const DashboardLoaded({required this.dashboardResponse, this.userName = ''});

  @override
  List<Object?> get props => [dashboardResponse, userName];
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
  String _userName = '';

  Future<void> fetchDashboardData() async {
    try {
      emit(DashboardLoading());

      // Fetch user name only once if not already fetched
      if (_userName.isEmpty) {
        final userData = await UserStorage.getUserData();
        _userName = userData?.name ?? '';
      }

      final dashboardResponse = await _dashboardApi.fetchDashboardData();

      if (dashboardResponse.month == null) {
        emit(const DashboardEmpty('No active month found'));
        return;
      }

      emit(
        DashboardLoaded(
          dashboardResponse: dashboardResponse,
          userName: _userName,
        ),
      );
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }

  Future<void> refreshDashboardData() async {
    await fetchDashboardData();
  }
}
