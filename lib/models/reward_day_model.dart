class RewardDayModel {
  final int day;
  final bool isClaimed;
  final bool isToday;
  final bool isLocked;
  final String rewardTitle;

  const RewardDayModel({
    required this.day,
    required this.isClaimed,
    required this.isToday,
    required this.isLocked,
    required this.rewardTitle,
  });

  RewardDayModel copyWith({
    int? day,
    bool? isClaimed,
    bool? isToday,
    bool? isLocked,
    String? rewardTitle,
  }) {
    return RewardDayModel(
      day: day ?? this.day,
      isClaimed: isClaimed ?? this.isClaimed,
      isToday: isToday ?? this.isToday,
      isLocked: isLocked ?? this.isLocked,
      rewardTitle: rewardTitle ?? this.rewardTitle,
    );
  }
}