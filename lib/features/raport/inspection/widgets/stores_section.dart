import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:apiarium/features/raport/inspection/bloc/inspection_bloc.dart';
import 'package:apiarium/features/raport/widgets/expandable_section.dart';
import 'package:apiarium/features/raport/inspection/widgets/fields/honey_stores_field.dart';
import 'package:apiarium/features/raport/inspection/widgets/fields/pollen_stores_field.dart';
import 'package:apiarium/features/raport/inspection/widgets/fields/supplemental_feed_field.dart';
import 'package:apiarium/features/raport/inspection/widgets/fields/supplemental_feed_type_field.dart';

class StoresSection extends StatelessWidget {
  const StoresSection({super.key});

  static const List<String> fields = [
    'stores.honey',
    'stores.pollen',
    'stores.supplementalFeedType',
    'stores.supplementalFeedAmount',
  ];

  @override
  Widget build(BuildContext context) {
    final isExpanded = context.select<InspectionBloc, bool>(
      (bloc) => bloc.state.expandedSections['storesSection'] ?? false,
    );
    final isActive = context.select<InspectionBloc, bool>(
      (bloc) => bloc.state.isCategoryActive(fields),
    );
    final filledCount = context.select<InspectionBloc, int>(
      (bloc) => bloc.state.countModifiedFieldsInCategory(fields),
    );

    return ExpandableSection(
      title: 'Food Stores',
      icon: Icons.restaurant,
      isExpanded: isExpanded,
      isActive: isActive,
      filledFieldsCount: filledCount,
      totalFieldsCount: fields.length,
      onToggle: () => context.read<InspectionBloc>().add(
        const ToggleSectionEvent('storesSection'),
      ),
      children: const [
        HoneyStoresField(),
        SizedBox(height: 12),
        PollenStoresField(),
        SizedBox(height: 16),
        SupplementalFeedTypeField(),
        SizedBox(height: 12),
        SupplementalFeedField(),
      ],
    );
  }
}
