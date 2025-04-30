import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:apiarium/features/raport/inspection/bloc/inspection_bloc.dart';
import 'package:apiarium/features/raport/widgets/checkbox_input_field.dart';

class ExcessDronesField extends StatelessWidget {
  final bool compact;
  
  const ExcessDronesField({
    super.key,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final value = context.select((InspectionBloc bloc) => 
      bloc.state.getFieldValue<bool>('brood.excessDrones'));
    final fieldState = context.select((InspectionBloc bloc) => 
      bloc.state.getFieldState('brood.excessDrones'));
    
    return CheckboxInputField(
      label: 'Excess Drones',
      icon: Icons.male,
      fieldName: 'brood.excessDrones',
      fieldState: fieldState,
      value: value,
      compact: compact,
      positiveText: compact ? null : 'Yes, excess drones observed',
      negativeText: compact ? null : 'No, normal drone population',
      onChanged: (newValue) {
        if (newValue != null) {
          context.read<InspectionBloc>().add(
            UpdateFieldEvent('brood.excessDrones', newValue),
          );
        }
      },
      onReset: () => context.read<InspectionBloc>().add(
        const ResetFieldEvent('brood.excessDrones'),
      ),
    );
  }
}
