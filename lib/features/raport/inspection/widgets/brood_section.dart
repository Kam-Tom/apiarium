import 'package:apiarium/features/raport/inspection/bloc/inspection_bloc.dart';
import 'package:apiarium/features/raport/inspection/widgets/fields/brood_pattern_field.dart';
import 'package:apiarium/features/raport/inspection/widgets/fields/brood_population_field.dart';
import 'package:apiarium/features/raport/inspection/widgets/fields/capped_brood_field.dart';
import 'package:apiarium/features/raport/inspection/widgets/fields/eggs_seen_field.dart';
import 'package:apiarium/features/raport/inspection/widgets/fields/excess_drones_field.dart';
import 'package:apiarium/features/raport/inspection/widgets/fields/larvae_seen_field.dart';
import 'package:apiarium/features/raport/widgets/expandable_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BroodSection extends StatelessWidget {
  const BroodSection({super.key});

  static const List<String> fields = [
    'brood.eggs', 
    'brood.larvae', 
    'brood.capped', 
    'brood.broodPattern', 
    'brood.excessDrones',
    'brood.population',
  ];

  @override
  Widget build(BuildContext context) {
    final isExpanded = context.select<InspectionBloc, bool>(
      (bloc) => bloc.state.expandedSections['broodSection'] ?? false,
    );
    final isActive = context.select<InspectionBloc, bool>(
      (bloc) => bloc.state.isCategoryActive(fields),
    );
    final filledCount = context.select<InspectionBloc, int>(
      (bloc) => bloc.state.countModifiedFieldsInCategory(fields),
    );

    return ExpandableSection(
      title: 'Brood Status',
      icon: Icons.child_care,
      isExpanded: isExpanded,
      isActive: isActive,
      filledFieldsCount: filledCount,
      totalFieldsCount: fields.length,
      onToggle: () => context.read<InspectionBloc>().add(
        const ToggleSectionEvent('broodSection'),
      ),
      children: const [
        
        EggsSeenField(),
        SizedBox(height: 12),
        
        LarvaeSeenField(),
        SizedBox(height: 12),
        
        CappedBroodField(),
        SizedBox(height: 12),
        
        ExcessDronesField(),
        SizedBox(height: 12),
        
        // Slider fields
        BroodPatternField(),
        SizedBox(height: 12),
        
        BroodPopulationField(),
      ],
    );
  }
}
