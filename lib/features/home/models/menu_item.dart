import 'package:apiarium/core/core.dart';
import 'package:flutter/material.dart';

class MenuItem {
  final IconData icon;
  final String label;
  final String route;

  const MenuItem({
    required this.icon,
    required this.label,
    required this.route,
  });
}

class HomeMenuItems {
  static const List<MenuItem> items = [
    MenuItem(icon: Icons.home, label: 'Apiary', route: AppRouter.managment),
    // MenuItem(icon: Icons.bar_chart, label: 'Statistics', route: AppRouter.statistics),
    // MenuItem(icon: Icons.mic, label: 'Voice Control', route: AppRouter.voiceControl),
    // MenuItem(icon: Icons.book, label: 'Storage', route: AppRouter.storage),
    // MenuItem(icon: Icons.calendar_today, label: 'Calendar', route: AppRouter.calendar),
    // MenuItem(icon: Icons.history, label: 'History', route: AppRouter.history),
  ];
}
