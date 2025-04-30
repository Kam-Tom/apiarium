import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:apiarium/features/raport/inspection/bloc/inspection_bloc.dart';
import 'package:apiarium/features/raport/widgets/expandable_section.dart';
import 'package:apiarium/features/raport/inspection/widgets/fields/diseases_spotted_field.dart';
import 'package:apiarium/features/raport/inspection/widgets/fields/pests_spotted_field.dart';
import 'package:apiarium/features/raport/inspection/widgets/fields/predators_spotted_field.dart';
import 'package:apiarium/features/raport/inspection/widgets/fields/varroa_drop_field.dart';

class PestsDiseasesSection extends StatelessWidget {
  const PestsDiseasesSection({super.key});

  static const List<String> fields = [
    'pestsAndDiseases.diseasesSpotted',
    'pestsAndDiseases.pestsSpotted',
    'pestsAndDiseases.predatorsSpotted',
    'pestsAndDiseases.varroaDropObserved',
  ];

  @override
  Widget build(BuildContext context) {
    final isExpanded = context.select<InspectionBloc, bool>(
      (bloc) => bloc.state.expandedSections['pestsDiseasesSection'] ?? false,
    );
    final isActive = context.select<InspectionBloc, bool>(
      (bloc) => bloc.state.isCategoryActive(fields),
    );
    final filledCount = context.select<InspectionBloc, int>(
      (bloc) => bloc.state.countModifiedFieldsInCategory(fields),
    );

    return ExpandableSection(
      title: 'Pests & Diseases',
      icon: Icons.bug_report,
      isExpanded: isExpanded,
      isActive: isActive,
      filledFieldsCount: filledCount,
      totalFieldsCount: fields.length,
      onToggle: () => context.read<InspectionBloc>().add(
        const ToggleSectionEvent('pestsDiseasesSection'),
      ),
      children: const [
        DiseasesSpottedField(),
        SizedBox(height: 12),
        PestsSpottedField(),
        SizedBox(height: 12),
        PredatorsSpottedField(),
        SizedBox(height: 12),
        VarroaDropField(),
      ],
    );
  }
}
