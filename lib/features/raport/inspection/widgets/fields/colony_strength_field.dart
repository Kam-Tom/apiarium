import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:apiarium/features/raport/inspection/bloc/inspection_bloc.dart';
import 'package:apiarium/features/raport/widgets/slider_input_field.dart';

class ColonyStrengthField extends StatelessWidget {
  const ColonyStrengthField({super.key});

  @override
  Widget build(BuildContext context) {
    final value = context.select<InspectionBloc, double?>((bloc) => 
      bloc.state.getFieldValue<double>('colony.strength'));
    final fieldState = context.select<InspectionBloc, FieldState>((bloc) => 
      bloc.state.getFieldState('colony.strength'));
    
    return SliderInputField(
      label: 'Colony Strength',
      icon: Icons.account_tree,
      fieldName: 'colony.strength',
      fieldState: fieldState,
      value: value ?? 0.0,
      min: -2.0,
      max: 2.0,
      divisions: 4,
      valueLabels: {
        -2.0: 'Very Weak',
        -1.0: 'Weak',
        0.0: 'Average',
        1.0: 'Strong',
        2.0: 'Very Strong',
      },
      onChanged: (newValue) {
        context.read<InspectionBloc>().add(
          UpdateFieldEvent('colony.strength', newValue),
        );
      },
      onReset: () => context.read<InspectionBloc>().add(
        const ResetFieldEvent('colony.strength'),
      ),
    );
  }
}
