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
  List<PlantedItemRecord> _plantedItems = const [];
  List<AppNotification> _notifications = const [];
  List<RewardClaim> _rewardClaims = const [];
  List<AchievementUnlock> _achievementUnlocks = const [];
  DailyGoalState _dailyGoalState = DailyGoalState.defaults();
  AmbientSoundPreference _ambientSoundPreference =
      AmbientSoundPreference.defaults();

  static const List<int> _growthMilestones = [0, 25, 120, 300, 600];
  static const List<_RewardDefinition> _rewardDefinitions = [
    _RewardDefinition(25, 'First Seed', 'A quiet beginning for your island.'),
    _RewardDefinition(75, 'Momentum Leaf', 'You started showing up consistently.'),
    _RewardDefinition(150, 'Calm Pebble', 'A grounding token for your focus path.'),
    _RewardDefinition(240, 'Morning Dew', 'A soft reminder that progress is building.'),
    _RewardDefinition(360, 'Sprout Glow', 'Your island now carries visible life.'),
    _RewardDefinition(480, 'Focus Lantern', 'A steady light for longer sessions ahead.'),
    _RewardDefinition(720, 'Canopy Badge', 'Your routine has grown into something strong.'),
    _RewardDefinition(900, 'River Charm', 'Your island flow keeps getting calmer.'),
    _RewardDefinition(1200, 'Sunrise Crest', 'A bright badge for sustained focus.'),
    _RewardDefinition(1800, 'Island Keeper', 'A signature milestone for true consistency.'),
  ];
  static const List<_ForestDefinition> _forestDefinitions = [
    _ForestDefinition('seedling_1', 25, 'First Seedling', 'Your island welcomed its first living companion.', 'seed'),
    _ForestDefinition('sprout_1', 90, 'Calm Sprout', 'A sprout appeared after repeated quiet work.', 'sprout'),
    _ForestDefinition('fern_1', 180, 'Morning Fern', 'A fern now follows your growing rhythm.', 'leaf'),
    _ForestDefinition('tree_1', 300, 'Young Tree', 'Your island planted its first young tree.', 'tree'),
    _ForestDefinition('bloom_1', 480, 'Island Bloom', 'A bright bloom marks deeper focus habits.', 'sun'),
    _ForestDefinition('tree_2', 720, 'Canopy Tree', 'A stronger tree grew from your steady sessions.', 'tree'),
    _ForestDefinition('grove_1', 960, 'Mini Grove', 'Your island now feels like a living grove.', 'island'),
  ];
  static const List<_AchievementDefinition> _achievementDefinitions = [
    _AchievementDefinition('first_roots', 'First Roots', 'Complete your first focus session.', 'seed', 1, _AchievementProgressType.sessions),
    _AchievementDefinition('steady_flow', 'Steady Flow', 'Complete 5 focus sessions.', 'river', 5, _AchievementProgressType.sessions),
    _AchievementDefinition('hour_of_focus', 'Hour of Focus', 'Reach 60 total focus minutes.', 'sun', 60, _AchievementProgressType.minutes),
    _AchievementDefinition('green_streak', 'Green Streak', 'Focus for 3 consecutive days.', 'leaf', 3, _AchievementProgressType.streak),
    _AchievementDefinition('young_canopy', 'Young Canopy', 'Reach the Young Tree growth stage.', 'tree', 300, _AchievementProgressType.minutes),
    _AchievementDefinition('island_keeper', 'Island Keeper', 'Reach 900 total focus minutes.', 'island', 900, _AchievementProgressType.minutes),
  ];
  static const List<_PlantDefinition> _plantDefinitions = [
    _PlantDefinition('small_sprout', 'Small Sprout', 10, 'sprout'),
    _PlantDefinition('small_plant', 'Small Plant', 20, 'small_plant'),
    _PlantDefinition('young_tree', 'Young Tree', 30, 'young_tree'),
    _PlantDefinition('medium_tree', 'Medium Tree', 45, 'medium_tree'),
    _PlantDefinition('large_tree', 'Large Tree', 60, 'large_tree'),
  ];

  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  String? get activeUserId => _activeUserId;
  UserProfile get profile => _profile;
  DailyGoalState get dailyGoalState => _dailyGoalState;
  AmbientSoundPreference get ambientSoundPreference => _ambientSoundPreference;
  List<FocusSessionRecord> get focusSessions => List.unmodifiable(_focusSessions.reversed.toList());
  List<PlantedItemRecord> get plantedItems => List.unmodifiable(_plantedItems.reversed.toList());
  List<AppNotification> get notifications => List.unmodifiable(_notifications.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt)));
  int get unreadNotificationsCount => _notifications.where((item) => !item.isRead).length;
  int get completedSessionsCount => _focusSessions.length;
  int get totalFocusMinutes => _focusSessions.fold(0, (sum, session) => sum + session.durationMinutes);
  int get todayFocusMinutes => _focusSessions.fold<int>(0, (sum, session) {
        final sessionDay = DateUtils.dateOnly(session.completedAt);
        final today = DateUtils.dateOnly(DateTime.now());
        return sessionDay == today ? sum + session.durationMinutes : sum;
      });
  double get dailyGoalProgress => _dailyGoalState.goalMinutes <= 0 ? 0 : (todayFocusMinutes / _dailyGoalState.goalMinutes).clamp(0.0, 1.0);
  bool get isDailyGoalReached => todayFocusMinutes >= _dailyGoalState.goalMinutes;
  bool get celebratedGoalToday => _dailyGoalState.lastCelebratedDateKey == _todayKey() && isDailyGoalReached;
  int get dailyGoalMinutes => _dailyGoalState.goalMinutes;
  int get remainingDailyGoalMinutes => max(0, _dailyGoalState.goalMinutes - todayFocusMinutes);
  double get averageFocusMinutes => _focusSessions.isEmpty ? 0 : totalFocusMinutes / _focusSessions.length;
  int get longestFocusSessionMinutes => _focusSessions.fold<int>(0, (current, session) => session.durationMinutes > current ? session.durationMinutes : current);
  int get currentStreak => _calculateCurrentStreak(_focusSessions);
  int get longestStreak => _calculateLongestStreak(_focusSessions);
  int get claimedRewardsCount => _rewardClaims.length;
  int get plantedItemsCount => _plantedItems.length;
  int get unlockedAchievementsCount => achievements.where((item) => item.isUnlocked).length;
  int get uniqueCategoryCount => categoryStats.length;
  int get personalFocusScore => totalFocusMinutes + (completedSessionsCount * 10) + (currentStreak * 20) + (unlockedAchievementsCount * 25);
  int get currentLevel => max(1, (totalFocusMinutes ~/ 60) + 1);

  List<FocusCategoryStat> get categoryStats {
    final buckets = <String, _CategoryAccumulator>{};
    for (final session in _focusSessions) {
      final rawCategoryId = session.categoryId.trim().isEmpty ? 'deep_focus' : session.categoryId.trim();
      final categoryLabel = session.categoryLabel.trim().isEmpty ? 'Deep Focus' : session.categoryLabel.trim();
      final categoryId = rawCategoryId == 'custom' ? 'custom_${categoryLabel.toLowerCase()}' : rawCategoryId;
      final bucket = buckets.putIfAbsent(categoryId, () => _CategoryAccumulator(categoryId, categoryLabel));
      bucket.totalMinutes += session.durationMinutes;
      bucket.sessionsCount += 1;
    }
    final stats = buckets.values
        .map((bucket) => FocusCategoryStat(categoryId: bucket.categoryId, label: bucket.label, totalMinutes: bucket.totalMinutes, sessionsCount: bucket.sessionsCount))
        .toList()
      ..sort((a, b) {
        final byMinutes = b.totalMinutes.compareTo(a.totalMinutes);
        if (byMinutes != 0) return byMinutes;
        final bySessions = b.sessionsCount.compareTo(a.sessionsCount);
        if (bySessions != 0) return bySessions;
        return a.label.compareTo(b.label);
      });
    return stats;
  }

  String get favoriteCategoryLabel => categoryStats.isEmpty ? 'No category yet' : categoryStats.first.label;
  List<PlantedItemRecord> get recentPlantedItems => List.unmodifiable(plantedItems.take(4).toList());

  Map<String, int> get weeklyFocusMinutes {
    final now = DateTime.now();
    final startOfToday = DateUtils.dateOnly(now);
    final result = <String, int>{};
    for (var offset = 6; offset >= 0; offset--) {
      final date = startOfToday.subtract(Duration(days: offset));
      result[_dateKey(date)] = 0;
    }
    for (final session in _focusSessions) {
      final key = _dateKey(DateUtils.dateOnly(session.completedAt));
      if (result.containsKey(key)) {
        result[key] = (result[key] ?? 0) + session.durationMinutes;
      }
    }
    return result;
  }

  PlantGrowthStage get currentGrowthStage {
    final focusMinutes = totalFocusMinutes;
    if (focusMinutes >= _growthMilestones[4]) {
      return const PlantGrowthStage(id: 'mature_tree', title: 'Mature Tree', subtitle: 'Your island now stands calm, rooted, and alive.', visualKey: 'mature_tree', minFocusMinutes: 600, nextStageFocusMinutes: null);
    }
    if (focusMinutes >= _growthMilestones[3]) {
      return const PlantGrowthStage(id: 'young_tree', title: 'Young Tree', subtitle: 'The island has a strong trunk and healthy canopy.', visualKey: 'young_tree', minFocusMinutes: 300, nextStageFocusMinutes: 600);
    }
    if (focusMinutes >= _growthMilestones[2]) {
      return const PlantGrowthStage(id: 'small_plant', title: 'Small Plant', subtitle: 'Your routine is turning into visible growth.', visualKey: 'small_plant', minFocusMinutes: 120, nextStageFocusMinutes: 300);
    }
    if (focusMinutes >= _growthMilestones[1]) {
      return const PlantGrowthStage(id: 'sprout', title: 'Sprout', subtitle: 'A real habit has begun to break through the soil.', visualKey: 'sprout', minFocusMinutes: 25, nextStageFocusMinutes: 120);
    }
    return const PlantGrowthStage(id: 'seed', title: 'Seed', subtitle: 'The island is waiting for its first completed session.', visualKey: 'seed', minFocusMinutes: 0, nextStageFocusMinutes: 25);
  }

  int get focusMinutesToNextGrowth {
    final nextThreshold = currentGrowthStage.nextStageFocusMinutes;
    if (nextThreshold == null) return 0;
    return max(0, nextThreshold - totalFocusMinutes);
  }

  double get growthProgress {
    final stage = currentGrowthStage;
    final nextThreshold = stage.nextStageFocusMinutes;
    if (nextThreshold == null) return 1;
    final currentMinutes = totalFocusMinutes - stage.minFocusMinutes;
    final stageSpan = nextThreshold - stage.minFocusMinutes;
    if (stageSpan <= 0) return 1;
    return (currentMinutes / stageSpan).clamp(0.0, 1.0);
  }

  List<ForestEntry> get forestEntries {
    final sessionsAscending = _focusSessions.toList()..sort((a, b) => a.completedAt.compareTo(b.completedAt));
    final entries = <ForestEntry>[];
    var cumulativeMinutes = 0;
    for (final session in sessionsAscending) {
      cumulativeMinutes += session.durationMinutes;
      for (final definition in _forestDefinitions) {
        final alreadyUnlocked = entries.any((entry) => entry.id == definition.id);
        if (alreadyUnlocked || cumulativeMinutes < definition.milestoneFocusMinutes) continue;
        entries.add(ForestEntry(id: definition.id, title: definition.title, description: definition.description, visualKey: definition.visualKey, milestoneFocusMinutes: definition.milestoneFocusMinutes, unlockedAt: session.completedAt));
      }
    }
    return entries;
  }

  List<RewardTrackItem> get rewardTrack => _rewardDefinitions.map((definition) {
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
          isAvailable: claim == null && totalFocusMinutes >= definition.focusMinuteTarget,
          claimedAt: claim?.claimedAt,
        );
      }).toList();

  RewardTrackItem? get nextAvailableReward {
    for (final reward in rewardTrack) {
      if (reward.isAvailable) return reward;
    }
    return null;
  }

  RewardTrackItem? get upcomingReward {
    for (final reward in rewardTrack) {
      if (!reward.isClaimed) return reward;
    }
    return null;
  }

  int get focusMinutesToNextReward {
    final reward = upcomingReward;
    if (reward == null) return 0;
    return max(0, reward.focusMinuteTarget - totalFocusMinutes);
  }

  List<AchievementStatus> get achievements => _achievementDefinitions.map((definition) {
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

  Future<void> initialize() async {
    if (_isInitialized || _isLoading) return;
    await reloadForCurrentUser();
  }

  Future<void> reloadForCurrentUser() async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();
    final activeUserId = await _onboardingStorageService.getActiveUserId();
    if (activeUserId == null || activeUserId.isEmpty) {
      _activeUserId = null;
      _profile = _emptyProfile();
      _focusSessions = [];
      _plantedItems = [];
      _notifications = [];
      _rewardClaims = [];
      _achievementUnlocks = [];
      _dailyGoalState = DailyGoalState.defaults();
      _ambientSoundPreference = AmbientSoundPreference.defaults();
      _isInitialized = true;
      _isLoading = false;
      notifyListeners();
      return;
    }
    final snapshot = await _localAppStateService.loadState(userId: activeUserId);
    _activeUserId = activeUserId;
    _profile = await _onboardingStorageService.getUserProfile(userId: activeUserId);
    _focusSessions = snapshot.focusSessions;
    _plantedItems = snapshot.plantedItems.isNotEmpty ? snapshot.plantedItems : _focusSessions.map(_plantFromSession).toList();
    _notifications = snapshot.notifications;
    _rewardClaims = snapshot.rewardClaims;
    _achievementUnlocks = snapshot.achievementUnlocks;
    _dailyGoalState = snapshot.dailyGoalState;
    _ambientSoundPreference = snapshot.ambientSoundPreference;
    _isInitialized = true;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> refreshProfile() async {
    if (_activeUserId == null || _activeUserId!.isEmpty) {
      await reloadForCurrentUser();
      return;
    }
    _profile = await _onboardingStorageService.getUserProfile(userId: _activeUserId);
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
    if (currentUserId == null || currentUserId.isEmpty) return;
    final updatedProfile = _profile.copyWith(
      userId: currentUserId,
      name: displayName.trim(),
      bio: bio.trim(),
      avatarId: avatarId,
      phone: phone.trim(),
      country: country.trim().toUpperCase(),
    );
    await _onboardingStorageService.updateUserProfile(updatedProfile);
    await _authLocalStorageService.syncCurrentProfileToLocalAccount(updatedProfile);
    _profile = updatedProfile;
    notifyListeners();
  }

  Future<void> updateDailyGoalMinutes(int minutes) async {
    _dailyGoalState = _dailyGoalState.copyWith(goalMinutes: minutes.clamp(10, 360));
    await _persistState();
    notifyListeners();
  }

  Future<void> updateAmbientSoundPreference({String? selectedTrackId, double? volume}) async {
    _ambientSoundPreference = _ambientSoundPreference.copyWith(
      selectedTrackId: selectedTrackId,
      volume: volume?.clamp(0.0, 1.0),
    );
    await _persistState();
    notifyListeners();
  }

  Future<FocusSessionCompletionResult?> recordCompletedFocusSession({
    required int durationMinutes,
    required int interruptionCount,
    required String categoryId,
    required String categoryLabel,
    DateTime? startedAt,
    DateTime? completedAt,
  }) async {
    final currentUserId = _activeUserId;
    if (currentUserId == null || currentUserId.isEmpty) return null;
    final beforeStreak = currentStreak;
    final beforeStageId = currentGrowthStage.id;
    final beforeGoalReached = isDailyGoalReached;
    final normalizedDuration = durationMinutes.clamp(10, 180);
    final normalizedCategoryId = categoryId.trim().isEmpty ? 'deep_focus' : categoryId.trim();
    final normalizedCategoryLabel = categoryLabel.trim().isEmpty ? 'Deep Focus' : categoryLabel.trim();
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
    final plantedItem = _plantFromSession(session);
    _focusSessions = [..._focusSessions, session];
    _plantedItems = [..._plantedItems, plantedItem];
    _addNotification(
      title: 'Focus session completed',
      message: 'Session complete. You planted a ${plantedItem.plantTitle} from $normalizedDuration minutes of $normalizedCategoryLabel.',
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
    PlantGrowthStage? evolvedStage;
    final afterStage = currentGrowthStage;
    if (afterStage.id != beforeStageId) {
      evolvedStage = afterStage;
      _addNotification(
        title: 'Plant evolved',
        message: 'Your island reached the ${afterStage.title} stage after this session.',
        type: AppNotificationType.plantEvolved,
        createdAt: now,
      );
    }
    final goalReachedNow = !beforeGoalReached && isDailyGoalReached;
    if (goalReachedNow) {
      _dailyGoalState = _dailyGoalState.copyWith(lastCelebratedDateKey: _todayKey());
      _addNotification(
        title: 'Daily goal reached',
        message: 'You reached today\'s goal with $todayFocusMinutes of focused work.',
        type: AppNotificationType.goalReached,
        createdAt: now,
      );
    }
    _unlockAchievementsIfNeeded(now);
    await _persistState();
    notifyListeners();
    return FocusSessionCompletionResult(
      session: session,
      plantedItem: plantedItem,
      dailyGoalReachedNow: goalReachedNow,
      evolvedGrowthStage: evolvedStage,
    );
  }

  Future<void> claimNextReward() async {
    final reward = nextAvailableReward;
    if (reward == null) return;
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
      message: 'You claimed "${reward.title}" for reaching ${reward.focusMinuteTarget} focus minutes.',
      type: AppNotificationType.rewardEarned,
      createdAt: claimedAt,
    );
    await _persistState();
    notifyListeners();
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    var changed = false;
    _notifications = _notifications.map((notification) {
      if (notification.id != notificationId || notification.isRead) return notification;
      changed = true;
      return notification.copyWith(isRead: true);
    }).toList();
    if (!changed) return;
    await _persistState();
    notifyListeners();
  }

  Future<void> markAllNotificationsAsRead() async {
    if (_notifications.every((notification) => notification.isRead)) return;
    _notifications = _notifications.map((notification) => notification.copyWith(isRead: true)).toList();
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
    if (currentUserId == null || currentUserId.isEmpty) return;
    _focusSessions = [];
    _plantedItems = [];
    _notifications = [];
    _rewardClaims = [];
    _achievementUnlocks = [];
    _dailyGoalState = _dailyGoalState.copyWith(clearCelebratedDate: true);
    await _localAppStateService.clearState(currentUserId);
    await _persistState();
    notifyListeners();
  }

  void _unlockAchievementsIfNeeded(DateTime unlockedAt) {
    final unlockedIds = _achievementUnlocks.map((item) => item.id).toSet();
    for (final definition in _achievementDefinitions) {
      final currentValue = _achievementValueFor(definition.progressType);
      if (currentValue >= definition.targetValue && !unlockedIds.contains(definition.id)) {
        _achievementUnlocks = [..._achievementUnlocks, AchievementUnlock(id: definition.id, unlockedAt: unlockedAt)];
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
    if (orderedDays.isEmpty) return 0;
    final today = DateUtils.dateOnly(DateTime.now());
    final latestDifference = today.difference(orderedDays.first).inDays;
    if (latestDifference > 1) return 0;
    var streak = 1;
    for (var index = 0; index < orderedDays.length - 1; index++) {
      final difference = orderedDays[index].difference(orderedDays[index + 1]).inDays;
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
    if (orderedDays.isEmpty) return 0;
    var longest = 1;
    var current = 1;
    for (var index = 1; index < orderedDays.length; index++) {
      final difference = orderedDays[index].difference(orderedDays[index - 1]).inDays;
      if (difference == 1) {
        current++;
        if (current > longest) longest = current;
      } else {
        current = 1;
      }
    }
    return longest;
  }

  List<DateTime> _uniqueSessionDays(List<FocusSessionRecord> sessions) {
    final uniqueDays = sessions.map((session) => DateUtils.dateOnly(session.completedAt)).toSet().toList()..sort((a, b) => b.compareTo(a));
    return uniqueDays;
  }

  PlantedItemRecord _plantFromSession(FocusSessionRecord session) {
    final definition = _plantDefinitionFor(session.durationMinutes);
    return PlantedItemRecord(
      id: 'plant_${session.completedAt.microsecondsSinceEpoch}',
      sessionId: session.id,
      durationMinutes: session.durationMinutes,
      categoryId: session.categoryId,
      categoryLabel: session.categoryLabel,
      plantedAt: session.completedAt,
      plantTypeId: definition.id,
      plantTitle: definition.title,
      visualKey: definition.visualKey,
    );
  }

  _PlantDefinition _plantDefinitionFor(int durationMinutes) {
    _PlantDefinition selected = _plantDefinitions.first;
    for (final definition in _plantDefinitions) {
      if (durationMinutes >= definition.minDurationMinutes) {
        selected = definition;
      }
    }
    return selected;
  }

  String _todayKey() => _dateKey(DateUtils.dateOnly(DateTime.now()));

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
    if (currentUserId == null || currentUserId.isEmpty) return;
    await _localAppStateService.saveState(
      currentUserId,
      AppStateSnapshot(
        focusSessions: _focusSessions,
        plantedItems: _plantedItems,
        notifications: _notifications,
        rewardClaims: _rewardClaims,
        achievementUnlocks: _achievementUnlocks,
        dailyGoalState: _dailyGoalState,
        ambientSoundPreference: _ambientSoundPreference,
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
  const _RewardDefinition(this.focusMinuteTarget, this.title, this.description);
}

class _ForestDefinition {
  final String id;
  final int milestoneFocusMinutes;
  final String title;
  final String description;
  final String visualKey;
  const _ForestDefinition(this.id, this.milestoneFocusMinutes, this.title, this.description, this.visualKey);
}

class _PlantDefinition {
  final String id;
  final String title;
  final int minDurationMinutes;
  final String visualKey;
  const _PlantDefinition(this.id, this.title, this.minDurationMinutes, this.visualKey);
}

class _AchievementDefinition {
  final String id;
  final String title;
  final String description;
  final String visualKey;
  final int targetValue;
  final _AchievementProgressType progressType;
  const _AchievementDefinition(this.id, this.title, this.description, this.visualKey, this.targetValue, this.progressType);
}

class _CategoryAccumulator {
  final String categoryId;
  final String label;
  int totalMinutes = 0;
  int sessionsCount = 0;
  _CategoryAccumulator(this.categoryId, this.label);
}

enum _AchievementProgressType { sessions, minutes, streak }
