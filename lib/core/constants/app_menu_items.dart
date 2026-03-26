import 'package:flutter/material.dart';

class MenuItem {
  final String title;
  final IconData icon;
  final String route;
  final bool isEnabled;
  final String? supportingLabel;

  const MenuItem({
    required this.title,
    required this.icon,
    required this.route,
    this.isEnabled = true,
    this.supportingLabel,
  });
}

class AppMenuItems {
  static const List<MenuItem> mainItems = [
    MenuItem(title: 'Forest', icon: Icons.forest, route: '/'),
    MenuItem(
      title: 'Deep Focus',
      icon: Icons.center_focus_strong_rounded,
      route: '/deep-focus',
    ),
    MenuItem(title: 'Timeline', icon: Icons.timeline, route: '/timeline'),
    MenuItem(title: 'Statistics', icon: Icons.bar_chart, route: '/statistics'),
    MenuItem(
      title: 'Ambient Sounds',
      icon: Icons.music_note,
      route: '/sounds',
    ),
    MenuItem(
      title: 'Tags',
      icon: Icons.label,
      route: '/tags',
      isEnabled: false,
      supportingLabel: 'Later',
    ),
  ];

  static const List<MenuItem> socialItems = [
    MenuItem(
      title: 'Friends',
      icon: Icons.people,
      route: '/friends',
      isEnabled: false,
      supportingLabel: 'Later',
    ),
    MenuItem(title: 'Achievements', icon: Icons.military_tech, route: '/achievements'),
  ];

  static const List<MenuItem> shopItems = [
    MenuItem(
      title: 'Store',
      icon: Icons.shopping_bag,
      route: '/store',
      isEnabled: false,
      supportingLabel: 'Later',
    ),
    MenuItem(title: 'Premium', icon: Icons.star, route: '/premium'),
  ];

  static const List<MenuItem> otherItems = [
    MenuItem(title: 'Settings', icon: Icons.settings, route: '/settings'),
  ];
}
