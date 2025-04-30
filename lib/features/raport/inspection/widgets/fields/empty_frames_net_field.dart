import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:apiarium/features/raport/inspection/bloc/inspection_bloc.dart';
import 'package:apiarium/features/raport/widgets/net_count_input_field.dart';
import 'dart:math' as math;

class EmptyFramesNetCountField extends StatelessWidget {
  const EmptyFramesNetCountField({super.key});

  @override
  Widget build(BuildContext context) {
    // Base frame counts
    final totalFrames = context.select<InspectionBloc, int>((bloc) => bloc.state.totalFrames);
    final framesPerBox = context.select<InspectionBloc, int>((bloc) => bloc.state.framesPerSuperBox);
    final maxFrames = context.select<InspectionBloc, int>((bloc) => bloc.state.maxFrames);
    
    // Box changes affect max capacity
    final boxNetChange = context.select<InspectionBloc, int?>((bloc) => 
      bloc.state.getFieldValue<int>('framesMoved.honeySuperBoxNet')) ?? 0;
    
    // Get related frame counts
    final honeyNet = context.select<InspectionBloc, int?>((bloc) => 
      bloc.state.getFieldValue<int>('framesMoved.honeyNet')) ?? 0;
    
    final fieldState = context.select<InspectionBloc, FieldState>((bloc) => 
      bloc.state.getFieldState('framesMoved.emptyNet'));
      
    // Get old value for display in label when state is "old"
    final oldValue = context.select<InspectionBloc, int?>((bloc) => 
      bloc.state.getOldFieldValue<int>('framesMoved.emptyNet')) ?? 0;
      
    // Use actual value only if it's set or saved, otherwise use 0
    final value = fieldState == FieldState.old 
        ? 0 
        : context.select<InspectionBloc, int?>((bloc) => 
            bloc.state.getFieldValue<int>('framesMoved.emptyNet')) ?? 0;
    
    // Min/max calculation with clamping to dynamic limits
    int min = -totalFrames - math.min(0, honeyNet);
    int max = (maxFrames - totalFrames + boxNetChange * framesPerBox - honeyNet);
    
    // Adjust limits to valid range
    if (max < 0) {
      max = 0;
    }
    if (min > 0) {
      min = 0;
    }
    
    // Clamp current value to new min/max
    final clampedValue = value.clamp(min, max);
    if (value != clampedValue && fieldState != FieldState.old) {
      // Update to clamped value if it's different from current
      context.read<InspectionBloc>().add(
        UpdateFieldEvent('framesMoved.emptyNet', clampedValue),
      );
    }
    
    // Divisions should be at least 1
    final divisions = (max - min) > 0 ? (max - min).toInt() : 1;
    
    return NetCountInputField(
      label: 'Empty Frames +/-',
      icon: Icons.crop_square,
      fieldName: 'framesMoved.emptyNet',
      fieldState: fieldState,
      value: clampedValue,
      oldValue: fieldState == FieldState.old ? oldValue : null,
      min: min,
      max: max,
      divisions: divisions,
      onChanged: (newValue) {
        // When slider moves to 0, this will now reset the field
        context.read<InspectionBloc>().add(
          UpdateFieldEvent('framesMoved.emptyNet', newValue),
        );
      },
      onReset: () => context.read<InspectionBloc>().add(
        const ResetFieldEvent('framesMoved.emptyNet'),
      ),
    );
  }
}
