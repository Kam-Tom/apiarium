import 'package:apiarium/features/managment/edit_apiary/bloc/edit_apiary_bloc.dart';
import 'package:apiarium/features/managment/edit_apiary/widgets/edit_apiary_card.dart';
import 'package:apiarium/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';

class ApiaryStatusInfo extends StatelessWidget {
  const ApiaryStatusInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return EditApiaryCard(
      title: 'Status'.tr(),
      icon: Icons.assignment_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Apiary Status'.tr(), style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          _buildStatus(context),
          const SizedBox(height: 16),
          _buildHiveSummary(context),
        ],
      ),
    );
  }

  Widget _buildStatus(BuildContext context) {
    final status = context.select((EditApiaryBloc bloc) => bloc.state.status);

    return RoundedDropdown<ApiaryStatus>(
      value: status,
      items: ApiaryStatus.values,
      onChanged: (value) {
        if (value != null) {
          context.read<EditApiaryBloc>().add(EditApiaryStatusChanged(value));
        }
      },
    );
  }

  Widget _buildHiveSummary(BuildContext context) {
    final hives = context.select((EditApiaryBloc bloc) => bloc.state.apiarySummaryHives);
    
    if (hives.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          'No hives in this apiary yet'.tr(),
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      );
    }
    
    // Group hives by type
    final hivesByType = <HiveType, List<Hive>>{};
    for (final hive in hives) {
      if (!hivesByType.containsKey(hive.hiveType)) {
        hivesByType[hive.hiveType] = [];
      }
      hivesByType[hive.hiveType]!.add(hive);
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Summary of Hives'.tr(),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        ...hivesByType.entries.map((entry) {
          final hiveType = entry.key;
          final typeHives = entry.value;
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    '${hiveType.name}:',
                    style: Theme.of(context).textTheme.bodyLarge,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${typeHives.length} ${typeHives.length == 1 ? "hive" : "hives"}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          );
        }),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  'Total:',
                  style: Theme.of(context).textTheme.titleMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${hives.length} ${hives.length == 1 ? "hive" : "hives"}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
