import 'package:flutter/material.dart';

class MenuItem {
  final IconData icon;
  final String labelKey;
  final String route;

  const MenuItem({
    required this.icon,
    required this.labelKey,
    required this.route,
  });
}

const List<MenuItem> homeMenuItems = [
  MenuItem(icon: Icons.home, labelKey: 'home.menu.apiary', route: '/apiary'),
  MenuItem(icon: Icons.bar_chart, labelKey: 'home.menu.statistics', route: '/statistics'),
  MenuItem(icon: Icons.mic, labelKey: 'home.menu.voice_control', route: '/voice-control'),
  MenuItem(icon: Icons.inventory, labelKey: 'home.menu.storage', route: '/storage'),
  MenuItem(icon: Icons.calendar_today, labelKey: 'home.menu.calendar', route: '/calendar'),
  MenuItem(icon: Icons.history, labelKey: 'home.menu.history', route: '/history'),
];
