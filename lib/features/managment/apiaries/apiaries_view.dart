import 'package:apiarium/core/router/app_router.dart';
import 'package:apiarium/features/managment/apiaries/bloc/apiaries_bloc.dart';
import 'package:apiarium/features/managment/apiaries/widgets/apiary_card.dart';
import 'package:apiarium/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ApiariesView extends StatefulWidget {
  const ApiariesView({super.key});

  @override
  State<ApiariesView> createState() => _ApiariesViewState();
}

class _ApiariesViewState extends State<ApiariesView> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade100,
      child: Column(
        children: [
          // Apiaries count and swipe hint
          _buildInfoBanner(),
          
          // List of apiaries with reordering capability
          Expanded(
            child: _buildApiariesList(),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBanner() {
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
              // Apiaries count
              Text(
                '${state.filteredApiaries.length} ${state.filteredApiaries.length == 1 ? 'apiary' : 'apiaries'} found',
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
  
  Widget _buildApiariesList() {
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
        if (state.status == ApiariesStatus.initial) {
          // Load apiaries when the view is first shown
          context.read<ApiariesBloc>().add(const LoadApiaries());
          return const Center(child: CircularProgressIndicator());
        }
        
        if (state.status == ApiariesStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (state.status == ApiariesStatus.error) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(state.errorMessage ?? 'An error occurred'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.read<ApiariesBloc>().add(const LoadApiaries()),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        
        if (state.filteredApiaries.isEmpty) {
          return const Center(
            child: Text('No apiaries found matching your filters.'),
          );
        }
        
        return ReorderableListView.builder(
          padding: const EdgeInsets.only(bottom: 80), // Space for FAB
          itemCount: state.filteredApiaries.length,
          onReorder: (oldIndex, newIndex) {
            context.read<ApiariesBloc>().add(
              ReorderApiaries(oldIndex: oldIndex, newIndex: newIndex),
            );
            
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Apiary order updated')),
            );
          },
          itemBuilder: (context, index) {
            final apiary = state.filteredApiaries[index];
            
            return Dismissible(
              key: Key(apiary.id),
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
                  return await _showDeleteConfirmationDialog(context, apiary.name);
                } else {
                  // Edit operation
                  _navigateToEditApiary(context, apiary);
                  return false;
                }
              },
              onDismissed: (direction) {
                context.read<ApiariesBloc>().add(DeleteApiary(apiary.id));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${apiary.name} removed')),
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
      },
    );
  }
  
  // New method to handle delete button press
  void _handleDelete(BuildContext context, Apiary apiary) async {
    final delete = await _showDeleteConfirmationDialog(context, apiary.name);
    if (delete && context.mounted) {
      context.read<ApiariesBloc>().add(DeleteApiary(apiary.id));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${apiary.name} removed')),
      );
    }
  }
  
  Future<bool> _showDeleteConfirmationDialog(BuildContext context, String apiaryName) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete $apiaryName?'),
        content: const Text('This will permanently delete the apiary and all its data. This action cannot be undone.'),
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
  
  void _navigateToApiaryDetails(BuildContext context, Apiary apiary) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Viewing details of ${apiary.name}')),
    );
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
}
