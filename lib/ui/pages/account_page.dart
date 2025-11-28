import 'package:dorm_of_decents/configs/theme.dart';
import 'package:dorm_of_decents/logic/auth_cubit.dart';
import 'package:dorm_of_decents/ui/pages/account/account_actions.dart';
import 'package:dorm_of_decents/ui/pages/account/info_cards_section.dart';
import 'package:dorm_of_decents/ui/pages/account/profile_avatar.dart';
import 'package:dorm_of_decents/ui/pages/account/profile_info_section.dart';
import 'package:dorm_of_decents/ui/widgets/custom_page_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
