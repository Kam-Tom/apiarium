import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:apiarium/features/raport/inspection/bloc/inspection_bloc.dart';
import 'package:apiarium/features/raport/widgets/checkbox_input_field.dart';

class BroodPresentField extends StatelessWidget {
  final bool compact;
  
  const BroodPresentField({
    super.key,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final value = context.select((InspectionBloc bloc) => 
      bloc.state.getFieldValue<bool>('brood.present'));
    final fieldState = context.select((InspectionBloc bloc) => 
      bloc.state.getFieldState('brood.present'));
    
    return CheckboxInputField(
      label: 'Brood Present',
      icon: Icons.bubble_chart,
      fieldName: 'brood.present',
      fieldState: fieldState,
      value: value,
      compact: compact,
      positiveText: compact ? null : 'Yes, brood was observed',
      negativeText: compact ? null : 'No, no brood present', 
      onChanged: (newValue) {
        if (newValue != null) {
          context.read<InspectionBloc>().add(
            UpdateFieldEvent('brood.present', newValue),
          );
        }
      },
      onReset: () => context.read<InspectionBloc>().add(
        const ResetFieldEvent('brood.present'),
      ),
    );
  }
}
