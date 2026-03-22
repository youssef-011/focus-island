import 'package:flutter/material.dart';
import '../models/leaderboard_user_model.dart';

class LeaderboardProvider extends ChangeNotifier {
  final List<LeaderboardUserModel> _users = const [
    LeaderboardUserModel(
      name: 'Luna',
      trees: 420,
      focusSessions: 180,
      level: 21,
      country: 'Japan',
    ),
    LeaderboardUserModel(
      name: 'Adam',
      trees: 390,
      focusSessions: 165,
      level: 19,
      country: 'Canada',
    ),
    LeaderboardUserModel(
      name: 'Youssef',
      trees: 365,
      focusSessions: 152,
      level: 18,
      country: 'Egypt',
      isCurrentUser: true,
    ),
    LeaderboardUserModel(
      name: 'Mira',
      trees: 330,
      focusSessions: 141,
      level: 17,
      country: 'Germany',
    ),
    LeaderboardUserModel(
      name: 'Kai',
      trees: 295,
      focusSessions: 130,
      level: 16,
      country: 'Korea',
    ),
  ];

  List<LeaderboardUserModel> get users => _users;
}