import 'package:dorm_of_decents/configs/theme.dart';
import 'package:dorm_of_decents/logic/meal_cubit.dart';
import 'package:dorm_of_decents/ui/widgets/custom_page_header.dart';
import 'package:dorm_of_decents/ui/widgets/loading_animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MealsPage extends StatelessWidget {
  const MealsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.getTheme(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomPageHeader(theme: theme, title: 'Meals'),
            Expanded(
              child: BlocConsumer<MealCubit, MealState>(
                listener: (context, state) {
                  // You can handle side effects here based on state changes
                },
                builder: (context, state) {
                  if (state is MealInitial) {
                    context.read<MealCubit>().fetchMeals();
                    return const Center(child: LoadingAnimation());
                  } else if (state is MealLoading) {
                    return const Center(child: LoadingAnimation());
                  } else if (state is MealError) {
                    return Center(child: Text(state.message));
                  } else if (state is MealEmpty) {
                    return const Center(child: Text('No meal data available'));
                  } else if (state is MealLoaded) {
                    final meals = state.meals;
                    return Center(child: Text('Total meals: ${meals.length}'));
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
}
