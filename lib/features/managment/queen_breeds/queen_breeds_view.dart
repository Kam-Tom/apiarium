import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:apiarium/core/theme/app_theme.dart';
import 'package:apiarium/core/router/app_router.dart';
import 'package:apiarium/features/managment/queen_breeds/bloc/queen_breeds_bloc.dart';
import 'package:apiarium/features/managment/queen_breeds/bloc/queen_breeds_event.dart';
import 'package:apiarium/features/managment/queen_breeds/bloc/queen_breeds_state.dart';
import 'package:apiarium/features/managment/queen_breeds/widgets/improved_queen_breed_card.dart';
import 'package:go_router/go_router.dart';

class QueenBreedsView extends StatelessWidget {
  const QueenBreedsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade100,
      child: Column(
        children: [
          // Breed count and filter info
          _buildInfoBanner(context),
          // Breeds list
          Expanded(
            child: _buildBreedsList(context),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBanner(BuildContext context) {
    return BlocBuilder<QueenBreedsBloc, QueenBreedsState>(
      builder: (context, state) {
        if (state.filteredBreeds.isEmpty || state.status != QueenBreedsStatus.loaded) {
          return const SizedBox.shrink();
        }
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          color: Colors.grey.shade100,
          child: Row(
            children: [
              Text(
                '${state.filteredBreeds.length} ${state.filteredBreeds.length == 1 ? 'breed' : 'breeds'} found',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (_hasActiveFilters(state))
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.filter_list,
                        color: AppTheme.primaryColor,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Filtered',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  bool _hasActiveFilters(QueenBreedsState state) {
    final filter = state.filter;
    return filter.starredOnly == true || filter.localOnly == true;
  }

  Widget _buildBreedsList(BuildContext context) {
    return BlocConsumer<QueenBreedsBloc, QueenBreedsState>(
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
        if (state.status == QueenBreedsStatus.initial) {
          context.read<QueenBreedsBloc>().add(const LoadQueenBreeds());
          return const Center(child: CircularProgressIndicator());
        }
        
        if (state.status == QueenBreedsStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (state.status == QueenBreedsStatus.error) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(state.errorMessage ?? 'An error occurred'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.read<QueenBreedsBloc>().add(const LoadQueenBreeds()),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        
        if (state.filteredBreeds.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.pets,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  _hasActiveFilters(state) 
                    ? 'No breeds found matching your filters.' 
                    : 'No queen breeds yet. Add your first breed!',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
                if (_hasActiveFilters(state)) ...[
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<QueenBreedsBloc>().add(const FilterByStarred(null));
                      context.read<QueenBreedsBloc>().add(const FilterByLocal(null));
                    },
                    child: const Text('Clear Filters'),
                  ),
                ],
              ],
            ),
          );
        }
          return RefreshIndicator(
          onRefresh: () async {
            context.read<QueenBreedsBloc>().add(const LoadQueenBreeds());
          },
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            itemCount: state.filteredBreeds.length,
            itemBuilder: (context, index) {
              final breed = state.filteredBreeds[index];
              return ImprovedQueenBreedCard(
                breed: breed,
                onDelete: () {
                  context.read<QueenBreedsBloc>().add(DeleteQueenBreed(breed.id));
                },
              );
            },
          ),
        );      },
    );
  }
}