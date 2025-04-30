import 'package:flutter/material.dart';
import 'package:apiarium/features/raport/widgets/base_input_field.dart';
import 'package:apiarium/features/raport/inspection/bloc/inspection_bloc.dart';

class SliderInputField extends BaseInputField {
  final double value;
  final double min;
  final double max;
  final int divisions;
  final Map<double, String>? valueLabels;
  final ValueChanged<double> onChanged;
  final bool showBottomLabels;
  final bool showAllLabels;

  const SliderInputField({
    Key? key,
    required String label,
    required IconData icon,
    required String fieldName,
    required FieldState fieldState,
    required VoidCallback onReset,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    this.valueLabels,
    required this.onChanged,
    this.showBottomLabels = false,
    this.showAllLabels = false,
  }) : super(
          key: key,
          label: label,
          icon: icon,
          fieldName: fieldName,
          fieldState: fieldState,
          onReset: onReset,
        );

  @override
  Widget build(BuildContext context) {
    // Get current value label if available
    final currentLabel = valueLabels != null ? 
        valueLabels![value] : value.round().toString();

    // Prepare value indicator for the header with different styling based on field state
    final valueIndicator = isActive
        ? Text(
            currentLabel ?? '',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: stateColor,
            ),
          )
        : null;

    // Get min and max labels
    final lowLabel = valueLabels != null ? 
        (valueLabels![min] ?? min.round().toString()) : 
        min.round().toString();
    
    final highLabel = valueLabels != null ? 
        (valueLabels![max] ?? max.round().toString()) : 
        max.round().toString();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with label and reset button
          buildHeader(valueIndicator: valueIndicator),
          
          // Custom slider layout with better label placement
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Show full labels above the slider
              Padding(
                padding: const EdgeInsets.only(top: 2, bottom: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      lowLabel,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      highLabel,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Slider with texts as tooltips
              SliderTheme(
                data: SliderThemeData(
                  trackHeight: 3,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                ),
                child: Slider(
                  value: value,
                  min: min,
                  max: max,
                  divisions: divisions,
                  label: currentLabel,
                  activeColor: stateColor.withOpacity(isOld ? 0.7 : 1.0),
                  inactiveColor: Colors.grey.shade200,
                  onChanged: onChanged,
                ),
              ),
              
              // Only show bottom labels if requested
              if (showBottomLabels && valueLabels != null)
                _buildBottomLabels(context),
            ],
          ),
        ],
      ),
    );
  }
  
  // Extract bottom labels to a separate method for clarity
  Widget _buildBottomLabels(BuildContext context) {
    // Select which labels to show
    final labelsToShow = <double, String>{};
    
    if (showAllLabels) {
      // Show all labels
      labelsToShow.addAll(valueLabels!);
    } else {
      // Show only key labels (min, middle, max, and current value)
      final middle = min + (max - min) / 2;
      labelsToShow[min] = valueLabels![min] ?? min.toString();
      
      // Add the middle value if it exists or is close to an existing key
      final middleKey = valueLabels!.keys.firstWhere(
        (k) => (k - middle).abs() < 0.1,
        orElse: () => middle,
      );
      if (valueLabels!.containsKey(middleKey)) {
        labelsToShow[middleKey] = valueLabels![middleKey]!;
      }
      
      labelsToShow[max] = valueLabels![max] ?? max.toString();
      
      // Include current value if it's different from min/middle/max
      if (value != min && value != middleKey && value != max && 
          valueLabels!.containsKey(value)) {
        labelsToShow[value] = valueLabels![value]!;
      }
    }
    
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Always include the minimum label, left-aligned
          Text(
            valueLabels![min] ?? '',
            style: TextStyle(
              color: value == min ? stateColor : Colors.grey.shade500,
              fontSize: 10,
              fontWeight: value == min ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          
          // Spacer
          const Spacer(),
          
          // Current value indicator (if not at min/max)
          if (value != min && value != max && valueLabels!.containsKey(value))
            Text(
              valueLabels![value] ?? '',
              style: TextStyle(
                color: stateColor,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
            
          // Spacer
          const Spacer(),
          
          // Always include the maximum label, right-aligned
          Text(
            valueLabels![max] ?? '',
            style: TextStyle(
              color: value == max ? stateColor : Colors.grey.shade500,
              fontSize: 10,
              fontWeight: value == max ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
