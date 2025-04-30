import 'package:flutter/material.dart';
import 'package:apiarium/features/raport/widgets/base_input_field.dart';
import 'package:apiarium/features/raport/inspection/bloc/inspection_bloc.dart';

class ToggleOption<T> {
  final T value;
  final String label;
  final IconData? icon;

  const ToggleOption({
    required this.value,
    required this.label,
    this.icon,
  });
}

class ToggleInputField<T> extends BaseInputField {
  final T? value;
  final List<ToggleOption<T>> options;
  final ValueChanged<T?> onChanged;
  final bool useVerticalLayout;
  final bool showIcons;

  const ToggleInputField({
    Key? key,
    required String label,
    required IconData icon,
    required String fieldName,
    required FieldState fieldState,
    required VoidCallback onReset,
    required this.value,
    required this.options,
    required this.onChanged,
    this.useVerticalLayout = false,
    this.showIcons = true,
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
    // Get current label if value is set
    final currentOption = value != null 
        ? options.firstWhere(
            (option) => option.value == value,
            orElse: () => ToggleOption<T>(
              value: value as T, 
              label: 'Unknown'
            ),
          )
        : null;
    
    // Prepare value indicator for the header
    final valueIndicator = isActive && currentOption != null
        ? Text(
            currentOption.label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: stateColor,
            ),
          )
        : null;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with label and reset button
          buildHeader(valueIndicator: valueIndicator),
          
          // Toggle buttons
          Container(
            margin: const EdgeInsets.only(top: 8, bottom: 4),
            child: useVerticalLayout
                ? _buildVerticalToggle()
                : _buildHorizontalToggle(context),
          ),
        ],
      ),
    );
  }
  
  Widget _buildHorizontalToggle(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final spacing = 8.0;
        final buttonWidth = (constraints.maxWidth - 
                        (options.length - 1) * spacing) / options.length;
        
        return Wrap(
          spacing: spacing,
          alignment: WrapAlignment.spaceEvenly,
          children: options.map((option) => 
            _buildToggleButton(option, buttonWidth: buttonWidth)
          ).toList(),
        );
      }
    );
  }
  
  Widget _buildVerticalToggle() {
    return Column(
      children: options.map((option) => 
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: _buildToggleButton(option, fullWidth: true),
        )
      ).toList(),
    );
  }
  
  Widget _buildToggleButton(ToggleOption<T> option, {double? buttonWidth, bool fullWidth = false}) {
    // Consider selected if set, old, or saved
    final isSelected = (isSet || isOld || isSaved) && value != null && value == option.value;

    // Use stateColor for selected, fallback to gray for unselected
    final backgroundColor = isSelected
        ? stateColor.withOpacity(isOld ? 0.15 : isSaved ? 0.18 : 0.10)
        : Colors.grey.shade50;
    
    final borderColor = isSelected
        ? stateColor
        : Colors.grey.shade300;
        
    final textColor = isSelected
        ? stateColor
        : Colors.grey.shade700;
    final iconColor = isSelected
        ? stateColor
        : Colors.grey.shade600;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onChanged(option.value),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: fullWidth ? double.infinity : buttonWidth,
          height: showIcons && option.icon != null ? 70 : 48,
          padding: const EdgeInsets.symmetric(
            vertical: 8, 
            horizontal: 4,
          ),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: borderColor,
              width: 1.5,
            ),
          ),
          child: Center(
            child: showIcons && option.icon != null 
                ? _buildButtonWithIcon(option, textColor, iconColor, isSelected)
                : _buildButtonTextOnly(option, textColor, isSelected),
          ),
        ),
      ),
    );
  }
  
  Widget _buildButtonWithIcon(ToggleOption<T> option, Color textColor, Color iconColor, bool isSelected) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          option.icon,
          color: iconColor,
          size: 18,
        ),
        const SizedBox(height: 4),
        Text(
          option.label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected 
                ? FontWeight.bold 
                : FontWeight.normal,
            color: textColor,
          ),
        ),
      ],
    );
  }
  
  Widget _buildButtonTextOnly(ToggleOption<T> option, Color textColor, bool isSelected) {
    return Text(
      option.label,
      textAlign: TextAlign.center,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 12,
        fontWeight: isSelected 
            ? FontWeight.bold 
            : FontWeight.normal,
        color: textColor,
      ),
    );
  }
}
