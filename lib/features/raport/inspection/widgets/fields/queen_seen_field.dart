import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:apiarium/features/raport/inspection/bloc/inspection_bloc.dart';
import 'package:apiarium/features/raport/widgets/checkbox_input_field.dart';

class QueenSeenField extends StatelessWidget {
  final bool compact;
  
  const QueenSeenField({
    super.key,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final value = context.select((InspectionBloc bloc) => 
      bloc.state.getFieldValue<bool>('queen.seen'));
    final fieldState = context.select((InspectionBloc bloc) => 
      bloc.state.getFieldState('queen.seen'));
    
    return CheckboxInputField(
      label: 'Queen Seen ', // Added space at end
      icon: Icons.visibility,
      fieldName: 'queen.seen',
      fieldState: fieldState,
      value: value,
      compact: compact,
      positiveText: compact ? null : 'Yes, queen was observed',
      negativeText: compact ? null : 'No, queen was not seen',
      onChanged: (newValue) {
        if (newValue != null) {
          context.read<InspectionBloc>().add(
            UpdateFieldEvent('queen.seen', newValue),
          );
        }
      },
      onReset: () => context.read<InspectionBloc>().add(
        const ResetFieldEvent('queen.seen'),
      ),
    );
  }
}
