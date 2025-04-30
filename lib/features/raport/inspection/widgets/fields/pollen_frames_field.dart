import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:apiarium/features/raport/inspection/bloc/inspection_bloc.dart';
import 'package:apiarium/features/raport/widgets/slider_input_field.dart';

class PollenFramesField extends StatelessWidget {
  const PollenFramesField({super.key});

  @override
  Widget build(BuildContext context) {
    final totalFrames = context.select<InspectionBloc, int>((bloc) => bloc.state.totalFrames);
    final value = context.select((InspectionBloc bloc) => 
      bloc.state.getFieldValue<int>('frames.pollenFrames'));
    final fieldState = context.select((InspectionBloc bloc) => 
      bloc.state.getFieldState('frames.pollenFrames'));
    final currentValue = value ?? (totalFrames * 0.1).round();

    return SliderInputField(
      label: 'Pollen Frames',
      icon: Icons.grain,
      fieldName: 'frames.pollenFrames',
      fieldState: fieldState,
      value: currentValue.toDouble(),
      min: 0,
      max: totalFrames.toDouble(),
      divisions: totalFrames,
      valueLabels: null,
      showBottomLabels: true,
      onChanged: (newValue) {
        context.read<InspectionBloc>().add(
          UpdateFieldEvent('frames.pollenFrames', newValue.round()),
        );
      },
      onReset: () => context.read<InspectionBloc>().add(
        const ResetFieldEvent('frames.pollenFrames'),
      ),
    );
  }
}
