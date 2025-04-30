import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:apiarium/features/raport/inspection/bloc/inspection_bloc.dart';
import 'package:apiarium/features/raport/widgets/checkbox_input_field.dart';

class SwarmingSignsField extends StatelessWidget {
  const SwarmingSignsField({super.key});

  @override
  Widget build(BuildContext context) {
    final value = context.select((InspectionBloc bloc) => 
      bloc.state.getFieldValue<bool>('queen.swarmingSigns'));
    final fieldState = context.select((InspectionBloc bloc) => 
      bloc.state.getFieldState('queen.swarmingSigns'));
    
    return CheckboxInputField(
      label: 'Swarming Signs',
      icon: Icons.swipe_right_alt,
      fieldName: 'queen.swarmingSigns',
      fieldState: fieldState,
      value: value,
      positiveText: 'Yes, swarming signs observed',
      negativeText: 'No, no swarming signs observed',
      onChanged: (newValue) {
        if (newValue != null) {
          context.read<InspectionBloc>().add(
            UpdateFieldEvent('queen.swarmingSigns', newValue),
          );
        }
      },
      onReset: () => context.read<InspectionBloc>().add(
        const ResetFieldEvent('queen.swarmingSigns'),
      ),
    );
  }
}
