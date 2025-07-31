import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../shared/widgets/dropdown/searchable_rounded_dropdown.dart';
import '../../../shared/utils/countries.dart';

class CountryDropdown extends StatelessWidget {
  final String? value;
  final ValueChanged<String?> onChanged;
  final bool hasError;
  final String? errorText;

  const CountryDropdown({
    super.key,
    required this.value,
    required this.onChanged,
    this.hasError = false,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return SearchableRoundedDropdown<String>(
      value: value,
      items: Countries.list.map((c) => c.code).toList(),
      onChanged: onChanged,
      hintText: 'auth.common.select_country'.tr(),
      searchHintText: 'auth.common.search_countries'.tr(),
      hasError: hasError,
      errorText: errorText,
      searchMatchFn: (item, searchValue) {
        final country = Countries.byCode(item.value ?? 'USA');
        return country.name.toLowerCase().contains(searchValue.toLowerCase()) || 
               country.code.toLowerCase().contains(searchValue.toLowerCase());
      },
      itemBuilder: (context, item, isSelected) {
        final country = Countries.byCode(item);
        
        return Row(
          children: [
            Text(
              country.flag,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(width: 12),
            Text(
              country.code,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isSelected ? Theme.of(context).primaryColor : null,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                country.name,
                style: TextStyle(
                  color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
            ),
            Text(
              Countries.getCurrencySymbol(country.currency),
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade500,
                fontSize: 12,
              ),
            ),
          ],
        );
      },
      buttonItemBuilder: (context, item) {
        final country = Countries.byCode(item);
        
        return Row(
          children: [
            Text(
              country.flag,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(width: 12),
            Text(
              country.code,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                country.name,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
            ),
            Text(
              Countries.getCurrencySymbol(country.currency),
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade500,
                fontSize: 12,
              ),
            ),
          ],
        );
      },
    );
  }
}
