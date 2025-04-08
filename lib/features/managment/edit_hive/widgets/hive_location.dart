import 'package:apiarium/core/theme/app_theme.dart';
import 'package:apiarium/features/managment/edit_hive/widgets/edit_hive_card.dart';
import 'package:apiarium/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:apiarium/features/managment/edit_hive/bloc/edit_hive_bloc.dart';

class HiveLocation extends StatelessWidget {
  const HiveLocation({super.key});

  @override
  Widget build(BuildContext context) {
    return EditHiveCard(
      title: 'Location',
      icon: Icons.location_on_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Apiary', style: Theme.of(context).textTheme.titleMedium),
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
      itemBuilder: (context, item, isSelected) => item != null 
          ? Center(
              child: Text(
                item.name,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: isSelected ? AppTheme.primaryColor : null,
                ),
              ),
            ) 
          : const Center(child: Text("None")),
      buttonItemBuilder: (context, item) => item != null 
          ? Center(child: Text(item.name)) 
          : const Center(child: Text("None")),
    );
  }
}
