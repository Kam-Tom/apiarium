import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:apiarium/features/raport/inspection/bloc/inspection_bloc.dart';
import 'package:apiarium/features/raport/widgets/slider_input_field.dart';

class TemperamentField extends StatelessWidget {
  const TemperamentField({super.key});

  @override
  Widget build(BuildContext context) {
    final value = context.select((InspectionBloc bloc) => 
      bloc.state.getFieldValue<double>('colony.temperament'));
    final fieldState = context.select((InspectionBloc bloc) => 
      bloc.state.getFieldState('colony.temperament'));
    
    return SliderInputField(
      label: 'Temperament',
      icon: Icons.mood,
      fieldName: 'colony.temperament',
      fieldState: fieldState, // Pass the field state instead of isSet
      value: value ?? 0.0,
      min: -2.0,
      max: 2.0,
      divisions: 4,
      valueLabels: {
        -2.0: 'Very Gentle',
        -1.0: 'Gentle',
        0.0: 'Normal',
        1.0: 'Defensive',
        2.0: 'Aggressive',
      },
      showBottomLabels: false, // Don't show bottom labels
      onChanged: (newValue) {
        context.read<InspectionBloc>().add(
          UpdateFieldEvent('colony.temperament', newValue),
        );
        
        // Map slider value to string value for API
        String temperamentLevel;
        if (newValue <= -1.5) {
          temperamentLevel = 'very gentle';
        } else if (newValue <= -0.5) {
          temperamentLevel = 'gentle';
        } else if (newValue <= 0.5) {
          temperamentLevel = 'normal';
        } else if (newValue <= 1.5) {
          temperamentLevel = 'defensive';
        } else {
          temperamentLevel = 'aggressive';
        }
        
        context.read<InspectionBloc>().add(
          UpdateFieldEvent('colony.temperamentLevel', temperamentLevel),
        );
      },
      onReset: () => context.read<InspectionBloc>().add(
        const ResetFieldEvent('colony.temperament'),
      ),
    );
  }
}
