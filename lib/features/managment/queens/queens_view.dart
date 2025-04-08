import 'package:apiarium/core/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:apiarium/core/theme/app_theme.dart';
import 'package:apiarium/shared/shared.dart';
import 'package:apiarium/features/managment/queens/bloc/queens_bloc.dart';
import 'package:apiarium/features/managment/queens/bloc/queens_event.dart';
import 'package:apiarium/features/managment/queens/bloc/queens_state.dart';
import 'package:apiarium/features/managment/queens/widgets/queen_card.dart';
import 'package:go_router/go_router.dart';

class QueensView extends StatelessWidget {
  const QueensView({super.key});

  @override
  Widget build(BuildContext context) {
    // Removed the search bar, now the Column starts directly with the queens list
    return Container(
      color:Colors.grey.shade100,
      child: Column(
        children: [
          // Queen count and swipe hint
          _buildInfoBanner(context),
          // Queens list
          Expanded(
            child: _buildQueensList(context),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBanner(BuildContext context) {
    return BlocBuilder<QueensBloc, QueensState>(
      builder: (context, state) {
        if (state.filteredQueens.isEmpty || state.status != QueensStatus.loaded) {
          return const SizedBox.shrink();
        }
        
        // Show count and swipe instruction
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          color: Colors.grey.shade100,
          child: Row(
            children: [
              // Queens count
              Text(
                '${state.filteredQueens.length} ${state.filteredQueens.length == 1 ? 'queen' : 'queens'} found',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              // Swipe instructions
              Row(
                children: [
                  Icon(
                    Icons.swipe,
                    color: AppTheme.primaryColor,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Swipe to edit or delete',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQueensList(BuildContext context) {
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
        if (state.status == QueensStatus.initial) {
          // Load queens when the view is first shown
          context.read<QueensBloc>().add(const LoadQueens());
          return const Center(child: CircularProgressIndicator());
        }
        
        if (state.status == QueensStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (state.status == QueensStatus.error) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(state.errorMessage ?? 'An error occurred'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.read<QueensBloc>().add(const LoadQueens()),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        
        if (state.filteredQueens.isEmpty) {
          return const Center(
            child: Text('No queens found matching your filters.'),
          );
        }
        
        return RefreshIndicator(
          onRefresh: () async {
            context.read<QueensBloc>().add(const LoadQueens());
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: state.filteredQueens.length,
            itemBuilder: (context, index) {
              final queen = state.filteredQueens[index];
              return Dismissible(
                key: Key(queen.id),
                background: Container(
                  color: Colors.blue,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 16),
                  child: const Icon(
                    Icons.edit,
                    color: Colors.white,
                  ),
                ),
                secondaryBackground: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 16),
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),
                confirmDismiss: (direction) async {
                  if (direction == DismissDirection.startToEnd) {
                    // Edit operation
                    _navigateToEditQueen(context, queen);
                    return false;
                  } else {
                    // Delete operation
                    return await _confirmDelete(context, queen);
                  }
                },
                onDismissed: (direction) {
                  context.read<QueensBloc>().add(DeleteQueen(queen.id));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${queen.name} deleted')),
                  );
                },
                child: QueenCard(
                  queen: queen,
                  onTap: () => _navigateToQueenDetails(context, queen),
                  onEditTap: () => _navigateToEditQueen(context, queen),
                  onDeleteTap: () => _handleDelete(context, queen),
                ),
              );
            },
          ),
        );
      },
    );
  }
  
  // Add a method to handle delete button press
  void _handleDelete(BuildContext context, Queen queen) async {
    final delete = await _confirmDelete(context, queen);
    if (delete && context.mounted) {
      context.read<QueensBloc>().add(DeleteQueen(queen.id));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${queen.name} deleted')),
      );
    }
  }

  Future<bool> _confirmDelete(BuildContext context, Queen queen) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Queen'),
          content: Text('Are you sure you want to delete ${queen.name}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'DELETE',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _navigateToEditQueen(BuildContext context, Queen queen) async {
    await context.push(
      AppRouter.editQueen,
      extra: queen.id,
    );
    if (context.mounted) {
      context.read<QueensBloc>().add(const LoadQueens());
    }
  }

  void _navigateToQueenDetails(BuildContext context, Queen queen) {
    // Navigate to queen details screen
    // Navigator.of(context).push(MaterialPageRoute(builder: (_) => QueenDetailsView(queen: queen)));
    // For now, just show a placeholder
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Details for ${queen.name} coming soon')),
    );
  }

  void _showQueenHistory(BuildContext context, Queen queen) {
    // Show queen history - could be a bottom sheet or new screen
    // For now, just show a placeholder
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('History for ${queen.name} coming soon')),
    );
  }
}
