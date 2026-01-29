import 'package:dorm_of_decents/configs/theme.dart';
import 'package:dorm_of_decents/logic/auth_cubit.dart';
import 'package:dorm_of_decents/logic/bills_due_cubit.dart';
import 'package:dorm_of_decents/ui/widgets/add_repayment_dialog.dart';
import 'package:dorm_of_decents/ui/widgets/custom_page_header.dart';
import 'package:dorm_of_decents/ui/widgets/meals_page_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BillsDuePage extends StatefulWidget {
  const BillsDuePage({super.key});

  @override
  State<BillsDuePage> createState() => _BillsDuePageState();
}

class _BillsDuePageState extends State<BillsDuePage> {
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
              title: 'Bills Due',
              subtitle: 'Track bill payments and who owes whom',
              showMenuButton: false,
              showBackButton: true,
            ),
            Expanded(
              child: BlocBuilder<BillsDueCubit, BillsDueState>(
                builder: (context, state) {
                  if (state is BillsDueInitial) {
                    context.read<BillsDueCubit>().fetchBillsDue();
                    return const MealsPageShimmer();
                  } else if (state is BillsDueLoading) {
                    return const MealsPageShimmer();
                  } else if (state is BillsDueFailure) {
                    return Center(child: Text('Error: ${state.error}'));
                  } else if (state is BillsDueLoaded) {
                    final response = state.billsDueResponse;
                    final bills = response.bills;
                    final billPayments = response.billPayments;
                    final profiles = response.profiles;
                    final month = response.month;

                    if (month == null) {
                      return const Center(
                        child: Text('No active month found'),
                      );
                    }

                    // Calculate bills due for each member
                    final billsDueMap = _calculateBillsDue(bills, billPayments, profiles);

                    return RefreshIndicator(
                      onRefresh: () async {
                        await context.read<BillsDueCubit>().refreshBillsDue();
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
                            // Total Bills Card
                            _buildTotalBillsCard(theme, bills, month.monthName),
                            const SizedBox(height: 24),

                            // Bill Type Breakdown
                            Text(
                              'Bills by Type',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildBillTypeCards(theme, bills, profiles.length),
                            const SizedBox(height: 24),

                            // Active Members Count
                            _buildActiveMembersCard(theme, profiles),
                            const SizedBox(height: 24),

                            // Add Repayment Button (Admin Only)
                            BlocBuilder<AuthCubit, AuthState>(
                              builder: (context, authState) {
                                if (authState is AuthAuthenticated &&
                                    authState.userData.role == 'admin') {
                                  return Column(
                                    children: [
                                      SizedBox(
                                        width: double.infinity,
                                        child: OutlinedButton.icon(
                                          style: ButtonStyle(
                                            padding: MaterialStateProperty.all(
                                              const EdgeInsets.symmetric(
                                                vertical: 14,
                                              ),
                                            ),
                                            side: MaterialStateProperty.all(
                                              BorderSide(
                                                color: theme.colorScheme.primary.withAlpha(100),
                                                width: 1.5
                                              ),
                                            ),
                                          ),
                                          onPressed: () async {
                                            await showDialog(
                                              context: context,
                                              builder: (context) => AddRepaymentDialog(
                                                bills: bills,
                                                profiles: profiles,
                                                activeUsersCount: profiles.length,
                                                onRefetch: () {
                                                  context.read<BillsDueCubit>().refreshBillsDue();
                                                },
                                              ),

                                            );
                                          },
                                          icon: const Icon(Icons.handshake_outlined),
                                          label: const Text('Add Repayment'),
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                    ],
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),

                            // Individual Bills Due
                            Text(
                              'Individual Bills Due',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ...billsDueMap.entries.map((entry) {
                              final profile = profiles.firstWhere((p) => p.id == entry.key);
                              final dueData = entry.value;
                              return _buildIndividualBillCard(theme, profile, dueData, profiles.length);
                            }),
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

  Widget _buildTotalBillsCard(ThemeData theme, List bills, String monthName) {
    final totalBills = bills.fold<double>(0.0, (sum, bill) => sum + bill.amount);

    return Container(
      width: double.infinity,
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
          Text(
            'Total Bills',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            '${bills.length} entries • $monthName',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '৳${totalBills.toStringAsFixed(2)}',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBillTypeCards(ThemeData theme, List bills, int memberCount) {
    final electricityTotal = bills
        .where((b) => b.billType == 'electricity')
        .fold<double>(0.0, (sum, b) => sum + b.amount);
    final gasTotal = bills
        .where((b) => b.billType == 'gas')
        .fold<double>(0.0, (sum, b) => sum + b.amount);
    final internetTotal = bills
        .where((b) => b.billType == 'internet')
        .fold<double>(0.0, (sum, b) => sum + b.amount);

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _buildBillTypeCard(theme, '⚡', 'Electricity', electricityTotal),
        _buildBillTypeCard(theme, '🔥', 'Gas', gasTotal),
        _buildBillTypeCard(theme, '🌐', 'Internet', internetTotal),
      ],
    );
  }

  Widget _buildBillTypeCard(ThemeData theme, String icon, String label, double amount) {
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
              Text(icon, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                label,
                style: theme.textTheme.titleSmall?.copyWith(
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

  Widget _buildActiveMembersCard(ThemeData theme, List profiles) {
    return Container(
      width: double.infinity,
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Active Members',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                onPressed: () {
                  context.read<BillsDueCubit>().refreshBillsDue();
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${profiles.length}',
            style: theme.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndividualBillCard(ThemeData theme, profile, Map<String, dynamic> dueData, int memberCount) {
    final totalDue = dueData['total'] as double;
    final billBreakdown = dueData['breakdown'] as Map<String, double>;
    final totalPaid = dueData['paid'] as double;

    final netAmount = totalDue - totalPaid;
    final status = netAmount > 0.01 ? 'Owes' : netAmount < -0.01 ? 'Gets Back' : 'Settled';
    final statusColor = netAmount > 0.01
        ? Colors.red
        : netAmount < -0.01
            ? Colors.green
            : theme.colorScheme.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                profile.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            netAmount >= 0 ? 'Amount to pay' : 'Amount to receive',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '৳${netAmount.abs().toStringAsFixed(2)}',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: statusColor,
            ),
          ),
          const SizedBox(height: 16),
          ...billBreakdown.entries.map((entry) {
            final icon = entry.key == 'electricity'
                ? '⚡'
                : entry.key == 'gas'
                    ? '🔥'
                    : '🌐';
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(icon),
                      const SizedBox(width: 8),
                      Text(
                        entry.key[0].toUpperCase() + entry.key.substring(1),
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  Text(
                    '৳${entry.value.toStringAsFixed(2)}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }),
          if (totalPaid > 0) ...[
            Divider(height: 24,color: theme.colorScheme.primary.withAlpha(75)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Bills Paid',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.green,
                  ),
                ),
                Text(
                  '৳${totalPaid.toStringAsFixed(2)}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Map<String, Map<String, dynamic>> _calculateBillsDue(
    List bills,
    List billPayments,
    List profiles,
  ) {
    final Map<String, Map<String, dynamic>> billsDueMap = {};
    final memberCount = profiles.length;

    // Initialize for each profile
    for (var profile in profiles) {
      billsDueMap[profile.id] = {
        'total': 0.0,
        'breakdown': <String, double>{},
        'paid': 0.0,
      };
    }

    // Calculate what each person owes
    for (var bill in bills) {
      final perPersonAmount = bill.amount / memberCount;
      final billPayer = bill.paidBy;

      for (var profile in profiles) {
        if (profile.id != billPayer) {
          // This person owes money
          billsDueMap[profile.id]!['total'] =
              (billsDueMap[profile.id]!['total'] as double) + perPersonAmount;
          billsDueMap[profile.id]!['breakdown'][bill.billType] =
              ((billsDueMap[profile.id]!['breakdown'] as Map<String, double>)[bill.billType] ?? 0.0) + perPersonAmount;
        }
      }
    }

    // Subtract what each person has already paid
    for (var payment in billPayments) {
      final paidBy = payment.paidBy;
      billsDueMap[paidBy]!['paid'] =
          (billsDueMap[paidBy]!['paid'] as double) + payment.amount;
    }

    return billsDueMap;
  }
}
