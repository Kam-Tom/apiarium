import 'package:apiarium/features/raport/inspection/bloc/inspection_bloc.dart';
import 'package:apiarium/features/raport/inspection/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class InspectionView extends StatelessWidget {
  const InspectionView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<InspectionBloc, InspectionState>(
      listenWhen: (previous, current) => 
          previous.errorMessage != current.errorMessage ||
          previous.isSubmissionSuccess != current.isSubmissionSuccess,
      listener: (context, state) {
        // Show snackbar on error
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }
        
        // Show success message
        if (state.isSubmissionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Inspection report saved successfully!')),
          );
        }
      },
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        return Container(
          color: Colors.grey.shade100,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top section: Apiary and hive selector
                  const ApiarySelectorBar(),
                  
                  const SizedBox(height: 16.0),
                  Divider(color: Colors.grey.shade300, height: 1),
                  const SizedBox(height: 16.0),
                  
                  // Main content: Either form or empty state
                  state.selectedHiveId == null
                      ? const EmptyState()
                      : _buildInspectionForm(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInspectionForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        // Header with title and stats
        FormHeader(),
        
        SizedBox(height: 16),
        
        // Quick inspection section (always first)
        QuickInspectionSection(),
        SizedBox(height: 16),
        
        // Detailed sections
        ColonySection(),
        SizedBox(height: 16),
        
        QueenSection(),
        SizedBox(height: 16),
        
        BroodSection(),
        SizedBox(height: 16),
        
        FramesSection(),
        SizedBox(height: 16),
        
        StoresSection(),
        SizedBox(height: 16),

        PestsDiseasesSection(),
        SizedBox(height: 16),

        HiveConditionSection(),
        SizedBox(height: 16),

        FramesMovedSection(),
        SizedBox(height: 16),

        WeightSection(),
        SizedBox(height: 16),

        WeatherSection(),
        SizedBox(height: 16),

        AdditionalActionsSection(),
        SizedBox(height: 16),

        NotesSection(),
        SizedBox(height: 24),
        
      ],
    );
  }
}
