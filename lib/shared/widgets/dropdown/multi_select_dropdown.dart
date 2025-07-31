import 'package:apiarium/core/theme/app_theme.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

class MultiSelectDropdown<T> extends StatefulWidget {
  final List<T> items;
  final List<T> selectedItems;
  final ValueChanged<List<T>> onChanged;
  final String Function(T item) itemLabelBuilder;
  final String? hintText;
  final double maxHeight;
  final double minHeight;

  const MultiSelectDropdown({
    super.key,
    required this.items,
    required this.selectedItems,
    required this.onChanged,
    required this.itemLabelBuilder,
    this.hintText,
    this.maxHeight = 200.0,
    this.minHeight = 48.0,
  });

  @override
  State<MultiSelectDropdown<T>> createState() => _MultiSelectDropdownState<T>();
}

class _MultiSelectDropdownState<T> extends State<MultiSelectDropdown<T>> {
  bool _menuOpen = false;

  List<T> get _availableItems {
    return widget.items.where((item) => !widget.selectedItems.contains(item)).toList();
  }

  void _selectItem(T item) {
    final updatedItems = List<T>.from(widget.selectedItems)..add(item);
    widget.onChanged(updatedItems);
  }

  void _removeItem(T item) {
    final updatedItems = List<T>.from(widget.selectedItems)..remove(item);
    widget.onChanged(updatedItems);
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Selected items as chips
        if (widget.selectedItems.isNotEmpty) ...[
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: widget.selectedItems.map((item) {
              return Chip(
                label: Text(
                  widget.itemLabelBuilder(item),
                  style: TextStyle(
                    fontSize: isSmallScreen ? 12 : 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onDeleted: () => _removeItem(item),
                deleteIconColor: Colors.grey.shade600,
                backgroundColor: Colors.grey.shade100,
                side: BorderSide(color: Colors.grey.shade300, width: 0.5),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 6 : 8,
                  vertical: isSmallScreen ? 2 : 4,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
        ],
        // Dropdown for available items
        DropdownButton2<T>(
          value: null,
          underline: const SizedBox.shrink(),
          items: _availableItems.isEmpty
              ? []
              : _availableItems.map((item) {
                  return DropdownMenuItem<T>(
                    value: item,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                      child: Text(
                        widget.itemLabelBuilder(item),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  );
                }).toList(),
          onChanged: _availableItems.isEmpty 
              ? null 
              : (T? value) {
                  if (value != null) {
                    _selectItem(value);
                  }
                },
          onMenuStateChange: (isOpen) {
            setState(() {
              _menuOpen = isOpen;
            });
          },
          hint: Text(
            widget.hintText ?? 'Select items...',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: _availableItems.isEmpty ? Colors.grey.shade500 : Colors.grey.shade700,
              fontSize: isSmallScreen ? 14 : 16,
            ),
          ),
          buttonStyleData: ButtonStyleData(
            width: double.infinity,
            height: widget.minHeight,
            padding: EdgeInsets.symmetric(
              vertical: 2,
              horizontal: isSmallScreen ? 10 : 12,
            ),
            decoration: BoxDecoration(
              color: _availableItems.isEmpty ? Colors.grey.shade100 : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _availableItems.isEmpty
                    ? Colors.grey.shade400
                    : (_menuOpen ? AppTheme.primaryColor : Colors.grey.shade300),
                width: _menuOpen ? 2 : 1,
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
              color: _availableItems.isEmpty ? Colors.grey.shade500 : null,
            ),
          ),
          isExpanded: true,
        ),
      ],
    );
  }
}
