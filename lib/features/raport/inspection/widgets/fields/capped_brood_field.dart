import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:apiarium/features/raport/inspection/bloc/inspection_bloc.dart';
import 'package:apiarium/features/raport/widgets/checkbox_input_field.dart';

class CappedBroodField extends StatelessWidget {
  final bool compact;
  
  const CappedBroodField({
    super.key,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final value = context.select<InspectionBloc, bool?>((bloc) => 
      bloc.state.getFieldValue<bool>('brood.capped'));
    final fieldState = context.select<InspectionBloc, FieldState>((bloc) => 
      bloc.state.getFieldState('brood.capped'));
    
    return CheckboxInputField(
      label: 'Capped Brood',
      icon: Icons.grid_view,
      fieldName: 'brood.capped',
      fieldState: fieldState,
      value: value,
      compact: compact,
      positiveText: compact ? null : 'Yes, capped brood was observed',
      negativeText: compact ? null : 'No, no capped brood seen',
      onChanged: (newValue) {
        if (newValue != null) {
          context.read<InspectionBloc>().add(
            UpdateFieldEvent('brood.capped', newValue),
          );
        }
      },
      onReset: () => context.read<InspectionBloc>().add(
        const ResetFieldEvent('brood.capped'),
      ),
    );
  }
}
