import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:apiarium/features/raport/inspection/bloc/inspection_bloc.dart';
import 'package:apiarium/features/raport/widgets/slider_input_field.dart';

class EmptyFramesField extends StatelessWidget {
  const EmptyFramesField({super.key});

  @override
  Widget build(BuildContext context) {
    final totalFrames = context.select<InspectionBloc, int>((bloc) => bloc.state.totalFrames);
    final value = context.select((InspectionBloc bloc) => 
      bloc.state.getFieldValue<int>('frames.emptyFrames'));
    final fieldState = context.select((InspectionBloc bloc) => 
      bloc.state.getFieldState('frames.emptyFrames'));
    var currentValue = value ?? (totalFrames * 0.2).round();
    if(currentValue > totalFrames) {
      currentValue = totalFrames;
    } else if (currentValue < 0) {
      currentValue = 0;
    }

    return SliderInputField(
      label: 'Empty Frames',
      icon: Icons.crop_square,
      fieldName: 'frames.emptyFrames',
      fieldState: fieldState,
      value: currentValue.toDouble(),
      min: 0,
      max: totalFrames.toDouble(),
      divisions: totalFrames,
      valueLabels: null,
      showBottomLabels: true,
      onChanged: (newValue) {
        context.read<InspectionBloc>().add(
          UpdateFieldEvent('frames.emptyFrames', newValue.round()),
        );
      },
      onReset: () => context.read<InspectionBloc>().add(
        const ResetFieldEvent('frames.emptyFrames'),
      ),
    );
  }
}
