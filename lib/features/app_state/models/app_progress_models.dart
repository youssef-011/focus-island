enum AppNotificationType {
  focusCompleted,
  rewardEarned,
  streakUpdated,
  plantEvolved,
  challengeCompleted,
  goalReached,
}

class FocusCategoryOption {
  final String id;
  final String label;
  final bool allowsCustomLabel;

  const FocusCategoryOption({
    required this.id,
    required this.label,
    this.allowsCustomLabel = false,
  });
}

class FocusSessionRecord {
  final String id;
  final DateTime startedAt;
  final DateTime completedAt;
  final int durationMinutes;
  final int interruptionCount;
  final String categoryId;
  final String categoryLabel;

  const FocusSessionRecord({
    required this.id,
    required this.startedAt,
    required this.completedAt,
    required this.durationMinutes,
    required this.interruptionCount,
    required this.categoryId,
    required this.categoryLabel,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startedAt': startedAt.toIso8601String(),
      'completedAt': completedAt.toIso8601String(),
      'durationMinutes': durationMinutes,
      'interruptionCount': interruptionCount,
      'categoryId': categoryId,
      'categoryLabel': categoryLabel,
    };
  }

  factory FocusSessionRecord.fromJson(Map<String, dynamic> json) {
    return FocusSessionRecord(
      id: json['id'] as String? ?? '',
      startedAt: DateTime.tryParse(json['startedAt'] as String? ?? '') ??
          DateTime.now(),
      completedAt: DateTime.tryParse(json['completedAt'] as String? ?? '') ??
          DateTime.now(),
      durationMinutes: json['durationMinutes'] as int? ?? 25,
      interruptionCount: json['interruptionCount'] as int? ?? 0,
      categoryId: json['categoryId'] as String? ?? 'deep_focus',
      categoryLabel: json['categoryLabel'] as String? ?? 'Deep Focus',
    );
  }
}

class PlantedItemRecord {
  final String id;
  final String sessionId;
  final int durationMinutes;
  final String categoryId;
  final String categoryLabel;
  final DateTime plantedAt;
  final String plantTypeId;
  final String plantTitle;
  final String visualKey;

  const PlantedItemRecord({
    required this.id,
    required this.sessionId,
    required this.durationMinutes,
    required this.categoryId,
    required this.categoryLabel,
    required this.plantedAt,
    required this.plantTypeId,
    required this.plantTitle,
    required this.visualKey,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sessionId': sessionId,
      'durationMinutes': durationMinutes,
      'categoryId': categoryId,
      'categoryLabel': categoryLabel,
      'plantedAt': plantedAt.toIso8601String(),
      'plantTypeId': plantTypeId,
      'plantTitle': plantTitle,
      'visualKey': visualKey,
    };
  }

  factory PlantedItemRecord.fromJson(Map<String, dynamic> json) {
    return PlantedItemRecord(
      id: json['id'] as String? ?? '',
      sessionId: json['sessionId'] as String? ?? '',
      durationMinutes: json['durationMinutes'] as int? ?? 25,
      categoryId: json['categoryId'] as String? ?? 'deep_focus',
      categoryLabel: json['categoryLabel'] as String? ?? 'Deep Focus',
      plantedAt: DateTime.tryParse(json['plantedAt'] as String? ?? '') ??
          DateTime.now(),
      plantTypeId: json['plantTypeId'] as String? ?? 'young_tree',
      plantTitle: json['plantTitle'] as String? ?? 'Young Tree',
      visualKey: json['visualKey'] as String? ?? 'young_tree',
    );
  }
}

class AppNotification {
  final String id;
  final AppNotificationType type;
  final String title;
  final String message;
  final DateTime createdAt;
  final bool isRead;

  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.createdAt,
    this.isRead = false,
  });

  AppNotification copyWith({
    String? id,
    AppNotificationType? type,
    String? title,
    String? message,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return AppNotification(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'title': title,
      'message': message,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
    };
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    final typeName =
        json['type'] as String? ?? AppNotificationType.focusCompleted.name;

    return AppNotification(
      id: json['id'] as String? ?? '',
      type: AppNotificationType.values.firstWhere(
        (value) => value.name == typeName,
        orElse: () => AppNotificationType.focusCompleted,
      ),
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      isRead: json['isRead'] as bool? ?? false,
    );
  }
}

class RewardClaim {
  final int focusMinuteTarget;
  final String title;
  final DateTime claimedAt;

  const RewardClaim({
    required this.focusMinuteTarget,
    required this.title,
    required this.claimedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'focusMinuteTarget': focusMinuteTarget,
      'title': title,
      'claimedAt': claimedAt.toIso8601String(),
    };
  }

  factory RewardClaim.fromJson(Map<String, dynamic> json) {
    final title = json['title'] as String? ?? '';
    final legacyTarget = json['sessionTarget'] as int?;

    return RewardClaim(
      focusMinuteTarget:
          json['focusMinuteTarget'] as int? ??
          _migrateLegacyRewardTarget(legacyTarget, title),
      title: title,
      claimedAt:
          DateTime.tryParse(json['claimedAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

class AchievementUnlock {
  final String id;
  final DateTime unlockedAt;

  const AchievementUnlock({
    required this.id,
    required this.unlockedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'unlockedAt': unlockedAt.toIso8601String(),
    };
  }

  factory AchievementUnlock.fromJson(Map<String, dynamic> json) {
    return AchievementUnlock(
      id: json['id'] as String? ?? '',
      unlockedAt:
          DateTime.tryParse(json['unlockedAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

class DailyGoalState {
  final int goalMinutes;
  final String? lastCelebratedDateKey;

  const DailyGoalState({
    required this.goalMinutes,
    required this.lastCelebratedDateKey,
  });

  factory DailyGoalState.defaults() {
    return const DailyGoalState(
      goalMinutes: 90,
      lastCelebratedDateKey: null,
    );
  }

  DailyGoalState copyWith({
    int? goalMinutes,
    String? lastCelebratedDateKey,
    bool clearCelebratedDate = false,
  }) {
    return DailyGoalState(
      goalMinutes: goalMinutes ?? this.goalMinutes,
      lastCelebratedDateKey:
          clearCelebratedDate ? null : lastCelebratedDateKey ?? this.lastCelebratedDateKey,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'goalMinutes': goalMinutes,
      'lastCelebratedDateKey': lastCelebratedDateKey,
    };
  }

  factory DailyGoalState.fromJson(Map<String, dynamic> json) {
    return DailyGoalState(
      goalMinutes: json['goalMinutes'] as int? ?? 90,
      lastCelebratedDateKey: json['lastCelebratedDateKey'] as String?,
    );
  }
}

class AmbientSoundPreference {
  final String selectedTrackId;
  final double volume;

  const AmbientSoundPreference({
    required this.selectedTrackId,
    required this.volume,
  });

  factory AmbientSoundPreference.defaults() {
    return const AmbientSoundPreference(
      selectedTrackId: '',
      volume: 0.6,
    );
  }

  AmbientSoundPreference copyWith({
    String? selectedTrackId,
    double? volume,
  }) {
    return AmbientSoundPreference(
      selectedTrackId: selectedTrackId ?? this.selectedTrackId,
      volume: volume ?? this.volume,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'selectedTrackId': selectedTrackId,
      'volume': volume,
    };
  }

  factory AmbientSoundPreference.fromJson(Map<String, dynamic> json) {
    return AmbientSoundPreference(
      selectedTrackId: json['selectedTrackId'] as String? ?? '',
      volume: (json['volume'] as num?)?.toDouble() ?? 0.6,
    );
  }
}

class AppStateSnapshot {
  final List<FocusSessionRecord> focusSessions;
  final List<PlantedItemRecord> plantedItems;
  final List<AppNotification> notifications;
  final List<RewardClaim> rewardClaims;
  final List<AchievementUnlock> achievementUnlocks;
  final DailyGoalState dailyGoalState;
  final AmbientSoundPreference ambientSoundPreference;

  const AppStateSnapshot({
    required this.focusSessions,
    required this.plantedItems,
    required this.notifications,
    required this.rewardClaims,
    required this.achievementUnlocks,
    required this.dailyGoalState,
    required this.ambientSoundPreference,
  });

  factory AppStateSnapshot.empty() {
    return AppStateSnapshot(
      focusSessions: const [],
      plantedItems: const [],
      notifications: const [],
      rewardClaims: const [],
      achievementUnlocks: const [],
      dailyGoalState: DailyGoalState.defaults(),
      ambientSoundPreference: AmbientSoundPreference.defaults(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'focusSessions': focusSessions.map((item) => item.toJson()).toList(),
      'plantedItems': plantedItems.map((item) => item.toJson()).toList(),
      'notifications': notifications.map((item) => item.toJson()).toList(),
      'rewardClaims': rewardClaims.map((item) => item.toJson()).toList(),
      'achievementUnlocks':
          achievementUnlocks.map((item) => item.toJson()).toList(),
      'dailyGoalState': dailyGoalState.toJson(),
      'ambientSoundPreference': ambientSoundPreference.toJson(),
    };
  }

  factory AppStateSnapshot.fromJson(Map<String, dynamic> json) {
    return AppStateSnapshot(
      focusSessions: (json['focusSessions'] as List<dynamic>? ?? [])
          .map(
            (item) => FocusSessionRecord.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
      plantedItems: (json['plantedItems'] as List<dynamic>? ?? [])
          .map(
            (item) => PlantedItemRecord.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
      notifications: (json['notifications'] as List<dynamic>? ?? [])
          .map(
            (item) => AppNotification.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
      rewardClaims: (json['rewardClaims'] as List<dynamic>? ?? [])
          .map(
            (item) => RewardClaim.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
      achievementUnlocks: (json['achievementUnlocks'] as List<dynamic>? ?? [])
          .map(
            (item) => AchievementUnlock.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
      dailyGoalState: json['dailyGoalState'] is Map
          ? DailyGoalState.fromJson(
              Map<String, dynamic>.from(json['dailyGoalState'] as Map),
            )
          : DailyGoalState.defaults(),
      ambientSoundPreference: json['ambientSoundPreference'] is Map
          ? AmbientSoundPreference.fromJson(
              Map<String, dynamic>.from(
                json['ambientSoundPreference'] as Map,
              ),
            )
          : AmbientSoundPreference.defaults(),
    );
  }
}

class PlantGrowthStage {
  final String id;
  final String title;
  final String subtitle;
  final String visualKey;
  final int minFocusMinutes;
  final int? nextStageFocusMinutes;

  const PlantGrowthStage({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.visualKey,
    required this.minFocusMinutes,
    required this.nextStageFocusMinutes,
  });
}

class ForestEntry {
  final String id;
  final String title;
  final String description;
  final String visualKey;
  final int milestoneFocusMinutes;
  final DateTime unlockedAt;

  const ForestEntry({
    required this.id,
    required this.title,
    required this.description,
    required this.visualKey,
    required this.milestoneFocusMinutes,
    required this.unlockedAt,
  });
}

class RewardTrackItem {
  final int focusMinuteTarget;
  final String title;
  final String description;
  final bool isClaimed;
  final bool isAvailable;
  final DateTime? claimedAt;

  const RewardTrackItem({
    required this.focusMinuteTarget,
    required this.title,
    required this.description,
    required this.isClaimed,
    required this.isAvailable,
    required this.claimedAt,
  });
}

class FocusCategoryStat {
  final String categoryId;
  final String label;
  final int totalMinutes;
  final int sessionsCount;

  const FocusCategoryStat({
    required this.categoryId,
    required this.label,
    required this.totalMinutes,
    required this.sessionsCount,
  });
}

class FocusSessionCompletionResult {
  final FocusSessionRecord session;
  final PlantedItemRecord plantedItem;
  final bool dailyGoalReachedNow;
  final PlantGrowthStage? evolvedGrowthStage;

  const FocusSessionCompletionResult({
    required this.session,
    required this.plantedItem,
    required this.dailyGoalReachedNow,
    required this.evolvedGrowthStage,
  });
}

class AchievementStatus {
  final String id;
  final String title;
  final String description;
  final String visualKey;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final int currentValue;
  final int targetValue;

  const AchievementStatus({
    required this.id,
    required this.title,
    required this.description,
    required this.visualKey,
    required this.isUnlocked,
    required this.unlockedAt,
    required this.currentValue,
    required this.targetValue,
  });

  double get progress {
    if (targetValue <= 0) {
      return 0;
    }

    return (currentValue / targetValue).clamp(0.0, 1.0);
  }
}

int _migrateLegacyRewardTarget(int? legacyTarget, String title) {
  switch (title) {
    case 'First Seed':
      return 25;
    case 'Momentum Leaf':
      return 75;
    case 'Calm Pebble':
      return 150;
    case 'Morning Dew':
      return 240;
    case 'Sprout Glow':
      return 360;
    case 'Focus Lantern':
      return 480;
    case 'Canopy Badge':
      return 720;
    case 'River Charm':
      return 900;
    case 'Sunrise Crest':
      return 1200;
    case 'Island Keeper':
      return 1800;
    default:
      return (legacyTarget ?? 1) * 25;
  }
}
