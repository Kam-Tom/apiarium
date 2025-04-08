import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:apiarium/features/managment/hives/bloc/hives_bloc.dart';

class HiveSortModal extends StatelessWidget {
  const HiveSortModal({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = context.read<HivesBloc>().state;
    
    return AlertDialog(
      title: const Text('Sort Hives'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSortOption(
            context,
            title: 'Name',
            sortOption: HiveSortOption.name,
            currentOption: state.sortOption,
            ascending: state.ascending,
          ),
          _buildSortOption(
            context,
            title: 'Apiary',
            sortOption: HiveSortOption.apiary,
            currentOption: state.sortOption,
            ascending: state.ascending,
          ),
          _buildSortOption(
            context,
            title: 'Hive Type',
            sortOption: HiveSortOption.type,
            currentOption: state.sortOption,
            ascending: state.ascending,
          ),
          _buildSortOption(
            context,
            title: 'Queen Status',
            sortOption: HiveSortOption.queenStatus,
            currentOption: state.sortOption,
            ascending: state.ascending,
          ),
          _buildSortOption(
            context,
            title: 'Hive Status',
            sortOption: HiveSortOption.hiveStatus,
            currentOption: state.sortOption,
            ascending: state.ascending,
          ),
        ],
      ),
    );
  }

  Widget _buildSortOption(
    BuildContext context, {
    required String title,
    required HiveSortOption sortOption,
    required HiveSortOption currentOption,
    required bool ascending,
  }) {
    final isSelected = sortOption == currentOption;
    
    return RadioListTile<HiveSortOption>(
      title: Text(title),
      value: sortOption,
      groupValue: currentOption,
      onChanged: (value) {
        context.read<HivesBloc>().add(SortHives(
          sortOption: value!,
          ascending: isSelected ? !ascending : true,
        ));
        Navigator.pop(context);
      },
      secondary: Icon(
        isSelected
            ? (ascending ? Icons.arrow_upward : Icons.arrow_downward)
            : null,
      ),
      selected: isSelected,
      activeColor: Theme.of(context).colorScheme.primary,
    );
  }
}
