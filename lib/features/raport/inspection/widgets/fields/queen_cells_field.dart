import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:apiarium/features/raport/inspection/bloc/inspection_bloc.dart';
import 'package:apiarium/features/raport/widgets/toggle_input_field.dart';

class QueenCellsField extends StatelessWidget {
  const QueenCellsField({super.key});

  @override
  Widget build(BuildContext context) {
    final value = context.select((InspectionBloc bloc) => 
      bloc.state.getFieldValue<String>('queen.queenCells'));
    final fieldState = context.select((InspectionBloc bloc) => 
      bloc.state.getFieldState('queen.queenCells'));
    
    return ToggleInputField<String>(
      label: 'Queen Cells',
      icon: Icons.cell_tower,
      fieldName: 'queen.queenCells',
      fieldState: fieldState,
      value: value,
      options: const [
        ToggleOption(
          value: 'none', 
          label: 'None', 
          icon: Icons.do_not_disturb
        ),
        ToggleOption(
          value: 'swarm', 
          label: 'Swarm', 
          icon: Icons.groups
        ),
        ToggleOption(
          value: 'emergency', 
          label: 'Emergency', 
          icon: Icons.warning
        ),
        ToggleOption(
          value: 'supersedure', 
          label: 'Supersedure', 
          icon: Icons.change_circle
        ),
      ],
      onChanged: (newValue) {
        if (newValue != null) {
          context.read<InspectionBloc>().add(
            UpdateFieldEvent('queen.queenCells', newValue),
          );
        }
      },
      onReset: () => context.read<InspectionBloc>().add(
        const ResetFieldEvent('queen.queenCells'),
      ),
    );
  }
}
