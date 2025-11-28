import 'package:dorm_of_decents/configs/constants.dart';
import 'package:dorm_of_decents/configs/routes.dart';
import 'package:dorm_of_decents/configs/theme.dart';
import 'package:dorm_of_decents/logic/auth_cubit.dart';
import 'package:dorm_of_decents/logic/login_cubit.dart';
import 'package:dorm_of_decents/ui/widgets/app_logo.dart';
import 'package:dorm_of_decents/ui/widgets/custom_button.dart';
import 'package:dorm_of_decents/ui/widgets/custom_textfield.dart';
import 'package:dorm_of_decents/utils/sizing.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:grid_background/grid_background.dart';
import 'package:toastification/toastification.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.getTheme(context);
    final windowSize = Sizing.windowSize(context);
    final loginCubit = context.read<LoginCubit>();

    return BlocListener<LoginCubit, LoginState>(
      listener: (context, state) {
        if (state is LoginFailure) {
          // Clean up error message by removing "Exception: " prefix
          String errorMessage = state.error;
          if (errorMessage.startsWith('Exception: ')) {
            errorMessage = errorMessage.substring(11);
          }

          toastification.show(
            context: context,
            autoCloseDuration: const Duration(seconds: 4),
            icon: Icon(
              Icons.error_outline,
              color: theme.colorScheme.error,
              size: 20,
            ),
            title: Text(
              "Login Failed",
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onError,
              ),
            ),
            description: Text(
              errorMessage,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onError,
              ),
            ),
          );
        } else if (state is LoginSuccess) {
          final response = state.loginResponse;

          // Set authentication state with user data
          context.read<AuthCubit>().setAuthentication(
            accessToken: response.accessToken,
            refreshToken: response.refreshToken,
            userData: response.userData,
          );

          context.pushReplacement(AppRoutes.home);
        }
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Stack(
            fit: StackFit.expand,
            children: [
              Gridbackground(
                space: 60,
                horizontallinewidth: 1.0,
                verticallinewidth: 1.0,
                color: theme.colorScheme.onSurface.withAlpha(20),
              ),

              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: Sizing.screenHPadding,
                  ),
                  child: Card(
                    color: theme.scaffoldBackgroundColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                      side: BorderSide(
                        color: theme.colorScheme.primary.withAlpha(30),
                      ),
                    ),
                    child: SingleChildScrollView(
                      physics: BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(25),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AppLogo(windowSize: windowSize),
                          const SizedBox(height: 10),
                          Text(
                            AppConstants.appTitle,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 20),
                          CustomTextField(
                            controller: loginCubit.emailController,
                            prefixIcon: Icons.email,
                            label: AppConstants.emailLabel,
                            isBordered: false,
                          ),
                          const SizedBox(height: 10),
                          CustomTextField(
                            controller: loginCubit.passwordController,
                            prefixIcon: Icons.lock,
                            label: AppConstants.passwordLabel,
                            isBordered: false,
                            obscureText: true,
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: .end,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  loginCubit.openUrl(
                                    'https://dorm-of-decent.vercel.app/forgot-password',
                                  );
                                },
                                child: Text(
                                  AppConstants.forgotPassword,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.error,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          BlocBuilder<LoginCubit, LoginState>(
                            builder: (context, state) {
                              final isLoading = state is LoginLoading;

                              return CustomButton(
                                size: ButtonSize.md,
                                label: AppConstants.loginButton,
                                loadingLabel: AppConstants.loadingLabel,
                                variant: ButtonVariant.solid,
                                loading: isLoading,
                                onPressed: isLoading
                                    ? null
                                    : () {
                                        if (loginCubit.emailController.text
                                            .trim()
                                            .isEmpty) {
                                          toastification.show(
                                            context: context,
                                            style:
                                                ToastificationStyle.fillColored,
                                            backgroundColor:
                                                theme.colorScheme.error,
                                            title: Text(
                                              "Validation Error",
                                              style: theme.textTheme.titleMedium
                                                  ?.copyWith(
                                                    color: theme
                                                        .colorScheme
                                                        .onError,
                                                  ),
                                            ),
                                            description: Text(
                                              "Email cannot be empty.",
                                              style: theme.textTheme.bodyMedium
                                                  ?.copyWith(
                                                    color: theme
                                                        .colorScheme
                                                        .onError,
                                                  ),
                                            ),
                                          );
                                          return;
                                        } else if (loginCubit
                                            .passwordController
                                            .text
                                            .trim()
                                            .isEmpty) {
                                          toastification.show(
                                            context: context,
                                            style:
                                                ToastificationStyle.fillColored,
                                            backgroundColor:
                                                theme.colorScheme.error,
                                            title: Text(
                                              "Validation Error",
                                              style: theme.textTheme.titleMedium
                                                  ?.copyWith(
                                                    color: theme
                                                        .colorScheme
                                                        .onError,
                                                  ),
                                            ),
                                            description: Text(
                                              "Password cannot be empty.",
                                              style: theme.textTheme.bodyMedium
                                                  ?.copyWith(
                                                    color: theme
                                                        .colorScheme
                                                        .onError,
                                                  ),
                                            ),
                                          );
                                          return;
                                        }
                                        loginCubit.login(
                                          email: loginCubit.emailController.text
                                              .trim(),
                                          password: loginCubit
                                              .passwordController
                                              .text
                                              .trim(),
                                        );
                                      },
                              );
                            },
                          ),
                          const SizedBox(height: 15),
                          Center(
                            child: Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 2,
                              runSpacing: 2,
                              children: [
                                Text(
                                  "Contact ",
                                  style: theme.textTheme.bodySmall,
                                ),
                                RichText(
                                  text: TextSpan(
                                    text: "@kaiumallimon",
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () async {
                                        await loginCubit.openUrl(
                                          'https://wa.me/+8801738439423',
                                        );
                                      },
                                  ),
                                ),
                                Text(
                                  " to create or update an account.",
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
