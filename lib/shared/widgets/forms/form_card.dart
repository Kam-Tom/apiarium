import 'package:flutter/material.dart';

class FormCard extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Widget? iconWidget;
  final Widget child;
  final Color? iconColor;

  const FormCard({
    super.key,
    required this.title,
    this.icon,
    this.iconWidget,
    required this.child,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: (iconColor ?? Theme.of(context).primaryColor).withAlpha(26),
                    radius: 20,
                    child: iconWidget ??
                        (icon != null
                            ? Icon(
                                icon,
                                color: iconColor ?? Theme.of(context).primaryColor,
                                size: 24,
                              )
                            : null),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: iconColor ?? Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              child,
            ],
          ),
        ),
      ),
    );
  }
}
