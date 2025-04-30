import 'package:apiarium/features/raport/inspection/bloc/inspection_bloc.dart';
import 'package:apiarium/features/raport/inspection/widgets/fields/colony_activity_field.dart';
import 'package:apiarium/features/raport/inspection/widgets/fields/colony_strength_field.dart';
import 'package:apiarium/features/raport/inspection/widgets/fields/robbing_observed_field.dart';
import 'package:apiarium/features/raport/inspection/widgets/fields/temperament_field.dart';
import 'package:apiarium/features/raport/widgets/expandable_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ColonySection extends StatelessWidget {
  const ColonySection({super.key});

  static const List<String> fields = [
    'colony.strength', 
    'colony.activity', 
    'colony.temperament', 
    'colony.robbingObserved'
  ];

  @override
  Widget build(BuildContext context) {
    final isExpanded = context.select<InspectionBloc, bool>(
      (bloc) => bloc.state.expandedSections['colonySection'] ?? false,
    );
    final isActive = context.select<InspectionBloc, bool>(
      (bloc) => bloc.state.isCategoryActive(fields),
    );
    final filledCount = context.select<InspectionBloc, int>(
      (bloc) => bloc.state.countModifiedFieldsInCategory(fields),
    );

    return ExpandableSection(
      title: 'Colony Status',
      icon: Icons.groups,
      isExpanded: isExpanded,
      isActive: isActive,
      filledFieldsCount: filledCount,
      totalFieldsCount: fields.length,
      onToggle: () => context.read<InspectionBloc>().add(
        const ToggleSectionEvent('colonySection'),
      ),
      children: const [
        // Slider fields for measurements
        ColonyStrengthField(),
        SizedBox(height: 12),
        ColonyActivityField(),
        SizedBox(height: 12),
        TemperamentField(),
        SizedBox(height: 12),
        
        // Boolean field for observation
        RobbingObservedField(),
      ],
    );
  }
}
