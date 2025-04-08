import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:apiarium/core/theme/app_theme.dart';
import 'package:apiarium/features/managment/queens/bloc/queens_bloc.dart';
import 'package:apiarium/features/managment/queens/bloc/queens_event.dart';
import 'package:apiarium/features/managment/queens/bloc/queens_state.dart';
import 'package:apiarium/shared/shared.dart';
import 'package:apiarium/shared/widgets/dropdown/searchable_rounded_dropdown.dart';
import 'package:apiarium/features/managment/queens/widgets/filter_widgets/filter_container.dart';
import 'package:apiarium/features/managment/queens/widgets/filter_widgets/filter_section_title.dart';
import 'package:apiarium/features/managment/queens/widgets/filter_widgets/date_range_filter.dart';
import 'package:apiarium/features/managment/edit_queen/widgets/queen_breed_input_item.dart';

class QueenFilterModal extends StatelessWidget {
  const QueenFilterModal({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<QueensBloc>().state;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: FilterContainer(
        title: 'Filter Queens',
        icon: Icons.filter_list,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status filter
            const FilterSectionTitle(title: 'Status'),
            const SizedBox(height: 8),
            _buildStatusFilter(context, state),
            const SizedBox(height: 24),
            
            // Breed filter
            const FilterSectionTitle(title: 'Breed'),
            const SizedBox(height: 8),
            _buildBreedFilter(context, state),
            const SizedBox(height: 24),
            
            // Apiary filter
            const FilterSectionTitle(title: 'Apiary'),
            const SizedBox(height: 8),
            _buildApiaryFilter(context, state),
            const SizedBox(height: 24),
            
            // Date range filter
            const FilterSectionTitle(title: 'Birth Date Range'),
            const SizedBox(height: 8),
            DateRangeFilter(
              fromDate: state.filter.fromDate,
              toDate: state.filter.toDate,
              onDateRangeChanged: (fromDate, toDate) {
                context.read<QueensBloc>().add(
                  FilterByDateRange(
                    fromDate: fromDate,
                    toDate: toDate,
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.read<QueensBloc>().add(ResetFilters());
            },
            child: const Text('RESET FILTERS'),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('CLOSE'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFilter(BuildContext context, QueensState state) {
    // Using the enums directly
    final items = [null, ...QueenStatus.values];
    
    return RoundedDropdown<QueenStatus?>(
      value: state.filter.status,
      items: items,
      minHeight: 48,
      itemBuilder: (context, status, isSelected) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Row(
            children: [
              if (status != null)
                _buildStatusIcon(status)
              else
                const Icon(Icons.filter_alt_outlined, color: Colors.grey),
              const SizedBox(width: 12),
              Text(
                status != null ? _formatEnumName(status.name) : 'Any Status',
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? AppTheme.primaryColor : null,
                ),
              ),
            ],
          ),
        );
      },
      buttonItemBuilder: (context, status) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (status != null)
                  _buildStatusIcon(status)
                else
                  const Icon(Icons.filter_alt_outlined, color: Colors.grey),
                const SizedBox(width: 12),
                Text(
                  status != null ? _formatEnumName(status.name) : 'Any Status',
                ),
              ],
            ),
          ),
        );
      },
      onChanged: (status) {
        context.read<QueensBloc>().add(FilterByStatus(status));
      },
    );
  }

  Widget _buildBreedFilter(BuildContext context, QueensState state) {
    // Adding a "null" breed to represent "Any Breed"
    final breeds = [null, ...state.availableBreeds];
    
    return SearchableRoundedDropdown<QueenBreed?>(
      value: state.filter.breedId != null 
          ? state.availableBreeds.firstWhere(
              (b) => b.id == state.filter.breedId
            ) 
          : null,
      items: breeds,
      searchHintText: 'Search breeds...',
      maxHeight: 300,
      minHeight: 48,
      itemBuilder: (context, item, isSelected) {
        if (item == null) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Text('Any Breed'),
          );
        }
        
        if (item.scientificName == null || item.scientificName!.isEmpty) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.star, 
                color: item.isStarred ? AppTheme.primaryColor : Colors.grey
              ),
              const SizedBox(width: 8),
              Text(
                item.name,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: isSelected ? AppTheme.primaryColor : null,
                ),
              ),
            ],
          );
        }
        
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.star, 
              color: item.isStarred ? AppTheme.primaryColor : Colors.grey
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: isSelected ? AppTheme.primaryColor : null,
                  ),
                ),
                Text(
                  item.scientificName ?? '',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isSelected 
                      ? AppTheme.primaryColor.withOpacity(0.5) 
                      : Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        );
      },
      buttonItemBuilder: (context, breed) {
        if (breed == null) {
          return const Center(
            child: Text('Any Breed'),
          );
        }
        
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: QueenBreedInputItem(breed: breed),
          ),
        );
      },
      searchMatchFn: (item, searchValue) {
        QueenBreed? breed = item.value;
        if (breed == null) return searchValue.isEmpty;
        
        final searchLower = searchValue.toLowerCase();
        return breed.name.toLowerCase().contains(searchLower) ||
               (breed.scientificName?.toLowerCase().contains(searchLower) ?? false);
      },
      onChanged: (breed) {
        context.read<QueensBloc>().add(FilterByBreed(breed?.id));
      },
    );
  }

  Widget _buildApiaryFilter(BuildContext context, QueensState state) {
    // Adding a "null" apiary to represent "Any Apiary"
    final apiaries = [null, ...state.availableApiaries];
    
    return RoundedDropdown<Apiary?>(
      value: state.filter.apiaryId != null 
          ? state.availableApiaries.firstWhere(
              (a) => a.id == state.filter.apiaryId
            ) 
          : null,
      items: apiaries,
      minHeight: 48,
      itemBuilder: (context, apiary, isSelected) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Text(
            apiary?.name ?? 'Any Apiary',
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? AppTheme.primaryColor : null,
            ),
          ),
        );
      },
      buttonItemBuilder: (context, apiary) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Text(
              apiary?.name ?? 'Any Apiary',
            ),
          ),
        );
      },
      onChanged: (apiary) {
        context.read<QueensBloc>().add(FilterByApiary(apiary?.id));
      },
    );
  }

  Widget _buildStatusIcon(QueenStatus status) {
    IconData iconData;
    Color iconColor;
    
    switch (status) {
      case QueenStatus.active:
        iconData = Icons.check_circle;
        iconColor = Colors.green;
        break;
      case QueenStatus.dead:
        iconData = Icons.cancel;
        iconColor = Colors.red;
        break;
      case QueenStatus.replaced:
        iconData = Icons.swap_horiz;
        iconColor = Colors.orange;
        break;
      case QueenStatus.lost:
        iconData = Icons.help;
        iconColor = Colors.grey;
        break;
      default:
        iconData = Icons.circle;
        iconColor = Colors.blue;
    }
    
    return Icon(iconData, color: iconColor);
  }

  String _formatEnumName(String name) {
    return name[0].toUpperCase() + name.substring(1);
  }
}
