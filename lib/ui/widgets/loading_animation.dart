import 'package:dorm_of_decents/configs/theme.dart';
import 'package:flutter/cupertino.dart';

class LoadingAnimation extends StatelessWidget {
  const LoadingAnimation({super.key, this.radius = 10.0, this.color});

  final double radius;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return CupertinoActivityIndicator(
      radius: radius,
      color: color ?? AppTheme.getTheme(context).colorScheme.primary,
    );
  }
}
