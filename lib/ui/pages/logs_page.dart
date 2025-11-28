import 'package:dorm_of_decents/configs/theme.dart';
import 'package:dorm_of_decents/data/models/logs_response.dart';
import 'package:dorm_of_decents/logic/logs_cubit.dart';
import 'package:dorm_of_decents/ui/widgets/custom_page_header.dart';
import 'package:dorm_of_decents/ui/widgets/meals_page_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timeago/timeago.dart' as timeago;

class LogsPage extends StatelessWidget {
  const LogsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.getTheme(context);

    return BlocProvider(
      create: (_) => LogsCubit()..fetchLogs(),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomPageHeader(
                theme: theme,
                title: 'Recent Activity',
                showBackButton: true,
              ),
              Expanded(
                child: BlocBuilder<LogsCubit, LogsState>(
                  builder: (context, state) {
                    if (state is LogsInitial || state is LogsLoading) {
                      return const MealsPageShimmer();
                    }

                    if (state is LogsError) {
                      return Center(
                        child: Text(
                          state.message,
                          style: theme.textTheme.bodyMedium,
                        ),
                      );
                    }

                    if (state is LogsEmpty) {
                      return const Center(
                        child: Text('No activity logs found.'),
                      );
                    }

                    if (state is LogsLoaded) {
                      return RefreshIndicator(
                        onRefresh: () async {
                          await context.read<LogsCubit>().fetchLogs();
                        },
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 10,
                          ),
                          itemCount: state.logs.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final log = state.logs[index];
                            return _LogCard(log, theme);
                          },
                        ),
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogCard extends StatelessWidget {
  final ActivityLog log;
  final ThemeData theme;
  const _LogCard(this.log, this.theme);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Avatar(log.userName, theme),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _ActionBadge(log.description, theme),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            log.userName,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(_formatAction(log), style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                timeago.format(log.timestamp),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              if (log.amount > 0)
                Text(
                  log.type == ActivityType.meal
                      ? '${log.amount.toInt()} meal${log.amount > 1 ? 's' : ''}'
                      : '৳${log.amount.toStringAsFixed(2)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

String _formatAction(ActivityLog log) {
  switch (log.type) {
    case ActivityType.meal:
      return 'added ${log.amount.toInt()} meal${log.amount > 1 ? 's' : ''}';
    case ActivityType.expense:
      return 'added an expense of ৳${log.amount.toStringAsFixed(2)}';
    case ActivityType.settlement:
      return 'made a settlement of ৳${log.amount.toStringAsFixed(2)}';
  }
}

class _ActionBadge extends StatelessWidget {
  final String action;
  final ThemeData theme;
  const _ActionBadge(this.action, this.theme);

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    String label;

    final actionLower = action.toLowerCase();
    if (actionLower.contains('create') || actionLower.contains('add')) {
      backgroundColor = Colors.green.withOpacity(0.15);
      textColor = Colors.green.shade700;
      label = 'CREATE';
    } else if (actionLower.contains('update') || actionLower.contains('edit')) {
      backgroundColor = Colors.blue.withOpacity(0.15);
      textColor = Colors.blue.shade700;
      label = 'UPDATE';
    } else if (actionLower.contains('delete') ||
        actionLower.contains('remove')) {
      backgroundColor = Colors.red.withOpacity(0.15);
      textColor = Colors.red.shade700;
      label = 'DELETE';
    } else if (actionLower.contains('settlement') ||
        actionLower.contains('pay')) {
      backgroundColor = Colors.orange.withOpacity(0.15);
      textColor = Colors.orange.shade700;
      label = 'SETTLE';
    } else {
      backgroundColor = Colors.grey.withOpacity(0.15);
      textColor = Colors.grey.shade700;
      label = 'ACTION';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String name;
  final ThemeData theme;
  const _Avatar(this.name, this.theme);

  @override
  Widget build(BuildContext context) {
    final initials = name.isEmpty ? '?' : name.substring(0, 1).toUpperCase();

    return CircleAvatar(
      radius: 20,
      backgroundColor: theme.colorScheme.primary.withOpacity(0.15),
      child: Text(
        initials,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
