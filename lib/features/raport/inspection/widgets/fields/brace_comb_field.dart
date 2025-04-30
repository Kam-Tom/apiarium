import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:apiarium/features/raport/inspection/bloc/inspection_bloc.dart';
import 'package:apiarium/features/raport/widgets/checkbox_input_field.dart';

class BraceCombField extends StatelessWidget {
  const BraceCombField({super.key});

  @override
  Widget build(BuildContext context) {
    final value = context.select((InspectionBloc bloc) => 
      bloc.state.getFieldValue<bool>('hiveCondition.braceComb') ?? false);
    final fieldState = context.select((InspectionBloc bloc) => 
      bloc.state.getFieldState('hiveCondition.braceComb'));
    
    return CheckboxInputField(
      label: 'Brace Comb Present',
      icon: Icons.hive,
      fieldName: 'hiveCondition.braceComb',
      fieldState: fieldState,
      value: value,
      positiveText: 'Yes, brace comb is present',
      negativeText: 'No brace comb observed',
      onChanged: (newValue) {
        if (newValue != null) {
          context.read<InspectionBloc>().add(
            UpdateFieldEvent('hiveCondition.braceComb', newValue),
          );
        }
      },
      onReset: () => context.read<InspectionBloc>().add(
        const ResetFieldEvent('hiveCondition.braceComb'),
      ),
    );
  }
}
