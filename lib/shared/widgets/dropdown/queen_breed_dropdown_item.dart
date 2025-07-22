import 'package:flutter/material.dart';
import 'package:apiarium/shared/domain/models/queen_breed.dart';

class QueenBreedDropdownItem extends StatelessWidget {
  final QueenBreed breed;
  final bool isSelected;
  final bool showScientificName;
  final TextStyle? style;
  final bool colorizeSelected;

  const QueenBreedDropdownItem({
    super.key,
    required this.breed,
    this.isSelected = false,
    this.showScientificName = true,
    this.colorizeSelected = true,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    var defaultStyle = Theme.of(context).textTheme.bodyLarge?.copyWith(
      color: isSelected && colorizeSelected ? Theme.of(context).colorScheme.primary : null,
      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
    );
    if(breed.name.length > 15 && screenWidth < 600) {
      defaultStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: isSelected && colorizeSelected ? Theme.of(context).colorScheme.primary : null,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      );
    }
    final textStyle = style ?? defaultStyle;

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 44, maxHeight: 56),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.star,
            color: breed.isStarred ? Colors.amber : Colors.grey[400],
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  breed.name,
                  style: textStyle,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                if (showScientificName && breed.scientificName != null && breed.scientificName!.isNotEmpty)
                  Text(
                    breed.scientificName!,
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
