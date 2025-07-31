import 'package:apiarium/core/router/app_router.dart';
import 'package:apiarium/features/management/apiaries/bloc/apiaries_bloc.dart';
import 'package:apiarium/features/management/apiaries/widgets/apiary_card.dart';
import 'package:apiarium/shared/shared.dart';
import 'package:apiarium/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';

class ApiariesView extends StatelessWidget {
  const ApiariesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade100,
      child: Column(
        children: [
          const _InfoBanner(),
          const Expanded(child: _ApiariesList()),
        ],
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ApiariesBloc, ApiariesState>(
      builder: (context, state) {
        if (state.filteredApiaries.isEmpty || state.status != ApiariesStatus.loaded) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          color: Colors.grey.shade100,
          child: Row(
            children: [
              Text(
                'apiaries.count'.tr(namedArgs: {
                  'count': '${state.filteredApiaries.length}',
                  'type': state.filteredApiaries.length == 1
                      ? 'apiaries.singular'.tr()
                      : 'apiaries.plural'.tr()
                }),
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (_hasActiveFilters(state)) const _FilteredBadge(),
            ],
          ),
        );
      },
    );
  }

  bool _hasActiveFilters(ApiariesState state) {
    final filter = state.filter;
    return filter.location != null ||
        filter.isMigratory != null ||
        filter.status != null;
  }
}

class _FilteredBadge extends StatelessWidget {
  const _FilteredBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.filter_list, color: AppTheme.primaryColor, size: 16),
          const SizedBox(width: 4),
          Text(
            'apiaries.filtered'.tr(),
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

class _ApiariesList extends StatelessWidget {
  const _ApiariesList();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ApiariesBloc, ApiariesState>(
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
          case ApiariesStatus.initial:
          case ApiariesStatus.loading:
            return const Center(child: CircularProgressIndicator());
          case ApiariesStatus.error:
            return _ErrorView(
              message: state.errorMessage ?? 'common.error_occurred'.tr(),
              onRetry: () => context.read<ApiariesBloc>().add(const LoadApiaries()),
            );
          case ApiariesStatus.loaded:
            if (state.filteredApiaries.isEmpty) {
              return _EmptyView(hasActiveFilters: _hasActiveFilters(state));
            }
            return _ApiariesListView(apiaries: state.filteredApiaries);
        }
      },
    );
  }

  bool _hasActiveFilters(ApiariesState state) {
    final filter = state.filter;
    return filter.location != null ||
        filter.isMigratory != null ||
        filter.status != null;
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
          Icon(Icons.location_on, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            hasActiveFilters
                ? 'apiaries.no_matches'.tr()
                : 'apiaries.empty'.tr(),
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
          if (hasActiveFilters) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.read<ApiariesBloc>().add(const ResetFilters()),
              child: Text('apiaries.clear_filters'.tr()),
            ),
          ],
        ],
      ),
    );
  }
}

class _ApiariesListView extends StatelessWidget {
  final List<Apiary> apiaries;

  const _ApiariesListView({required this.apiaries});

  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      padding: const EdgeInsets.only(bottom: 80, top: 8),
      itemCount: apiaries.length,
      onReorder: (oldIndex, newIndex) {
        context.read<ApiariesBloc>().add(
          ReorderApiaries(oldIndex: oldIndex, newIndex: newIndex),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('apiaries.order_updated'.tr())),
        );
      },
      itemBuilder: (context, index) {
        final apiary = apiaries[index];
        return Dismissible(
          key: Key(apiary.id),
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
              _navigateToEditApiary(context, apiary);
              return false;
            } else {
              return await _confirmDelete(context, apiary);
            }
          },
          onDismissed: (direction) {
            context.read<ApiariesBloc>().add(DeleteApiary(apiary.id));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('apiaries.deleted'.tr(namedArgs: {'name': apiary.name}))),
            );
          },
          child: ApiaryCard(
            key: Key('apiary_${apiary.id}'),
            apiary: apiary,
            onTap: () => _navigateToApiaryDetails(context, apiary),
            onEditTap: () => _navigateToEditApiary(context, apiary),
            onDeleteTap: () => _handleDelete(context, apiary),
          ),
        );
      },
    );
  }

  void _handleDelete(BuildContext context, Apiary apiary) async {
    final delete = await _confirmDelete(context, apiary);
    if (delete && context.mounted) {
      context.read<ApiariesBloc>().add(DeleteApiary(apiary.id));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('apiaries.deleted'.tr(namedArgs: {'name': apiary.name}))),
      );
    }
  }

  Future<bool> _confirmDelete(BuildContext context, Apiary apiary) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('apiaries.delete_title'.tr()),
          content: Text('apiaries.delete_confirm'.tr(namedArgs: {'name': apiary.name})),
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

  void _navigateToEditApiary(BuildContext context, Apiary apiary) async {
    await context.push(
      AppRouter.editApiary,
      extra: apiary.id,
    );
    if (context.mounted) {
      context.read<ApiariesBloc>().add(const LoadApiaries());
    }
  }

  void _navigateToApiaryDetails(BuildContext context, Apiary apiary) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('apiaries.details_coming_soon'.tr(namedArgs: {'name': apiary.name}))),
    );
  }
}
