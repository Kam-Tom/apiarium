import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:apiarium/features/management/queens/bloc/queens_bloc.dart';
import 'package:apiarium/features/management/queens/bloc/queens_event.dart';
import 'package:apiarium/features/management/queens/bloc/queens_state.dart';

class QueenSortModal extends StatelessWidget {
  const QueenSortModal({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.read<QueensBloc>().state;
    
    return AlertDialog(
      title: const Text('Sort Queens'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSortOption(
            context,
            title: 'Name',
            sortOption: QueenSortOption.name,
            currentOption: state.sortOption,
            ascending: state.ascending,
          ),
          _buildSortOption(
            context,
            title: 'Birth Date',
            sortOption: QueenSortOption.birthDate,
            currentOption: state.sortOption,
            ascending: state.ascending,
          ),
          _buildSortOption(
            context,
            title: 'Breed',
            sortOption: QueenSortOption.breedName,
            currentOption: state.sortOption,
            ascending: state.ascending,
          ),
          _buildSortOption(
            context,
            title: 'Status',
            sortOption: QueenSortOption.status,
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
    required QueenSortOption sortOption,
    required QueenSortOption currentOption,
    required bool ascending,
  }) {
    final isSelected = sortOption == currentOption;
    
    return RadioListTile<QueenSortOption>(
      title: Text(title),
      value: sortOption,
      groupValue: currentOption,
      onChanged: (value) {
        context.read<QueensBloc>().add(SortQueens(
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
