import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:apiarium/features/raport/inspection/bloc/inspection_bloc.dart';
import 'package:apiarium/features/raport/widgets/number_input_field.dart';

class PressureField extends StatelessWidget {
  const PressureField({super.key});

  @override
  Widget build(BuildContext context) {
    final value = context.select<InspectionBloc, int?>(
      (bloc) => bloc.state.getFieldValue<int>('weather.pressure'),
    );
    final fieldState = context.select<InspectionBloc, FieldState>(
      (bloc) => bloc.state.getFieldState('weather.pressure'),
    );

    return NumberInputField(
      label: 'Atmospheric Pressure',
      icon: Icons.speed,
      fieldName: 'weather.pressure',
      fieldState: fieldState,
      value: value,
      min: 800,
      max: 1100,
      suffix: 'hPa',
      onChanged: (newValue) {
        if (newValue == null) {
          context.read<InspectionBloc>().add(
            const ResetFieldEvent('weather.pressure'),
          );
        } else {
          context.read<InspectionBloc>().add(
            UpdateFieldEvent('weather.pressure', newValue),
          );
        }
      },
      onReset: () => context.read<InspectionBloc>().add(
        const ResetFieldEvent('weather.pressure'),
      ),
    );
  }
}
