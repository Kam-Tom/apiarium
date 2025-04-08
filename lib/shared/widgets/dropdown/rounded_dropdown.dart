import 'package:apiarium/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class RoundedDropdown<T> extends StatefulWidget {
  final T? value;
  final List<T> items;
  final ValueChanged<T?> onChanged;
  final double? maxHeight;
  /// A custom builder for dropdown items.
  final Widget Function(BuildContext context, T item, bool isSelected)? itemBuilder;
  /// A custom builder for the dropdown button display.
  final Widget Function(BuildContext context, T item)? buttonItemBuilder;
  /// Hint text to display when no item is selected or available
  final String? hintText;
  /// Minimum height for the dropdown button
  final double minHeight;

  const RoundedDropdown({
    super.key,
    required this.items,
    required this.onChanged,
    this.value,
    this.maxHeight,
    this.itemBuilder,
    this.buttonItemBuilder,
    this.hintText,
    this.minHeight = 48.0,
  });

  @override
  State<RoundedDropdown<T>> createState() => _RoundedDropdownState<T>();
}

class _RoundedDropdownState<T> extends State<RoundedDropdown<T>> {
  bool _menuOpen = false;

  @override
  Widget build(BuildContext context) {
    final bool isEmpty = widget.items.isEmpty;
    final String displayText = widget.hintText ?? (isEmpty ? 'No items available' : 'Select an item');

    return DropdownButton2<T>(
      value: widget.value,
      underline: const SizedBox.shrink(),
      items: isEmpty 
          ? [] 
          : widget.items.map((item) {
              final isSelected = item == widget.value;
              return DropdownMenuItem<T>(
                value: item,
                child: widget.itemBuilder != null
                    ? widget.itemBuilder!(context, item, isSelected)
                    : Text(
                        item.toString(),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: isSelected ? AppTheme.primaryColor : null),
                      ),
              );
            }).toList(),
      selectedItemBuilder: (BuildContext context) {
        if (isEmpty) {
          return [Container()]; // Placeholder for empty state
        }
        
        return widget.items.map((item) {
          return widget.buttonItemBuilder != null
              ? widget.buttonItemBuilder!(context, item)
              : Center(
                  child: Text(
                    item.toString(), 
                    style: Theme.of(context).textTheme.bodyLarge
                  ),
                );
        }).toList();
      },
      onChanged: isEmpty ? null : widget.onChanged,
      onMenuStateChange: (isOpen) {
        setState(() {
          _menuOpen = isOpen;
        });
      },
      hint: Container(
        alignment: Alignment.centerLeft,
        child: Text(
          displayText,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontStyle: isEmpty ? FontStyle.italic : FontStyle.normal,
          ),
        ),
      ),
      buttonStyleData: ButtonStyleData(
        width: double.infinity,
        height: widget.minHeight,
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 12),
        decoration: BoxDecoration(
          color: isEmpty ? Colors.grey.shade100 : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isEmpty 
                ? Colors.grey.shade400 
                : (_menuOpen ? AppTheme.primaryColor : Colors.grey.shade300),
            width: 2,
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
              color: Colors.grey.withAlpha(51), // Alpha 0.2 ~ 51
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
      isExpanded: true,
    );
  }
}