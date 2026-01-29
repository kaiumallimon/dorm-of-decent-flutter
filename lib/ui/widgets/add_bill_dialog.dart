import 'package:dorm_of_decents/configs/theme.dart';
import 'package:dorm_of_decents/data/services/api/logs.dart';
import 'package:dorm_of_decents/data/services/client/supabase_client.dart';
import 'package:dorm_of_decents/logic/bills_cubit.dart';
import 'package:dorm_of_decents/ui/widgets/custom_button.dart';
import 'package:dorm_of_decents/ui/widgets/custom_dropdown.dart';
import 'package:dorm_of_decents/ui/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:toastification/toastification.dart';

class AddBillDialog extends StatefulWidget {
  const AddBillDialog({super.key});

  @override
  State<AddBillDialog> createState() => _AddBillDialogState();
}

class _AddBillDialogState extends State<AddBillDialog> {
  final _dateController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  List<Map<String, dynamic>> _users = [];
  String? _selectedUserId;
  String _selectedBillType = 'electricity';
  bool _isLoadingData = true;
  String? _activeMonthId;

  final List<Map<String, String>> _billTypes = [
    {'value': 'electricity', 'label': 'Electricity'},
    {'value': 'gas', 'label': 'Gas'},
    {'value': 'internet', 'label': 'Internet'},
  ];

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatDisplayDate(DateTime date) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    final day = date.day;
    final suffix = _getDaySuffix(day);
    return '${months[date.month - 1]} $day$suffix, ${date.year}';
  }

  String _getDaySuffix(int day) {
    if (day >= 11 && day <= 13) return 'th';
    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  @override
  void initState() {
    super.initState();
    _dateController.text = _formatDisplayDate(DateTime.now());
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

      // Fetch all users
      final usersResponse = await supabase
          .from('profiles')
          .select('id, name')
          .eq('isActive', true)
          .order('name');

      setState(() {
        _users = List<Map<String, dynamic>>.from(usersResponse);
      });
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
      firstDate: DateTime(2000),
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
        _dateController.text = _formatDisplayDate(picked);
      });
    }
  }

  Future<void> _handleSubmit() async {
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    final amountText = _amountController.text.trim();
    final description = _descriptionController.text.trim();

    // Validation
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

    if (_selectedUserId == null) {
      setState(() {
        _errorMessage = 'Please select who paid';
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

      // Parse the display date back to yyyy-MM-dd format
      final displayText = _dateController.text;
      DateTime selectedDate;
      try {
        // Extract date from "January 30th, 2026" format
        final parts = displayText.split(' ');
        final monthNames = [
          'January',
          'February',
          'March',
          'April',
          'May',
          'June',
          'July',
          'August',
          'September',
          'October',
          'November',
          'December'
        ];
        final monthIndex = monthNames.indexOf(parts[0]) + 1;
        final day = int.parse(parts[1].replaceAll(RegExp(r'[^0-9]'), ''));
        final year = int.parse(parts[2]);
        selectedDate = DateTime(year, monthIndex, day);
      } catch (e) {
        selectedDate = DateTime.now();
      }

      final dateString = _formatDate(selectedDate);

      final insertResponse = await supabase.from('bills').insert({
        'date': dateString,
        'amount': amount,
        'bill_type': _selectedBillType,
        'description': description.isEmpty ? null : description,
        'month_id': _activeMonthId,
        'paid_by': _selectedUserId,
      }).select('id').single();

      final billId = insertResponse['id'];

      // Log the action
      try {
        String? targetUserName;
        final targetProfile = await supabase
            .from('profiles')
            .select('name')
            .eq('id', _selectedUserId!)
            .single();
        targetUserName = targetProfile['name'];

        await LogsApi().createLog(
          action: 'create',
          entityType: 'bill',
          entityId: billId,
          metadata: {
            'amount': amount,
            'bill_type': _selectedBillType,
            'description': description.isEmpty ? null : description,
            'paid_by': _selectedUserId,
            if (targetUserName != null) 'paid_by_name': targetUserName,
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
          "Bill added successfully",
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
        type: ToastificationType.success,
        style: ToastificationStyle.fillColored,
        primaryColor: theme.colorScheme.primary,
      );

      // Refresh bills
      context.read<BillsCubit>().refreshBills();

      Navigator.of(context).pop();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to add bill. Please try again.';
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
              'Add New Bill',
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

        // Bill Type Dropdown
        CustomDropdown<String>(
          label: 'Bill Type',
          value: _selectedBillType,
          items: _billTypes.map((billType) {
            return DropdownMenuItem(
              value: billType['value']!,
              child: Text(billType['label']!),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedBillType = value!;
            });
          },
        ),
        const SizedBox(height: 16),

        // Amount Field
        CustomTextField(
          label: 'Amount (BDT)',
          controller: _amountController,
        ),
        const SizedBox(height: 16),

        // Paid By Dropdown
        CustomDropdown<String>(
          label: 'Paid By',
          value: _selectedUserId ?? '',
          hint: 'Select who paid',
          items: [
            const DropdownMenuItem(
              value: '',
              child: Text('Select who paid'),
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

        // Description Field
        CustomTextField(
          label: 'Description (Optional)',
          controller: _descriptionController,
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
                label: 'Add Bill',
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
