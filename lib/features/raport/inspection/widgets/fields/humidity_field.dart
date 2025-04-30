import 'package:apiarium/features/raport/inspection/bloc/inspection_bloc.dart';
import 'package:apiarium/features/raport/widgets/slider_input_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HumidityField extends StatelessWidget {
  const HumidityField({super.key});

  @override
  Widget build(BuildContext context) {
    final value = context.select((InspectionBloc bloc) => 
      bloc.state.getFieldValue<int>('weather.humidity') ?? 50);
    final fieldState = context.select((InspectionBloc bloc) => 
      bloc.state.getFieldState('weather.humidity'));
    
    // Create a map for the value labels
    final Map<double, String> valueLabels = {
      0: 'Very Dry (0%)',
      25: '25%',
      50: 'Medium (50%)',
      75: '75%',
      100: 'Humid (100%)',
    };
    
    return SliderInputField(
      label: 'Humidity',
      icon: Icons.water_drop,
      fieldName: 'weather.humidity',
      fieldState: fieldState,
      value: value.toDouble(),
      min: 0,
      max: 100,
      divisions: 100,
      valueLabels: valueLabels,
      showBottomLabels: true,
      onChanged: (newValue) {
        context.read<InspectionBloc>().add(
          UpdateFieldEvent('weather.humidity', newValue.round()),
        );
      },
      onReset: () => context.read<InspectionBloc>().add(
        const ResetFieldEvent('weather.humidity'),
      ),
    );
  }
}
