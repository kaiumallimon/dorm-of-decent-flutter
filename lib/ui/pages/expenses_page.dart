import 'package:dorm_of_decents/configs/theme.dart';
import 'package:dorm_of_decents/logic/expense_cubit.dart';
import 'package:dorm_of_decents/ui/widgets/add_expense_dialog.dart';
import 'package:dorm_of_decents/ui/widgets/custom_button.dart';
import 'package:dorm_of_decents/ui/widgets/custom_dropdown.dart';
import 'package:dorm_of_decents/ui/widgets/custom_page_header.dart';
import 'package:dorm_of_decents/ui/widgets/meals_page_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ExpensesPage extends StatefulWidget {
  const ExpensesPage({super.key});

  @override
  State<ExpensesPage> createState() => _ExpensesPageState();
}

class _ExpensesPageState extends State<ExpensesPage> {
  String selectedCategory = 'All Categories';
  String selectedPaidBy = 'All Members';
  String selectedSort = 'Date (Newest)';

  Future<void> _showAddExpenseDialog() async {
    await showDialog(
      context: context,
      builder: (context) => const AddExpenseDialog(),
    );
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
              title: 'Expenses',
              actionButton: CustomButton(
                label: "Add Expense",
                icon: Icons.add_rounded,
                onPressed: _showAddExpenseDialog,
                size: ButtonSize.sm,
              ),
            ),
            Expanded(
              child: BlocConsumer<ExpenseCubit, ExpenseState>(
                listener: (context, state) {
                  // You can handle side effects here based on state changes
                },
                builder: (context, state) {
                  if (state is ExpenseInitial) {
                    context.read<ExpenseCubit>().fetchExpenses();
                    return const MealsPageShimmer();
                  } else if (state is ExpenseLoading) {
                    return const MealsPageShimmer();
                  } else if (state is ExpenseFailure) {
                    return Center(child: Text(state.error));
                  } else if (state is ExpenseLoaded) {
                    final expenseResponse = state.expenseResponse;
                    final expenses = expenseResponse.expenses;

                    if (expenses.isEmpty) {
                      return const Center(
                        child: Text('No expense data available'),
                      );
                    }

                    // Calculate totals
                    final totalExpenses = expenses.fold<double>(
                      0.0,
                      (sum, expense) => sum + expense.amount,
                    );

                    // Calculate per-person totals
                    final Map<String, double> personTotals = {};
                    final Map<String, String> personIds = {};
                    for (var expense in expenses) {
                      final personName = expense.profiles.name;
                      final personId = expense.profiles.id;
                      personTotals[personName] =
                          (personTotals[personName] ?? 0) + expense.amount;
                      personIds[personName] = personId;
                    }

                    // Sort person totals by amount (descending)
                    final sortedPersonTotals = personTotals.entries.toList()
                      ..sort((a, b) => b.value.compareTo(a.value));

                    // Get unique categories
                    final categories =
                        expenses.map((e) => e.category).toSet().toList()
                          ..sort();

                    return RefreshIndicator(
                      onRefresh: () async {
                        await context.read<ExpenseCubit>().refreshExpenses();
                      },
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 10,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Overall Expenses Card
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
                                    'Total Expenses',
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${expenses.length} entries • ${expenseResponse.expenseMonth.monthName}',
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
                                        '৳${totalExpenses.toStringAsFixed(2)}',
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

                            // Individual Person Totals
                            Text(
                              'Expenses by Person',
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
                                            style: theme
                                                .textTheme
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
                                // Category Filter
                                Expanded(
                                  child: CustomDropdown<String>(
                                    label: 'Filter by Category',
                                    value: selectedCategory,
                                    prefixIcon: Icons.category_outlined,
                                    items: [
                                      const DropdownMenuItem(
                                        value: 'All Categories',
                                        child: Text('All Categories'),
                                      ),
                                      ...categories.map((category) {
                                        return DropdownMenuItem(
                                          value: category,
                                          child: Text(category),
                                        );
                                      }),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        selectedCategory = value!;
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
                            const SizedBox(height: 16),

                            // Table
                            _buildExpensesTable(
                              theme,
                              expenses,
                              selectedCategory,
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

  void _showExpenseDetails(BuildContext context, dynamic expense) {
    final theme = AppTheme.getTheme(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Expense Details',
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
              '${expense.date.month.toString().padLeft(2, '0')}/${expense.date.day.toString().padLeft(2, '0')}/${expense.date.year}',
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              theme,
              'Amount',
              '৳${expense.amount.toStringAsFixed(2)}',
            ),
            const SizedBox(height: 12),
            _buildDetailRow(theme, 'Category', expense.category),
            const SizedBox(height: 12),
            _buildDetailRow(theme, 'Paid By', expense.profiles.name),
            const SizedBox(height: 12),
            _buildDetailRow(theme, 'Description', expense.description),
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

  Widget _buildExpensesTable(
    ThemeData theme,
    List<dynamic> allExpenses,
    String categoryFilter,
    String paidByFilter,
    String sortOption,
  ) {
    // Filter expenses
    var filteredExpenses = List.from(allExpenses);

    // Apply category filter
    if (categoryFilter != 'All Categories') {
      filteredExpenses = filteredExpenses
          .where((expense) => expense.category == categoryFilter)
          .toList();
    }

    // Apply paid by filter
    if (paidByFilter != 'All Members') {
      filteredExpenses = filteredExpenses
          .where((expense) => expense.profiles.id == paidByFilter)
          .toList();
    }

    // Sort expenses
    if (sortOption == 'Date (Newest)') {
      filteredExpenses.sort((a, b) => b.date.compareTo(a.date));
    } else if (sortOption == 'Date (Oldest)') {
      filteredExpenses.sort((a, b) => a.date.compareTo(b.date));
    } else if (sortOption == 'Amount (High to Low)') {
      filteredExpenses.sort((a, b) => b.amount.compareTo(a.amount));
    } else if (sortOption == 'Amount (Low to High)') {
      filteredExpenses.sort((a, b) => a.amount.compareTo(b.amount));
    }

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
                  flex: 4,
                  child: Text(
                    'Description',
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
          ...filteredExpenses.map((expense) {
            return InkWell(
              onTap: () => _showExpenseDetails(context, expense),
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
                        '${expense.date.month.toString().padLeft(2, '0')}/${expense.date.day.toString().padLeft(2, '0')}/${expense.date.year}',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Text(
                        expense.description,
                        style: theme.textTheme.bodyMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        '৳${expense.amount.toStringAsFixed(2)}',
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
