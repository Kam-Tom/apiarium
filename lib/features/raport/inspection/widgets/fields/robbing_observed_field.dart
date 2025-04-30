import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:apiarium/features/raport/inspection/bloc/inspection_bloc.dart';
import 'package:apiarium/features/raport/widgets/checkbox_input_field.dart';

class RobbingObservedField extends StatelessWidget {
  final bool compact;
  
  const RobbingObservedField({
    super.key,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final value = context.select((InspectionBloc bloc) => 
      bloc.state.getFieldValue<bool>('colony.robbingObserved'));
    final fieldState = context.select((InspectionBloc bloc) => 
      bloc.state.getFieldState('colony.robbingObserved'));
    
    return CheckboxInputField(
      label: 'Robbing Observed',
      icon: Icons.bug_report,
      fieldName: 'colony.robbingObserved',
      fieldState: fieldState,
      value: value,
      compact: compact,
      positiveText: compact ? null : 'Yes, robbing was observed',
      negativeText: compact ? null : 'No, no robbing behavior',
      onChanged: (newValue) {
        if (newValue != null) {
          context.read<InspectionBloc>().add(
            UpdateFieldEvent('colony.robbingObserved', newValue),
          );
        }
      },
      onReset: () => context.read<InspectionBloc>().add(
        const ResetFieldEvent('colony.robbingObserved'),
      ),
    );
  }
}
