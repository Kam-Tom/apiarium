import 'package:apiarium/features/raport/inspection/bloc/inspection_bloc.dart';
import 'package:apiarium/features/raport/widgets/apiary_selector.dart';
import 'package:apiarium/features/raport/widgets/hive_selector.dart';
import 'package:apiarium/shared/domain/models/apiary.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ApiarySelectorBar extends StatelessWidget {
  const ApiarySelectorBar({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedApiary = context.select<InspectionBloc, Apiary?>(
      (bloc) => bloc.state.selectedApiary,
    );
    final selectedHiveId = context.select<InspectionBloc, String?>(
      (bloc) => bloc.state.selectedHiveId,
    );

    return SizedBox(
      height: 64,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          if (selectedApiary != null)
            ApiarySelector(
              apiary: selectedApiary,
              onTap: () => _showApiaryPicker(context),
            ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 20,
                  width: 1,
                  color: Colors.grey.shade300,
                ),
              ],
            ),
          ),
          
          if (selectedApiary != null)
            _HiveSelectorList(
              selectedApiary: selectedApiary,
              selectedHiveId: selectedHiveId,
            )
        ],
      ),
    );
  }

  void _showApiaryPicker(BuildContext context) {
    final inspectionBloc = context.read<InspectionBloc>();
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => BlocProvider.value(
        value: inspectionBloc,
        child: const _ApiaryPickerSheet(),
      ),
    );
  }
}

class _HiveSelectorList extends StatelessWidget {
  final Apiary selectedApiary;
  final String? selectedHiveId;

  const _HiveSelectorList({
    super.key,
    required this.selectedApiary,
    required this.selectedHiveId,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedApiary.hives?.isNotEmpty ?? false) {
      return Row(
        children: selectedApiary.hives!.map((hive) => HiveSelector(
          hive: hive,
          isSelected: selectedHiveId == hive.id,
          onTap: () => context.read<InspectionBloc>().add(SelectHiveEvent(hive.id)),
        )).toList(),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        alignment: Alignment.center,
        child: Text(
          'No hives in this apiary',
          style: TextStyle(color: Colors.grey.shade600),
        ),
      );
    }
  }
}

/// Bottom sheet for selecting an apiary
class _ApiaryPickerSheet extends StatelessWidget {
  const _ApiaryPickerSheet();

  @override
  Widget build(BuildContext context) {
    final apiaries = context.select<InspectionBloc, List<Apiary>>(
      (bloc) => bloc.state.apiaries,
    );
    final selectedApiaryId = context.select<InspectionBloc, String?>(
      (bloc) => bloc.state.selectedApiaryId,
    );

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Select Apiary',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber.shade800,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: apiaries.length,
              itemBuilder: (context, index) {
                final apiary = apiaries[index];
                final isSelected = apiary.id == selectedApiaryId;
                
                return ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? Colors.amber.shade100 
                          : Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.home_work,
                      color: isSelected 
                          ? Colors.amber.shade700 
                          : Colors.grey.shade700,
                    ),
                  ),
                  title: Text(
                    apiary.name,
                    style: TextStyle(
                      fontWeight: isSelected 
                          ? FontWeight.bold 
                          : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(
                    '${apiary.location ?? "Unknown location"} • ${apiary.hiveCount} hives',
                  ),
                  trailing: isSelected 
                      ? Icon(Icons.check_circle, color: Colors.amber.shade700)
                      : null,
                  onTap: () {
                    context.read<InspectionBloc>().add(SelectApiaryEvent(apiary.id));
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
