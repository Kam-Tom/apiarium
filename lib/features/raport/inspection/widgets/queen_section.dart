import 'package:apiarium/features/raport/inspection/bloc/inspection_bloc.dart';
import 'package:apiarium/features/raport/inspection/widgets/fields/queen_behavior_field.dart';
import 'package:apiarium/features/raport/inspection/widgets/fields/queen_cells_field.dart';
import 'package:apiarium/features/raport/inspection/widgets/fields/queen_is_marked_field.dart';
import 'package:apiarium/features/raport/inspection/widgets/fields/queen_seen_field.dart';
import 'package:apiarium/features/raport/inspection/widgets/fields/swarming_signs_field.dart';
import 'package:apiarium/features/raport/widgets/expandable_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class QueenSection extends StatelessWidget {
  const QueenSection({super.key});

  static const List<String> fields = [
    'queen.seen', 
    'queen.isMarked',
    'queen.behavior', 
    'queen.queenCells', 
    'queen.swarmingSigns'
  ];

  @override
  Widget build(BuildContext context) {
    final isExpanded = context.select<InspectionBloc, bool>(
      (bloc) => bloc.state.expandedSections['queenSection'] ?? false,
    );
    final isActive = context.select<InspectionBloc, bool>(
      (bloc) => bloc.state.isCategoryActive(fields),
    );
    final filledCount = context.select<InspectionBloc, int>(
      (bloc) => bloc.state.countModifiedFieldsInCategory(fields),
    );

    return ExpandableSection(
      title: 'Queen Information',
      icon: Icons.query_builder,
      isExpanded: isExpanded,
      isActive: isActive,
      filledFieldsCount: filledCount,
      totalFieldsCount: fields.length,
      onToggle: () => context.read<InspectionBloc>().add(
        const ToggleSectionEvent('queenSection'),
      ),
      children: const [
        QueenSeenField(),
        SizedBox(height: 12),
        
        QueenIsMarkedField(),
        SizedBox(height: 12),
        
        QueenBehaviorField(),
        SizedBox(height: 12),
        QueenCellsField(),
        SizedBox(height: 12),
        
        SwarmingSignsField(),
      ],
    );
  }
}
