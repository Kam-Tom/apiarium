import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:apiarium/features/raport/inspection/bloc/inspection_bloc.dart';
import 'package:apiarium/features/raport/widgets/number_input_field.dart';
import 'package:apiarium/features/raport/widgets/dropdown_input_field.dart';

class WindField extends StatelessWidget {
  static const List<String> directions = [
    'N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'
  ];

  const WindField({super.key});

  @override
  Widget build(BuildContext context) {
    final windSpeed = context.select<InspectionBloc, int?>(
      (bloc) => bloc.state.getFieldValue<double>('weather.wind.speed')?.round(),
    );
    final windDirection = context.select<InspectionBloc, String?>(
      (bloc) => bloc.state.getFieldValue<String>('weather.wind.direction'),
    );
    final speedFieldState = context.select<InspectionBloc, FieldState>(
      (bloc) => bloc.state.getFieldState('weather.wind.speed'),
    );
    final directionFieldState = context.select<InspectionBloc, FieldState>(
      (bloc) => bloc.state.getFieldState('weather.wind.direction'),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NumberInputField(
          label: 'Wind Speed',
          icon: Icons.air,
          fieldName: 'weather.wind.speed',
          fieldState: speedFieldState,
          value: windSpeed,
          min: 0,
          max: 50,
          suffix: 'm/s',
          onChanged: (newValue) {
            if (newValue == null) {
              context.read<InspectionBloc>().add(
                const ResetFieldEvent('weather.wind.speed'),
              );
            } else {
              context.read<InspectionBloc>().add(
                UpdateFieldEvent('weather.wind.speed', newValue),
              );
            }
          },
          onReset: () => context.read<InspectionBloc>().add(
            const ResetFieldEvent('weather.wind.speed'),
          ),
        ),
        DropdownInputField(
          label: 'Wind Direction',
          icon: Icons.explore,
          fieldName: 'weather.wind.direction',
          fieldState: directionFieldState,
          value: windDirection,
          options: directions,
          onChanged: (newValue) {
            context.read<InspectionBloc>().add(
              UpdateFieldEvent('weather.wind.direction', newValue),
            );
          },
          onReset: () => context.read<InspectionBloc>().add(
            const ResetFieldEvent('weather.wind.direction'),
          ),
        ),
      ],
    );
  }
}
