import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:apiarium/features/raport/inspection/bloc/inspection_bloc.dart';
import 'package:apiarium/features/raport/widgets/checkbox_input_field.dart';

class LarvaeSeenField extends StatelessWidget {
  final bool compact;
  
  const LarvaeSeenField({
    super.key,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final value = context.select((InspectionBloc bloc) => 
      bloc.state.getFieldValue<bool>('brood.larvae'));
    final fieldState = context.select((InspectionBloc bloc) => 
      bloc.state.getFieldState('brood.larvae'));
    
    return CheckboxInputField(
      label: 'Larvae Seen',
      icon: Icons.bug_report,
      fieldName: 'brood.larvae',
      fieldState: fieldState,
      value: value,
      compact: compact,
      positiveText: compact ? null : 'Yes, larvae were observed',
      negativeText: compact ? null : 'No, larvae were not seen',
      onChanged: (newValue) {
        if (newValue != null) {
          context.read<InspectionBloc>().add(
            UpdateFieldEvent('brood.larvae', newValue),
          );
        }
      },
      onReset: () => context.read<InspectionBloc>().add(
        const ResetFieldEvent('brood.larvae'),
      ),
    );
  }
}
