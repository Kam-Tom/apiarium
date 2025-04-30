import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:apiarium/features/raport/inspection/bloc/inspection_bloc.dart';
import 'package:apiarium/features/raport/widgets/multi_select_input_field.dart';

class PestsSpottedField extends StatelessWidget {
  const PestsSpottedField({super.key});

  @override
  Widget build(BuildContext context) {
    final values = context.select((InspectionBloc bloc) => 
      bloc.state.getFieldValue<List<String>>('pestsAndDiseases.pestsSpotted') ?? []);
    final fieldState = context.select((InspectionBloc bloc) => 
      bloc.state.getFieldState('pestsAndDiseases.pestsSpotted'));
    
    // List of common bee pests
    const options = [
      'none',
      'Varroa mites',
      'Wax moths',
      'Small hive beetles',
      'Tropilaelaps mites',
      'Tracheal mites',
      'Ants',
      'Other'
    ];
    
    return MultiSelectInputField(
      label: 'Pests Spotted',
      icon: Icons.pest_control,
      fieldName: 'pestsAndDiseases.pestsSpotted',
      fieldState: fieldState,
      values: values,
      options: options,
      onChanged: (newValues) {
        context.read<InspectionBloc>().add(
          UpdateFieldEvent('pestsAndDiseases.pestsSpotted', newValues.join(',')),
        );
      },
      onReset: () => context.read<InspectionBloc>().add(
        const ResetFieldEvent('pestsAndDiseases.pestsSpotted'),
      ),
      hintText: 'Select pests spotted',
    );
  }
}
