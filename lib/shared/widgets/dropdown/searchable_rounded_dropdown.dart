import 'package:apiarium/core/theme/app_theme.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class SearchableRoundedDropdown<T> extends StatefulWidget {
  final T? value;
  final List<T> items;
  final ValueChanged<T?> onChanged;
  final Widget Function(BuildContext context, T item, bool isSelected)? itemBuilder;
  final Widget Function(BuildContext context, T item)? buttonItemBuilder;
  final bool Function(DropdownMenuItem<T> item, String searchValue)? searchMatchFn;
  final double? maxHeight;
  final double minHeight;
  final VoidCallback? onAddNewItem;
  final String searchHintText;
  final String? hintText;
  final bool hasError;
  final String? errorText;
  final bool translate;

  const SearchableRoundedDropdown({
    super.key,
    required this.items,
    required this.onChanged,
    this.value,
    this.itemBuilder,
    this.buttonItemBuilder,
    this.searchMatchFn,
    this.maxHeight = 300.0,
    this.minHeight = 48.0,
    this.onAddNewItem,
    this.searchHintText = 'Search for an item...',
    this.hintText,
    this.hasError = false,
    this.errorText,
    this.translate = false,
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
    final isEmpty = widget.items.isEmpty;
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

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
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                      child: 
                          widget.itemBuilder != null
                            ? widget.itemBuilder!(context, item, isSelected)
                            : Text(
                                _translateValue(context, item),
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: isSelected ? AppTheme.primaryColor : null,
                                    ),
                            ),
                    ),
                  );
                }).toList(),
          selectedItemBuilder: (BuildContext context) {
            if (isEmpty) return [Container()];
            return widget.items.map((item) {
              return widget.buttonItemBuilder != null
                  ? SizedBox(
                      height: widget.minHeight,
                      child: widget.buttonItemBuilder!(context, item),
                    )
                  : Container(
                      alignment: Alignment.centerLeft,
                      height: widget.minHeight,
                      child: Text(
                        _translateValue(context, item),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontSize: isSmallScreen ? 14 : 16,
                          fontWeight: FontWeight.w600,
                        ),
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
          hint: Text(widget.hintText?.tr() ?? 'none'.tr(),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: isEmpty ? Colors.grey.shade500 : null,
                    fontSize: isSmallScreen ? 17 : 18,
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
            maxHeight: widget.maxHeight ?? 300.0, // Ensure we always have a max height
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
          dropdownSearchData: isEmpty
              ? null
              : DropdownSearchData(
                  searchController: _searchController,
                  searchInnerWidgetHeight: isSmallScreen ? 50 : 60,
                  searchInnerWidget: Container(
                    height: isSmallScreen ? 50 : 60,
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 6 : 8,
                      vertical: isSmallScreen ? 6 : 8,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: widget.searchHintText,
                              hintStyle: TextStyle(fontSize: isSmallScreen ? 14 : 16),
                              prefixIcon: const Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                vertical: isSmallScreen ? 8 : 10,
                                horizontal: isSmallScreen ? 10 : 12,
                              ),
                            ),
                            style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
                          ),
                        ),
                        if (widget.onAddNewItem != null)
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: widget.onAddNewItem,
                            iconSize: isSmallScreen ? 20 : 24,
                          ),
                      ],
                    ),
                  ),
                  searchMatchFn: widget.searchMatchFn ??
                      (item, searchValue) {
                        return item.value
                            .toString()
                            .toLowerCase()
                            .contains(searchValue.toLowerCase());
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