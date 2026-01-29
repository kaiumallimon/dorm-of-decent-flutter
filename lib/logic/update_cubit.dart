import 'package:dorm_of_decents/data/models/app_update.dart';
import 'package:dorm_of_decents/data/services/api/update.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class UpdateState extends Equatable {
  const UpdateState();

  @override
  List<Object?> get props => [];
}

class UpdateInitial extends UpdateState {}

class UpdateChecking extends UpdateState {}

class UpdateAvailable extends UpdateState {
  final AppUpdate update;

  const UpdateAvailable(this.update);

  @override
  List<Object?> get props => [update];
}

class UpdateNotAvailable extends UpdateState {}

class UpdateError extends UpdateState {
  final String message;

  const UpdateError(this.message);

  @override
  List<Object?> get props => [message];
}

class UpdateSkipped extends UpdateState {
  final AppUpdate update;

  const UpdateSkipped(this.update);

  @override
  List<Object?> get props => [update];
}

class UpdateCubit extends Cubit<UpdateState> {
  UpdateCubit() : super(UpdateInitial());

  final UpdateApi _updateApi = UpdateApi();
  String? _skippedVersionThisSession; // Only stored in memory, not persisted

  /// Check for app updates
  Future<void> checkForUpdate({bool showNoUpdateMessage = false}) async {
    try {
      emit(UpdateChecking());

      final update = await _updateApi.checkForUpdate();

      if (update == null) {
        emit(UpdateNotAvailable());
        return;
      }

      // Check if this version was skipped in current session only
      if (_skippedVersionThisSession == update.version && !update.isForceUpdate) {
        emit(UpdateSkipped(update));
        return;
      }

      emit(UpdateAvailable(update));
    } catch (e) {
      emit(UpdateError(e.toString()));
    }
  }

  /// Check if current version is supported
  Future<bool> isVersionSupported() async {
    return await _updateApi.isVersionSupported();
  }

  /// Skip this update (only for optional updates, only for current session)
  Future<void> skipUpdate(String version) async {
    try {
      // Store only in memory, not persisted to storage
      _skippedVersionThisSession = version;

      if (state is UpdateAvailable) {
        emit(UpdateSkipped((state as UpdateAvailable).update));
      }
    } catch (e) {
      // Ignore errors when skipping
    }
  }

  /// Clear skipped update (for current session)
  Future<void> clearSkippedUpdate() async {
    _skippedVersionThisSession = null;
  }

  /// Get download URL for update
  Future<String> getDownloadUrl(String filePath) async {
    return await _updateApi.downloadUpdate(filePath);
  }

  /// Reset state to initial
  void reset() {
    emit(UpdateInitial());
  }
}
