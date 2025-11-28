import 'package:dorm_of_decents/configs/theme.dart';
import 'package:dorm_of_decents/data/models/profile.dart';
import 'package:dorm_of_decents/logic/users_cubit.dart';
import 'package:dorm_of_decents/ui/widgets/custom_page_header.dart';
import 'package:dorm_of_decents/ui/widgets/meals_page_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timeago/timeago.dart' as timeago;

class UsersPage extends StatelessWidget {
  const UsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.getTheme(context);

    return BlocProvider(
      create: (_) => UsersCubit()..fetchUsers(),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomPageHeader(
                theme: theme,
                title: 'Users',
                showBackButton: true,
              ),
              Expanded(
                child: BlocBuilder<UsersCubit, UsersState>(
                  builder: (context, state) {
                    if (state is UsersInitial || state is UsersLoading) {
                      return const MealsPageShimmer();
                    }

                    if (state is UsersError) {
                      return Center(
                        child: Text(
                          state.message,
                          style: theme.textTheme.bodyMedium,
                        ),
                      );
                    }

                    if (state is UsersEmpty) {
                      return const Center(child: Text('No users found.'));
                    }

                    if (state is UsersLoaded) {
                      return RefreshIndicator(
                        onRefresh: () async {
                          await context.read<UsersCubit>().fetchUsers();
                        },
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 10,
                          ),
                          itemCount: state.users.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final user = state.users[index];
                            return _UserCard(user, theme);
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

class _UserCard extends StatelessWidget {
  final Profile user;
  final ThemeData theme;
  const _UserCard(this.user, this.theme);

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
              _Avatar(user.name, theme),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            user.name,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _RoleBadge(user.role, theme),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (user.phone != null && user.phone!.isNotEmpty)
                      Text(
                        user.phone!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
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
                'Joined ${timeago.format(user.createdAt)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              Text(
                'ID: ${user.id.substring(0, 8)}...',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final UserRole role;
  final ThemeData theme;
  const _RoleBadge(this.role, this.theme);

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;

    switch (role) {
      case UserRole.admin:
        backgroundColor = Colors.purple.withOpacity(0.15);
        textColor = Colors.purple.shade700;
        break;
      case UserRole.member:
        backgroundColor = Colors.blue.withOpacity(0.15);
        textColor = Colors.blue.shade700;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        role.displayName.toUpperCase(),
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
      radius: 24,
      backgroundColor: theme.colorScheme.primary.withOpacity(0.15),
      child: Text(
        initials,
        style: theme.textTheme.titleMedium?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
