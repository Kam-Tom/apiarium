import 'package:apiarium/core/theme/app_theme.dart';
import 'package:apiarium/features/managment/edit_queen/widgets/edit_queen_card.dart';
import 'package:apiarium/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:apiarium/features/managment/edit_queen/bloc/edit_queen_bloc.dart';

class QueenLocation extends StatelessWidget {
  const QueenLocation({super.key});

  @override
  Widget build(BuildContext context) {
    return EditQueenCard(
      title: 'Location',
      icon: Icons.location_on_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Apiary', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          _buildApiary(context),
          const SizedBox(height: 16),
          Text('Hive', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          _buildHive(context),
        ],
      ),
    );
  }

  Widget _buildApiary(BuildContext context) {
    final apiary = context.select((EditQueenBloc bloc) => bloc.state.selectedApiary);
    final apiaries = [
      null,
      ...context.select((EditQueenBloc bloc) => bloc.state.availableApiaries)
    ];

    return RoundedDropdown<Apiary?>(
      value: apiary,
      items: apiaries,
      onChanged: (value) {
        context.read<EditQueenBloc>().add(EditQueenApiaryChanged(apiary: value));
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
  
  Widget _buildHive(BuildContext context) {
    final hive = context.select((EditQueenBloc bloc) => bloc.state.selectedHive);
    final hives = [
      null,
      ...context.select((EditQueenBloc bloc) => bloc.state.availableHives)
    ];
    
    return RoundedDropdown<Hive?>(
      value: hive,
      items: hives,
      onChanged: (value) {
        context.read<EditQueenBloc>().add(EditQueenHiveChanged(hive: value));
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
