import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:apiarium/features/raport/inspection/bloc/inspection_bloc.dart';
import 'package:apiarium/features/raport/widgets/slider_input_field.dart';

class BroodPopulationField extends StatelessWidget {
  const BroodPopulationField({super.key});

  @override
  Widget build(BuildContext context) {
    final value = context.select((InspectionBloc bloc) => 
      bloc.state.getFieldValue<String>('brood.population'));
    final fieldState = context.select((InspectionBloc bloc) => 
      bloc.state.getFieldState('brood.population'));
    
    double sliderValue = 0.0;
    if (value == 'very low') {
      sliderValue = -2.0;
    } else if (value == 'low') {
      sliderValue = -1.0;
    } else if (value == 'average') {
      sliderValue = 0.0;
    } else if (value == 'high') {
      sliderValue = 1.0;
    } else if (value == 'very high') {
      sliderValue = 2.0;
    }
    
    return SliderInputField(
      label: 'Brood Population',
      icon: Icons.people,
      fieldName: 'brood.population',
      fieldState: fieldState,
      value: sliderValue,
      min: -2.0,
      max: 2.0,
      divisions: 4,
      valueLabels: {
        -2.0: 'Very Low',
        -1.0: 'Low',
        0.0: 'Average',
        1.0: 'High',
        2.0: 'Very High',
      },
      onChanged: (newValue) {
        String population;
        if (newValue <= -1.5) {
          population = 'very low';
        } else if (newValue <= -0.5) {
          population = 'low';
        } else if (newValue <= 0.5) {
          population = 'average';
        } else if (newValue <= 1.5) {
          population = 'high';
        } else {
          population = 'very high';
        }
        
        context.read<InspectionBloc>().add(
          UpdateFieldEvent('brood.population', population),
        );
      },
      onReset: () => context.read<InspectionBloc>().add(
        const ResetFieldEvent('brood.population'),
      ),
    );
  }
}
