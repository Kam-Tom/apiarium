import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:apiarium/features/raport/inspection/bloc/inspection_bloc.dart';
import 'package:apiarium/features/raport/widgets/toggle_input_field.dart';

class BroodPatternField extends StatelessWidget {
  const BroodPatternField({super.key});

  @override
  Widget build(BuildContext context) {
    final value = context.select((InspectionBloc bloc) => 
      bloc.state.getFieldValue<String>('brood.broodPattern'));
    final fieldState = context.select((InspectionBloc bloc) => 
      bloc.state.getFieldState('brood.broodPattern'));
    
    return ToggleInputField<String>(
      label: 'Brood Pattern',
      icon: Icons.grid_3x3,
      fieldName: 'brood.broodPattern',
      fieldState: fieldState,
      value: value,
      options: const [
        ToggleOption(
          value: 'none', 
          label: 'None', 
          icon: Icons.block
        ),
        ToggleOption(
          value: 'irregular', 
          label: 'Irregular', 
          icon: Icons.scatter_plot
        ),
        ToggleOption(
          value: 'partial', 
          label: 'Partial', 
          icon: Icons.grid_view
        ),
        ToggleOption(
          value: 'uniform', 
          label: 'Uniform', 
          icon: Icons.grid_on
        ),
      ],
      onChanged: (newValue) {
        if (newValue != null) {
          context.read<InspectionBloc>().add(
            UpdateFieldEvent('brood.broodPattern', newValue),
          );
        }
      },
      onReset: () => context.read<InspectionBloc>().add(
        const ResetFieldEvent('brood.broodPattern'),
      ),
    );
  }
}
