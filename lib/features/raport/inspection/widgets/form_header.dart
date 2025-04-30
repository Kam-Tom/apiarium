import 'package:apiarium/features/raport/inspection/bloc/inspection_bloc.dart';
import 'package:apiarium/shared/domain/models/queen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FormHeader extends StatelessWidget {
  const FormHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedHive = context.select<InspectionBloc, dynamic>(
      (bloc) => bloc.state.selectedHive,
    );
    
    final modifiedFieldsCount = context.select<InspectionBloc, int>(
      (bloc) => bloc.state.fields.length,
    );
    
    final hasModifiedFields = context.select<InspectionBloc, bool>(
      (bloc) => bloc.state.fields.isNotEmpty,
    );

    // Get queen information from the hive
    final queen = selectedHive?.queen;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with hive name and date
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Inspection for ${selectedHive?.name ?? ""}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber.shade800,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            Text(
              DateTime.now().toString().substring(0, 10),
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // Queen information with visual marking
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildQueenMarking(queen),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildQueenInfo(queen),
                  if (queen != null)
                    Text(
                      queen.breed.name,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // Fields filled indicator
        Row(
          children: [
            Icon(
              Icons.check_circle_outline,
              color: Colors.green.shade600,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              'Fields filled: $modifiedFieldsCount',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: hasModifiedFields
                  ? () => context.read<InspectionBloc>().add(ResetAllFieldsEvent())
                  : null,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Reset All',
                style: TextStyle(
                  fontSize: 12,
                  color: hasModifiedFields
                      ? Colors.red.shade700
                      : Colors.grey.shade400,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildQueenMarking(Queen? queen) {
    final size = 40.0; // Smaller than in the queen card
    
    if (queen == null) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.grey.shade400,
            width: 1.5,
          ),
        ),
        child: const Center(
          child: Icon(Icons.help_outline, color: Colors.white, size: 24),
        ),
      );
    }
    
    // Use gray for unmarked queens, regardless of markColor
    final circleColor = queen.marked ? (queen.markColor ?? Colors.grey.shade300) : Colors.grey.shade300;
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: circleColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.grey.shade400,
          width: 1.5,
        ),
      ),
      child: Center(
        child: queen.marked
          ? const Icon(Icons.check, color: Colors.white, size: 24)
          : const Icon(Icons.question_mark, color: Colors.white, size: 24),
      ),
    );
  }
  
  Widget _buildQueenInfo(Queen? queen) {
    if (queen == null) {
      return const Text(
        'No queen information',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      );
    }
    
    // Calculate queen age more precisely in years and months
    final now = DateTime.now();
    final ageInDays = now.difference(queen.birthDate).inDays;
    final ageInMonths = ageInDays / 30.44; // average days per month
    final ageInYears = ageInMonths / 12.0;
    
    // Format to one decimal place
    final formattedAge = ageInYears.toStringAsFixed(1);
    
    // Build age display with warning color for old queens
    final isOldQueen = ageInYears > 2;
    
    return Row(
      children: [
        Text(
          '$formattedAge y',
          style: TextStyle(
            fontSize: 18, // Larger font for age
            fontWeight: FontWeight.bold,
            color: isOldQueen ? Colors.red : Colors.grey.shade800,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          'old',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
  
  // Helper method to convert color to a readable string
  String _colorToReadableString(Color color) {
    // Standard mark colors
    if (color.value == Colors.white.value) return 'white';
    if (color.value == Colors.yellow.value) return 'yellow';
    if (color.value == Colors.red.value) return 'red';
    if (color.value == Colors.green.value) return 'green';
    if (color.value == Colors.blue.value) return 'blue';
    
    // Default to hex code
    return '#${color.value.toRadixString(16).substring(2, 8)}';
  }
}
