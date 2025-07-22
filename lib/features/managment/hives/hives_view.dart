import 'package:apiarium/core/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:apiarium/core/theme/app_theme.dart';
import 'package:apiarium/features/managment/hives/bloc/hives_bloc.dart';
import 'package:apiarium/features/managment/hives/widgets/hive_card.dart';
import 'package:apiarium/shared/shared.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';

class HivesView extends StatelessWidget {
  const HivesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade100,
      child: Column(
        children: const [
          _InfoBanner(),
          Expanded(child: _HivesList()),
        ],
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HivesBloc, HivesState>(
      builder: (context, state) {
        if (state.filteredHives.isEmpty || state.status != HivesStatus.loaded) {
          return const SizedBox.shrink();
        }
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          color: Colors.grey.shade100,
          child: Row(
            children: [
              Text(
                '${state.filteredHives.length} ${state.filteredHives.length == 1 ? 'vc.hive'.tr() : 'vc.hives'.tr()}',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (_hasActiveFilters(state))
                const _FilteredBadge(),
            ],
          ),
        );
      },
    );
  }

  bool _hasActiveFilters(HivesState state) {
    final filter = state.filter;
    return filter.apiaryId != null ||
           filter.strength != null ||
           filter.hiveTypeId != null ||
           filter.queenStatus != null ||
           filter.hiveStatus != null;
  }
}

class _FilteredBadge extends StatelessWidget {
  const _FilteredBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.filter_list, color: AppTheme.primaryColor, size: 16),
          const SizedBox(width: 4),
          Text(
            'common.filtered'.tr(),
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _HivesList extends StatelessWidget {
  const _HivesList();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HivesBloc, HivesState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        switch (state.status) {
          case HivesStatus.initial:
          case HivesStatus.loading:
            return const _LoadingView();
          case HivesStatus.error:
            return _ErrorView(
              message: state.errorMessage ?? 'common.error_occurred'.tr(),
              onRetry: () => context.read<HivesBloc>().add(const LoadHives()),
            );
          case HivesStatus.loaded:
            if (state.filteredHives.isEmpty) {
              return _EmptyView(hasActiveFilters: _hasActiveFilters(state));
            }
            return _HivesListView(hives: state.filteredHives);
        }
      },
    );
  }

  bool _hasActiveFilters(HivesState state) {
    final filter = state.filter;
    return filter.apiaryId != null ||
           filter.strength != null ||
           filter.hiveTypeId != null ||
           filter.queenStatus != null ||
           filter.hiveStatus != null;
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(message),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            child: Text('common.retry'.tr()),
          ),
        ],
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  final bool hasActiveFilters;

  const _EmptyView({required this.hasActiveFilters});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.home, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            hasActiveFilters
                ? 'hives.no_matches'.tr()
                : 'hives.empty'.tr(),
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
          if (hasActiveFilters) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.read<HivesBloc>().add(const ResetFilters()),
              child: Text('common.clear_filters'.tr()),
            ),
          ],
        ],
      ),
    );
  }
}

class _HivesListView extends StatelessWidget {
  final List<Hive> hives;

  const _HivesListView({required this.hives});

  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      padding: const EdgeInsets.only(bottom: 80, top: 8),
      itemCount: hives.length,
      onReorder: (oldIndex, newIndex) {
        context.read<HivesBloc>().add(
          ReorderHives(oldIndex: oldIndex, newIndex: newIndex),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('hives.order_updated'.tr())),
        );
      },
      itemBuilder: (context, index) {
        final hive = hives[index];
        return Dismissible(
          key: Key(hive.id),
          background: Container(
            color: Colors.blue,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 16),
            child: const Icon(Icons.edit, color: Colors.white),
          ),
          secondaryBackground: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          confirmDismiss: (direction) async {
            if (direction == DismissDirection.startToEnd) {
              _navigateToEditHive(context, hive);
              return false;
            } else {
              return await _confirmDelete(context, hive);
            }
          },
          onDismissed: (direction) {
            context.read<HivesBloc>().add(DeleteHive(hive.id));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('hives.deleted'.tr(namedArgs: {'name': hive.name}))),            );
          },
          child: HiveCard(
            key: Key('hive_${hive.id}'),
            hive: hive,
            onTap: () => _navigateToHiveDetails(context, hive),
            onEditTap: () => _navigateToEditHive(context, hive),
            onDeleteTap: () => _handleDelete(context, hive),
          ),
        );
      },
    );
  }

  void _handleDelete(BuildContext context, Hive hive) async {
    final delete = await _confirmDelete(context, hive);
    if (delete && context.mounted) {
      context.read<HivesBloc>().add(DeleteHive(hive.id));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('hives.deleted'.tr(namedArgs: {'name': hive.name}))),      );
    }
  }

  Future<bool> _confirmDelete(BuildContext context, Hive hive) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('hives.delete_title'.tr()),
          content: Text('hives.delete_confirm'.tr(namedArgs: {'name': hive.name})),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('common.cancel'.tr()),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                'common.delete'.tr(),
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    ) ?? false;
  }

  void _navigateToEditHive(BuildContext context, Hive hive) async {
    await context.push(
      AppRouter.editHive,
      extra: {'hiveId': hive.id},
    );
    if (context.mounted) {
      context.read<HivesBloc>().add(const LoadHives());
    }
  }

  void _navigateToHiveDetails(BuildContext context, Hive hive) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('hives.details_coming_soon'.tr(namedArgs: {'name': hive.name}))),    );
  }
}