import 'package:dorm_of_decents/configs/routes.dart';
import 'package:dorm_of_decents/configs/theme.dart';
import 'package:dorm_of_decents/logic/auth_cubit.dart';
import 'package:dorm_of_decents/ui/pages/account/account_actions.dart';
import 'package:dorm_of_decents/ui/pages/account/info_cards_section.dart';
import 'package:dorm_of_decents/ui/pages/account/profile_avatar.dart';
import 'package:dorm_of_decents/ui/pages/account/profile_info_section.dart';
import 'package:dorm_of_decents/ui/widgets/custom_page_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

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
                          ProfileAvatar(name: userData.name),
                          const SizedBox(height: 20),

                          // Name
                          ProfileInfoSection(name: userData.name),
                          const SizedBox(height: 40),

                          // Info Cards
                          InfoCardsSection(userData: userData),
                          const SizedBox(height: 30),

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Row(
                              mainAxisAlignment: .start,
                              children: [
                                Text(
                                  'Menu',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          // menu for logs and users
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Row(
                              mainAxisAlignment: .start,
                              spacing: 15,
                              children: [
                                Expanded(
                                  child: AccountsMenuCard(
                                    title: 'Logs',
                                    icon: Icons.history_outlined,
                                    onTap: () {
                                      context.push(
                                        AppRoutes.logs,
                                      );
                                    },
                                  ),
                                ),
                                Expanded(
                                  child: AccountsMenuCard(
                                    title: 'Users',
                                    icon: Icons.people_outline,
                                    onTap: () {
                                      context.push(
                                        AppRoutes.users,
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 40),

                          // Action Buttons
                          const AccountActions(),
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
}

class AccountsMenuCard extends StatelessWidget {
  const AccountsMenuCard({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.getTheme(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.getTheme(
              context,
            ).colorScheme.outline.withOpacity(0.1),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 32,
              color: AppTheme.getTheme(context).colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: AppTheme.getTheme(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
