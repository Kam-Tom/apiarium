import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:apiarium/features/raport/inspection/bloc/inspection_bloc.dart';
import 'package:apiarium/features/raport/widgets/slider_input_field.dart';

class HoneyFramesField extends StatelessWidget {
  const HoneyFramesField({super.key});

  @override
  Widget build(BuildContext context) {
    final totalFrames = context.select<InspectionBloc, int>((bloc) => bloc.state.totalFrames);
    final value = context.select((InspectionBloc bloc) => 
      bloc.state.getFieldValue<int>('frames.honeyFrames'));
    final fieldState = context.select((InspectionBloc bloc) => 
      bloc.state.getFieldState('frames.honeyFrames'));
    final currentValue = value ?? (totalFrames * 0.3).round();

    return SliderInputField(
      label: 'Honey Frames',
      icon: Icons.local_dining,
      fieldName: 'frames.honeyFrames',
      fieldState: fieldState,
      value: currentValue.toDouble(),
      min: 0,
      max: totalFrames.toDouble(),
      divisions: totalFrames,
      valueLabels: null,
      showBottomLabels: true,
      onChanged: (newValue) {
        context.read<InspectionBloc>().add(
          UpdateFieldEvent('frames.honeyFrames', newValue.round()),
        );
      },
      onReset: () => context.read<InspectionBloc>().add(
        const ResetFieldEvent('frames.honeyFrames'),
      ),
    );
  }
}
