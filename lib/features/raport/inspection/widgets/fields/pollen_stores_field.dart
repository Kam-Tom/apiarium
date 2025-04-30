import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:apiarium/features/raport/inspection/bloc/inspection_bloc.dart';
import 'package:apiarium/features/raport/widgets/slider_input_field.dart';

class PollenStoresField extends StatelessWidget {
  const PollenStoresField({super.key});

  @override
  Widget build(BuildContext context) {
    final value = context.select((InspectionBloc bloc) => 
      bloc.state.getFieldValue<double>('stores.pollen'));
    final fieldState = context.select((InspectionBloc bloc) => 
      bloc.state.getFieldState('stores.pollen'));
        
    return SliderInputField(
      label: 'Pollen Stores',
      icon: Icons.grain,
      fieldName: 'stores.pollen',
      fieldState: fieldState,
      value: value ?? 0.0,
      min: -2.0,
      max: 2.0,
      divisions: 4,
      valueLabels: {
        -2.0: 'Very Low',
        -1.0: 'Low',
        0.0: 'Adequate',
        1.0: 'High',
        2.0: 'Very High',
      },
      showBottomLabels: false,
      showAllLabels: true,
      onChanged: (newValue) {
        context.read<InspectionBloc>().add(
          UpdateFieldEvent('stores.pollen', newValue),
        );
        
        String pollenLevel;
        if (newValue <= -1.5) {
          pollenLevel = 'low';
        } else if (newValue <= 0.5) {
          pollenLevel = 'medium';
        } else {
          pollenLevel = 'high';
        }
        
        context.read<InspectionBloc>().add(
          UpdateFieldEvent('stores.pollenLevel', pollenLevel),
        );
      },
      onReset: () => context.read<InspectionBloc>().add(
        const ResetFieldEvent('stores.pollen'),
      ),
    );
  }
}
