import 'package:dorm_of_decents/configs/assets.dart';
import 'package:dorm_of_decents/configs/colors.dart';
import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key, required this.windowSize});

  final Size windowSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: windowSize.width * 0.18,
      height: windowSize.width * 0.18,
      padding: EdgeInsets.all(windowSize.width * 0.04),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary.withAlpha(55),
      ),
      child: Image.asset(AppAssets.appLogo, fit: BoxFit.contain),
    );
  }
}
