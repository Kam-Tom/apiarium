import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:apiarium/features/raport/inspection/bloc/inspection_bloc.dart';
import 'package:apiarium/features/raport/widgets/textarea_input_field.dart';

class NotesField extends StatelessWidget {
  const NotesField({super.key});

  @override
  Widget build(BuildContext context) {
    final value = context.select<InspectionBloc, String?>(
      (bloc) => bloc.state.getFieldValue<String>('notes'),
    );
    final fieldState = context.select<InspectionBloc, FieldState>(
      (bloc) => bloc.state.getFieldState('notes'),
    );

    return TextareaInputField(
      label: 'Notes',
      icon: Icons.notes,
      fieldName: 'notes',
      fieldState: fieldState,
      value: value,
      onChanged: (newValue) {
        if (newValue == null || newValue.isEmpty) {
          context.read<InspectionBloc>().add(
            const ResetFieldEvent('notes'),
          );
        } else {
          context.read<InspectionBloc>().add(
            UpdateFieldEvent('notes', newValue),
          );
        }
      },
      onReset: () => context.read<InspectionBloc>().add(
        const ResetFieldEvent('notes'),
      ),
      hintText: 'Add notes about the inspection...',
      minLines: 3,
      maxLines: 5,
    );
  }
}
