import 'package:flutter/material.dart';
import '../models/reward_day_model.dart';

class RewardsProvider extends ChangeNotifier {
  int currentStreak = 7;
  int claimedDays = 7;

  List<RewardDayModel> get rewards {
    return List.generate(30, (index) {
      final day = index + 1;
      return RewardDayModel(
        day: day,
        isClaimed: day < claimedDays,
        isToday: day == claimedDays,
        isLocked: day > claimedDays,
        rewardTitle: day % 5 == 0 ? 'Rare Tree' : 'Sapling',
      );
    });
  }

  void claimTodayReward() {
    if (claimedDays < 30) {
      claimedDays++;
      currentStreak++;
      notifyListeners();
    }
  }
}