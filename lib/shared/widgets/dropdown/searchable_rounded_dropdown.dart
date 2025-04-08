import 'package:apiarium/core/theme/app_theme.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

/// A searchable, rounded dropdown widget.
class SearchableRoundedDropdown<T> extends StatefulWidget {
  /// The currently selected value.
  final T? value;

  /// The list of possible items.
  final List<T> items;

  /// Callback when an item is selected.
  final ValueChanged<T?> onChanged;

  /// A custom builder for dropdown items.
  final Widget Function(BuildContext context, T item, bool isSelected)? itemBuilder;
  
  /// A custom builder for the dropdown button display.
  final Widget Function(BuildContext context, T item)? buttonItemBuilder;

  /// Custom function to match search items
  final bool Function(DropdownMenuItem<T> item, String searchValue)? searchMatchFn;

  /// Maximum height of dropdown.
  final double? maxHeight;

  /// Minimum height for the dropdown button
  final double minHeight;

  /// Optional callback for adding a new item.
  final VoidCallback? onAddNewItem;

  /// Custom hint text for the search field.
  final String searchHintText;
  
  /// Hint text to display when no item is selected or available
  final String? hintText;
  
  /// Whether the dropdown has an error.
  final bool hasError;
  
  /// Error message to display.
  final String? errorText;

  const SearchableRoundedDropdown({
    super.key,
    required this.items,
    required this.onChanged,
    this.value,
    this.itemBuilder,
    this.buttonItemBuilder,
    this.searchMatchFn,
    this.maxHeight,
    this.minHeight = 48.0,
    this.onAddNewItem,
    this.searchHintText = 'Search for an item...',
    this.hintText,
    this.hasError = false,
    this.errorText,
  });

  @override
  State<SearchableRoundedDropdown<T>> createState() =>
      _SearchableRoundedDropdownState<T>();
}

class _SearchableRoundedDropdownState<T>
    extends State<SearchableRoundedDropdown<T>> {
  bool _isMenuOpen = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isEmpty = widget.items.isEmpty;
    final String displayText = widget.hintText ?? (isEmpty ? 'No items available' : 'Select an item');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButton2<T>(
          isExpanded: true,
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
                                  color: isSelected ? AppTheme.primaryColor : null,
                                ),
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
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    );
            }).toList();
          },
          onChanged: isEmpty ? null : widget.onChanged,
          onMenuStateChange: (isOpen) {
            setState(() {
              _isMenuOpen = isOpen;
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
                color: widget.hasError
                    ? Colors.red
                    : isEmpty
                        ? Colors.grey.shade400
                        : _isMenuOpen
                            ? AppTheme.primaryColor
                            : Colors.grey.shade300,
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
          dropdownSearchData: isEmpty ? null : DropdownSearchData(
            searchController: _searchController,
            searchInnerWidgetHeight: 60,
            searchInnerWidget: Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: widget.searchHintText,
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 12,
                        ),
                      ),
                    ),
                  ),
                  if (widget.onAddNewItem != null)
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: widget.onAddNewItem,
                    ),
                ],
              ),
            ),
            searchMatchFn: widget.searchMatchFn ?? (item, searchValue) {
              return item.value.toString().toLowerCase().contains(searchValue.toLowerCase());
            },
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
