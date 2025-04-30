import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:apiarium/features/raport/inspection/bloc/inspection_bloc.dart';
import 'package:apiarium/features/raport/widgets/number_input_field.dart';

class EmptyAddedField extends StatelessWidget {
  const EmptyAddedField({super.key});

  @override
  Widget build(BuildContext context) {
    final value = context.select((InspectionBloc bloc) => 
      bloc.state.getFieldValue<int>('framesMoved.emptyAdded') ?? 0);
    final fieldState = context.select((InspectionBloc bloc) => 
      bloc.state.getFieldState('framesMoved.emptyAdded'));
    
    return NumberInputField(
      label: 'Empty Frames Added',
      icon: Icons.add_box,
      fieldName: 'framesMoved.emptyAdded',
      fieldState: fieldState,
      value: value,
      min: 0,
      max: 20,
      onChanged: (newValue) {
        context.read<InspectionBloc>().add(
          UpdateFieldEvent('framesMoved.emptyAdded', newValue),
        );
      },
      onReset: () => context.read<InspectionBloc>().add(
        const ResetFieldEvent('framesMoved.emptyAdded'),
      ),
    );
  }
}
