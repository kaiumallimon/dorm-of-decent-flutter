import 'package:equatable/equatable.dart';

class AppUpdate extends Equatable {
  final String version;
  final int buildNumber;
  final String title;
  final String description;
  final List<String> features;
  final List<String> bugFixes;
  final bool isForceUpdate;
  final String? downloadUrl;
  final String? androidDownloadUrl;
  final String? iosDownloadUrl;
  final String releaseDate;
  final String minSupportedVersion;

  const AppUpdate({
    required this.version,
    required this.buildNumber,
    required this.title,
    required this.description,
    required this.features,
    required this.bugFixes,
    required this.isForceUpdate,
    this.downloadUrl,
    this.androidDownloadUrl,
    this.iosDownloadUrl,
    required this.releaseDate,
    required this.minSupportedVersion,
  });

  factory AppUpdate.fromJson(Map<String, dynamic> json) {
    return AppUpdate(
      version: json['version'] ?? '',
      buildNumber: json['build_number'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      features: (json['features'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      bugFixes: (json['bug_fixes'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      isForceUpdate: json['is_force_update'] ?? false,
      downloadUrl: json['download_url'],
      androidDownloadUrl: json['android_download_url'],
      iosDownloadUrl: json['ios_download_url'],
      releaseDate: json['release_date'] ?? '',
      minSupportedVersion: json['min_supported_version'] ?? '1.0.0',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'build_number': buildNumber,
      'title': title,
      'description': description,
      'features': features,
      'bug_fixes': bugFixes,
      'is_force_update': isForceUpdate,
      'download_url': downloadUrl,
      'android_download_url': androidDownloadUrl,
      'ios_download_url': iosDownloadUrl,
      'release_date': releaseDate,
      'min_supported_version': minSupportedVersion,
    };
  }

  @override
  List<Object?> get props => [
        version,
        buildNumber,
        title,
        description,
        features,
        bugFixes,
        isForceUpdate,
        downloadUrl,
        androidDownloadUrl,
        iosDownloadUrl,
        releaseDate,
        minSupportedVersion,
      ];
}
