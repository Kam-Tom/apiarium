import 'package:apiarium/features/raport/inspection/widgets/fields/fields.dart';
import 'package:apiarium/features/raport/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:apiarium/features/raport/inspection/bloc/inspection_bloc.dart';

class QuickInspectionSection extends StatelessWidget {
  const QuickInspectionSection({super.key});

  static const List<String> fields = [
    'queen.seen', 'brood.eggs', 'colony.strength', 
    'brood.present', 'stores.honey', 'colony.temperament', 
    'colony.robbingObserved'
  ];

  @override
  Widget build(BuildContext context) {
    final isExpanded = context.select<InspectionBloc, bool>(
      (bloc) => bloc.state.expandedSections['quickInspection'] ?? true,
    );
    final isActive = context.select<InspectionBloc, bool>(
      (bloc) => bloc.state.isCategoryActive(fields),
    );
    final filledCount = context.select<InspectionBloc, int>(
      (bloc) => bloc.state.countModifiedFieldsInCategory(fields),
    );

    return ExpandableSection(
      title: 'Quick Inspection',
      icon: Icons.bolt,
      isExpanded: isExpanded,
      isActive: isActive,
      filledFieldsCount: filledCount,
      totalFieldsCount: fields.length,
      onToggle: () => context.read<InspectionBloc>().add(
        const ToggleSectionEvent('quickInspection'),
      ),
      children: [
        CheckboxInputRow(
          children: [
            const QueenSeenField(compact: true),
            const EggsSeenField(compact: true),
          ],
        ),
        
        CheckboxInputRow(
          children: [
            const BroodPresentField(compact: true),
            const RobbingObservedField(compact: true),
          ],
        ),
        
        const SizedBox(height: 8),
        ColonyStrengthField(),
        const SizedBox(height: 12),
        HoneyStoresField(),
        const SizedBox(height: 12),
        TemperamentField(),
      ],
    );
  }
}


