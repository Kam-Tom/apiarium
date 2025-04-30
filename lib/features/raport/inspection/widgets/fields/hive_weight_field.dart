import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:apiarium/features/raport/inspection/bloc/inspection_bloc.dart';
import 'package:apiarium/features/raport/widgets/number_input_field.dart';

class HiveWeightField extends StatelessWidget {
  const HiveWeightField({super.key});

  @override
  Widget build(BuildContext context) {
    final value = context.select<InspectionBloc, int?>(
      (bloc) => bloc.state.getFieldValue<double>('weight.hiveWeightKg')?.round(),
    );
    final fieldState = context.select<InspectionBloc, FieldState>(
      (bloc) => bloc.state.getFieldState('weight.hiveWeightKg'),
    );

    return NumberInputField(
      label: 'Hive Weight',
      icon: Icons.scale,
      fieldName: 'weight.hiveWeightKg',
      fieldState: fieldState,
      value: value,
      min: 0,
      max: 200,
      suffix: 'kg',
      onChanged: (newValue) {
        if (newValue == null) {
          context.read<InspectionBloc>().add(
            const ResetFieldEvent('weight.hiveWeightKg'),
          );
        } else {
          context.read<InspectionBloc>().add(
            UpdateFieldEvent('weight.hiveWeightKg', newValue),
          );
        }
      },
      onReset: () => context.read<InspectionBloc>().add(
        const ResetFieldEvent('weight.hiveWeightKg'),
      ),
    );
  }
}
