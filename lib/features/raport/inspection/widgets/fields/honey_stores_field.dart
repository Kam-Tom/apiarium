import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:apiarium/features/raport/inspection/bloc/inspection_bloc.dart';
import 'package:apiarium/features/raport/widgets/slider_input_field.dart';

class HoneyStoresField extends StatelessWidget {
  const HoneyStoresField({super.key});

  @override
  Widget build(BuildContext context) {
    final value = context.select((InspectionBloc bloc) => 
      bloc.state.getFieldValue<double>('stores.honey'));
    final fieldState = context.select((InspectionBloc bloc) => 
      bloc.state.getFieldState('stores.honey'));
        
    return SliderInputField(
      label: 'Honey Stores',
      icon: Icons.local_dining,
      fieldName: 'stores.honey',
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
          UpdateFieldEvent('stores.honey', newValue),
        );
        
        String honeyLevel;
        if (newValue <= -1.5) {
          honeyLevel = 'low';
        } else if (newValue <= 0.5) {
          honeyLevel = 'medium';
        } else {
          honeyLevel = 'high';
        }
        
        context.read<InspectionBloc>().add(
          UpdateFieldEvent('stores.honeyLevel', honeyLevel),
        );
      },
      onReset: () => context.read<InspectionBloc>().add(
        const ResetFieldEvent('stores.honey'),
      ),
    );
  }
}
