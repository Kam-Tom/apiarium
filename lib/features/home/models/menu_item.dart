import 'package:flutter/material.dart';

class MenuItem {
  final IconData icon;
  final String label;

  const MenuItem({
    required this.icon,
    required this.label,
  });
}

class HomeMenuItems {
  static const List<MenuItem> items = [
    MenuItem(icon: Icons.home, label: 'Apiary'),
    MenuItem(icon: Icons.bar_chart, label: 'Statistics'),
    MenuItem(icon: Icons.mic, label: 'Voice Control'),
    MenuItem(icon: Icons.book, label: 'Magazine'),
    MenuItem(icon: Icons.calendar_today, label: 'Calendar'),
    MenuItem(icon: Icons.history, label: 'History'),
  ];
}
