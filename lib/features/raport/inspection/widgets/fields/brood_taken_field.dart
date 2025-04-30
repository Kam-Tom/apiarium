import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:apiarium/features/raport/inspection/bloc/inspection_bloc.dart';
import 'package:apiarium/features/raport/widgets/number_input_field.dart';

class BroodTakenField extends StatelessWidget {
  const BroodTakenField({super.key});

  @override
  Widget build(BuildContext context) {
    final value = context.select((InspectionBloc bloc) => 
      bloc.state.getFieldValue<int>('framesMoved.broodTaken') ?? 0);
    final fieldState = context.select((InspectionBloc bloc) => 
      bloc.state.getFieldState('framesMoved.broodTaken'));
    
    return NumberInputField(
      label: 'Brood Frames Taken',
      icon: Icons.front_hand,
      fieldName: 'framesMoved.broodTaken',
      fieldState: fieldState,
      value: value,
      min: 0,
      max: 20,
      onChanged: (newValue) {
        context.read<InspectionBloc>().add(
          UpdateFieldEvent('framesMoved.broodTaken', newValue),
        );
      },
      onReset: () => context.read<InspectionBloc>().add(
        const ResetFieldEvent('framesMoved.broodTaken'),
      ),
    );
  }
}
