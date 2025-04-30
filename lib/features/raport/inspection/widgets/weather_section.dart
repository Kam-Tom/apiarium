import 'package:apiarium/features/raport/inspection/bloc/inspection_bloc.dart';
import 'package:apiarium/features/raport/inspection/widgets/fields/weather_conditions_field.dart';
import 'package:apiarium/features/raport/inspection/widgets/fields/temperature_field.dart';
import 'package:apiarium/features/raport/inspection/widgets/fields/humidity_field.dart';
import 'package:apiarium/features/raport/inspection/widgets/fields/pressure_field.dart';
import 'package:apiarium/features/raport/inspection/widgets/fields/wind_field.dart';
import 'package:apiarium/features/raport/widgets/expandable_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WeatherSection extends StatelessWidget {
  const WeatherSection({super.key});

  static const List<String> fields = [
    'weather.conditions', 
    'weather.temperature', 
    'weather.humidity',
    'weather.pressure',
    'weather.wind.speed',
    'weather.wind.direction'
  ];

  @override
  Widget build(BuildContext context) {
    final isExpanded = context.select<InspectionBloc, bool>(
      (bloc) => bloc.state.expandedSections['weatherSection'] ?? false,
    );
    final isActive = context.select<InspectionBloc, bool>(
      (bloc) => bloc.state.isCategoryActive(fields),
    );
    final filledCount = context.select<InspectionBloc, int>(
      (bloc) => bloc.state.countModifiedFieldsInCategory(fields),
    );

    return ExpandableSection(
      title: 'Weather Conditions',
      icon: Icons.cloud,
      isExpanded: isExpanded,
      isActive: isActive,
      filledFieldsCount: filledCount,
      totalFieldsCount: fields.length,
      onToggle: () => context.read<InspectionBloc>().add(
        const ToggleSectionEvent('weatherSection'),
      ),
      children: const [
        WeatherConditionsField(),
        SizedBox(height: 12),
        TemperatureField(),
        SizedBox(height: 12),
        HumidityField(),
        SizedBox(height: 12),
        PressureField(),
        SizedBox(height: 12),
        WindField(),
      ],
    );
  }
}
