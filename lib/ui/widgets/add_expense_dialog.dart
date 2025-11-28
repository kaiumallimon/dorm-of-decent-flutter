import 'package:dorm_of_decents/configs/theme.dart';
import 'package:dorm_of_decents/data/services/api/logs.dart';
import 'package:dorm_of_decents/data/services/client/supabase_client.dart';
import 'package:dorm_of_decents/logic/expense_cubit.dart';
import 'package:dorm_of_decents/ui/widgets/custom_button.dart';
import 'package:dorm_of_decents/ui/widgets/custom_dropdown.dart';
import 'package:dorm_of_decents/ui/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:toastification/toastification.dart';

class AddExpenseDialog extends StatefulWidget {
  const AddExpenseDialog({super.key});

  @override
  State<AddExpenseDialog> createState() => _AddExpenseDialogState();
}

class _AddExpenseDialogState extends State<AddExpenseDialog> {
  final _dateController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _isAdmin = false;
  List<Map<String, dynamic>> _users = [];
  String? _selectedUserId;
  String _selectedCategory = 'food';
  bool _isLoadingData = true;
  String? _activeMonthId;

  final List<Map<String, String>> _categories = [
    {'value': 'food', 'label': 'Food'},
    {'value': 'electricity', 'label': 'Electricity'},
    {'value': 'internet', 'label': 'Internet'},
    {'value': 'gas', 'label': 'Gas'},
    {'value': 'misc', 'label': 'Miscellaneous'},
  ];

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();
    _dateController.text = _formatDate(DateTime.now());
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

      // Get active month
      final monthResponse = await supabase
          .from('months')
          .select('id')
          .eq('status', 'active')
          .single();

      _activeMonthId = monthResponse['id'];

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
      // Silently fail
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
    _amountController.dispose();
    _descriptionController.dispose();
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
    final amountText = _amountController.text.trim();
    final description = _descriptionController.text.trim();

    // Validation
    if (date.isEmpty) {
      setState(() {
        _errorMessage = 'Please select a date';
        _isLoading = false;
      });
      return;
    }

    if (amountText.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter amount';
        _isLoading = false;
      });
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      setState(() {
        _errorMessage = 'Invalid amount';
        _isLoading = false;
      });
      return;
    }

    if (_activeMonthId == null) {
      setState(() {
        _errorMessage = 'No active month found';
        _isLoading = false;
      });
      return;
    }

    try {
      final supabase = SupabaseService.client;
      final user = supabase.auth.currentUser;

      if (user == null) {
        setState(() {
          _errorMessage = 'You must be logged in';
          _isLoading = false;
        });
        return;
      }

      // Determine who paid (added_by)
      final addedBy = _selectedUserId ?? user.id;

      final insertResponse = await supabase
          .from('expenses')
          .insert({
            'date': date,
            'amount': amount,
            'category': _selectedCategory,
            'description': description.isEmpty ? null : description,
            'month_id': _activeMonthId,
            'added_by': addedBy,
          })
          .select('id')
          .single();

      final expenseId = insertResponse['id'];

      // Log the action
      try {
        String? targetUserName;
        if (addedBy != user.id) {
          final targetProfile = await supabase
              .from('profiles')
              .select('name')
              .eq('id', addedBy)
              .single();
          targetUserName = targetProfile['name'];
        }

        await LogsApi().createLog(
          action: 'create',
          entityType: 'expense',
          entityId: expenseId,
          metadata: {
            'amount': amount,
            'category': _selectedCategory,
            'description': description.isEmpty ? null : description,
            if (addedBy != user.id) 'target_user_id': addedBy,
            if (targetUserName != null) 'target_user_name': targetUserName,
          },
        );
      } catch (e) {
        // Continue even if logging fails
      }

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      // Success
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
          "Expense added successfully",
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
        type: ToastificationType.success,
        style: ToastificationStyle.fillColored,
        primaryColor: theme.colorScheme.primary,
      );

      // Refresh expenses
      context.read<ExpenseCubit>().refreshExpenses();

      Navigator.of(context).pop();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to add expense. Please try again.';
        _isLoading = false;
      });
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
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 400),
          child: _isLoadingData
              ? _buildShimmerContent(theme)
              : _buildFormContent(theme),
        ),
      ),
    );
  }

  Widget _buildShimmerContent(ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildShimmerBox(theme: theme, height: 28, width: 120),
            _buildShimmerBox(theme: theme, height: 24, width: 24),
          ],
        ),
        const SizedBox(height: 20),
        _buildShimmerBox(theme: theme, height: 52),
        const SizedBox(height: 16),
        _buildShimmerBox(theme: theme, height: 52),
        const SizedBox(height: 16),
        _buildShimmerBox(theme: theme, height: 52),
        const SizedBox(height: 16),
        _buildShimmerBox(theme: theme, height: 52),
        const SizedBox(height: 16),
        _buildShimmerBox(theme: theme, height: 80),
        const SizedBox(height: 24),
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
              'Add Expense',
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

        // Admin: User Selection (who paid)
        if (_isAdmin && _users.isNotEmpty) ...[
          CustomDropdown<String>(
            label: 'Paid By (optional - defaults to yourself)',
            value: _selectedUserId ?? '',
            hint: 'Select who paid',
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

        // Amount Field
        CustomTextField(
          label: 'Amount',
          controller: _amountController,
          prefixIcon: Icons.attach_money_rounded,
        ),
        const SizedBox(height: 16),

        // Category Dropdown
        CustomDropdown<String>(
          label: 'Category',
          value: _selectedCategory,
          prefixIcon: Icons.category_outlined,
          items: _categories.map((category) {
            return DropdownMenuItem(
              value: category['value']!,
              child: Text(category['label']!),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedCategory = value!;
            });
          },
        ),
        const SizedBox(height: 16),

        // Description Field
        CustomTextField(
          label: 'Description (optional)',
          controller: _descriptionController,
          prefixIcon: Icons.notes_rounded,
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
                size: ButtonSize.sm,
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
              flex: 2,
              child: CustomButton(
                size: ButtonSize.sm,
                label: 'Add Expense',
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
