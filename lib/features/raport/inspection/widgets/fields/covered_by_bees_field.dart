import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:apiarium/features/raport/inspection/bloc/inspection_bloc.dart';
import 'package:apiarium/features/raport/widgets/slider_input_field.dart';

class CoveredByBeesField extends StatelessWidget {
  const CoveredByBeesField({super.key});

  @override
  Widget build(BuildContext context) {
    final totalFrames = context.select<InspectionBloc, int>((bloc) => bloc.state.totalFrames);
    final value = context.select<InspectionBloc, int?>((bloc) => 
      bloc.state.getFieldValue<int>('frames.coveredByBees'));
    final fieldState = context.select<InspectionBloc, FieldState>((bloc) => 
      bloc.state.getFieldState('frames.coveredByBees'));
    final currentValue = value ?? (totalFrames * 0.8).round();

    return SliderInputField(
      label: 'Covered by Bees',
      icon: Icons.bug_report,
      fieldName: 'frames.coveredByBees',
      fieldState: fieldState,
      value: currentValue.toDouble(),
      min: 0,
      max: totalFrames.toDouble(),
      divisions: totalFrames,
      valueLabels: null,
      showBottomLabels: true,
      onChanged: (newValue) {
        context.read<InspectionBloc>().add(
          UpdateFieldEvent('frames.coveredByBees', newValue.round()),
        );
      },
      onReset: () => context.read<InspectionBloc>().add(
        const ResetFieldEvent('frames.coveredByBees'),
      ),
    );
  }
}
