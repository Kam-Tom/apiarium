import 'package:apiarium/core/core.dart';
import 'package:apiarium/shared/shared.dart';
import 'package:flutter/material.dart';

class HiveTypeListItem extends StatelessWidget {
  final HiveType type;
  final bool isSelected;
  final VoidCallback onToggleStar;

  const HiveTypeListItem({
    required this.type,
    required this.isSelected,
    required this.onToggleStar,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        IconButton(
          icon: Icon(
            Icons.star,
            color: type.isStarred ? AppTheme.primaryColor : Colors.grey,
          ),
          onPressed: onToggleStar,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                type.name,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: isSelected ? AppTheme.primaryColor : null,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              if (type.manufacturer != null &&
                  type.manufacturer!.isEmpty == false)
                Text(
                  type.manufacturer!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color:
                        isSelected
                            ? AppTheme.primaryColor.withAlpha(128)
                            : Colors.grey,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
            ],
          ),
        ),
      ],
    );
  }
}