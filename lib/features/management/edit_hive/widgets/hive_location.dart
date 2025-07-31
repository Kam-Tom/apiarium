import 'package:apiarium/features/management/edit_hive/widgets/edit_hive_card.dart';
import 'package:apiarium/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:apiarium/features/management/edit_hive/bloc/edit_hive_bloc.dart';
import 'package:easy_localization/easy_localization.dart';

class HiveLocation extends StatelessWidget {
  const HiveLocation({super.key});

  @override
  Widget build(BuildContext context) {
    return EditHiveCard(
      title: 'edit_hive.location'.tr(),
      icon: Icons.location_on_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'edit_hive.apiary'.tr(),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          _buildApiary(context),
        ],
      ),
    );
  }

  Widget _buildApiary(BuildContext context) {
    final apiary = context.select((EditHiveBloc bloc) => bloc.state.selectedApiary);
    final apiaries = [
      null,
      ...context.select((EditHiveBloc bloc) => bloc.state.availableApiaries)
    ];

    return RoundedDropdown<Apiary?>(
      value: apiary,
      items: apiaries,
      onChanged: (value) {
        context.read<EditHiveBloc>().add(EditHiveApiaryChanged(value));
      },
      hintText: 'common.none'.tr()
    );
  }
}
