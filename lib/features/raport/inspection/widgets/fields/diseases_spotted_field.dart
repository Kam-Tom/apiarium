import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:apiarium/features/raport/inspection/bloc/inspection_bloc.dart';
import 'package:apiarium/features/raport/widgets/multi_select_input_field.dart';

class DiseasesSpottedField extends StatelessWidget {
  const DiseasesSpottedField({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the raw field value and handle potential type issues
    final values = context.select((InspectionBloc bloc) => 
      bloc.state.getFieldValue<List<String>>('pestsAndDiseases.diseasesSpotted'));
    
    final fieldState = context.select((InspectionBloc bloc) => 
      bloc.state.getFieldState('pestsAndDiseases.diseasesSpotted'));
    
    // List of common bee diseases
    const options = [
      'none',
      'American foulbrood',
      'European foulbrood',
      'Chalkbrood',
      'Sacbrood',
      'Nosema',
      'Deformed wing virus',
      'Black queen cell virus',
      'Other'
    ];
    
    return MultiSelectInputField(
      label: 'Diseases Spotted',
      icon: Icons.healing,
      fieldName: 'pestsAndDiseases.diseasesSpotted',
      fieldState: fieldState,
      values: values,
      options: options,
      onChanged: (newValues) {
        context.read<InspectionBloc>().add(
          UpdateFieldEvent('pestsAndDiseases.diseasesSpotted', newValues.join(',')),
        );
      },
      onReset: () => context.read<InspectionBloc>().add(
        const ResetFieldEvent('pestsAndDiseases.diseasesSpotted'),
      ),
      hintText: 'Select diseases spotted',
    );
  }
}
