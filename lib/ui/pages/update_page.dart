import 'package:dorm_of_decents/configs/colors.dart';
import 'package:dorm_of_decents/configs/routes.dart';
import 'package:dorm_of_decents/configs/theme.dart';
import 'package:dorm_of_decents/data/models/app_update.dart';
import 'package:dorm_of_decents/logic/update_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

class UpdatePage extends StatefulWidget {
  const UpdatePage({super.key});

  @override
  State<UpdatePage> createState() => _UpdatePageState();
}

class _UpdatePageState extends State<UpdatePage> {
  @override
  void initState() {
    super.initState();
    // Check for updates when page loads
    context.read<UpdateCubit>().checkForUpdate();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.getTheme(context);

    return WillPopScope(
      onWillPop: () async {
        // Check if it's a force update
        final state = context.read<UpdateCubit>().state;
        if (state is UpdateAvailable) {
          return !state.update.isForceUpdate;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: BlocConsumer<UpdateCubit, UpdateState>(
          listener: (context, state) {
            // If no update available, redirect to home
            if (state is UpdateNotAvailable) {
              context.go(AppRoutes.home);
            }
          },
          builder: (context, state) {
            if (state is UpdateChecking || state is UpdateInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is UpdateError) {
              // On error, redirect to home after a delay
              Future.delayed(const Duration(seconds: 2), () {
                if (mounted) context.go(AppRoutes.home);
              });
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to check for updates',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Redirecting to app...',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              );
            }

            if (state is UpdateAvailable) {
              return _buildUpdateContent(context, theme, state.update);
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildUpdateContent(BuildContext context, ThemeData theme, AppUpdate update) {
    return SafeArea(
      child: Column(
        children: [
          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      update.isForceUpdate
                          ? Icons.system_update_alt
                          : Icons.system_update,
                      size: 80,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Title
                  Text(
                    update.title,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),

                  // Version
                  Text(
                    'Version ${update.version}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Description
                  Text(
                    update.description,
                    style: theme.textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Features section
                  if (update.features.isNotEmpty) ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "What's New",
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...update.features.map(
                      (feature) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.star,
                              size: 20,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                feature,
                                style: theme.textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Bug fixes section
                  if (update.bugFixes.isNotEmpty) ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Bug Fixes',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...update.bugFixes.map(
                      (fix) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 20,
                              color: Colors.green.shade600,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                fix,
                                style: theme.textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Force update warning
                  if (update.isForceUpdate)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.orange.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.orange,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'This is a required update. Please update to continue using the app.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.orange.shade800,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Fixed bottom buttons
          Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                if (!update.isForceUpdate)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        context.read<UpdateCubit>().skipUpdate(update.version);
                        context.go(AppRoutes.home);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(
                          color: theme.colorScheme.outline,
                          width: 2,
                        ),
                      ),
                      child: const Text('Skip'),
                    ),
                  ),
                if (!update.isForceUpdate) const SizedBox(width: 16),
                Expanded(
                  flex: update.isForceUpdate ? 1 : 1,
                  child: ElevatedButton(
                    onPressed: () => _launchUpdate(context, update),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Update Now'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _launchUpdate(BuildContext context, AppUpdate update) async {
    String? url;

    if (Platform.isAndroid) {
      url = update.androidDownloadUrl ?? update.downloadUrl;
    } else if (Platform.isIOS) {
      url = update.iosDownloadUrl ?? update.downloadUrl;
    }

    if (url != null && url.isNotEmpty) {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open update link'),
            ),
          );
        }
      }
    }
  }
}
