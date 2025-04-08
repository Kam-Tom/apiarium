import 'package:apiarium/core/core.dart';
import 'package:apiarium/shared/shared.dart';
import 'package:flutter/material.dart';

class QueenBreedListItem extends StatefulWidget {
  final QueenBreed breed;
  final bool isSelected;
  final VoidCallback onToggleStar;

  const QueenBreedListItem({
    required this.breed,
    required this.isSelected,
    required this.onToggleStar,
    super.key,
  });

  @override
  State<QueenBreedListItem> createState() => _QueenBreedListItemState();
}

class _QueenBreedListItemState extends State<QueenBreedListItem> {
  late bool _isStarred;

  @override
  void initState() {
    super.initState();
    _isStarred = widget.breed.isStarred;
  }

  @override
  void didUpdateWidget(QueenBreedListItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.breed.isStarred != widget.breed.isStarred) {
      _isStarred = widget.breed.isStarred;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton(
          icon: Icon(
            Icons.star,
            color: _isStarred ? AppTheme.primaryColor : Colors.grey,
          ),
          onPressed: () {
            setState(() {
              _isStarred = !_isStarred;
            });
            widget.onToggleStar();
          },
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.breed.name,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: widget.isSelected ? AppTheme.primaryColor : null,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              if (widget.breed.scientificName != null &&
                  widget.breed.scientificName!.isEmpty == false)
                Text(
                  widget.breed.scientificName!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color:
                        widget.isSelected
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
