import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:apiarium/features/raport/inspection/bloc/inspection_bloc.dart';
import 'package:apiarium/features/raport/widgets/number_input_field.dart';

class TemperatureField extends StatelessWidget {
  const TemperatureField({super.key});

  @override
  Widget build(BuildContext context) {
    final value = context.select<InspectionBloc, int?>(
      (bloc) => bloc.state.getFieldValue<int>('weather.temperature')?.round(),
    );
    final fieldState = context.select<InspectionBloc, FieldState>(
      (bloc) => bloc.state.getFieldState('weather.temperature'),
    );

    return NumberInputField(
      label: 'Temperature',
      icon: Icons.thermostat,
      fieldName: 'weather.temperature',
      fieldState: fieldState,
      value: value,
      min: -40,
      max: 60,
      suffix: '°C',
      onChanged: (newValue) {
        if (newValue == null) {
          context.read<InspectionBloc>().add(
            const ResetFieldEvent('weather.temperature'),
          );
        } else {
          context.read<InspectionBloc>().add(
            UpdateFieldEvent('weather.temperature', newValue),
          );
        }
      },
      onReset: () => context.read<InspectionBloc>().add(
        const ResetFieldEvent('weather.temperature'),
      ),
    );
  }
}
