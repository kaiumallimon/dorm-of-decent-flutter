import 'package:dorm_of_decents/configs/theme.dart';
import 'package:dorm_of_decents/logic/meal_cubit.dart';
import 'package:dorm_of_decents/ui/widgets/add_meal_dialog.dart';
import 'package:dorm_of_decents/ui/widgets/custom_button.dart';
import 'package:dorm_of_decents/ui/widgets/custom_dropdown.dart';
import 'package:dorm_of_decents/ui/widgets/custom_page_header.dart';
import 'package:dorm_of_decents/ui/widgets/meals_page_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MealsPage extends StatefulWidget {
  const MealsPage({super.key});

  @override
  State<MealsPage> createState() => _MealsPageState();
}

class _MealsPageState extends State<MealsPage> {
  String selectedMember = 'All Members';
  String selectedSort = 'Date (Newest)';

  Future<void> _showAddMealDialog() async {
    await showDialog(
      context: context,
      builder: (context) => const AddMealDialog(),
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
              title: 'Meals',
              actionButton: CustomButton(
                label: "Add Meal",
                icon: Icons.add_rounded,
                onPressed: _showAddMealDialog,
                size: ButtonSize.sm,
              ),
            ),
            Expanded(
              child: BlocConsumer<MealCubit, MealState>(
                listener: (context, state) {
                  // You can handle side effects here based on state changes
                },
                builder: (context, state) {
                  if (state is MealInitial) {
                    context.read<MealCubit>().fetchMeals();
                    return const MealsPageShimmer();
                  } else if (state is MealLoading) {
                    return const MealsPageShimmer();
                  } else if (state is MealError) {
                    return Center(child: Text(state.message));
                  } else if (state is MealEmpty) {
                    return const Center(child: Text('No meal data available'));
                  } else if (state is MealLoaded) {
                    final mealResponse = state.mealResponse;
                    final memberTotals = mealResponse.sortedMemberTotals;

                    return RefreshIndicator(
                      onRefresh: () async {
                        await context.read<MealCubit>().refreshMeals();
                      },
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 10,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Overall Meals Card
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
                                    'Overall Meals',
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${mealResponse.totalEntries} entries',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurface
                                          .withOpacity(0.6),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    crossAxisAlignment: .center,
                                    mainAxisAlignment: .center,
                                    children: [
                                      Text(
                                        mealResponse.overallMeals
                                            .toStringAsFixed(1),
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
                            const SizedBox(height: 32),
                            // Section Title
                            Text(
                              'Meal Totals by Consumers',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Member Cards Grid
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: memberTotals.map((member) {
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
                                        member.userName,
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${member.entries} entries',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: theme.colorScheme.onSurface
                                                  .withOpacity(0.6),
                                            ),
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        crossAxisAlignment: .center,
                                        mainAxisAlignment: .center,
                                        children: [
                                          Text(
                                            member.totalMeals.toStringAsFixed(
                                              1,
                                            ),
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
                                // Member Filter
                                Expanded(
                                  child: CustomDropdown<String>(
                                    label: 'Filter by Member',
                                    value: selectedMember,
                                    prefixIcon: Icons.person_outline_rounded,
                                    items: [
                                      const DropdownMenuItem(
                                        value: 'All Members',
                                        child: Text('All Members'),
                                      ),
                                      ...memberTotals.map((member) {
                                        return DropdownMenuItem(
                                          value: member.userId,
                                          child: Text(member.userName),
                                        );
                                      }),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        selectedMember = value!;
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Sort Filter
                                Expanded(
                                  child: CustomDropdown<String>(
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
                                        value: 'Count (High to Low)',
                                        child: Text('Count (High to Low)'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'Count (Low to High)',
                                        child: Text('Count (Low to High)'),
                                      ),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        selectedSort = value!;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Table
                            _buildMealsTable(
                              theme,
                              mealResponse.meals,
                              selectedMember,
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

  Widget _buildMealsTable(
    ThemeData theme,
    List<dynamic> allMeals,
    String memberFilter,
    String sortOption,
  ) {
    // Filter meals
    var filteredMeals = memberFilter == 'All Members'
        ? List.from(allMeals)
        : allMeals.where((meal) => meal.userId == memberFilter).toList();

    // Sort meals
    if (sortOption == 'Date (Newest)') {
      filteredMeals.sort((a, b) => b.date.compareTo(a.date));
    } else if (sortOption == 'Date (Oldest)') {
      filteredMeals.sort((a, b) => a.date.compareTo(b.date));
    } else if (sortOption == 'Count (High to Low)') {
      filteredMeals.sort((a, b) => b.mealCount.compareTo(a.mealCount));
    } else if (sortOption == 'Count (Low to High)') {
      filteredMeals.sort((a, b) => a.mealCount.compareTo(b.mealCount));
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
                  flex: 2,
                  child: Text(
                    'Member',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'Count',
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
          ...filteredMeals.map((meal) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                      '${meal.date.month.toString().padLeft(2, '0')}/${meal.date.day.toString().padLeft(2, '0')}/${meal.date.year}',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      meal.profiles.name,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      meal.mealCount.toStringAsFixed(
                        meal.mealCount % 1 == 0 ? 0 : 1,
                      ),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
