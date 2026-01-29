import 'package:dorm_of_decents/data/models/app_update.dart';
import 'package:dorm_of_decents/data/services/api/update.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  /// Check for app updates
  Future<void> checkForUpdate({bool showNoUpdateMessage = false}) async {
    try {
      emit(UpdateChecking());

      final update = await _updateApi.checkForUpdate();

      if (update == null) {
        emit(UpdateNotAvailable());
        return;
      }

      // Check if this version was skipped
      final prefs = await SharedPreferences.getInstance();
      final skippedVersion = prefs.getString('skipped_update_version');

      if (skippedVersion == update.version && !update.isForceUpdate) {
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

  /// Skip this update (only for optional updates)
  Future<void> skipUpdate(String version) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('skipped_update_version', version);

      if (state is UpdateAvailable) {
        emit(UpdateSkipped((state as UpdateAvailable).update));
      }
    } catch (e) {
      // Ignore errors when skipping
    }
  }

  /// Clear skipped update
  Future<void> clearSkippedUpdate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('skipped_update_version');
    } catch (e) {
      // Ignore errors
    }
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
