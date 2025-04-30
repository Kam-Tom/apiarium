import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:apiarium/features/raport/inspection/bloc/inspection_bloc.dart';
import 'package:apiarium/features/raport/widgets/checkbox_input_field.dart';

class EggsSeenField extends StatelessWidget {
  final bool compact;
  
  const EggsSeenField({
    super.key,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final value = context.select((InspectionBloc bloc) => 
      bloc.state.getFieldValue<bool>('brood.eggs'));
    final fieldState = context.select((InspectionBloc bloc) => 
      bloc.state.getFieldState('brood.eggs'));
    
    return CheckboxInputField(
      label: 'Eggs Seen',
      icon: Icons.egg_alt,
      fieldName: 'brood.eggs',
      fieldState: fieldState,
      value: value,
      compact: compact,
      positiveText: compact ? null : 'Yes, eggs were observed',
      negativeText: compact ? null : 'No, eggs were not seen',
      onChanged: (newValue) {
        if (newValue != null) {
          context.read<InspectionBloc>().add(
            UpdateFieldEvent('brood.eggs', newValue),
          );
        }
      },
      onReset: () => context.read<InspectionBloc>().add(
        const ResetFieldEvent('brood.eggs'),
      ),
    );
  }
}
