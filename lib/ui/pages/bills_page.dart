import 'dart:io';
import 'package:dorm_of_decents/configs/theme.dart';
import 'package:dorm_of_decents/logic/auth_cubit.dart';
import 'package:dorm_of_decents/logic/bills_cubit.dart';
import 'package:dorm_of_decents/ui/widgets/add_bill_dialog.dart';
import 'package:dorm_of_decents/ui/widgets/custom_button.dart';
import 'package:dorm_of_decents/ui/widgets/custom_dropdown.dart';
import 'package:dorm_of_decents/ui/widgets/custom_page_header.dart';
import 'package:dorm_of_decents/ui/widgets/meals_page_shimmer.dart';
import 'package:dorm_of_decents/utils/bill_report_generator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:toastification/toastification.dart';

class BillsPage extends StatefulWidget {
  const BillsPage({super.key});

  @override
  State<BillsPage> createState() => _BillsPageState();
}

class _BillsPageState extends State<BillsPage> {
  String selectedBillType = 'All Types';
  String selectedPaidBy = 'All Members';
  String selectedSort = 'Date (Newest)';
  bool _isGeneratingReport = false;
  String? _generatingForUser;

  Future<void> _showAddBillDialog() async {
    await showDialog(
      context: context,
      builder: (context) => const AddBillDialog(),
    );
  }

  Future<void> _generateBillReport(String userId, String userName, List<dynamic> allBills) async {
    setState(() {
      _isGeneratingReport = true;
      _generatingForUser = userId;
    });

    final theme = AppTheme.getTheme(context);

    try {
      // Filter bills for this user
      final userBills = allBills.where((bill) => bill.paidBy == userId).toList();

      if (userBills.isEmpty) {
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
            "No bills found for this user",
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

      // Calculate total amount
      final totalAmount = userBills.fold<double>(
        0.0,
        (sum, bill) => sum + bill.amount,
      );

      // Format bills for the report
      final formattedBills = userBills.map((bill) {
        final date = bill.date;
        final formattedDate = '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}';
        
        return {
          'date': formattedDate,
          'amount': bill.amount.toStringAsFixed(2),
          'description': bill.description?.isEmpty ?? true 
              ? '${bill.billType[0].toUpperCase()}${bill.billType.substring(1)} Bill' 
              : bill.description!,
        };
      }).toList();

      // Sort by date (newest first)
      formattedBills.sort((a, b) {
        final dateA = a['date'] as String;
        final dateB = b['date'] as String;
        return dateB.compareTo(dateA);
      });

      // Generate the report
      final file = await BillReportGenerator.generateBillReport(
        userName: userName,
        totalAmount: totalAmount,
        bills: formattedBills,
        context: context,
      );

      if (file != null && mounted) {
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
            Platform.isAndroid
                ? "Bill report saved to Downloads folder: ${file.path.split('/').last}"
                : "Bill report saved: ${file.path}",
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          type: ToastificationType.success,
          style: ToastificationStyle.fillColored,
          primaryColor: theme.colorScheme.primary,
        );
      } else if (mounted) {
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
            "Failed to generate bill report",
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onErrorContainer,
            ),
          ),
          type: ToastificationType.error,
          style: ToastificationStyle.fillColored,
          primaryColor: theme.colorScheme.error,
        );
      }
    } catch (e) {
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
            e.toString(),
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
      setState(() {
        _isGeneratingReport = false;
        _generatingForUser = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.getTheme(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomPageHeader(
              theme: theme,
              title: 'Bills',
              subtitle: 'Track your bills',
              actionButton: BlocBuilder<AuthCubit, AuthState>(
                builder: (context, state) {
                  if (state is AuthAuthenticated) {
                    if (state.userData.role == 'admin') {
                      return CustomButton(
                        label: 'Add',
                        icon: Icons.add_rounded,
                        onPressed: _showAddBillDialog,
                      );
                    }
                    return const SizedBox.shrink();
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            Expanded(
              child: BlocConsumer<BillsCubit, BillsState>(
                listener: (context, state) {
                  // Handle side effects here
                },
                builder: (context, state) {
                  if (state is BillsInitial) {
                    context.read<BillsCubit>().fetchBills();
                    return const MealsPageShimmer();
                  } else if (state is BillsLoading) {
                    return const MealsPageShimmer();
                  } else if (state is BillsFailure) {
                    return Center(child: Text('Error: ${state.error}'));
                  } else if (state is BillsLoaded) {
                    final response = state.billsResponse;
                    final bills = response.bills;

                    if (bills.isEmpty) {
                      return const Center(
                        child: Text('No bills data available'),
                      );
                    }

                    // Calculate totals
                    final totalBills = response.totalBills();
                    final electricityTotal = response.electricityBills();
                    final internetTotal = response.internetBills();
                    final gasTotal = response.gasBills();

                    // Calculate per-person totals (following expenses page pattern)
                    final Map<String, double> personTotals = {};
                    final Map<String, String> personIds = {};
                    for (var bill in bills) {
                      final personName = bill.profiles['name'] as String;
                      final personId = bill.paidBy;
                      personTotals[personName] =
                          (personTotals[personName] ?? 0) + bill.amount;
                      // Only add to dropdown if there's a valid paid_by ID
                      if (personId != null && personId.isNotEmpty) {
                        personIds[personName] = personId;
                      }
                    }

                    // Sort person totals by amount (descending)
                    final sortedPersonTotals = personTotals.entries.toList()
                      ..sort((a, b) => b.value.compareTo(a.value));

                    // Get unique bill types
                    final billTypes =
                        bills.map((e) => e.billType).toSet().toList()..sort();

                    return RefreshIndicator(
                      onRefresh: () async {
                        await context.read<BillsCubit>().refreshBills();
                      },
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 10,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Overall Bills Card
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: theme.colorScheme.outline.withOpacity(
                                    0.1,
                                  ),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Total Bills',
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${bills.length} entries • ${response.month.monthName}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurface
                                          .withOpacity(0.6),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '৳${totalBills.toStringAsFixed(2)}',
                                        style: theme.textTheme.headlineMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Bill Type Breakdown
                            Text(
                              'Bills by Type',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Bill Type Cards
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                if (electricityTotal > 0)
                                  _buildBillTypeCard(
                                    theme,
                                    'Electricity',
                                    electricityTotal,
                                    Icons.flash_on,
                                    Colors.amber,
                                  ),
                                if (internetTotal > 0)
                                  _buildBillTypeCard(
                                    theme,
                                    'Internet',
                                    internetTotal,
                                    Icons.wifi,
                                    Colors.blue,
                                  ),
                                if (gasTotal > 0)
                                  _buildBillTypeCard(
                                    theme,
                                    'Gas',
                                    gasTotal,
                                    Icons.local_fire_department,
                                    Colors.orange,
                                  ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Bills by Person
                            Text(
                              'Bills by Person',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Person Cards Grid
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: sortedPersonTotals.map((entry) {
                                final personName = entry.key;
                                final amount = entry.value;
                                return Container(
                                  width:
                                      (MediaQuery.of(context).size.width - 60) /
                                          2,
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.surface,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: theme.colorScheme.outline
                                          .withOpacity(0.1),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        personName,
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            '৳${amount.toStringAsFixed(2)}',
                                            style: theme.textTheme
                                                .headlineMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 32),

                            // Filters
                            Row(
                              children: [
                                // Bill Type Filter
                                Expanded(
                                  child: CustomDropdown<String>(
                                    label: 'Filter by Type',
                                    value: selectedBillType,
                                    prefixIcon: Icons.category_outlined,
                                    items: [
                                      const DropdownMenuItem(
                                        value: 'All Types',
                                        child: Text('All Types'),
                                      ),
                                      ...billTypes.map((type) {
                                        return DropdownMenuItem(
                                          value: type,
                                          child: Text(
                                            type[0].toUpperCase() +
                                                type.substring(1),
                                          ),
                                        );
                                      }),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        selectedBillType = value!;
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Paid By Filter
                                Expanded(
                                  child: CustomDropdown<String>(
                                    label: 'Paid By',
                                    value: selectedPaidBy,
                                    prefixIcon: Icons.person_outline_rounded,
                                    items: [
                                      const DropdownMenuItem(
                                        value: 'All Members',
                                        child: Text('All Members'),
                                      ),
                                      ...personIds.entries.map((entry) {
                                        return DropdownMenuItem(
                                          value: entry.value,
                                          child: Text(entry.key),
                                        );
                                      }),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        selectedPaidBy = value!;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Sort Filter
                            CustomDropdown<String>(
                              label: 'Sort by',
                              value: selectedSort,
                              prefixIcon: Icons.sort_rounded,
                              items: const [
                                DropdownMenuItem(
                                  value: 'Date (Newest)',
                                  child: Text('Date (Newest)'),
                                ),
                                DropdownMenuItem(
                                  value: 'Date (Oldest)',
                                  child: Text('Date (Oldest)'),
                                ),
                                DropdownMenuItem(
                                  value: 'Amount (High to Low)',
                                  child: Text('Amount (High to Low)'),
                                ),
                                DropdownMenuItem(
                                  value: 'Amount (Low to High)',
                                  child: Text('Amount (Low to High)'),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  selectedSort = value!;
                                });
                              },
                            ),
                            const SizedBox(height: 24),

                            // Bills Table
                            _buildBillsTable(
                              theme,
                              bills,
                              selectedBillType,
                              selectedPaidBy,
                              selectedSort,
                            ),

                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    );
                  }
                  return const Center(child: Text('Unknown state'));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBillTypeCard(
    ThemeData theme,
    String type,
    double amount,
    IconData icon,
    Color color,
  ) {
    return Container(
      width: (MediaQuery.of(context).size.width - 60) / 2,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                type,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '৳${amount.toStringAsFixed(2)}',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showBillDetails(BuildContext context, dynamic bill) {
    final theme = AppTheme.getTheme(context);
    final dateFormat = DateFormat('MM/dd/yyyy');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Bill Details',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(
              theme,
              'Date',
              dateFormat.format(bill.date),
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              theme,
              'Amount',
              '৳${bill.amount.toStringAsFixed(2)}',
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              theme,
              'Bill Type',
              bill.billType[0].toUpperCase() + bill.billType.substring(1),
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              theme,
              'Paid By',
              bill.profiles['name'] as String,
            ),
            if (bill.description != null) ...[
              const SizedBox(height: 12),
              _buildDetailRow(theme, 'Description', bill.description!),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: TextStyle(color: theme.colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(ThemeData theme, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildBillsTable(
    ThemeData theme,
    List<dynamic> allBills,
    String typeFilter,
    String paidByFilter,
    String sortOption,
  ) {
    // Filter bills
    var filteredBills = List.from(allBills);

    // Apply type filter
    if (typeFilter != 'All Types') {
      filteredBills = filteredBills
          .where((bill) => bill.billType == typeFilter)
          .toList();
    }

    // Apply paid by filter
    if (paidByFilter != 'All Members') {
      filteredBills = filteredBills
          .where((bill) => bill.paidBy != null && bill.paidBy == paidByFilter)
          .toList();
    }

    // Sort bills
    if (sortOption == 'Date (Newest)') {
      filteredBills.sort((a, b) => b.date.compareTo(a.date));
    } else if (sortOption == 'Date (Oldest)') {
      filteredBills.sort((a, b) => a.date.compareTo(b.date));
    } else if (sortOption == 'Amount (High to Low)') {
      filteredBills.sort((a, b) => b.amount.compareTo(a.amount));
    } else if (sortOption == 'Amount (Low to High)') {
      filteredBills.sort((a, b) => a.amount.compareTo(b.amount));
    }

    final dateFormat = DateFormat('MM/dd/yy');

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline.withAlpha(25)),
      ),
      child: Column(
        children: [
          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: theme.colorScheme.outline.withAlpha(25),
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'Date',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'Type',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Amount',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
          // Table Rows
          ...filteredBills.map((bill) {
            return InkWell(
              onTap: () => _showBillDetails(context, bill),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: theme.colorScheme.outline.withOpacity(0.05),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        dateFormat.format(bill.date),
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        bill.billType[0].toUpperCase() +
                            bill.billType.substring(1),
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        '৳${bill.amount.toStringAsFixed(2)}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
