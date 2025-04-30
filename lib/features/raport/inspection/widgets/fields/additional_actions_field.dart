import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:apiarium/features/raport/inspection/bloc/inspection_bloc.dart';
import 'package:apiarium/features/raport/widgets/multi_select_input_field.dart';

class AdditionalActionsField extends StatelessWidget {
  const AdditionalActionsField({super.key});

  @override
  Widget build(BuildContext context) {
    final values = context.select((InspectionBloc bloc) => 
      bloc.state.getFieldValue<List<String>>('actions.additional') ?? []);
    final fieldState = context.select((InspectionBloc bloc) => 
      bloc.state.getFieldState('actions.additional'));
    
    return MultiSelectInputField(
      label: 'Additional Actions',
      icon: Icons.build,
      fieldName: 'actions.additional',
      fieldState: fieldState,
      values: values,
      options: const [
        'installed queen',
        'added feeder',
        'treated for mites',
        'added honey super',
        'added pollen patty',
        'replaced frames',
        'added foundation',
        'combined colonies',
        'added entrance reducer',
        'added medication',
        'marked queen',
        'harvested honey',
        'expanded hive',
        'reduced hive size',
        'other'
      ],
      onChanged: (newValues) {
        context.read<InspectionBloc>().add(
          UpdateFieldEvent('actions.additional', newValues.join(',')),
        );
      },
      onReset: () => context.read<InspectionBloc>().add(
        const ResetFieldEvent('actions.additional'),
      ),
      hintText: 'Select actions performed',
    );
  }
}
