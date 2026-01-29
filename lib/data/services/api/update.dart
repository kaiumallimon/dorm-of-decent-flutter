import 'package:dorm_of_decents/data/models/app_update.dart';
import 'package:dorm_of_decents/data/services/client/supabase_client.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:io';

class UpdateApi {
  /// Check for available app updates
  Future<AppUpdate?> checkForUpdate() async {
    try {
      final supabase = SupabaseService.client;
      final packageInfo = await PackageInfo.fromPlatform();
      final currentBuildNumber = int.parse(packageInfo.buildNumber);

      // Get the platform
      final platform = Platform.isAndroid ? 'android' : 'ios';

      // Fetch the latest update from Supabase
      final response = await supabase
          .from('app_updates')
          .select('*')
          .eq('platform', platform)
          .eq('is_active', true)
          .order('build_number', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      final latestUpdate = AppUpdate.fromJson(response);

      // Check if update is available
      if (latestUpdate.buildNumber > currentBuildNumber) {
        return latestUpdate;
      }

      return null;
    } catch (e) {
      throw Exception('Failed to check for updates: ${e.toString()}');
    }
  }

  /// Check if current version is supported
  Future<bool> isVersionSupported() async {
    try {
      final supabase = SupabaseService.client;
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      final platform = Platform.isAndroid ? 'android' : 'ios';

      // Get minimum supported version
      final response = await supabase
          .from('app_updates')
          .select('min_supported_version')
          .eq('platform', platform)
          .eq('is_active', true)
          .order('build_number', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response == null) {
        return true; // Assume supported if no data
      }

      final minVersion = response['min_supported_version'] as String?;
      if (minVersion == null) {
        return true;
      }

      return _compareVersions(currentVersion, minVersion) >= 0;
    } catch (e) {
      return true; // Assume supported on error
    }
  }

  /// Download update file from Supabase Storage
  Future<String> downloadUpdate(String filePath) async {
    try {
      final supabase = SupabaseService.client;

      // Get the public URL for the file
      final url = supabase.storage.from('app-updates').getPublicUrl(filePath);

      return url;
    } catch (e) {
      throw Exception('Failed to get download URL: ${e.toString()}');
    }
  }

  /// Compare two version strings (e.g., "1.2.3" vs "1.2.4")
  /// Returns: -1 if v1 < v2, 0 if v1 == v2, 1 if v1 > v2
  int _compareVersions(String v1, String v2) {
    final v1Parts = v1.split('.').map(int.parse).toList();
    final v2Parts = v2.split('.').map(int.parse).toList();

    for (int i = 0; i < 3; i++) {
      final part1 = i < v1Parts.length ? v1Parts[i] : 0;
      final part2 = i < v2Parts.length ? v2Parts[i] : 0;

      if (part1 < part2) return -1;
      if (part1 > part2) return 1;
    }

    return 0;
  }
}
