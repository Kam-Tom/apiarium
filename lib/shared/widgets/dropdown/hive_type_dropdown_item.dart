import 'package:flutter/material.dart';
import 'package:apiarium/shared/domain/models/hive_type.dart';

class HiveTypeDropdownItem extends StatelessWidget {
  final HiveType hiveType;
  final bool isSelected;
  final bool colorizeSelected;

  const HiveTypeDropdownItem({
    super.key,
    required this.hiveType,
    this.isSelected = false,
    this.colorizeSelected = true,
  });

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyLarge?.copyWith(
      color: isSelected && colorizeSelected ? Theme.of(context).colorScheme.primary : null,
      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
    );

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 44, maxHeight: 56),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.star,
            color: hiveType.isStarred ? Colors.amber : Colors.grey[400],
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hiveType.name,
                  style: style,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                if (hiveType.manufacturer != null && hiveType.manufacturer!.isNotEmpty)
                  Text(
                    hiveType.manufacturer!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                      fontSize: (Theme.of(context).textTheme.bodySmall?.fontSize ?? 12) - 1,
                      fontStyle: FontStyle.italic,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
