import 'package:apiarium/core/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:apiarium/features/managment/hives/bloc/hives_bloc.dart';
import 'package:apiarium/features/managment/hives/widgets/hive_card.dart';
import 'package:apiarium/shared/shared.dart';
import 'package:go_router/go_router.dart';

class HivesView extends StatefulWidget {
  const HivesView({super.key});

  @override
  State<HivesView> createState() => _HivesViewState();
}

class _HivesViewState extends State<HivesView> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade100,
      child: Column(
        children: [
          // Hives count and swipe hint
          _buildInfoBanner(),
          
          // List of hives with reordering capability
          Expanded(
            child: _buildHivesList(),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBanner() {
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
              // Hives count
              Text(
                '${state.filteredHives.length} ${state.filteredHives.length == 1 ? 'hive' : 'hives'} found',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              // Reordering hint
              Row(
                children: [
                  Icon(
                    Icons.swap_vert,
                    color: Colors.amber.shade800,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Drag to reorder',
                    style: TextStyle(
                      color: Colors.amber.shade800,
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

  Widget _buildHivesList() {
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
        if (state.status == HivesStatus.initial) {
          // Load hives when the view is first shown
          context.read<HivesBloc>().add(const LoadHives());
          return const Center(child: CircularProgressIndicator());
        }
        
        if (state.status == HivesStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (state.status == HivesStatus.error) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(state.errorMessage ?? 'An error occurred'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.read<HivesBloc>().add(const LoadHives()),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        
        if (state.filteredHives.isEmpty) {
          return const Center(
            child: Text('No hives found matching your filters.'),
          );
        }
        
        return ReorderableListView.builder(
          padding: const EdgeInsets.only(bottom: 80), // Space for FAB
          itemCount: state.filteredHives.length,
          onReorder: (oldIndex, newIndex) {
            context.read<HivesBloc>().add(
              ReorderHives(oldIndex: oldIndex, newIndex: newIndex),
            );
            
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Hive order updated')),
            );
          },
          itemBuilder: (context, index) {
            final hive = state.filteredHives[index];
            
            return Dismissible(
              key: Key(hive.id),
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              secondaryBackground: Container(
                color: Colors.blue,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const Icon(Icons.edit, color: Colors.white),
              ),
              confirmDismiss: (direction) async {
                if (direction == DismissDirection.startToEnd) {
                  // Delete operation
                  return await _showDeleteConfirmationDialog(context, hive.name);
                } else {
                  // Edit operation
                  _navigateToEditHive(context, hive);
                  return false;
                }
              },
              onDismissed: (direction) {
                context.read<HivesBloc>().add(DeleteHive(hive.id));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${hive.name} removed')),
                );
              },
              child: HiveCard(
                key: Key('hive_${hive.id}'),
                hive: hive,
                onTap: () => _navigateToHiveDetails(context, hive),
                onEditTap: () => _navigateToEditHive(context, hive),
                onDeleteTap: () => _handleDelete(context, hive), // Changed from onInspectTap to onDeleteTap
              ),
            );
          },
        );
      },
    );
  }
  
  // New method to handle delete button press
  void _handleDelete(BuildContext context, Hive hive) async {
    final delete = await _showDeleteConfirmationDialog(context, hive.name);
    if (delete && context.mounted) {
      context.read<HivesBloc>().add(DeleteHive(hive.id));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${hive.name} removed')),
      );
    }
  }
  
  Future<bool> _showDeleteConfirmationDialog(BuildContext context, String hiveName) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete $hiveName?'),
        content: const Text('This will permanently delete the hive and all its data. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('DELETE'),
          ),
        ],
      ),
    ) ?? false;
  }
  
  void _navigateToHiveDetails(BuildContext context, Hive hive) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Viewing details of ${hive.name}')),
    );
  }
  
  void _navigateToEditHive(BuildContext context, Hive hive) async {
    final result = await context.push(
      AppRouter.editHive,
      extra: hive.id,
    );
    
    if (context.mounted) {
      // If we got back a Hive object, we can use it directly
      // Otherwise reload all hives
      if (result is Hive) {
        context.read<HivesBloc>().add(const LoadHives());
      } else {
        context.read<HivesBloc>().add(const LoadHives());
      }
    }
  }

}
