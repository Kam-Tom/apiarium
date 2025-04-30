import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:apiarium/features/raport/inspection/bloc/inspection_bloc.dart';
import 'package:apiarium/features/raport/widgets/dropdown_input_field.dart';

class EquipmentStatusField extends StatelessWidget {
  const EquipmentStatusField({super.key});

  @override
  Widget build(BuildContext context) {
    final value = context.select((InspectionBloc bloc) => 
      bloc.state.getFieldValue<String>('hiveCondition.equipmentStatus'));
    final fieldState = context.select((InspectionBloc bloc) => 
      bloc.state.getFieldState('hiveCondition.equipmentStatus'));
    
    const options = ['damaged', 'fair', 'good'];
    
    return DropdownInputField(
      label: 'Equipment Status',
      icon: Icons.handyman,
      fieldName: 'hiveCondition.equipmentStatus',
      fieldState: fieldState,
      value: value,
      options: options,
      onChanged: (newValue) {
        context.read<InspectionBloc>().add(
          UpdateFieldEvent('hiveCondition.equipmentStatus', newValue),
        );
      },
      onReset: () => context.read<InspectionBloc>().add(
        const ResetFieldEvent('hiveCondition.equipmentStatus'),
      ),
      hintText: 'Select equipment status',
    );
  }
}
