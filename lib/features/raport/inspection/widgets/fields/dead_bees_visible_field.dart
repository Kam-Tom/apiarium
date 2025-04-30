import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:apiarium/features/raport/inspection/bloc/inspection_bloc.dart';
import 'package:apiarium/features/raport/widgets/checkbox_input_field.dart';

class DeadBeesVisibleField extends StatelessWidget {
  const DeadBeesVisibleField({super.key});

  @override
  Widget build(BuildContext context) {
    final value = context.select((InspectionBloc bloc) => 
      bloc.state.getFieldValue<bool>('hiveCondition.deadBeesVisible') ?? false);
    final fieldState = context.select((InspectionBloc bloc) => 
      bloc.state.getFieldState('hiveCondition.deadBeesVisible'));
    
    return CheckboxInputField(
      label: 'Dead Bees Visible',
      icon: Icons.dangerous,
      fieldName: 'hiveCondition.deadBeesVisible',
      fieldState: fieldState,
      value: value,
      positiveText: 'Yes, dead bees are visible',
      negativeText: 'No dead bees observed',
      onChanged: (newValue) {
        if (newValue != null) {
          context.read<InspectionBloc>().add(
            UpdateFieldEvent('hiveCondition.deadBeesVisible', newValue),
          );
        }
      },
      onReset: () => context.read<InspectionBloc>().add(
        const ResetFieldEvent('hiveCondition.deadBeesVisible'),
      ),
    );
  }
}
