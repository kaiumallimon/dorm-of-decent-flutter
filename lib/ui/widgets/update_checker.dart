import 'package:dorm_of_decents/data/models/app_update.dart';
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
  bool _isForceUpdate = false;
  OverlayEntry? _overlayEntry;
  BuildContext? _overlayContext;

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
    _overlayEntry?.remove();
    _overlayEntry = null;
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Don't check for updates if force update dialog is shown
    if (_isForceUpdate) return;

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

  void _showUpdateOverlay(AppUpdate update) {
    // Use the stored overlay context
    if (_overlayContext == null) {
      // Fallback: try again after a delay
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) _showUpdateOverlay(update);
      });
      return;
    }

    final overlayState = Overlay.maybeOf(_overlayContext!);
    if (overlayState == null) {
      // Fallback: try again after a delay
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) _showUpdateOverlay(update);
      });
      return;
    }

    _overlayEntry = OverlayEntry(
      builder: (overlayContext) => Material(
        color: Colors.black.withAlpha(128),
        child: WillPopScope(
          onWillPop: () async => !update.isForceUpdate,
          child: Center(
            child: UpdateDialog(
              update: update,
              onSkip: () {
                _overlayEntry?.remove();
                _overlayEntry = null;
                if (_overlayContext != null && mounted) {
                  _overlayContext!.read<UpdateCubit>().skipUpdate(update.version);
                }
                _isForceUpdate = false;
                _hasShownUpdateDialog = false;
              },
              onUpdate: () {
                // For force updates, keep overlay open
                if (!update.isForceUpdate) {
                  _overlayEntry?.remove();
                  _overlayEntry = null;
                  _hasShownUpdateDialog = false;
                }
              },
            ),
          ),
        ),
      ),
    );

    overlayState.insert(_overlayEntry!);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UpdateCubit, UpdateState>(
      listener: (listenerContext, state) {
        if (state is UpdateAvailable && !_hasShownUpdateDialog) {
          _hasShownUpdateDialog = true;
          _isForceUpdate = state.update.isForceUpdate;

          // Use post frame callback to ensure everything is ready
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            _showUpdateOverlay(state.update);
          });
        } else if (state is UpdateSkipped) {
          // Reset flag when update is skipped
          _hasShownUpdateDialog = false;
        }
      },
      child: Builder(
        builder: (builderContext) {
          // Store the context that has access to Overlay
          _overlayContext = builderContext;
          return widget.child;
        },
      ),
    );
  }
}
