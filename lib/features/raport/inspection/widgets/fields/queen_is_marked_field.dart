import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:apiarium/features/raport/inspection/bloc/inspection_bloc.dart';
import 'package:apiarium/features/raport/widgets/checkbox_input_field.dart';

class QueenIsMarkedField extends StatelessWidget {
  final bool compact;
  
  const QueenIsMarkedField({
    super.key,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final value = context.select((InspectionBloc bloc) => 
      bloc.state.getFieldValue<bool>('queen.isMarked'));
    final fieldState = context.select((InspectionBloc bloc) => 
      bloc.state.getFieldState('queen.isMarked'));
    
    return CheckboxInputField(
      label: 'Queen Marked',
      icon: Icons.brush,
      fieldName: 'queen.isMarked',
      fieldState: fieldState,
      value: value,
      compact: compact,
      positiveText: compact ? null : 'Yes, queen is marked',
      negativeText: compact ? null : 'No, queen is not marked',
      onChanged: (newValue) {
        if (newValue != null) {
          context.read<InspectionBloc>().add(
            UpdateFieldEvent('queen.isMarked', newValue),
          );
        }
      },
      onReset: () => context.read<InspectionBloc>().add(
        const ResetFieldEvent('queen.isMarked'),
      ),
    );
  }
}
