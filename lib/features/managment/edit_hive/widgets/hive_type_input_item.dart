import 'package:apiarium/core/core.dart';
import 'package:apiarium/shared/shared.dart';
import 'package:flutter/material.dart';

class HiveTypeInputItem extends StatelessWidget {
  final HiveType type;

  const HiveTypeInputItem({
    required this.type,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Icon(
          Icons.star,
          color: type.isStarred ? AppTheme.primaryColor : Colors.grey,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                type.name,
                style: Theme.of(context).textTheme.bodyLarge,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              if (type.manufacturer != null &&
                  type.manufacturer!.isEmpty == false)
                Text(
                  type.manufacturer!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
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
