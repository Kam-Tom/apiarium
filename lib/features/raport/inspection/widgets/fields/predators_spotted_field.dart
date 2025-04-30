import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:apiarium/features/raport/inspection/bloc/inspection_bloc.dart';
import 'package:apiarium/features/raport/widgets/multi_select_input_field.dart';

class PredatorsSpottedField extends StatelessWidget {
  const PredatorsSpottedField({super.key});

  @override
  Widget build(BuildContext context) {
    final values = context.select((InspectionBloc bloc) => 
      bloc.state.getFieldValue<List<String>>('pestsAndDiseases.predatorsSpotted') ?? []);
    final fieldState = context.select((InspectionBloc bloc) => 
      bloc.state.getFieldState('pestsAndDiseases.predatorsSpotted'));
    
    // List of common bee predators
    const options = [
      'none',
      'Birds',
      'Skunks',
      'Bears',
      'Wasps',
      'Hornets',
      'Spiders',
      'Other'
    ];
    
    return MultiSelectInputField(
      label: 'Predators Spotted',
      icon: Icons.warning_amber,
      fieldName: 'pestsAndDiseases.predatorsSpotted',
      fieldState: fieldState,
      values: values,
      options: options,
      onChanged: (newValues) {
        context.read<InspectionBloc>().add(
          UpdateFieldEvent('pestsAndDiseases.predatorsSpotted', newValues.join(',')),
        );
      },
      onReset: () => context.read<InspectionBloc>().add(
        const ResetFieldEvent('pestsAndDiseases.predatorsSpotted'),
      ),
      hintText: 'Select predators spotted',
    );
  }
}
