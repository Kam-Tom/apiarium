import 'package:flutter/material.dart';
import 'package:apiarium/features/raport/widgets/base_input_field.dart';

class CheckboxInputRow extends StatelessWidget {
  final List<Widget> children;
  final double spacing;

  const CheckboxInputRow({
    super.key,
    required this.children,
    this.spacing = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(children.length * 2 - 1, (index) {
          // Add spacing between items
          if (index.isOdd) {
            return SizedBox(width: spacing);
          }
          // Add the actual child
          final childIndex = index ~/ 2;
          return Expanded(child: children[childIndex]);
        }),
      ),
    );
  }
}
