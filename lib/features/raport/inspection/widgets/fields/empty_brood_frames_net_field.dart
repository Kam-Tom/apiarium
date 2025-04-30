import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:apiarium/features/raport/inspection/bloc/inspection_bloc.dart';
import 'package:apiarium/features/raport/widgets/net_count_input_field.dart';
import 'dart:math' as math;

class EmptyBroodFramesNetField extends StatelessWidget {
  const EmptyBroodFramesNetField({super.key});

  @override
  Widget build(BuildContext context) {
    final totalBroodFrames = context.select<InspectionBloc, int>((bloc) => bloc.state.totalBroodFrames);
    final framesPerBroodBox = context.select<InspectionBloc, int>((bloc) => bloc.state.framesPerBroodBox);
    final maxBroodFrames = context.select<InspectionBloc, int>((bloc) => bloc.state.maxBroodFrames);

    final broodBoxNetChange = context.select<InspectionBloc, int?>((bloc) => 
      bloc.state.getFieldValue<int>('framesMoved.broodBoxNet')) ?? 0;
    final broodNet = context.select<InspectionBloc, int?>((bloc) => 
      bloc.state.getFieldValue<int>('framesMoved.broodNet')) ?? 0;
    
    final fieldState = context.select<InspectionBloc, FieldState>((bloc) => 
      bloc.state.getFieldState('framesMoved.emptyBroodNet'));
      
    // Get old value for display in label when state is "old"
    final oldValue = context.select<InspectionBloc, int?>((bloc) => 
      bloc.state.getOldFieldValue<int>('framesMoved.emptyBroodNet')) ?? 0;
      
    // Use actual value only if it's set or saved, otherwise use 0
    final value = fieldState == FieldState.old 
        ? 0 
        : context.select<InspectionBloc, int?>((bloc) => 
            bloc.state.getFieldValue<int>('framesMoved.emptyBroodNet')) ?? 0;
    
    // Min/max calculation with clamping to dynamic limits
    int min = -totalBroodFrames - math.min(0,broodNet);
    int max = (maxBroodFrames - totalBroodFrames + broodBoxNetChange * framesPerBroodBox - broodNet);
    
    //Becasue of the throwwing way how sliders updates works, not as one but all time etc
    if(max < 0) {
      max = 0;
    }
    if(min > 0) {
      min = 0;
    }
    
    // Clamp current value to new min/max
    final clampedValue = value.clamp(min, max);
    if(value != clampedValue && fieldState != FieldState.old) {
      context.read<InspectionBloc>().add(
        UpdateFieldEvent('framesMoved.emptyBroodNet', clampedValue),
      );
    }
    
    // Divisions should be at least 1
    final divisions = (max - min) > 0 ? (max - min).toInt() : 1;
    
    return NetCountInputField(
      label: 'Empty Brood +/-',
      icon: Icons.crop_square_outlined,
      fieldName: 'framesMoved.emptyBroodNet',
      fieldState: fieldState,
      value: clampedValue,
      oldValue: fieldState == FieldState.old ? oldValue : null,
      min: min,
      max: max,
      divisions: divisions,
      onChanged: (newValue) {
        // When slider moves to 0, this will now reset the field
        context.read<InspectionBloc>().add(
          UpdateFieldEvent('framesMoved.emptyBroodNet', newValue),
        );
      },
      onReset: () => context.read<InspectionBloc>().add(
        const ResetFieldEvent('framesMoved.emptyBroodNet'),
      ),
    );
  }
}
