import 'package:dorm_of_decents/configs/routes.dart';
import 'package:dorm_of_decents/configs/theme.dart';
import 'package:dorm_of_decents/logic/auth_cubit.dart';
import 'package:dorm_of_decents/ui/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:toastification/toastification.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.getTheme(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          if (state is! AuthAuthenticated) {
            return const Center(child: Text('Not authenticated'));
          }

          final userData = state.userData;

          return SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomPageHeader(theme: theme, title: 'Account & Settings'),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      // try {
                      //   await context.read<AuthCubit>().refreshUserProfile();
                      //   if (context.mounted) {
                      //     toastification.show(
                      //       context: context,
                      //       autoCloseDuration: const Duration(seconds: 3),
                      //       style: ToastificationStyle.fillColored,
                      //       backgroundColor: theme.colorScheme.primary,
                      //       icon: Icon(
                      //         Icons.check_circle_outline,
                      //         color: theme.colorScheme.onPrimary,
                      //         size: 20,
                      //       ),
                      //       title: Text(
                      //         'Success',
                      //         style: theme.textTheme.titleMedium?.copyWith(
                      //           color: theme.colorScheme.onPrimary,
                      //         ),
                      //       ),
                      //       description: Text(
                      //         'Profile updated successfully',
                      //         style: theme.textTheme.bodyMedium?.copyWith(
                      //           color: theme.colorScheme.onPrimary,
                      //         ),
                      //       ),
                      //     );
                      //   }
                      // } catch (e) {
                      //   if (context.mounted) {
                      //     // Extract error message
                      //     String errorMessage = e.toString();
                      //     if (errorMessage.startsWith('Exception: ')) {
                      //       errorMessage = errorMessage.substring(11);
                      //     }

                      //     toastification.show(
                      //       context: context,
                      //       autoCloseDuration: const Duration(seconds: 4),
                      //       style: ToastificationStyle.fillColored,
                      //       backgroundColor: theme.colorScheme.error,
                      //       icon: Icon(
                      //         Icons.error_outline,
                      //         color: theme.colorScheme.onError,
                      //         size: 20,
                      //       ),
                      //       title: Text(
                      //         'Refresh Failed',
                      //         style: theme.textTheme.titleMedium?.copyWith(
                      //           color: theme.colorScheme.onError,
                      //         ),
                      //       ),
                      //       description: Text(
                      //         errorMessage,
                      //         style: theme.textTheme.bodyMedium?.copyWith(
                      //           color: theme.colorScheme.onError,
                      //         ),
                      //       ),
                      //     );
                      //   }
                      // }
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),
                          // Profile Avatar
                          Stack(
                            children: [
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      theme.colorScheme.primary,
                                      theme.colorScheme.primary.withOpacity(
                                        0.7,
                                      ),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: theme.colorScheme.primary
                                          .withOpacity(0.3),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    userData.name.isNotEmpty
                                        ? userData.name[0].toUpperCase()
                                        : 'U',
                                    style: theme.textTheme.displayLarge
                                        ?.copyWith(
                                          color: theme.colorScheme.onPrimary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.surface,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: theme.scaffoldBackgroundColor,
                                      width: 3,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.verified,
                                    size: 20,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Name
                          Text(
                            userData.name,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                          ),

                          // const SizedBox(height: 8),

                          // // Role Badge
                          // Container(
                          //   padding: const EdgeInsets.symmetric(
                          //     horizontal: 16,
                          //     vertical: 6,
                          //   ),
                          //   decoration: BoxDecoration(
                          //     color: theme.colorScheme.primaryContainer,
                          //     borderRadius: BorderRadius.circular(20),
                          //   ),
                          //   child: Text(
                          //     userData.role.toUpperCase(),
                          //     style: theme.textTheme.labelMedium?.copyWith(
                          //       color: theme.colorScheme.onPrimaryContainer,
                          //       fontWeight: FontWeight.w600,
                          //       letterSpacing: 1,
                          //     ),
                          //   ),
                          // ),
                          const SizedBox(height: 40),

                          // Info Cards
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              children: [
                                _buildInfoCard(
                                  context,
                                  icon: Icons.fingerprint_outlined,
                                  title: 'ID',
                                  value: userData.id,
                                ),
                                const SizedBox(height: 12),
                                _buildInfoCard(
                                  context,
                                  icon: Icons.work_outline,
                                  title: 'Role',
                                  value: userData.role.toUpperCase(),
                                ),
                                const SizedBox(height: 12),
                                _buildInfoCard(
                                  context,
                                  icon: Icons.email_outlined,
                                  title: 'Email',
                                  value: userData.email,
                                ),
                                const SizedBox(height: 12),
                                _buildInfoCard(
                                  context,
                                  icon: Icons.shield_outlined,
                                  title: 'Account Status',
                                  value: 'Active',
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 40),

                          // Action Buttons
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  child: CustomButton(
                                    label: 'Edit Profile',
                                    variant: ButtonVariant.outline,
                                    size: ButtonSize.lg,
                                    onPressed: () {
                                      // TODO: Navigate to edit profile
                                    },
                                  ),
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  child: CustomButton(
                                    label: 'Logout',
                                    variant: ButtonVariant.destructive,
                                    size: ButtonSize.lg,
                                    onPressed: () async {
                                      final shouldLogout = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                          ),
                                          title: Row(
                                            children: [
                                              Icon(
                                                Icons.logout_rounded,
                                                color: theme.colorScheme.error,
                                              ),
                                              const SizedBox(width: 12),
                                              const Text('Logout'),
                                            ],
                                          ),
                                          content: const Text(
                                            'Are you sure you want to logout from your account?',
                                          ),
                                          actions: [
                                            CustomButton(
                                              label: 'Cancel',
                                              variant: ButtonVariant.ghost,
                                              onPressed: () =>
                                                  Navigator.pop(context, false),
                                            ),
                                            CustomButton(
                                              label: 'Logout',
                                              variant:
                                                  ButtonVariant.destructive,
                                              onPressed: () =>
                                                  Navigator.pop(context, true),
                                            ),
                                          ],
                                        ),
                                      );

                                      if (shouldLogout == true &&
                                          context.mounted) {
                                        await context
                                            .read<AuthCubit>()
                                            .logout();
                                        if (context.mounted) {
                                          context.go(AppRoutes.login);
                                        }
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    final theme = AppTheme.getTheme(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 24, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CustomPageHeader extends StatelessWidget {
  const CustomPageHeader({super.key, required this.theme, required this.title});

  final ThemeData theme;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Text(
        title,
        style: theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
