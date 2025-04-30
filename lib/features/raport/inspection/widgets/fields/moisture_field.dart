import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:apiarium/features/raport/inspection/bloc/inspection_bloc.dart';
import 'package:apiarium/features/raport/widgets/checkbox_input_field.dart';

class MoistureField extends StatelessWidget {
  const MoistureField({super.key});

  @override
  Widget build(BuildContext context) {
    final value = context.select((InspectionBloc bloc) => 
      bloc.state.getFieldValue<bool>('hiveCondition.moisture') ?? false);
    final fieldState = context.select((InspectionBloc bloc) => 
      bloc.state.getFieldState('hiveCondition.moisture'));
    
    return CheckboxInputField(
      label: 'Moisture Present',
      icon: Icons.water_drop,
      fieldName: 'hiveCondition.moisture',
      fieldState: fieldState,
      value: value,
      positiveText: 'Yes, moisture is present',
      negativeText: 'No excess moisture observed',
      onChanged: (newValue) {
        if (newValue != null) {
          context.read<InspectionBloc>().add(
            UpdateFieldEvent('hiveCondition.moisture', newValue),
          );
        }
      },
      onReset: () => context.read<InspectionBloc>().add(
        const ResetFieldEvent('hiveCondition.moisture'),
      ),
    );
  }
}
