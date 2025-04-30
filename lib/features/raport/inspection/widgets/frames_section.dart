
import 'package:apiarium/features/raport/inspection/inspection.dart';
import 'package:apiarium/features/raport/inspection/widgets/fields/brood_frames_field.dart';
import 'package:apiarium/features/raport/inspection/widgets/fields/covered_by_bees_field.dart';
import 'package:apiarium/features/raport/inspection/widgets/fields/empty_frames_field.dart';
import 'package:apiarium/features/raport/inspection/widgets/fields/honey_frames_field.dart';
import 'package:apiarium/features/raport/inspection/widgets/fields/pollen_frames_field.dart';
import 'package:apiarium/features/raport/inspection/widgets/fields/total_frames_field.dart';
import 'package:apiarium/features/raport/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FramesSection extends StatelessWidget {
  const FramesSection({super.key});

  static const List<String> fields = [
    'frames.coveredByBees', 
    'frames.broodFrames', 
    'frames.honeyFrames', 
    'frames.pollenFrames',
    'frames.emptyFrames',
  ];

  @override
  Widget build(BuildContext context) {
    final isExpanded = context.select<InspectionBloc, bool>(
      (bloc) => bloc.state.expandedSections['framesSection'] ?? false,
    );
    final isActive = context.select<InspectionBloc, bool>(
      (bloc) => bloc.state.isCategoryActive(fields),
    );
    final filledCount = context.select<InspectionBloc, int>(
      (bloc) => bloc.state.countModifiedFieldsInCategory(fields),
    );

    return ExpandableSection(
      title: 'Frames Status',
      icon: Icons.grid_view_rounded,
      isExpanded: isExpanded,
      isActive: isActive,
      filledFieldsCount: filledCount,
      totalFieldsCount: fields.length,
      onToggle: () => context.read<InspectionBloc>().add(
        const ToggleSectionEvent('framesSection'),
      ),
      headerExtra: const TotalFramesField(),
      children: [
        const SizedBox(height: 16),
        
        // Individual frame fields
        const CoveredByBeesField(),
        const SizedBox(height: 12),
        
        const BroodFramesField(),
        const SizedBox(height: 12),
        
        const HoneyFramesField(),
        const SizedBox(height: 12),
        
        const PollenFramesField(),
        const SizedBox(height: 12),
        
        const EmptyFramesField(),
      ],
    );
  }
}
