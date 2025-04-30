import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:apiarium/features/raport/inspection/bloc/inspection_bloc.dart';
import 'package:apiarium/features/raport/widgets/slider_input_field.dart';

class QueenBehaviorField extends StatelessWidget {
  const QueenBehaviorField({super.key});

  @override
  Widget build(BuildContext context) {
    final value = context.select((InspectionBloc bloc) => 
      bloc.state.getFieldValue<double>('queen.behavior'));
    final fieldState = context.select((InspectionBloc bloc) => 
      bloc.state.getFieldState('queen.behavior'));
    
    return SliderInputField(
      label: 'Queen Behavior',
      icon: Icons.psychology,
      fieldName: 'queen.behavior',
      fieldState: fieldState,
      value: value ?? 0.0,
      min: -2.0,
      max: 2.0,
      divisions: 4,
      valueLabels: {
        -2.0: 'Running',
        -1.0: 'Nervous',
        0.0: 'Normal',
        1.0: 'Calm',
        2.0: 'Very Calm',
      },
      onChanged: (newValue) {
        context.read<InspectionBloc>().add(
          UpdateFieldEvent('queen.behavior', newValue),
        );
        
        String behaviorLevel;
        if (newValue <= -1.5) {
          behaviorLevel = 'running';
        } else if (newValue <= -0.5) {
          behaviorLevel = 'nervous';
        } else if (newValue <= 0.5) {
          behaviorLevel = 'normal';
        } else if (newValue <= 1.5) {
          behaviorLevel = 'calm';
        } else {
          behaviorLevel = 'very calm';
        }
        
        context.read<InspectionBloc>().add(
          UpdateFieldEvent('queen.behaviorLevel', behaviorLevel),
        );
      },
      onReset: () => context.read<InspectionBloc>().add(
        const ResetFieldEvent('queen.behavior'),
      ),
    );
  }
}
