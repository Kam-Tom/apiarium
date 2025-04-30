import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:apiarium/features/raport/inspection/bloc/inspection_bloc.dart';
import 'package:apiarium/features/raport/widgets/checkbox_input_field.dart';

class MoldField extends StatelessWidget {
  const MoldField({super.key});

  @override
  Widget build(BuildContext context) {
    final value = context.select((InspectionBloc bloc) => 
      bloc.state.getFieldValue<bool>('hiveCondition.mold') ?? false);
    final fieldState = context.select((InspectionBloc bloc) => 
      bloc.state.getFieldState('hiveCondition.mold'));
    
    return CheckboxInputField(
      label: 'Mold Present',
      icon: Icons.grass,
      fieldName: 'hiveCondition.mold',
      fieldState: fieldState,
      value: value,
      positiveText: 'Yes, mold is present',
      negativeText: 'No mold observed',
      onChanged: (newValue) {
        if (newValue != null) {
          context.read<InspectionBloc>().add(
            UpdateFieldEvent('hiveCondition.mold', newValue),
          );
        }
      },
      onReset: () => context.read<InspectionBloc>().add(
        const ResetFieldEvent('hiveCondition.mold'),
      ),
    );
  }
}
