import 'package:dorm_of_decents/logic/auth_cubit.dart';
import 'package:dorm_of_decents/logic/update_cubit.dart';
import 'package:dorm_of_decents/ui/widgets/update_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Widget that checks for app updates and shows update dialog
class UpdateChecker extends StatefulWidget {
  final Widget child;

  const UpdateChecker({super.key, required this.child});

  @override
  State<UpdateChecker> createState() => _UpdateCheckerState();
}

class _UpdateCheckerState extends State<UpdateChecker>
    with WidgetsBindingObserver {
  bool _hasShownUpdateDialog = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Check for updates after app is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForUpdates();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Check for updates when app comes to foreground
    if (state == AppLifecycleState.resumed) {
      _checkForUpdates();
    }
  }

  void _checkForUpdates() {
    // Only check if user is authenticated
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      context.read<UpdateCubit>().checkForUpdate();
    }
  }

  void _showUpdateDialog(BuildContext context) {
    final updateState = context.read<UpdateCubit>().state;

    if (updateState is UpdateAvailable && !_hasShownUpdateDialog) {
      _hasShownUpdateDialog = true;

      showDialog(
        context: context,
        barrierDismissible: !updateState.update.isForceUpdate,
        builder: (dialogContext) => UpdateDialog(
          update: updateState.update,
          onSkip: () {
            context.read<UpdateCubit>().skipUpdate(updateState.update.version);
            _hasShownUpdateDialog = false;
          },
          onUpdate: () {
            Navigator.of(dialogContext).pop();
            _hasShownUpdateDialog = false;
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UpdateCubit, UpdateState>(
      listener: (context, state) {
        if (state is UpdateAvailable) {
          // Show update dialog
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _showUpdateDialog(context);
            }
          });
        } else if (state is UpdateSkipped) {
          // Reset flag when update is skipped
          _hasShownUpdateDialog = false;
        }
      },
      child: widget.child,
    );
  }
}
