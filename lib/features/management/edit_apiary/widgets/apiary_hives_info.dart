import 'package:apiarium/features/management/edit_apiary/widgets/apiary_hives_grid.dart';
import 'package:apiarium/features/management/edit_apiary/widgets/edit_apiary_card.dart';
import 'package:apiarium/features/management/edit_apiary/bloc/edit_apiary_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';

class ApiaryHivesInfo extends StatelessWidget {
  const ApiaryHivesInfo({super.key});

  @override
  Widget build(BuildContext context) {
    final hiveCount = context.select(
      (EditApiaryBloc bloc) => bloc.state.apiarySummaryHives.length,
    );
    
    return EditApiaryCard(
      title: 'hives'.tr(),
      icon: Icons.hive,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'edit_apiary.hives_in_this_apiary'.tr(args: [hiveCount.toString()]),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          const ApiaryHivesGrid(),
        ],
      ),
    );
  }
}
