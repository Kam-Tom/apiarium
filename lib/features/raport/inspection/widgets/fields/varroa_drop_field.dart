import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:apiarium/features/raport/inspection/bloc/inspection_bloc.dart';
import 'package:apiarium/features/raport/widgets/number_input_field.dart';

class VarroaDropField extends StatelessWidget {
  const VarroaDropField({super.key});

  @override
  Widget build(BuildContext context) {
    final value = context.select((InspectionBloc bloc) => 
      bloc.state.getFieldValue<int>('pestsAndDiseases.varroaDropObserved') ?? 0);
    final fieldState = context.select((InspectionBloc bloc) => 
      bloc.state.getFieldState('pestsAndDiseases.varroaDropObserved'));
    
    return NumberInputField(
      label: 'Varroa Drop Count',
      icon: Icons.bug_report,
      fieldName: 'pestsAndDiseases.varroaDropObserved',
      fieldState: fieldState,
      value: value,
      min: 0,
      max: 50,
      onChanged: (newValue) {
        context.read<InspectionBloc>().add(
          UpdateFieldEvent('pestsAndDiseases.varroaDropObserved', newValue),
        );
      },
      onReset: () => context.read<InspectionBloc>().add(
        const ResetFieldEvent('pestsAndDiseases.varroaDropObserved'),
      ),
    );
  }
}
