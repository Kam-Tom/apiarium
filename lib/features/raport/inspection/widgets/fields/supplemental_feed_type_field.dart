import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:apiarium/features/raport/inspection/bloc/inspection_bloc.dart';
import 'package:apiarium/features/raport/widgets/dropdown_input_field.dart';

class SupplementalFeedTypeField extends StatelessWidget {
  const SupplementalFeedTypeField({super.key});

  @override
  Widget build(BuildContext context) {
    final value = context.select((InspectionBloc bloc) => 
      bloc.state.getFieldValue<String>('stores.supplementalFeedType'));
    final fieldState = context.select((InspectionBloc bloc) => 
      bloc.state.getFieldState('stores.supplementalFeedType'));
    
    const options = ['none', 'candy', 'syrup', 'fondant', 'mixed'];
    
    return DropdownInputField(
      label: 'Feed Type',
      icon: Icons.category,
      fieldName: 'stores.supplementalFeedType',
      fieldState: fieldState,
      value: value,
      options: options,
      onChanged: (newValue) {
        if (newValue != null) {
          context.read<InspectionBloc>().add(
            UpdateFieldEvent('stores.supplementalFeedType', newValue),
          );
        }
      },
      onReset: () => context.read<InspectionBloc>().add(
        const ResetFieldEvent('stores.supplementalFeedType'),
      ),
      hintText: 'Select feed type',
      itemBuilder: (context, item, isSelected) {
        return Text(
          _getDisplayText(item),
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected 
                ? (fieldState == FieldState.old ? Colors.indigo.shade300 : Colors.amber.shade800) 
                : Colors.black,
          ),
        );
      },
    );
  }

  String _getDisplayText(String value) {
    switch (value) {
      case 'none': return 'None - No supplemental feed';
      case 'candy': return 'Candy - Sugar candy provided';
      case 'syrup': return 'Syrup - Sugar syrup provided';
      case 'fondant': return 'Fondant - Sugar fondant provided';
      case 'mixed': return 'Mixed - Multiple types of feed';
      default: return value;
    }
  }
}
