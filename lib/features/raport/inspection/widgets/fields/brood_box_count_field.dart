import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:apiarium/features/raport/inspection/bloc/inspection_bloc.dart';
import 'package:apiarium/features/raport/widgets/net_count_input_field.dart';

class BroodBoxNetCountField extends StatelessWidget {
  const BroodBoxNetCountField({super.key});

  @override
  Widget build(BuildContext context) {
    final broodBoxCount = context.select<InspectionBloc, int>((bloc) => bloc.state.broodBoxCount);
    final fieldState = context.select<InspectionBloc, FieldState>((bloc) => 
      bloc.state.getFieldState('framesMoved.broodBoxNet'));
      
    final value = context.select<InspectionBloc, int?>((bloc) => 
      bloc.state.getOldFieldValue<int>('framesMoved.broodBoxNet')) ?? 0;

    final min = -broodBoxCount;
    final max = 10-broodBoxCount; // Really biggest number of boxes you can have
    final divisions = max - min;

    if(value == 0 && fieldState == FieldState.set) {
      context.read<InspectionBloc>().add(
        ResetFieldEvent('framesMoved.broodBoxNet'),
      );
    }

    final oldValue = fieldState == FieldState.old ? 0 : value;
    final curretnValue = fieldState != FieldState.old ? value : 0;

    
    return NetCountInputField(
      label: 'Brood Boxes +/-',
      icon: Icons.add_box_rounded,
      fieldName: 'framesMoved.broodBoxNet',
      fieldState: fieldState,
      value: curretnValue,
      oldValue: fieldState == FieldState.old ? oldValue : null,
      min: min,
      max: max,
      divisions: divisions,
      onChanged: (newValue) {
        // For box counts, going to 0 will also reset the field
        context.read<InspectionBloc>().add(
          UpdateBoxCountEvent(
            boxType: 'brood',
            newValue: newValue,
            oldValue: curretnValue,
          ),
        );
      },
      onReset: () => context.read<InspectionBloc>().add(
        const ResetFieldEvent('framesMoved.broodBoxNet'),
      ),
    );
  }
}
