import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../features/ambient_sounds/providers/ambient_sound_provider.dart';
import '../features/feedback/services/device_notification_service.dart';
import '../features/app_state/models/app_progress_models.dart';
import '../features/app_state/providers/app_state_provider.dart';

class DeepFocusProvider extends ChangeNotifier {
  static const int minDurationMinutes = 10;
  static const int maxDurationMinutes = 180;
  static const int defaultDurationMinutes = 25;
  static const List<int> quickDurationOptions = [25, 45, 60, 90];
  static const List<FocusCategoryOption> categoryOptions = [
    FocusCategoryOption(id: 'study', label: 'Study'),
    FocusCategoryOption(id: 'coding', label: 'Coding'),
    FocusCategoryOption(id: 'reading', label: 'Reading'),
    FocusCategoryOption(id: 'painting', label: 'Painting'),
    FocusCategoryOption(id: 'writing', label: 'Writing'),
    FocusCategoryOption(id: 'workout', label: 'Workout'),
    FocusCategoryOption(id: 'meditation', label: 'Meditation'),
    FocusCategoryOption(
      id: 'custom',
      label: 'Custom',
      allowsCustomLabel: true,
    ),
  ];

  int _selectedDurationMinutes = defaultDurationMinutes;
  int totalSeconds = defaultDurationMinutes * 60;
  int remainingSeconds = defaultDurationMinutes * 60;
  String _selectedCategoryId = categoryOptions.first.id;
  String _customCategoryLabel = '';
  bool isRunning = false;
  bool showWarning = false;
  int exitAttempts = 0;
  int _completionToken = 0;
  DateTime? _startedAt;
  AppStateProvider? _appStateProvider;
  AmbientSoundProvider? _ambientSoundProvider;
  final AudioPlayer _completionPlayer =
      AudioPlayer(playerId: 'focus_completion_chime');
  FocusSessionCompletionResult? _lastCompletionResult;
  String _completionMessage =
      'Great work. Your latest focus session was recorded.';

  Timer? _timer;

  int get completionToken => _completionToken;
  int get selectedDurationMinutes => _selectedDurationMinutes;
  String get selectedCategoryId => _selectedCategoryId;
  String get customCategoryLabel => _customCategoryLabel;
  bool get canEditSessionSetup => !isRunning && _startedAt == null;
  FocusSessionCompletionResult? get lastCompletionResult => _lastCompletionResult;
  String get completionMessage => _completionMessage;

  double get progress {
    if (totalSeconds <= 0) {
      return 0;
    }

    return 1 - (remainingSeconds / totalSeconds);
  }

  String get formattedTime {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get durationLabel => '$selectedDurationMinutes min';

  String get selectedCategoryLabel {
    final selectedOption = categoryOptions.firstWhere(
      (option) => option.id == _selectedCategoryId,
      orElse: () => categoryOptions.first,
    );

    if (!selectedOption.allowsCustomLabel) {
      return selectedOption.label;
    }

    final customLabel = _customCategoryLabel.trim();
    return customLabel.isEmpty ? selectedOption.label : customLabel;
  }

  void attachAppState(AppStateProvider appStateProvider) {
    _appStateProvider = appStateProvider;
  }

  void attachAmbientSound(AmbientSoundProvider ambientSoundProvider) {
    _ambientSoundProvider = ambientSoundProvider;
  }

  void setDurationMinutes(int durationMinutes) {
    if (!canEditSessionSetup) {
      return;
    }

    final normalizedDuration = durationMinutes.clamp(
      minDurationMinutes,
      maxDurationMinutes,
    );

    if (normalizedDuration == _selectedDurationMinutes) {
      return;
    }

    _selectedDurationMinutes = normalizedDuration;
    totalSeconds = normalizedDuration * 60;
    remainingSeconds = totalSeconds;
    notifyListeners();
  }

  void selectCategory(String categoryId) {
    if (!canEditSessionSetup) {
      return;
    }

    if (categoryId == _selectedCategoryId) {
      return;
    }

    _selectedCategoryId = categoryId;
    notifyListeners();
  }

  void setCustomCategoryLabel(String value) {
    if (!canEditSessionSetup) {
      return;
    }

    if (value == _customCategoryLabel) {
      return;
    }

    _customCategoryLabel = value;
    notifyListeners();
  }

  void startFocus() {
    if (isRunning) {
      return;
    }

    _startedAt ??= DateTime.now();
    isRunning = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds > 0) {
        remainingSeconds--;
        notifyListeners();
      } else {
        _completeFocusSession();
      }
    });
    notifyListeners();
  }

  void stopFocus() {
    _timer?.cancel();
    isRunning = false;
    notifyListeners();
  }

  void resetFocus() {
    _timer?.cancel();
    isRunning = false;
    totalSeconds = _selectedDurationMinutes * 60;
    remainingSeconds = totalSeconds;
    showWarning = false;
    exitAttempts = 0;
    _startedAt = null;
    notifyListeners();
  }

  void triggerWarning() {
    exitAttempts++;
    showWarning = true;
    notifyListeners();

    Future.delayed(const Duration(milliseconds: 900), () {
      showWarning = false;
      notifyListeners();
    });
  }

  void acknowledgeCompletion() {
    totalSeconds = _selectedDurationMinutes * 60;
    remainingSeconds = totalSeconds;
    exitAttempts = 0;
    showWarning = false;
    _startedAt = null;
    _lastCompletionResult = null;
    notifyListeners();
  }

  Future<void> _completeFocusSession() async {
    _timer?.cancel();
    isRunning = false;
    remainingSeconds = 0;
    final durationMinutes = totalSeconds ~/ 60;
    final result = await _appStateProvider?.recordCompletedFocusSession(
      durationMinutes: durationMinutes,
      interruptionCount: exitAttempts,
      categoryId: _selectedCategoryId,
      categoryLabel: selectedCategoryLabel,
      startedAt: _startedAt,
      completedAt: DateTime.now(),
    );
    if (result != null) {
      _lastCompletionResult = result;
      _completionMessage = _buildCompletionMessage(result);
      await _triggerCompletionFeedback(result);
    }
    _completionToken++;
    notifyListeners();
  }

  String _buildCompletionMessage(FocusSessionCompletionResult result) {
    final pieces = <String>[
      'You planted a ${result.plantedItem.plantTitle} after ${result.session.durationMinutes} minutes of ${result.session.categoryLabel}.',
      'Your forest, timeline, statistics, and profile were updated.',
    ];

    if (result.dailyGoalReachedNow) {
      pieces.add('Today\'s focus goal is complete.');
    }

    if (result.evolvedGrowthStage != null) {
      pieces.add(
        'Your island also evolved into ${result.evolvedGrowthStage!.title}.',
      );
    }

    return pieces.join(' ');
  }

  Future<void> _triggerCompletionFeedback(
    FocusSessionCompletionResult result,
  ) async {
    final notificationBody = _buildCompletionMessage(result);

    try {
      await HapticFeedback.mediumImpact();
      await HapticFeedback.vibrate();
    } catch (_) {
      // Ignore unsupported haptic feedback platforms.
    }

    try {
      await _completionPlayer.setVolume(
        ((_ambientSoundProvider?.volume ?? 0.6) * 0.85).clamp(0.2, 1.0),
      );
      await _completionPlayer.play(
        AssetSource('audio/completion_chime.wav'),
      );
    } catch (_) {
      // Keep the completion flow safe when audio playback is unavailable.
    }

    await deviceNotificationService.showSessionNotification(
      title: 'Session complete',
      body: notificationBody,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _completionPlayer.dispose();
    super.dispose();
  }
}
