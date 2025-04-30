import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:apiarium/features/raport/inspection/bloc/inspection_bloc.dart';
import 'package:apiarium/features/raport/widgets/net_count_input_field.dart';

class HoneySuperBoxNetCountField extends StatelessWidget {
  const HoneySuperBoxNetCountField({super.key});

  @override
  Widget build(BuildContext context) {
    final honeySuperBoxCount = context.select<InspectionBloc, int>((bloc) => bloc.state.honeySuperBoxCount);
    final fieldState = context.select<InspectionBloc, FieldState>((bloc) => 
      bloc.state.getFieldState('framesMoved.honeySuperBoxNet'));
      
    // Get old value for display in label when state is "old"
    final oldValue = context.select<InspectionBloc, int?>((bloc) => 
      bloc.state.getOldFieldValue<int>('framesMoved.honeySuperBoxNet')) ?? 0;
      
    // Use actual value only if it's set or saved, otherwise use 0
    final value = fieldState == FieldState.old 
        ? 0 
        : context.select<InspectionBloc, int?>((bloc) => 
            bloc.state.getFieldValue<int>('framesMoved.honeySuperBoxNet')) ?? 0;
    
    // Min/max calculation: can't go below removing all existing boxes
    // or adding more than is reasonable
    final min = -honeySuperBoxCount;
    final max = 10-honeySuperBoxCount; // Match the logic in brood_box_count_field
    final divisions = max - min;
    
    return NetCountInputField(
      label: 'Super Boxes +/-',
      icon: Icons.add_box,
      fieldName: 'framesMoved.honeySuperBoxNet',
      fieldState: fieldState,
      value: value,
      oldValue: fieldState == FieldState.old ? oldValue : null,
      min: min,
      max: max,
      divisions: divisions,
      onChanged: (newValue) {
        // For box counts, going to 0 will also reset the field
        context.read<InspectionBloc>().add(
          UpdateBoxCountEvent(
            boxType: 'honey',
            newValue: newValue,
            oldValue: value,
          ),
        );
      },
      onReset: () => context.read<InspectionBloc>().add(
        const ResetFieldEvent('framesMoved.honeySuperBoxNet'),
      ),
    );
  }
}
