import 'package:apiarium/features/raport/inspection/bloc/inspection_bloc.dart';
import 'package:apiarium/features/raport/inspection/widgets/fields/equipment_status_field.dart';
import 'package:apiarium/features/raport/inspection/widgets/fields/odor_field.dart';
import 'package:apiarium/features/raport/inspection/widgets/fields/brace_comb_field.dart';
import 'package:apiarium/features/raport/inspection/widgets/fields/excessive_propolis_field.dart';
import 'package:apiarium/features/raport/inspection/widgets/fields/dead_bees_visible_field.dart';
import 'package:apiarium/features/raport/inspection/widgets/fields/moisture_field.dart';
import 'package:apiarium/features/raport/inspection/widgets/fields/mold_field.dart';
import 'package:apiarium/features/raport/widgets/expandable_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HiveConditionSection extends StatelessWidget {
  const HiveConditionSection({super.key});

  static const List<String> fields = [
    'hiveCondition.equipmentStatus', 
    'hiveCondition.odor', 
    'hiveCondition.braceComb',
    'hiveCondition.excessivePropolis',
    'hiveCondition.deadBeesVisible',
    'hiveCondition.moisture',
    'hiveCondition.mold'
  ];

  @override
  Widget build(BuildContext context) {
    final isExpanded = context.select<InspectionBloc, bool>(
      (bloc) => bloc.state.expandedSections['hiveConditionSection'] ?? false,
    );
    final isActive = context.select<InspectionBloc, bool>(
      (bloc) => bloc.state.isCategoryActive(fields),
    );
    final filledCount = context.select<InspectionBloc, int>(
      (bloc) => bloc.state.countModifiedFieldsInCategory(fields),
    );

    return ExpandableSection(
      title: 'Hive Condition',
      icon: Icons.home,
      isExpanded: isExpanded,
      isActive: isActive,
      filledFieldsCount: filledCount,
      totalFieldsCount: fields.length,
      onToggle: () => context.read<InspectionBloc>().add(
        const ToggleSectionEvent('hiveConditionSection'),
      ),
      children: const [
        EquipmentStatusField(),
        SizedBox(height: 12),
        OdorField(),
        SizedBox(height: 12),
        BraceCombField(),
        SizedBox(height: 12),
        ExcessivePropolisField(),
        SizedBox(height: 12),
        DeadBeesVisibleField(),
        SizedBox(height: 12),
        MoistureField(),
        SizedBox(height: 12),
        MoldField(),
      ],
    );
  }
}
