import 'package:dorm_of_decents/configs/routes.dart';
import 'package:dorm_of_decents/configs/theme.dart';
import 'package:dorm_of_decents/logic/auth_cubit.dart';
import 'package:dorm_of_decents/ui/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class AccountActions extends StatelessWidget {
  const AccountActions({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.getTheme(context);

    return Padding(
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
                      borderRadius: BorderRadius.circular(16),
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
                        onPressed: () => Navigator.pop(context, false),
                      ),
                      CustomButton(
                        label: 'Logout',
                        variant: ButtonVariant.destructive,
                        onPressed: () => Navigator.pop(context, true),
                      ),
                    ],
                  ),
                );

                if (shouldLogout == true && context.mounted) {
                  await context.read<AuthCubit>().logout();
                  if (context.mounted) {
                    context.go(AppRoutes.login);
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
