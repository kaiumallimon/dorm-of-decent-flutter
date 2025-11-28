import 'package:dorm_of_decents/configs/theme.dart';
import 'package:dorm_of_decents/data/services/api/meal.dart';
import 'package:dorm_of_decents/data/services/client/supabase_client.dart';
import 'package:dorm_of_decents/logic/meal_cubit.dart';
import 'package:dorm_of_decents/ui/widgets/custom_button.dart';
import 'package:dorm_of_decents/ui/widgets/custom_dropdown.dart';
import 'package:dorm_of_decents/ui/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:toastification/toastification.dart';

class AddMealDialog extends StatefulWidget {
  const AddMealDialog({super.key});

  @override
  State<AddMealDialog> createState() => _AddMealDialogState();
}

class _AddMealDialogState extends State<AddMealDialog> {
  final _dateController = TextEditingController();
  final _mealCountController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _isAdmin = false;
  List<Map<String, dynamic>> _users = [];
  String? _selectedUserId;
  bool _isLoadingData = true;

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();
    // Set today's date as default
    _dateController.text = _formatDate(DateTime.now());
    // Set default meal count
    _mealCountController.text = '1';
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final supabase = SupabaseService.client;
      final user = supabase.auth.currentUser;

      if (user == null) {
        setState(() {
          _isLoadingData = false;
        });
        return;
      }

      // Check if admin
      final profileResponse = await supabase
          .from('profiles')
          .select('role')
          .eq('id', user.id)
          .single();

      if (profileResponse['role'] == 'admin') {
        setState(() {
          _isAdmin = true;
        });

        // Fetch all users for admin
        final usersResponse = await supabase
            .from('profiles')
            .select('id, name')
            .order('name');

        setState(() {
          _users = List<Map<String, dynamic>>.from(usersResponse);
        });
      }
    } catch (e) {
      // Silently fail - user just won't see admin options
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingData = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    _mealCountController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final theme = AppTheme.getTheme(context);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(colorScheme: theme.colorScheme),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dateController.text = _formatDate(picked);
      });
    }
  }

  Future<void> _handleSubmit() async {
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    final date = _dateController.text.trim();
    final mealCountText = _mealCountController.text.trim();

    // Validation
    if (date.isEmpty) {
      setState(() {
        _errorMessage = 'Please select a date';
        _isLoading = false;
      });
      return;
    }

    if (mealCountText.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter meal count';
        _isLoading = false;
      });
      return;
    }

    final mealCount = double.tryParse(mealCountText);
    if (mealCount == null) {
      setState(() {
        _errorMessage = 'Invalid meal count';
        _isLoading = false;
      });
      return;
    }

    // Call API
    final mealApi = MealApi();
    final result = await mealApi.addMeal(
      date: date,
      mealCount: mealCount,
      userId: _selectedUserId, // Pass selected user if admin chose one
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (result['error'] != null) {
      setState(() {
        _errorMessage = result['error'];
      });
    } else {
      // Success - show success toast and refresh meals
      if (mounted) {
        final theme = AppTheme.getTheme(context);

        toastification.show(
          context: context,
          autoCloseDuration: const Duration(seconds: 3),
          icon: Icon(
            Icons.check_circle_outline,
            color: theme.colorScheme.primary,
            size: 20,
          ),
          title: Text(
            "Success",
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          description: Text(
            "Meal added successfully",
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          type: ToastificationType.success,
          style: ToastificationStyle.fillColored,
          primaryColor: theme.colorScheme.primary,
        );

        // Refresh meals from cubit
        context.read<MealCubit>().refreshMeals();

        Navigator.of(context).pop();
      }
    }
  }

  Widget _buildShimmerBox({
    required ThemeData theme,
    required double height,
    double? width,
  }) {
    final isDark = theme.brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark
          ? theme.colorScheme.onSurface.withAlpha(10)
          : theme.colorScheme.outline.withAlpha(25),
      highlightColor: isDark
          ? theme.colorScheme.onSurface.withAlpha(50)
          : theme.colorScheme.outline.withAlpha(10),
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.getTheme(context);

    return Dialog(
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400),
        child: _isLoadingData
            ? _buildShimmerContent(theme)
            : _buildFormContent(theme),
      ),
    );
  }

  Widget _buildShimmerContent(ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header shimmer
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildShimmerBox(theme: theme, height: 28, width: 100),
            _buildShimmerBox(theme: theme, height: 24, width: 24),
          ],
        ),
        const SizedBox(height: 20),

        // User dropdown shimmer (potential admin field)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildShimmerBox(theme: theme, height: 14, width: 120),
            const SizedBox(height: 6),
            _buildShimmerBox(theme: theme, height: 52),
          ],
        ),
        const SizedBox(height: 16),

        // Date field shimmer
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildShimmerBox(theme: theme, height: 14, width: 60),
            const SizedBox(height: 6),
            _buildShimmerBox(theme: theme, height: 52),
          ],
        ),
        const SizedBox(height: 16),

        // Meal count field shimmer
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildShimmerBox(theme: theme, height: 14, width: 80),
            const SizedBox(height: 6),
            _buildShimmerBox(theme: theme, height: 52),
          ],
        ),
        const SizedBox(height: 8),

        // Helper text shimmer
        _buildShimmerBox(theme: theme, height: 12, width: 200),
        const SizedBox(height: 24),

        // Buttons shimmer
        Row(
          children: [
            Expanded(child: _buildShimmerBox(theme: theme, height: 42)),
            const SizedBox(width: 12),
            Expanded(child: _buildShimmerBox(theme: theme, height: 42)),
          ],
        ),
      ],
    );
  }

  Widget _buildFormContent(ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Add Meal',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close_rounded),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Admin: User Selection
        if (_isAdmin && _users.isNotEmpty) ...[
          CustomDropdown<String>(
            label: 'User (optional - defaults to yourself)',
            value: _selectedUserId ?? '',
            hint: 'Select a user or leave empty',
            items: [
              const DropdownMenuItem(
                value: '',
                child: Text('-- Select a user --'),
              ),
              ..._users.map((user) {
                return DropdownMenuItem(
                  value: user['id'] as String,
                  child: Text(user['name'] as String),
                );
              }),
            ],
            onChanged: (value) {
              setState(() {
                _selectedUserId = value == '' ? null : value;
              });
            },
          ),
          const SizedBox(height: 16),
        ],

        // Date Field
        GestureDetector(
          onTap: _selectDate,
          child: AbsorbPointer(
            child: CustomTextField(
              label: 'Date',
              controller: _dateController,
              prefixIcon: Icons.calendar_today_rounded,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Meal Count Field
        CustomTextField(
          label: 'Meal Count',
          controller: _mealCountController,
          prefixIcon: Icons.restaurant_rounded,
        ),
        const SizedBox(height: 8),

        // Helper text
        Text(
          'Enter a value between 0.5 and 10',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),

        // Error message
        if (_errorMessage != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: theme.colorScheme.error.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  color: theme.colorScheme.error,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 24),

        // Action buttons
        Row(
          children: [
            Expanded(
              child: CustomButton(
                label: 'Cancel',
                variant: ButtonVariant.outline,
                onPressed: _isLoading
                    ? null
                    : () {
                        Navigator.of(context).pop();
                      },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomButton(
                label: 'Add Meal',
                loading: _isLoading,
                onPressed: _isLoading ? null : _handleSubmit,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
