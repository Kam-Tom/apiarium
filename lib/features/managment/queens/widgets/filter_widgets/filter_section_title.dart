import 'package:flutter/material.dart';

class FilterSectionTitle extends StatelessWidget {
  final String title;

  const FilterSectionTitle({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Container(
            height: 1,
            color: Colors.grey.shade300,
            margin: const EdgeInsets.only(left: 8),
          ),
        ),
      ],
    );
  }
}
