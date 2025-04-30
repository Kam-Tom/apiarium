import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:apiarium/features/raport/inspection/bloc/inspection_bloc.dart';
import 'package:apiarium/features/raport/widgets/checkbox_input_field.dart';

class ExcessivePropolisField extends StatelessWidget {
  const ExcessivePropolisField({super.key});

  @override
  Widget build(BuildContext context) {
    final value = context.select((InspectionBloc bloc) => 
      bloc.state.getFieldValue<bool>('hiveCondition.excessivePropolis') ?? false);
    final fieldState = context.select((InspectionBloc bloc) => 
      bloc.state.getFieldState('hiveCondition.excessivePropolis'));
    
    return CheckboxInputField(
      label: 'Excessive Propolis',
      icon: Icons.format_color_fill,
      fieldName: 'hiveCondition.excessivePropolis',
      fieldState: fieldState,
      value: value,
      positiveText: 'Yes, excessive propolis present',
      negativeText: 'No excessive propolis observed',
      onChanged: (newValue) {
        if (newValue != null) {
          context.read<InspectionBloc>().add(
            UpdateFieldEvent('hiveCondition.excessivePropolis', newValue),
          );
        }
      },
      onReset: () => context.read<InspectionBloc>().add(
        const ResetFieldEvent('hiveCondition.excessivePropolis'),
      ),
    );
  }
}
