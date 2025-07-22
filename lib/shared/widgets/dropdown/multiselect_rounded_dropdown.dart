import 'package:apiarium/core/theme/app_theme.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// A multiselect rounded dropdown widget that allows selection of multiple items.
class MultiselectRoundedDropdown<T> extends StatefulWidget {
  /// The list of currently selected values.
  final List<T> selectedValues;

  /// The list of possible items.
  final List<T> items;

  /// Callback when the selection changes.
  final ValueChanged<List<T>> onChanged;

  /// A custom builder for dropdown items.
  final Widget Function(BuildContext context, T item, bool isSelected)? itemBuilder;
  
  /// A custom builder for the dropdown button display.
  final Widget Function(BuildContext context, List<T> selectedItems)? buttonItemBuilder;

  /// Maximum height of dropdown.
  final double? maxHeight;

  /// Minimum height for the dropdown button.
  final double minHeight;

  /// Hint text to display when no item is selected or available.
  final String? hintText;
  
  /// Whether the dropdown has an error.
  final bool hasError;
  
  /// Error message to display.
  final String? errorText;

  /// Separator used when joining multiple selected items in display.
  final String separator;

  /// Flag to indicate if the values should be translated.
  final bool translate;

  const MultiselectRoundedDropdown({
    super.key,
    required this.items,
    required this.onChanged,
    required this.selectedValues,
    this.itemBuilder,
    this.buttonItemBuilder,
    this.maxHeight,
    this.minHeight = 48.0,
    this.hintText,
    this.hasError = false,
    this.errorText,
    this.separator = ', ',
    this.translate = false,
  });

  @override
  State<MultiselectRoundedDropdown<T>> createState() => _MultiselectRoundedDropdownState<T>();
}

class _MultiselectRoundedDropdownState<T> extends State<MultiselectRoundedDropdown<T>> {
  bool _isMenuOpen = false;

  String _translateValue(BuildContext context, T? value) {
    if (!widget.translate) {
      if (value == null && widget.hintText != null) return widget.hintText!;
      if (value == null) return '';
      return value.toString();
    }
    if (value == null && widget.hintText != null) return widget.hintText!.tr();
    if (value is Enum) {
      final type = value as Enum;
      return type.name.tr();
    }

    return 'common.${value.toString()}'.tr();
  }

  @override
  Widget build(BuildContext context) {
    final bool isEmpty = widget.items.isEmpty;
    final String displayText = widget.hintText ?? (isEmpty ? 'No items available' : 'Select items');
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    final responsiveHeight = isSmallScreen ? 46.0 : widget.minHeight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButton2<T>(
          isExpanded: true,
          value: widget.selectedValues.isEmpty ? null : widget.selectedValues.last,
          underline: const SizedBox.shrink(),
          items: isEmpty
              ? []
              : widget.items.map((item) {
                  return DropdownMenuItem<T>(
                    value: item,
                    enabled: false, // Disable default onTap to avoid closing menu
                    child: StatefulBuilder(
                      builder: (context, menuSetState) {
                        final isItemSelected = widget.selectedValues.contains(item);
                        
                        return InkWell(
                          onTap: () {
                            List<T> newSelection = List<T>.from(widget.selectedValues);
                            
                            if (isItemSelected) {
                              newSelection.remove(item);
                            } else if (!newSelection.contains(item)) {
                              newSelection.add(item);
                            }
                            
                            widget.onChanged(newSelection);
                            menuSetState(() {});
                          },
                          child: Container(
                            height: double.infinity,
                            padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 6.0 : 8.0),
                            child: widget.itemBuilder != null
                                ? widget.itemBuilder!(context, item, isItemSelected)
                                : Row(
                                    children: [
                                      Icon(
                                        isItemSelected
                                            ? Icons.check_box_outlined
                                            : Icons.check_box_outline_blank,
                                        color: isItemSelected ? AppTheme.primaryColor : null,
                                        size: isSmallScreen ? 20 : 24,
                                      ),
                                      SizedBox(width: isSmallScreen ? 6 : 8),
                                      Expanded(
                                        child: Text(
                                          _translateValue(context, item),
                                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                                color: isItemSelected ? AppTheme.primaryColor : null,
                                                fontSize: isSmallScreen ? 14 : 16,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        );
                      },
                    ),
                  );
                }).toList(),
          selectedItemBuilder: (BuildContext context) {
            if (isEmpty) {
              return [Container()];
            }
            
            return widget.items.map((_) {
              return widget.buttonItemBuilder != null
                  ? widget.buttonItemBuilder!(context, widget.selectedValues)
                  : Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        widget.selectedValues.isEmpty
                            ? displayText
                            : widget.selectedValues.map((e) => _translateValue(context, e)).join(widget.separator),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontSize: isSmallScreen ? 14 : 16,
                          fontWeight: widget.selectedValues.isNotEmpty ? FontWeight.w600 : FontWeight.normal,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
            }).toList();
          },
          onChanged: isEmpty ? null : (_) {}, // No-op because selection is handled in items
          onMenuStateChange: (isOpen) {
            setState(() {
              _isMenuOpen = isOpen;
            });
          },
          hint: Container(
            alignment: Alignment.centerLeft,
            child: Text(
              _translateValue(context, null),
              style: TextStyle(
                color: Colors.grey.shade600,
                fontStyle: isEmpty ? FontStyle.italic : FontStyle.normal,
                fontSize: isSmallScreen ? 14 : 16,
              ),
            ),
          ),
          buttonStyleData: ButtonStyleData(
            width: double.infinity,
            height: responsiveHeight,
            padding: EdgeInsets.symmetric(
              vertical: 2, 
              horizontal: isSmallScreen ? 10 : 12,
            ),
            decoration: BoxDecoration(
              color: isEmpty ? Colors.grey.shade100 : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: widget.hasError
                    ? Colors.red
                    : isEmpty
                        ? Colors.grey.shade400
                        : _isMenuOpen
                            ? AppTheme.primaryColor
                            : Colors.grey.shade300,
                width: _isMenuOpen ? 2 : 1,
              ),
            ),
          ),
          dropdownStyleData: DropdownStyleData(
            maxHeight: widget.maxHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey.shade50,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withAlpha(51),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            openInterval: const Interval(0.0, 0.5),
          ),
          iconStyleData: IconStyleData(
            icon: Icon(
              Icons.arrow_drop_down,
              color: isEmpty ? Colors.grey.shade500 : null,
            ),
          ),
          menuItemStyleData: MenuItemStyleData(
            height: isSmallScreen ? 36 : 40,
            padding: EdgeInsets.zero,
          ),
        ),
        if (widget.hasError && widget.errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 6.0, left: 12.0),
            child: Text(
              widget.errorText!,
              style: TextStyle(
                color: Colors.red.shade700,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
}