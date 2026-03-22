import 'dart:async';
import 'package:flutter/material.dart';

class DeepFocusProvider extends ChangeNotifier {
  int totalSeconds = 25 * 60;
  int remainingSeconds = 25 * 60;
  bool isRunning = false;
  bool showWarning = false;
  int exitAttempts = 0;

  Timer? _timer;

  double get progress {
    return 1 - (remainingSeconds / totalSeconds);
  }

  String get formattedTime {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void startFocus() {
    if (isRunning) return;

    isRunning = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds > 0) {
        remainingSeconds--;
        notifyListeners();
      } else {
        stopFocus();
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
    remainingSeconds = totalSeconds;
    showWarning = false;
    exitAttempts = 0;
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

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}