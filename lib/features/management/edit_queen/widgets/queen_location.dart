import 'package:apiarium/features/management/edit_queen/widgets/edit_queen_card.dart';
import 'package:apiarium/shared/shared.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:apiarium/features/management/edit_queen/bloc/edit_queen_bloc.dart';

class QueenLocation extends StatelessWidget {
  const QueenLocation({super.key});

  @override
  Widget build(BuildContext context) {
    return EditQueenCard(
      title: 'edit_queen.location'.tr(),
      icon: Icons.location_on_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('apiary.apiary'.tr(), style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          _buildApiary(context),
          const SizedBox(height: 16),
          Text('management.queens.hive'.tr(), style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          _buildHive(context),
        ],
      ),
    );
  }

  Widget _buildApiary(BuildContext context) {
    final selectedApiary = context.select((EditQueenBloc bloc) => bloc.state.selectedApiary);
    final apiaries = [
      null,
      ...context.select((EditQueenBloc bloc) => bloc.state.availableApiaries)
    ];
    return RoundedDropdown<Apiary?>(
      value: selectedApiary,
      items: apiaries,
      onChanged: (value) => context.read<EditQueenBloc>().add(EditQueenApiaryChanged(value)),
      hintText: 'common.none'.tr(),
    );
  }

  Widget _buildHive(BuildContext context) {
    final selectedApiary = context.select((EditQueenBloc bloc) => bloc.state.selectedApiary);
    final selectedHive = context.select((EditQueenBloc bloc) => bloc.state.selectedHive);
    final allHives = context.select((EditQueenBloc bloc) => bloc.state.availableHives);

    final filteredHives = [
      ...allHives.where((hive) =>
        selectedApiary == null
          ? hive.apiaryId == null
          : hive.apiaryId == selectedApiary.id
      )
    ];

    return RoundedDropdown<Hive?>(
      value: selectedHive,
      items: filteredHives,
      onChanged: (value) => context.read<EditQueenBloc>().add(EditQueenHiveChanged(value)),
      hintText: 'common.none'.tr(),
    );
  }
}

