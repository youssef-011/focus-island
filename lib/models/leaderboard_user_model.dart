class LeaderboardUserModel {
  final String name;
  final int trees;
  final int focusSessions;
  final int level;
  final String country;
  final bool isCurrentUser;

  const LeaderboardUserModel({
    required this.name,
    required this.trees,
    required this.focusSessions,
    required this.level,
    required this.country,
    this.isCurrentUser = false,
  });
}