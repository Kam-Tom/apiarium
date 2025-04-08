import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:apiarium/features/managment/hives/bloc/hives_bloc.dart';
import 'package:apiarium/shared/shared.dart';

class HiveFilterModal extends StatelessWidget {
  const HiveFilterModal({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hivesBloc = context.read<HivesBloc>();
    final state = hivesBloc.state;
    
    // Get list of available apiaries from the state
    final apiaries = state.availableApiaries;
    
    return AlertDialog(
      title: const Text('Filter Hives'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Apiary filter
            DropdownButtonFormField<String?>(
              decoration: const InputDecoration(
                labelText: 'Apiary',
                isDense: true,
              ),
              value: state.filter.apiaryId,
              items: [
                const DropdownMenuItem(value: null, child: Text('All Apiaries')),
                ...apiaries.map((apiary) {
                  return DropdownMenuItem(
                    value: apiary.id,
                    child: Text(apiary.name),
                  );
                }),
              ],
              onChanged: (value) {
                hivesBloc.add(FilterByApiaryId(value));
              },
            ),
            const SizedBox(height: 16),
            
            // Hive Type filter
            DropdownButtonFormField<String?>(
              decoration: const InputDecoration(
                labelText: 'Hive Type',
                isDense: true,
              ),
              value: state.filter.hiveTypeId,
              items: [
                const DropdownMenuItem(value: null, child: Text('All Types')),
                // This would be populated from a repository of hive types
                // For now, we'll use static items
                const DropdownMenuItem(value: 'langstroth', child: Text('Langstroth')),
                const DropdownMenuItem(value: 'dadant', child: Text('Dadant')),
                const DropdownMenuItem(value: 'warre', child: Text('Warré')),
                const DropdownMenuItem(value: 'topbar', child: Text('Top Bar')),
              ],
              onChanged: (value) {
                hivesBloc.add(FilterByHiveTypeId(value));
              },
            ),
            const SizedBox(height: 16),
            
            // Queen Status filter
            DropdownButtonFormField<String?>(
              decoration: const InputDecoration(
                labelText: 'Queen Status',
                isDense: true,
              ),
              value: state.filter.queenStatus,
              items: const [
                DropdownMenuItem(value: null, child: Text('All Queen Statuses')),
                DropdownMenuItem(value: 'withQueen', child: Text('With Queen')),
                DropdownMenuItem(value: 'noQueen', child: Text('No Queen')),
                DropdownMenuItem(value: 'mated', child: Text('Mated Queen')),
                DropdownMenuItem(value: 'unmated', child: Text('Unmated Queen')),
                DropdownMenuItem(value: 'marked', child: Text('Marked Queen')),
              ],
              onChanged: (value) {
                hivesBloc.add(FilterByQueenStatus(value));
              },
            ),
            const SizedBox(height: 16),
            
            // Hive Status filter
            DropdownButtonFormField<HiveStatus?>(
              decoration: const InputDecoration(
                labelText: 'Hive Status',
                isDense: true,
              ),
              value: state.filter.hiveStatus,
              items: [
                const DropdownMenuItem(value: null, child: Text('All Statuses')),
                ...HiveStatus.values.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(status.name),
                  );
                }),
              ],
              onChanged: (value) {
                hivesBloc.add(FilterByHiveStatus(value));
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            hivesBloc.add(const ResetFilters());
            Navigator.pop(context);
          },
          child: const Text('RESET FILTERS'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber,
          ),
          child: const Text('APPLY'),
        ),
      ],
    );
  }
}
