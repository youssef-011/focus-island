import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const FocusIslandApp());
}

class FocusIslandApp extends StatelessWidget {
  const FocusIslandApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Focus Island',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: const Color(0xFFF4F8F2),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const int quickFocusSeconds = 10 * 60;
  static const int normalFocusSeconds = 25 * 60;
  static const int deepFocusSeconds = 50 * 60;

  int selectedDuration = normalFocusSeconds;
  int remainingSeconds = normalFocusSeconds;
  int points = 0;
  int sessions = 0;

  Timer? timer;
  bool isRunning = false;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      points = prefs.getInt('points') ?? 0;
      sessions = prefs.getInt('sessions') ?? 0;
    });
  }

  Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('points', points);
    await prefs.setInt('sessions', sessions);
  }

  void selectDuration(int seconds) {
    if (isRunning) return;
    setState(() {
      selectedDuration = seconds;
      remainingSeconds = seconds;
    });
  }

  void startTimer() {
    if (isRunning) return;

    setState(() {
      isRunning = true;
    });

    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (remainingSeconds > 0) {
        setState(() {
          remainingSeconds--;
        });
      } else {
        t.cancel();

        int earnedPoints = 10;
        if (selectedDuration == quickFocusSeconds) {
          earnedPoints = 5;
        } else if (selectedDuration == deepFocusSeconds) {
          earnedPoints = 25;
        }

        setState(() {
          isRunning = false;
          points += earnedPoints;
          sessions += 1;
        });

        saveData();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Session complete! +$earnedPoints points'),
          ),
        );
      }
    });
  }

  void pauseTimer() {
    timer?.cancel();
    setState(() {
      isRunning = false;
    });
  }

  void resetTimer() {
    timer?.cancel();
    setState(() {
      isRunning = false;
      remainingSeconds = selectedDuration;
    });
  }

  String get formattedTime {
    final minutes = (remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  String get islandStage {
    if (points < 20) return 'Tiny Island';
    if (points < 50) return 'Growing Island';
    if (points < 100) return 'Blooming Island';
    return 'Paradise Island';
  }

  String get islandEmoji {
    if (points < 20) return '🌱';
    if (points < 50) return '🌴';
    if (points < 100) return '🌺';
    return '🏝️';
  }

  double get progressToNextStage {
    if (points < 20) return points / 20;
    if (points < 50) return (points - 20) / 30;
    if (points < 100) return (points - 50) / 50;
    return 1;
  }

  String get nextStageText {
    if (points < 20) return '${20 - points} pts to Growing Island';
    if (points < 50) return '${50 - points} pts to Blooming Island';
    if (points < 100) return '${100 - points} pts to Paradise Island';
    return 'Max island stage reached';
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Widget buildDurationButton(String label, int seconds) {
    final bool isSelected = selectedDuration == seconds;

    return Expanded(
      child: GestureDetector(
        onTap: () => selectDuration(seconds),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? Colors.green : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.green.shade200),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.green.shade800,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Focus Island'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 10,
                    color: Colors.black12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'Your Progress',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    '$points Points',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$sessions Completed Sessions',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 10,
                    color: Colors.black12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'Choose Your Session',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      buildDurationButton('10 min', quickFocusSeconds),
                      const SizedBox(width: 10),
                      buildDurationButton('25 min', normalFocusSeconds),
                      const SizedBox(width: 10),
                      buildDurationButton('50 min', deepFocusSeconds),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Focus Timer',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    formattedTime,
                    style: const TextStyle(
                      fontSize: 54,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: isRunning ? null : startTimer,
                        child: const Text('Start'),
                      ),
                      ElevatedButton(
                        onPressed: isRunning ? pauseTimer : null,
                        child: const Text('Pause'),
                      ),
                      OutlinedButton(
                        onPressed: resetTimer,
                        child: const Text('Reset'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 10,
                    color: Colors.black12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'Island Progress',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    islandEmoji,
                    style: const TextStyle(fontSize: 70),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    islandStage,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: progressToNextStage,
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    nextStageText,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => IslandScreen(
                              points: points,
                              sessions: sessions,
                            ),
                          ),
                        );
                      },
                      child: const Text('Open Island'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class IslandScreen extends StatelessWidget {
  final int points;
  final int sessions;

  const IslandScreen({
    super.key,
    required this.points,
    required this.sessions,
  });

  String get islandStage {
    if (points < 20) return 'Tiny Island';
    if (points < 50) return 'Growing Island';
    if (points < 100) return 'Blooming Island';
    return 'Paradise Island';
  }

  String get islandEmoji {
    if (points < 20) return '🌱';
    if (points < 50) return '🌴';
    if (points < 100) return '🌺';
    return '🏝️';
  }

  String get islandDescription {
    if (points < 20) return 'Your island has just begun to grow.';
    if (points < 50) return 'Nice progress. Your island is getting greener.';
    if (points < 100) return 'Your island feels alive and beautiful.';
    return 'Your island is now a peaceful paradise.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Island'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 10,
                    color: Colors.black12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    islandEmoji,
                    style: const TextStyle(fontSize: 90),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    islandStage,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    islandDescription,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 10,
                    color: Colors.black12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'Island Stats',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Points: $points',
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Completed Sessions: $sessions',
                    style: const TextStyle(fontSize: 20),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}