import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:apiarium/features/management/hives/bloc/hives_bloc.dart';
import 'package:easy_localization/easy_localization.dart';

class HiveSortModal extends StatelessWidget {
  const HiveSortModal({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.read<HivesBloc>().state;

    return AlertDialog(
      title: Text('hives.sort_title'.tr()),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSortOption(
            context,
            title: 'hives.sort_name'.tr(),
            sortOption: HiveSortOption.name,
            currentOption: state.sortOption,
            ascending: state.ascending,
          ),
          _buildSortOption(
            context,
            title: 'hives.sort_apiary'.tr(),
            sortOption: HiveSortOption.apiary,
            currentOption: state.sortOption,
            ascending: state.ascending,
          ),
          _buildSortOption(
            context,
            title: 'hives.sort_type'.tr(),
            sortOption: HiveSortOption.type,
            currentOption: state.sortOption,
            ascending: state.ascending,
          ),
          _buildSortOption(
            context,
            title: 'hives.sort_queen_status'.tr(),
            sortOption: HiveSortOption.queenStatus,
            currentOption: state.sortOption,
            ascending: state.ascending,
          ),
          _buildSortOption(
            context,
            title: 'hives.sort_hive_status'.tr(),
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
      secondary: isSelected
          ? Icon(ascending ? Icons.arrow_upward : Icons.arrow_downward)
          : null,
      selected: isSelected,
      activeColor: Theme.of(context).colorScheme.primary,
    );
  }
}
