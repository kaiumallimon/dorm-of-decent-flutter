import 'package:dorm_of_decents/data/models/logs_response.dart';
import 'package:dorm_of_decents/data/services/api/logs.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class LogsState extends Equatable {
  const LogsState();

  @override
  List<Object?> get props => [];
}

class LogsInitial extends LogsState {
  const LogsInitial();
}

class LogsLoading extends LogsState {
  const LogsLoading();
}

class LogsLoaded extends LogsState {
  final List<ActivityLog> logs;

  const LogsLoaded({required this.logs});

  @override
  List<Object?> get props => [logs];
}

class LogsError extends LogsState {
  final String message;

  const LogsError({required this.message});

  @override
  List<Object?> get props => [message];
}

class LogsEmpty extends LogsState {
  const LogsEmpty();
}

class LogsCubit extends Cubit<LogsState> {
  LogsCubit() : super(const LogsInitial());

  final LogsApi _logsApi = LogsApi();

  Future<void> fetchLogs() async {
    emit(const LogsLoading());
    try {
      final logs = await _logsApi.fetchLogs();
      if (logs.isEmpty) {
        emit(const LogsEmpty());
      } else {
        emit(LogsLoaded(logs: logs));
      }
    } catch (e) {
      emit(LogsError(message: e.toString()));
    }
  }
}
