import 'package:apiarium/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:easy_localization/easy_localization.dart';

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
  final bool translate;

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
    this.translate = false,
  });

  @override
  State<RoundedDropdown<T>> createState() => _RoundedDropdownState<T>();
}

class _RoundedDropdownState<T> extends State<RoundedDropdown<T>> {
  bool _menuOpen = false; 

  String _translateValue(BuildContext context, T? value) {
    if (!widget.translate) {
      if (value == null && (widget.hintText == 'any' || widget.hintText == 'none')) return widget.hintText!.tr();
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
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    final responsiveHeight = isSmallScreen ? 46.0 : widget.minHeight;


    return DropdownButton2<T>(
      value: widget.value,
      underline: const SizedBox.shrink(),      
      items: isEmpty 
          ? [] 
          : widget.items.map((item) {
              final isSelected = item == widget.value;
              return DropdownMenuItem<T>(
                value: item,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                  child:
                        widget.itemBuilder != null
                          ? widget.itemBuilder!(context, item, isSelected)
                          : Text(
                              _translateValue(context, item),
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: isSelected ? Theme.of(context).colorScheme.primary : null,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                ),
              );
            }).toList(),
      selectedItemBuilder: (BuildContext context) {
        if (isEmpty) return [Container()];
        return widget.items.map((item) {
          return widget.buttonItemBuilder != null
              ? widget.buttonItemBuilder!(context, item)
              : Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _translateValue(context, item),
                    style:  Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight:FontWeight.bold,
                  ),
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
      hint: Text(widget.hintText?.tr() ?? 'none'.tr(),
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: isEmpty ? Colors.grey.shade500 : null,
            fontSize: isSmallScreen ? 17 : 18,
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
            color: isEmpty 
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
          color: isEmpty ? Colors.grey.shade500 : null,
        ),
      ),
      isExpanded: true,
    );
  }
}