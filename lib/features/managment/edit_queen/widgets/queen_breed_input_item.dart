import 'package:apiarium/core/core.dart';
import 'package:apiarium/shared/shared.dart';
import 'package:flutter/material.dart';

class QueenBreedInputItem extends StatelessWidget {
  final QueenBreed breed;

  const QueenBreedInputItem({
    required this.breed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.star,
          color: breed.isStarred ? AppTheme.primaryColor : Colors.grey,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                breed.name, 
                style: Theme.of(context).textTheme.bodyLarge,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              if (breed.scientificName != null &&
                  breed.scientificName?.isEmpty == false)
                Text(
                  breed.scientificName!,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey),
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
