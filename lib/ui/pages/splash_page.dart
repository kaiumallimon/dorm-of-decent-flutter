import 'package:dorm_of_decents/configs/assets.dart';
import 'package:dorm_of_decents/configs/colors.dart';
import 'package:dorm_of_decents/configs/routes.dart';
import 'package:dorm_of_decents/configs/theme.dart';
import 'package:dorm_of_decents/logic/auth_cubit.dart';
import 'package:dorm_of_decents/logic/splash_cubit.dart';
import 'package:dorm_of_decents/ui/widgets/loading_animation.dart';
import 'package:dorm_of_decents/utils/sizing.dart';
import 'package:flutter/material.dart';
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
    // Check auth status when splash screen loads
    context.read<AuthCubit>().checkAuthStatus();
  }

  @override
  Widget build(BuildContext context) {
    // size of the current window
    final windowSize = Sizing.windowSize(context);

    return MultiBlocListener(
      listeners: [
        BlocListener<SplashCubit, SplashState>(
          listener: (context, state) {
            // check if splash screen has finished &
            // navigate accordingly
            if (state is SplashFinished) {
              final authState = context.read<AuthCubit>().state;
              if (authState is AuthAuthenticated) {
                // navigate to home page
                context.pushReplacement(AppRoutes.home);
              } else {
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
                child: Container(
                  width: windowSize.width * 0.25,
                  height: windowSize.width * 0.25,
                  padding: EdgeInsets.all(windowSize.width * 0.05),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary.withAlpha(75)),
                  ),
                  child: Image.asset(AppAssets.appLogo, fit: BoxFit.contain),
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
