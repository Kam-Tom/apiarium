import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:apiarium/features/raport/inspection/bloc/inspection_bloc.dart';
import 'package:apiarium/features/raport/widgets/dropdown_input_field.dart';

class OdorField extends StatelessWidget {
  const OdorField({super.key});

  @override
  Widget build(BuildContext context) {
    final value = context.select((InspectionBloc bloc) => 
      bloc.state.getFieldValue<String>('hiveCondition.odor'));
    final fieldState = context.select((InspectionBloc bloc) => 
      bloc.state.getFieldState('hiveCondition.odor'));
    
    const options = ['normal', 'fermented', 'foul'];
    
    return DropdownInputField(
      label: 'Hive Odor',
      icon: Icons.air,
      fieldName: 'hiveCondition.odor',
      fieldState: fieldState,
      value: value,
      options: options,
      onChanged: (newValue) {
        context.read<InspectionBloc>().add(
          UpdateFieldEvent('hiveCondition.odor', newValue),
        );
      },
      onReset: () => context.read<InspectionBloc>().add(
        const ResetFieldEvent('hiveCondition.odor'),
      ),
      hintText: 'Select hive odor',
    );
  }
}
