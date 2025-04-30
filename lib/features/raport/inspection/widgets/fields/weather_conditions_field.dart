import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:apiarium/features/raport/inspection/bloc/inspection_bloc.dart';
import 'package:apiarium/features/raport/widgets/dropdown_input_field.dart';

class WeatherConditionsField extends StatelessWidget {
  const WeatherConditionsField({super.key});

  @override
  Widget build(BuildContext context) {
    final value = context.select((InspectionBloc bloc) => 
      bloc.state.getFieldValue<String>('weather.conditions'));
    final fieldState = context.select((InspectionBloc bloc) => 
      bloc.state.getFieldState('weather.conditions'));
    
    const options = [
      'Clear',
      'Sunny',
      'Partly cloudy',
      'Cloudy',
      'Overcast',
      'Foggy',
      'Rainy',
      'Drizzle',
      'Stormy',
      'Thunderstorm',
      'Windy',
      'Snowy',
      'Hot',
      'Cold'
    ];
    
    return DropdownInputField(
      label: 'Weather Conditions',
      icon: Icons.cloud,
      fieldName: 'weather.conditions',
      fieldState: fieldState,
      value: value,
      options: options,
      onChanged: (newValue) {
        context.read<InspectionBloc>().add(
          UpdateFieldEvent('weather.conditions', newValue),
        );
      },
      onReset: () => context.read<InspectionBloc>().add(
        const ResetFieldEvent('weather.conditions'),
      ),
      hintText: 'Select weather conditions',
    );
  }
}
