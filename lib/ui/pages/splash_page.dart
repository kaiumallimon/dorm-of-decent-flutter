import 'package:dorm_of_decents/configs/assets.dart';
import 'package:dorm_of_decents/configs/colors.dart';
import 'package:dorm_of_decents/configs/constants.dart';
import 'package:dorm_of_decents/configs/routes.dart';
import 'package:dorm_of_decents/configs/theme.dart';
import 'package:dorm_of_decents/logic/auth_cubit.dart';
import 'package:dorm_of_decents/logic/update_cubit.dart';
import 'package:dorm_of_decents/ui/widgets/loading_animation.dart';
import 'package:dorm_of_decents/utils/sizing.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    // Check for updates first
    context.read<UpdateCubit>().checkForUpdate();
  }

  @override
  Widget build(BuildContext context) {
    // size of the current window
    final windowSize = Sizing.windowSize(context);

    final theme = AppTheme.getTheme(context);

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: theme.scaffoldBackgroundColor,
        statusBarIconBrightness: theme.brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark,
        systemNavigationBarColor: theme.colorScheme.surface,
        systemNavigationBarIconBrightness: theme.brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark,
      ),
    );

    return MultiBlocListener(
      listeners: [
        BlocListener<UpdateCubit, UpdateState>(
          listener: (context, state) {
            // After update check, proceed with auth check
            if (state is UpdateAvailable) {
              // Navigate to update page
              context.pushReplacement(AppRoutes.update);
            } else if (state is UpdateNotAvailable || state is UpdateError || state is UpdateSkipped) {
              // No update needed, check auth
              context.read<AuthCubit>().checkAuthStatus();
            }
          },
        ),
        BlocListener<AuthCubit, AuthState>(
          listener: (context, state) {
            // Only navigate after update check is done
            final updateState = context.read<UpdateCubit>().state;
            if (updateState is UpdateNotAvailable || updateState is UpdateError || updateState is UpdateSkipped) {
              if (state is AuthAuthenticated) {
                // navigate to home page
                context.pushReplacement(AppRoutes.home);
              } else if (state is AuthUnauthenticated) {
                // navigate to login
                context.pushReplacement(AppRoutes.login);
              }
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: AppTheme.getTheme(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: Stack(
            fit: StackFit.expand,
            children: [
              Center(
                child: Column(
                  mainAxisSize: .min,
                  mainAxisAlignment: .center,
                  children: [
                    Container(
                      width: windowSize.width * 0.25,
                      height: windowSize.width * 0.25,
                      padding: EdgeInsets.all(windowSize.width * 0.05),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primary.withAlpha(75),
                        ),
                      ),
                      child: Image.asset(
                        AppAssets.appLogo,
                        fit: BoxFit.contain,
                      ),
                    ),

                    const SizedBox(height: 25),

                    Text(
                      AppConstants.appTitle,
                      style: AppTheme.getTheme(context).textTheme.headlineSmall?.copyWith(
                        fontFamily: 'Crimson Text'
                      ),
                    ),
                  ],
                ),
              ),

              Positioned(
                bottom: windowSize.height * 0.08,
                left: 0,
                right: 0,
                child: LoadingAnimation(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
