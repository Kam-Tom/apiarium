import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:apiarium/features/raport/inspection/bloc/inspection_bloc.dart';
import 'package:apiarium/features/raport/widgets/slider_input_field.dart';

class ColonyActivityField extends StatelessWidget {
  const ColonyActivityField({super.key});

  @override
  Widget build(BuildContext context) {
    final value = context.select<InspectionBloc, double?>((bloc) => 
      bloc.state.getFieldValue<double>('colony.activity'));
    final fieldState = context.select<InspectionBloc, FieldState>((bloc) => 
      bloc.state.getFieldState('colony.activity'));
    
    return SliderInputField(
      label: 'Colony Activity',
      icon: Icons.timeline,
      fieldName: 'colony.activity',
      fieldState: fieldState,
      value: value ?? 0.0,
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
        context.read<InspectionBloc>().add(
          UpdateFieldEvent('colony.activity', newValue),
        );
        
        String activityLevel;
        if (newValue <= -1.5) {
          activityLevel = 'very low';
        } else if (newValue <= -0.5) {
          activityLevel = 'low';
        } else if (newValue <= 0.5) {
          activityLevel = 'average';
        } else if (newValue <= 1.5) {
          activityLevel = 'high';
        } else {
          activityLevel = 'very high';
        }
        
        context.read<InspectionBloc>().add(
          UpdateFieldEvent('colony.activityLevel', activityLevel),
        );
      },
      onReset: () => context.read<InspectionBloc>().add(
        const ResetFieldEvent('colony.activity'),
      ),
    );
  }
}
