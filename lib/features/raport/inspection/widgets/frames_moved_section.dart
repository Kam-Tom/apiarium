import 'package:apiarium/features/raport/inspection/bloc/inspection_bloc.dart';
import 'package:apiarium/features/raport/inspection/widgets/fields/brood_box_count_field.dart';
import 'package:apiarium/features/raport/inspection/widgets/fields/empty_brood_frames_net_field.dart';
import 'package:apiarium/features/raport/inspection/widgets/fields/honey_super_box_count_field.dart';
import 'package:apiarium/features/raport/inspection/widgets/fields/brood_frames_net_field.dart';
import 'package:apiarium/features/raport/inspection/widgets/fields/honey_frames_net_field.dart';
import 'package:apiarium/features/raport/inspection/widgets/fields/empty_frames_net_field.dart';
import 'package:apiarium/features/raport/inspection/widgets/fields/total_frames_label.dart';
import 'package:apiarium/features/raport/inspection/widgets/fields/total_brood_frames_label.dart';
import 'package:apiarium/features/raport/widgets/expandable_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FramesMovedSection extends StatelessWidget {
  const FramesMovedSection({super.key});

  static const List<String> fields = [
    'framesMoved.broodNet', 
    'framesMoved.honeyNet', 
    'framesMoved.emptyNet',
  ];

  @override
  Widget build(BuildContext context) {
    final isExpanded = context.select<InspectionBloc, bool>(
      (bloc) => bloc.state.expandedSections['framesMovedSection'] ?? false,
    );
    final isActive = context.select<InspectionBloc, bool>(
      (bloc) => bloc.state.isCategoryActive(fields),
    );
    final filledCount = context.select<InspectionBloc, int>(
      (bloc) => bloc.state.countModifiedFieldsInCategory(fields),
    );

    return ExpandableSection(
      title: 'Frames Moved',
      icon: Icons.swap_horiz,
      isExpanded: isExpanded,
      isActive: isActive,
      filledFieldsCount: filledCount,
      totalFieldsCount: fields.length,
      onToggle: () => context.read<InspectionBloc>().add(
        const ToggleSectionEvent('framesMovedSection'),
      ),
      children: const [
        TotalFramesLabel(),
        SizedBox(height: 12),
        
        HoneySuperBoxNetCountField(),
        SizedBox(height: 12),

        HoneyFramesNetCountField(),
        SizedBox(height: 12),

        EmptyFramesNetCountField(),
        SizedBox(height: 12),

        TotalBroodFramesLabel(),
        SizedBox(height: 12),

        BroodBoxNetCountField(),
        SizedBox(height: 12),

        HoneyBroodFramesNetField(),
        SizedBox(height: 12),

        EmptyBroodFramesNetField(),
      ],
    );
  }
}
