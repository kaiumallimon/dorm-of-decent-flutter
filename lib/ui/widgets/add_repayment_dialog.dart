import 'package:dorm_of_decents/configs/theme.dart';
import 'package:dorm_of_decents/data/models/bills_due_response.dart';
import 'package:dorm_of_decents/data/services/api/bill_payments.dart';
import 'package:dorm_of_decents/ui/widgets/custom_button.dart';
import 'package:dorm_of_decents/ui/widgets/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class AddRepaymentDialog extends StatefulWidget {
  final List<BillDue> bills;
  final List<ProfileDue> profiles;
  final int activeUsersCount;
  final VoidCallback? onRefetch;

  const AddRepaymentDialog({
    super.key,
    required this.bills,
    required this.profiles,
    required this.activeUsersCount,
    this.onRefetch,
  });

  @override
  State<AddRepaymentDialog> createState() => _AddRepaymentDialogState();
}

class _AddRepaymentDialogState extends State<AddRepaymentDialog> {
  String? selectedBillId;
  String? selectedUser;
  bool submitting = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> handleSubmit() async {
    if (selectedUser == null || selectedBillId == null) {
      final theme = AppTheme.getTheme(context);
      toastification.show(
        context: context,
        autoCloseDuration: const Duration(seconds: 3),
        icon: Icon(
          Icons.warning_amber_rounded,
          color: Colors.orange,
          size: 20,
        ),
        title: Text(
          "Warning",
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
        description: Text(
          "Please select both user and bill",
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
        type: ToastificationType.warning,
        style: ToastificationStyle.fillColored,
        primaryColor: Colors.orange,
      );
      return;
    }

    final bill = widget.bills.firstWhere((b) => b.id == selectedBillId);
    final perPersonAmount = bill.amount / widget.activeUsersCount;

    setState(() {
      submitting = true;
    });

    final theme = AppTheme.getTheme(context);

    try {
      final billPaymentsApi = BillPaymentsApi();

      await billPaymentsApi.recordRepayment(
        billId: selectedBillId!,
        paidBy: selectedUser!,
        amount: perPersonAmount,
      );

      if (mounted) {
        toastification.show(
          context: context,
          autoCloseDuration: const Duration(seconds: 5),
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
            "Repayment recorded: ৳${perPersonAmount.toStringAsFixed(2)}",
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          type: ToastificationType.success,
          style: ToastificationStyle.fillColored,
          primaryColor: theme.colorScheme.primary,
        );

        Navigator.pop(context);
        widget.onRefetch?.call();
      }
    } catch (error) {
      if (mounted) {
        toastification.show(
          context: context,
          autoCloseDuration: const Duration(seconds: 3),
          icon: Icon(
            Icons.error_outline,
            color: theme.colorScheme.error,
            size: 20,
          ),
          title: Text(
            "Error",
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onErrorContainer,
            ),
          ),
          description: Text(
            error.toString(),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onErrorContainer,
            ),
          ),
          type: ToastificationType.error,
          style: ToastificationStyle.fillColored,
          primaryColor: theme.colorScheme.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          submitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.getTheme(context);
    final selectedBillData = selectedBillId != null
        ? widget.bills.firstWhere((b) => b.id == selectedBillId)
        : null;
    final availableUsers = selectedBillData != null
        ? widget.profiles.where((p) => p.id != selectedBillData.paidBy).toList()
        : widget.profiles;

    return Dialog(
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Record Bill Repayment',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Record when a user has paid their share of a bill to the person who initially paid it.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),

            // Select Bill
            Text(
              'Select Bill',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            CustomDropdown<String?>(
              label: '',
              value: selectedBillId,
              prefixIcon: Icons.receipt_long_outlined,
              items: widget.bills.isEmpty
                  ? [
                      const DropdownMenuItem(
                        value: '',
                        enabled: false,
                        child: Text('No bills available'),
                      ),
                    ]
                  : widget.bills.map((bill) {
                      final icon = bill.billType == 'electricity'
                          ? '⚡'
                          : bill.billType == 'gas'
                              ? '🔥'
                              : '🌐';
                      return DropdownMenuItem(
                        value: bill.id,
                        child: Text(
                          '$icon ${bill.billType[0].toUpperCase()}${bill.billType.substring(1)} (৳${(bill.amount / widget.activeUsersCount).toStringAsFixed(2)} per person)',
                        ),
                      );
                    }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedBillId = value;
                  selectedUser = null; // Reset user selection
                });
              },
            ),
            const SizedBox(height: 16),

            // Bill Details
            if (selectedBillData != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Paid by:',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        Text(
                          widget.profiles
                              .firstWhere((p) => p.id == selectedBillData.paidBy)
                              .name,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total amount:',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        Text(
                          '৳${selectedBillData.amount.toStringAsFixed(2)}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Per person:',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        Text(
                          '৳${(selectedBillData.amount / widget.activeUsersCount).toStringAsFixed(2)}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Select User
            Text(
              'Who paid?',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            CustomDropdown<String?>(
              label: '',
              value: selectedUser,
              prefixIcon: Icons.person_outline_rounded,
              items: availableUsers.isEmpty
                  ? [
                      const DropdownMenuItem(
                        value: '',
                        enabled: false,
                        child: Text('No users available'),
                      ),
                    ]
                  : availableUsers.map((profile) {
                      return DropdownMenuItem(
                        value: profile.id,
                        child: Text(profile.name),
                      );
                    }).toList(),
              onChanged: selectedBillId == null
                  ? null
                  : (value) {
                      setState(() {
                        selectedUser = value;
                      });
                    },
            ),
            if (selectedBillId != null) ...[
              const SizedBox(height: 8),
              Text(
                'Select the user who made the payment (excludes the person who originally paid the bill)',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            ],
            const SizedBox(height: 24),

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CustomButton(
                  label: 'Cancel',
                  variant: ButtonVariant.ghost,
                  onPressed: submitting
                      ? null
                      : () {
                          Navigator.pop(context);
                        },
                ),
                const SizedBox(width: 12),
                CustomButton(
                  label: submitting ? 'Recording...' : 'Record Repayment',
                  onPressed: (selectedUser == null || selectedBillId == null || submitting)
                      ? null
                      : handleSubmit,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
