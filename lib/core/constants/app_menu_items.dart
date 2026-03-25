import 'package:flutter/material.dart';

class MenuItem {
  final String title;
  final IconData icon;
  final String route;

  const MenuItem({
    required this.title,
    required this.icon,
    required this.route,
  });
}

class AppMenuItems {
  static const List<MenuItem> mainItems = [
    MenuItem(title: 'Forest', icon: Icons.forest, route: '/'),
    MenuItem(title: 'Focus Challenge', icon: Icons.emoji_events, route: '/challenge'),
    MenuItem(title: 'Timeline', icon: Icons.timeline, route: '/timeline'),
    MenuItem(title: 'Statistics', icon: Icons.bar_chart, route: '/statistics'),
    MenuItem(title: 'Ambient Sounds', icon: Icons.music_note, route: '/sounds'),
    MenuItem(title: 'Tags', icon: Icons.label, route: '/tags'),
  ];

  static const List<MenuItem> socialItems = [
    MenuItem(title: 'Friends', icon: Icons.people, route: '/friends'),
    MenuItem(title: 'Achievements', icon: Icons.military_tech, route: '/achievements'),
  ];

  static const List<MenuItem> shopItems = [
    MenuItem(title: 'Store', icon: Icons.shopping_bag, route: '/store'),
    MenuItem(title: 'Premium', icon: Icons.star, route: '/premium'),
  ];

  static const List<MenuItem> otherItems = [
    MenuItem(title: 'Settings', icon: Icons.settings, route: '/settings'),
  ];
}
