import 'dart:math';

import 'package:flutter/material.dart';

import '../../auth/services/auth_local_storage_service.dart';
import '../../onboarding/models/user_profile.dart';
import '../../onboarding/services/onboarding_storage_service.dart';
import '../models/app_progress_models.dart';
import '../services/local_app_state_service.dart';

class AppStateProvider extends ChangeNotifier {
  AppStateProvider({
    LocalAppStateService? localAppStateService,
    OnboardingStorageService? onboardingStorageService,
    AuthLocalStorageService? authLocalStorageService,
  })  : _localAppStateService = localAppStateService ?? LocalAppStateService(),
        _onboardingStorageService =
            onboardingStorageService ?? OnboardingStorageService(),
        _authLocalStorageService =
            authLocalStorageService ?? AuthLocalStorageService();

  final LocalAppStateService _localAppStateService;
  final OnboardingStorageService _onboardingStorageService;
  final AuthLocalStorageService _authLocalStorageService;

  bool _isInitialized = false;
  bool _isLoading = false;
  String? _activeUserId;
  UserProfile _profile = _emptyProfile();
  List<FocusSessionRecord> _focusSessions = const [];
  List<AppNotification> _notifications = const [];
  List<RewardClaim> _rewardClaims = const [];
  List<AchievementUnlock> _achievementUnlocks = const [];

  static const List<int> _growthMilestones = [0, 25, 120, 300, 600];
  static const List<_RewardDefinition> _rewardDefinitions = [
    _RewardDefinition(
      focusMinuteTarget: 25,
      title: 'First Seed',
      description: 'A quiet beginning for your island.',
    ),
    _RewardDefinition(
      focusMinuteTarget: 75,
      title: 'Momentum Leaf',
      description: 'You started showing up consistently.',
    ),
    _RewardDefinition(
      focusMinuteTarget: 150,
      title: 'Calm Pebble',
      description: 'A grounding token for your focus path.',
    ),
    _RewardDefinition(
      focusMinuteTarget: 240,
      title: 'Morning Dew',
      description: 'A soft reminder that progress is building.',
    ),
    _RewardDefinition(
      focusMinuteTarget: 360,
      title: 'Sprout Glow',
      description: 'Your island now carries visible life.',
    ),
    _RewardDefinition(
      focusMinuteTarget: 480,
      title: 'Focus Lantern',
      description: 'A steady light for longer sessions ahead.',
    ),
    _RewardDefinition(
      focusMinuteTarget: 720,
      title: 'Canopy Badge',
      description: 'Your routine has grown into something strong.',
    ),
    _RewardDefinition(
      focusMinuteTarget: 900,
      title: 'River Charm',
      description: 'Your island flow keeps getting calmer.',
    ),
    _RewardDefinition(
      focusMinuteTarget: 1200,
      title: 'Sunrise Crest',
      description: 'A bright badge for sustained focus.',
    ),
    _RewardDefinition(
      focusMinuteTarget: 1800,
      title: 'Island Keeper',
      description: 'A signature milestone for true consistency.',
    ),
  ];

  static const List<_ForestDefinition> _forestDefinitions = [
    _ForestDefinition(
      id: 'seedling_1',
      milestoneFocusMinutes: 25,
      title: 'First Seedling',
      description: 'Your island welcomed its first living companion.',
      visualKey: 'seed',
    ),
    _ForestDefinition(
      id: 'sprout_1',
      milestoneFocusMinutes: 90,
      title: 'Calm Sprout',
      description: 'A sprout appeared after repeated quiet work.',
      visualKey: 'sprout',
    ),
    _ForestDefinition(
      id: 'fern_1',
      milestoneFocusMinutes: 180,
      title: 'Morning Fern',
      description: 'A fern now follows your growing rhythm.',
      visualKey: 'leaf',
    ),
    _ForestDefinition(
      id: 'tree_1',
      milestoneFocusMinutes: 300,
      title: 'Young Tree',
      description: 'Your island planted its first young tree.',
      visualKey: 'tree',
    ),
    _ForestDefinition(
      id: 'bloom_1',
      milestoneFocusMinutes: 480,
      title: 'Island Bloom',
      description: 'A bright bloom marks deeper focus habits.',
      visualKey: 'sun',
    ),
    _ForestDefinition(
      id: 'tree_2',
      milestoneFocusMinutes: 720,
      title: 'Canopy Tree',
      description: 'A stronger tree grew from your steady sessions.',
      visualKey: 'tree',
    ),
    _ForestDefinition(
      id: 'grove_1',
      milestoneFocusMinutes: 960,
      title: 'Mini Grove',
      description: 'Your island now feels like a living grove.',
      visualKey: 'island',
    ),
  ];

  static const List<_AchievementDefinition> _achievementDefinitions = [
    _AchievementDefinition(
      id: 'first_roots',
      title: 'First Roots',
      description: 'Complete your first focus session.',
      visualKey: 'seed',
      targetValue: 1,
      progressType: _AchievementProgressType.sessions,
    ),
    _AchievementDefinition(
      id: 'steady_flow',
      title: 'Steady Flow',
      description: 'Complete 5 focus sessions.',
      visualKey: 'river',
      targetValue: 5,
      progressType: _AchievementProgressType.sessions,
    ),
    _AchievementDefinition(
      id: 'hour_of_focus',
      title: 'Hour of Focus',
      description: 'Reach 60 total focus minutes.',
      visualKey: 'sun',
      targetValue: 60,
      progressType: _AchievementProgressType.minutes,
    ),
    _AchievementDefinition(
      id: 'green_streak',
      title: 'Green Streak',
      description: 'Focus for 3 consecutive days.',
      visualKey: 'leaf',
      targetValue: 3,
      progressType: _AchievementProgressType.streak,
    ),
    _AchievementDefinition(
      id: 'young_canopy',
      title: 'Young Canopy',
      description: 'Reach the Young Tree growth stage.',
      visualKey: 'tree',
      targetValue: 300,
      progressType: _AchievementProgressType.minutes,
    ),
    _AchievementDefinition(
      id: 'island_keeper',
      title: 'Island Keeper',
      description: 'Reach 900 total focus minutes.',
      visualKey: 'island',
      targetValue: 900,
      progressType: _AchievementProgressType.minutes,
    ),
  ];

  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  String? get activeUserId => _activeUserId;
  UserProfile get profile => _profile;
  List<FocusSessionRecord> get focusSessions =>
      List.unmodifiable(_focusSessions.reversed.toList());
  List<AppNotification> get notifications => List.unmodifiable(
        _notifications.toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
      );
  int get unreadNotificationsCount =>
      _notifications.where((item) => !item.isRead).length;
  int get completedSessionsCount => _focusSessions.length;
  int get totalFocusMinutes =>
      _focusSessions.fold(0, (sum, session) => sum + session.durationMinutes);
  double get averageFocusMinutes =>
      _focusSessions.isEmpty ? 0 : totalFocusMinutes / _focusSessions.length;
  int get longestFocusSessionMinutes => _focusSessions.fold<int>(
        0,
        (current, session) =>
            session.durationMinutes > current ? session.durationMinutes : current,
      );
  int get currentStreak => _calculateCurrentStreak(_focusSessions);
  int get longestStreak => _calculateLongestStreak(_focusSessions);
  int get claimedRewardsCount => _rewardClaims.length;
  int get plantedItemsCount => forestEntries.length;
  int get unlockedAchievementsCount =>
      achievements.where((item) => item.isUnlocked).length;
  int get uniqueCategoryCount => categoryStats.length;
  int get personalFocusScore =>
      totalFocusMinutes +
      (completedSessionsCount * 10) +
      (currentStreak * 20) +
      (unlockedAchievementsCount * 25);
  int get currentLevel => max(1, (totalFocusMinutes ~/ 60) + 1);

  List<FocusCategoryStat> get categoryStats {
    final buckets = <String, _CategoryAccumulator>{};

    for (final session in _focusSessions) {
      final rawCategoryId = session.categoryId.trim().isEmpty
          ? 'deep_focus'
          : session.categoryId.trim();
      final categoryLabel = session.categoryLabel.trim().isEmpty
          ? 'Deep Focus'
          : session.categoryLabel.trim();
      final categoryId = rawCategoryId == 'custom'
          ? 'custom_${categoryLabel.toLowerCase()}'
          : rawCategoryId;

      final bucket = buckets.putIfAbsent(
        categoryId,
        () => _CategoryAccumulator(
          categoryId: categoryId,
          label: categoryLabel,
        ),
      );
      bucket.totalMinutes += session.durationMinutes;
      bucket.sessionsCount += 1;
    }

    final stats = buckets.values
        .map(
          (bucket) => FocusCategoryStat(
            categoryId: bucket.categoryId,
            label: bucket.label,
            totalMinutes: bucket.totalMinutes,
            sessionsCount: bucket.sessionsCount,
          ),
        )
        .toList()
      ..sort((a, b) {
        final byMinutes = b.totalMinutes.compareTo(a.totalMinutes);
        if (byMinutes != 0) {
          return byMinutes;
        }

        final bySessions = b.sessionsCount.compareTo(a.sessionsCount);
        if (bySessions != 0) {
          return bySessions;
        }

        return a.label.compareTo(b.label);
      });

    return stats;
  }

  String get favoriteCategoryLabel =>
      categoryStats.isEmpty ? 'No category yet' : categoryStats.first.label;

  Map<String, int> get weeklyFocusMinutes {
    final now = DateTime.now();
    final startOfToday = DateUtils.dateOnly(now);
    final result = <String, int>{};

    for (var offset = 6; offset >= 0; offset--) {
      final date = startOfToday.subtract(Duration(days: offset));
      final key = _dateKey(date);
      result[key] = 0;
    }

    for (final session in _focusSessions) {
      final day = DateUtils.dateOnly(session.completedAt);
      final key = _dateKey(day);
      if (result.containsKey(key)) {
        result[key] = (result[key] ?? 0) + session.durationMinutes;
      }
    }

    return result;
  }

  PlantGrowthStage get currentGrowthStage {
    final focusMinutes = totalFocusMinutes;

    if (focusMinutes >= _growthMilestones[4]) {
      return const PlantGrowthStage(
        id: 'mature_tree',
        title: 'Mature Tree',
        subtitle: 'Your island now stands calm, rooted, and alive.',
        visualKey: 'mature_tree',
        minFocusMinutes: 600,
        nextStageFocusMinutes: null,
      );
    }

    if (focusMinutes >= _growthMilestones[3]) {
      return const PlantGrowthStage(
        id: 'young_tree',
        title: 'Young Tree',
        subtitle: 'The island has a strong trunk and healthy canopy.',
        visualKey: 'young_tree',
        minFocusMinutes: 300,
        nextStageFocusMinutes: 600,
      );
    }

    if (focusMinutes >= _growthMilestones[2]) {
      return const PlantGrowthStage(
        id: 'small_plant',
        title: 'Small Plant',
        subtitle: 'Your routine is turning into visible growth.',
        visualKey: 'small_plant',
        minFocusMinutes: 120,
        nextStageFocusMinutes: 300,
      );
    }

    if (focusMinutes >= _growthMilestones[1]) {
      return const PlantGrowthStage(
        id: 'sprout',
        title: 'Sprout',
        subtitle: 'A real habit has begun to break through the soil.',
        visualKey: 'sprout',
        minFocusMinutes: 25,
        nextStageFocusMinutes: 120,
      );
    }

    return const PlantGrowthStage(
      id: 'seed',
      title: 'Seed',
      subtitle: 'The island is waiting for its first completed session.',
      visualKey: 'seed',
      minFocusMinutes: 0,
      nextStageFocusMinutes: 25,
    );
  }

  int get focusMinutesToNextGrowth {
    final nextThreshold = currentGrowthStage.nextStageFocusMinutes;
    if (nextThreshold == null) {
      return 0;
    }

    return max(0, nextThreshold - totalFocusMinutes);
  }

  double get growthProgress {
    final stage = currentGrowthStage;
    final nextThreshold = stage.nextStageFocusMinutes;
    if (nextThreshold == null) {
      return 1;
    }

    final currentMinutes = totalFocusMinutes - stage.minFocusMinutes;
    final stageSpan = nextThreshold - stage.minFocusMinutes;
    if (stageSpan <= 0) {
      return 1;
    }

    return (currentMinutes / stageSpan).clamp(0.0, 1.0);
  }

  List<ForestEntry> get forestEntries {
    final sessionsAscending = _focusSessions.toList()
      ..sort((a, b) => a.completedAt.compareTo(b.completedAt));

    final entries = <ForestEntry>[];
    var cumulativeMinutes = 0;

    for (final session in sessionsAscending) {
      cumulativeMinutes += session.durationMinutes;

      for (final definition in _forestDefinitions) {
        final alreadyUnlocked =
            entries.any((entry) => entry.id == definition.id);
        if (alreadyUnlocked ||
            cumulativeMinutes < definition.milestoneFocusMinutes) {
          continue;
        }

        entries.add(
          ForestEntry(
            id: definition.id,
            title: definition.title,
            description: definition.description,
            visualKey: definition.visualKey,
            milestoneFocusMinutes: definition.milestoneFocusMinutes,
            unlockedAt: session.completedAt,
          ),
        );
      }
    }

    return entries;
  }

  List<RewardTrackItem> get rewardTrack {
    return _rewardDefinitions.map((definition) {
      RewardClaim? claim;
      for (final item in _rewardClaims) {
        if (item.focusMinuteTarget == definition.focusMinuteTarget) {
          claim = item;
          break;
        }
      }

      return RewardTrackItem(
        focusMinuteTarget: definition.focusMinuteTarget,
        title: definition.title,
        description: definition.description,
        isClaimed: claim != null,
        isAvailable:
            claim == null && totalFocusMinutes >= definition.focusMinuteTarget,
        claimedAt: claim?.claimedAt,
      );
    }).toList();
  }

  RewardTrackItem? get nextAvailableReward {
    for (final reward in rewardTrack) {
      if (reward.isAvailable) {
        return reward;
      }
    }

    return null;
  }

  RewardTrackItem? get upcomingReward {
    for (final reward in rewardTrack) {
      if (!reward.isClaimed) {
        return reward;
      }
    }

    return null;
  }

  int get focusMinutesToNextReward {
    final reward = upcomingReward;
    if (reward == null) {
      return 0;
    }

    return max(0, reward.focusMinuteTarget - totalFocusMinutes);
  }

  List<AchievementStatus> get achievements {
    return _achievementDefinitions.map((definition) {
      AchievementUnlock? unlock;
      for (final item in _achievementUnlocks) {
        if (item.id == definition.id) {
          unlock = item;
          break;
        }
      }
      final currentValue = _achievementValueFor(definition.progressType);

      return AchievementStatus(
        id: definition.id,
        title: definition.title,
        description: definition.description,
        visualKey: definition.visualKey,
        isUnlocked: unlock != null,
        unlockedAt: unlock?.unlockedAt,
        currentValue: currentValue,
        targetValue: definition.targetValue,
      );
    }).toList();
  }

  Future<void> initialize() async {
    if (_isInitialized || _isLoading) {
      return;
    }

    await reloadForCurrentUser();
  }

  Future<void> reloadForCurrentUser() async {
    if (_isLoading) {
      return;
    }

    _isLoading = true;
    notifyListeners();

    final activeUserId = await _onboardingStorageService.getActiveUserId();
    if (activeUserId == null || activeUserId.isEmpty) {
      _activeUserId = null;
      _profile = _emptyProfile();
      _focusSessions = [];
      _notifications = [];
      _rewardClaims = [];
      _achievementUnlocks = [];
      _isInitialized = true;
      _isLoading = false;
      notifyListeners();
      return;
    }

    final snapshot = await _localAppStateService.loadState(userId: activeUserId);
    _activeUserId = activeUserId;
    _profile = await _onboardingStorageService.getUserProfile(userId: activeUserId);
    _focusSessions = snapshot.focusSessions;
    _notifications = snapshot.notifications;
    _rewardClaims = snapshot.rewardClaims;
    _achievementUnlocks = snapshot.achievementUnlocks;

    _isInitialized = true;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> refreshProfile() async {
    if (_activeUserId == null || _activeUserId!.isEmpty) {
      await reloadForCurrentUser();
      return;
    }

    _profile = await _onboardingStorageService.getUserProfile(
      userId: _activeUserId,
    );
    notifyListeners();
  }

  Future<void> updateProfile({
    required String displayName,
    required String bio,
    required String avatarId,
    required String phone,
    required String country,
  }) async {
    final currentUserId = _activeUserId;
    if (currentUserId == null || currentUserId.isEmpty) {
      return;
    }

    final updatedProfile = _profile.copyWith(
      userId: currentUserId,
      name: displayName.trim(),
      bio: bio.trim(),
      avatarId: avatarId,
      phone: phone.trim(),
      country: country.trim().toUpperCase(),
    );

    await _onboardingStorageService.updateUserProfile(updatedProfile);
    await _authLocalStorageService.syncCurrentProfileToLocalAccount(
      updatedProfile,
    );
    _profile = updatedProfile;
    notifyListeners();
  }

  Future<void> recordCompletedFocusSession({
    required int durationMinutes,
    required int interruptionCount,
    required String categoryId,
    required String categoryLabel,
    DateTime? startedAt,
    DateTime? completedAt,
  }) async {
    final currentUserId = _activeUserId;
    if (currentUserId == null || currentUserId.isEmpty) {
      return;
    }

    final beforeStreak = currentStreak;
    final beforeStageId = currentGrowthStage.id;
    final normalizedDuration = durationMinutes.clamp(10, 180);
    final normalizedCategoryId =
        categoryId.trim().isEmpty ? 'deep_focus' : categoryId.trim();
    final normalizedCategoryLabel =
        categoryLabel.trim().isEmpty ? 'Deep Focus' : categoryLabel.trim();
    final now = completedAt ?? DateTime.now();
    final session = FocusSessionRecord(
      id: 'session_${now.microsecondsSinceEpoch}',
      startedAt: startedAt ?? now.subtract(Duration(minutes: normalizedDuration)),
      completedAt: now,
      durationMinutes: normalizedDuration,
      interruptionCount: interruptionCount,
      categoryId: normalizedCategoryId,
      categoryLabel: normalizedCategoryLabel,
    );

    _focusSessions = [..._focusSessions, session];
    _addNotification(
      title: 'Focus session completed',
      message:
          'You finished $normalizedDuration minutes of $normalizedCategoryLabel.',
      type: AppNotificationType.focusCompleted,
      createdAt: now,
    );

    final afterStreak = currentStreak;
    if (afterStreak > beforeStreak) {
      _addNotification(
        title: 'Streak updated',
        message: 'You are now on a $afterStreak day focus streak.',
        type: AppNotificationType.streakUpdated,
        createdAt: now,
      );
    }

    final afterStage = currentGrowthStage;
    if (afterStage.id != beforeStageId) {
      _addNotification(
        title: 'Plant evolved',
        message:
            'Your island reached the ${afterStage.title} stage after this session.',
        type: AppNotificationType.plantEvolved,
        createdAt: now,
      );
    }

    _unlockAchievementsIfNeeded(now);
    await _persistState();
    notifyListeners();
  }

  Future<void> claimNextReward() async {
    final reward = nextAvailableReward;
    if (reward == null) {
      return;
    }

    final claimedAt = DateTime.now();
    _rewardClaims = [
      ..._rewardClaims,
      RewardClaim(
        focusMinuteTarget: reward.focusMinuteTarget,
        title: reward.title,
        claimedAt: claimedAt,
      ),
    ];

    _addNotification(
      title: 'Reward earned',
      message:
          'You claimed "${reward.title}" for reaching ${reward.focusMinuteTarget} focus minutes.',
      type: AppNotificationType.rewardEarned,
      createdAt: claimedAt,
    );

    await _persistState();
    notifyListeners();
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    var changed = false;
    _notifications = _notifications.map((notification) {
      if (notification.id != notificationId || notification.isRead) {
        return notification;
      }

      changed = true;
      return notification.copyWith(isRead: true);
    }).toList();

    if (!changed) {
      return;
    }

    await _persistState();
    notifyListeners();
  }

  Future<void> markAllNotificationsAsRead() async {
    if (_notifications.every((notification) => notification.isRead)) {
      return;
    }

    _notifications = _notifications
        .map((notification) => notification.copyWith(isRead: true))
        .toList();
    await _persistState();
    notifyListeners();
  }

  Future<void> clearNotifications() async {
    _notifications = [];
    await _persistState();
    notifyListeners();
  }

  Future<void> resetProgress() async {
    final currentUserId = _activeUserId;
    if (currentUserId == null || currentUserId.isEmpty) {
      return;
    }

    _focusSessions = [];
    _notifications = [];
    _rewardClaims = [];
    _achievementUnlocks = [];
    await _localAppStateService.clearState(currentUserId);
    notifyListeners();
  }

  void _unlockAchievementsIfNeeded(DateTime unlockedAt) {
    final unlockedIds = _achievementUnlocks.map((item) => item.id).toSet();

    for (final definition in _achievementDefinitions) {
      final currentValue = _achievementValueFor(definition.progressType);
      if (currentValue >= definition.targetValue &&
          !unlockedIds.contains(definition.id)) {
        _achievementUnlocks = [
          ..._achievementUnlocks,
          AchievementUnlock(id: definition.id, unlockedAt: unlockedAt),
        ];

        _addNotification(
          title: 'Challenge completed',
          message: 'You unlocked "${definition.title}".',
          type: AppNotificationType.challengeCompleted,
          createdAt: unlockedAt,
        );
      }
    }
  }

  int _achievementValueFor(_AchievementProgressType progressType) {
    switch (progressType) {
      case _AchievementProgressType.sessions:
        return completedSessionsCount;
      case _AchievementProgressType.minutes:
        return totalFocusMinutes;
      case _AchievementProgressType.streak:
        return currentStreak;
    }
  }

  int _calculateCurrentStreak(List<FocusSessionRecord> sessions) {
    final orderedDays = _uniqueSessionDays(sessions);
    if (orderedDays.isEmpty) {
      return 0;
    }

    final today = DateUtils.dateOnly(DateTime.now());
    final latestDifference = today.difference(orderedDays.first).inDays;
    if (latestDifference > 1) {
      return 0;
    }

    var streak = 1;
    for (var index = 0; index < orderedDays.length - 1; index++) {
      final difference =
          orderedDays[index].difference(orderedDays[index + 1]).inDays;
      if (difference == 1) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }

  int _calculateLongestStreak(List<FocusSessionRecord> sessions) {
    final orderedDays = _uniqueSessionDays(sessions).reversed.toList();
    if (orderedDays.isEmpty) {
      return 0;
    }

    var longest = 1;
    var current = 1;

    for (var index = 1; index < orderedDays.length; index++) {
      final difference =
          orderedDays[index].difference(orderedDays[index - 1]).inDays;
      if (difference == 1) {
        current++;
        if (current > longest) {
          longest = current;
        }
      } else {
        current = 1;
      }
    }

    return longest;
  }

  List<DateTime> _uniqueSessionDays(List<FocusSessionRecord> sessions) {
    final uniqueDays = sessions
        .map((session) => DateUtils.dateOnly(session.completedAt))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));
    return uniqueDays;
  }

  String _dateKey(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  void _addNotification({
    required String title,
    required String message,
    required AppNotificationType type,
    DateTime? createdAt,
  }) {
    final timestamp = createdAt ?? DateTime.now();
    _notifications = [
      AppNotification(
        id: 'notification_${timestamp.microsecondsSinceEpoch}_${_notifications.length}',
        type: type,
        title: title,
        message: message,
        createdAt: timestamp,
      ),
      ..._notifications,
    ];
  }

  Future<void> _persistState() async {
    final currentUserId = _activeUserId;
    if (currentUserId == null || currentUserId.isEmpty) {
      return;
    }

    await _localAppStateService.saveState(
      currentUserId,
      AppStateSnapshot(
        focusSessions: _focusSessions,
        notifications: _notifications,
        rewardClaims: _rewardClaims,
        achievementUnlocks: _achievementUnlocks,
      ),
    );
  }

  static UserProfile _emptyProfile() {
    return const UserProfile(
      userId: '',
      name: '',
      email: '',
      phone: '',
      country: 'EG',
      bio: '',
      avatarId: 'seed',
    );
  }
}

class _RewardDefinition {
  final int focusMinuteTarget;
  final String title;
  final String description;

  const _RewardDefinition({
    required this.focusMinuteTarget,
    required this.title,
    required this.description,
  });
}

class _ForestDefinition {
  final String id;
  final int milestoneFocusMinutes;
  final String title;
  final String description;
  final String visualKey;

  const _ForestDefinition({
    required this.id,
    required this.milestoneFocusMinutes,
    required this.title,
    required this.description,
    required this.visualKey,
  });
}

class _AchievementDefinition {
  final String id;
  final String title;
  final String description;
  final String visualKey;
  final int targetValue;
  final _AchievementProgressType progressType;

  const _AchievementDefinition({
    required this.id,
    required this.title,
    required this.description,
    required this.visualKey,
    required this.targetValue,
    required this.progressType,
  });
}

class _CategoryAccumulator {
  final String categoryId;
  final String label;
  int totalMinutes = 0;
  int sessionsCount = 0;

  _CategoryAccumulator({
    required this.categoryId,
    required this.label,
  });
}

enum _AchievementProgressType {
  sessions,
  minutes,
  streak,
}
