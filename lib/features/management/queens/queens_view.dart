import 'package:apiarium/core/router/app_router.dart';
import 'package:apiarium/shared/domain/models/queen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:apiarium/core/theme/app_theme.dart';
import 'package:apiarium/features/management/queens/bloc/queens_bloc.dart';
import 'package:apiarium/features/management/queens/bloc/queens_event.dart';
import 'package:apiarium/features/management/queens/bloc/queens_state.dart';
import 'package:apiarium/features/management/queens/widgets/queen_card.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';

class QueensView extends StatelessWidget {
  const QueensView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade100,
      child: Column(
        children: [
          const _InfoBanner(),
          Expanded(child: const _QueensList()),
        ],
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QueensBloc, QueensState>(
      builder: (context, state) {
        if (state.filteredQueens.isEmpty || state.status != QueensStatus.loaded) {
          return const SizedBox.shrink();
        }
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          color: Colors.grey.shade100,
          child: Row(
            children: [
              Text(
                'management.queens.count'.tr(namedArgs: {
                  'count': '${state.filteredQueens.length}',
                  'type': state.filteredQueens.length == 1 ? 'management.queens.singular'.tr() : 'management.queens.plural'.tr()
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

  bool _hasActiveFilters(QueensState state) {
    final filter = state.filter;
    return filter.status != null ||
           filter.breedId != null ||
           filter.apiaryId != null ||
           filter.fromDate != null ||
           filter.toDate != null;
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

class _QueensList extends StatelessWidget {
  const _QueensList();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<QueensBloc, QueensState>(
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
        return switch (state.status) {
          QueensStatus.initial => const _LoadingView(),
          QueensStatus.loading => const _LoadingView(),
          QueensStatus.error => _ErrorView(
              message: state.errorMessage ?? 'common.error_occurred'.tr(),
              onRetry: () => context.read<QueensBloc>().add(const LoadQueens()),
            ),
          QueensStatus.loaded => state.filteredQueens.isEmpty
              ? _EmptyView(hasActiveFilters: _hasActiveFilters(state))
              : _QueensListView(queens: state.filteredQueens),
        };
      },
    );
  }

  bool _hasActiveFilters(QueensState state) {
    final filter = state.filter;
    return filter.status != null ||
           filter.breedId != null ||
           filter.apiaryId != null ||
           filter.fromDate != null ||
           filter.toDate != null;
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
          Icon(Icons.pets, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            hasActiveFilters 
              ? 'management.queens.no_matches'.tr() 
              : 'management.queens.empty'.tr(),
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
          if (hasActiveFilters) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.read<QueensBloc>().add(ResetFilters()),
              child: Text('common.clear_filters'.tr()),
            ),
          ],
        ],
      ),
    );
  }
}

class _QueensListView extends StatelessWidget {
  final List<Queen> queens;

  const _QueensListView({required this.queens});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<QueensBloc>().add(const LoadQueens());
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        itemCount: queens.length,
        itemBuilder: (context, index) {
          final queen = queens[index];
          return QueenCard(
            queen: queen,
            onEdit: () => _handleEdit(context, queen.id),
            onDelete: () => _handleDelete(context, queen),
          );
        },
      ),
    );
  }

  Future<void> _handleEdit(BuildContext context, String queenId) async {
    await context.push(
      AppRouter.editQueen,
      extra: {'queenId': queenId},
    );
    if (context.mounted) {
      context.read<QueensBloc>().add(const LoadQueens());
    }
  }

  void _handleDelete(BuildContext context, Queen queen) {
    context.read<QueensBloc>().add(DeleteQueen(queen.id));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('management.queens.deleted'.tr(namedArgs: {'name': queen.name}))),
    );
  }
}
