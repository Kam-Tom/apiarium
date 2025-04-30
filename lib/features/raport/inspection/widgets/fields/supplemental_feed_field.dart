import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:apiarium/features/raport/inspection/bloc/inspection_bloc.dart';
import 'package:apiarium/features/raport/widgets/slider_input_field.dart';

class SupplementalFeedField extends StatelessWidget {
  const SupplementalFeedField({super.key});

  @override
  Widget build(BuildContext context) {
    final value = context.select((InspectionBloc bloc) => 
      bloc.state.getFieldValue<double>('stores.supplementalFeedAmount'));
    final fieldState = context.select((InspectionBloc bloc) => 
      bloc.state.getFieldState('stores.supplementalFeedAmount'));
      
    return SliderInputField(
      label: 'Feed Amount',
      icon: Icons.fastfood,
      fieldName: 'stores.supplementalFeedAmount',
      fieldState: fieldState,
      value: value ?? 0.0,
      min: -2.0,
      max: 2.0,
      divisions: 4,
      valueLabels: {
        -2.0: 'None',
        -1.0: 'Very Low',
        0.0: 'Low',
        1.0: 'Medium',
        2.0: 'High',
      },
      showBottomLabels: false,
      showAllLabels: true,
      onChanged: (newValue) {
        context.read<InspectionBloc>().add(
          UpdateFieldEvent('stores.supplementalFeedAmount', newValue),
        );
        
        // Map slider value to string value for API
        String amountLevel;
        if (newValue <= -1.5) {
          amountLevel = 'none';
        } else if (newValue <= -0.5) {
          amountLevel = 'very_low';
        } else if (newValue <= 0.5) {
          amountLevel = 'low';
        } else if (newValue <= 1.5) {
          amountLevel = 'medium';
        } else {
          amountLevel = 'high';
        }
        
        context.read<InspectionBloc>().add(
          UpdateFieldEvent('stores.supplementalFeedLevel', amountLevel),
        );
      },
      onReset: () => context.read<InspectionBloc>().add(
        const ResetFieldEvent('stores.supplementalFeedAmount'),
      ),
    );
  }
}
