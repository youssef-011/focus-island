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
  int seconds = 1500;
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

  void startTimer() {
    if (isRunning) return;

    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (seconds > 0) {
        setState(() => seconds--);
      } else {
        t.cancel();
        setState(() {
          isRunning = false;
          points += 10;
          sessions += 1;
        });
        saveData();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Nice! +10 points 🎉"),
          ),
        );
      }
    });

    setState(() => isRunning = true);
  }

  void pauseTimer() {
    timer?.cancel();
    setState(() => isRunning = false);
  }

  void resetTimer() {
    timer?.cancel();
    setState(() {
      seconds = 1500;
      isRunning = false;
    });
  }

  String formatTime() {
    int m = seconds ~/ 60;
    int s = seconds % 60;
    return "$m:${s.toString().padLeft(2, '0')}";
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Focus Island"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              "Points: $points",
              style: const TextStyle(fontSize: 24),
            ),
            Text(
              "Sessions: $sessions",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),

            Text(
              formatTime(),
              style: const TextStyle(fontSize: 50),
            ),

            const SizedBox(height: 30),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: startTimer,
                  child: const Text("Start"),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: pauseTimer,
                  child: const Text("Pause"),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: resetTimer,
                  child: const Text("Reset"),
                ),
              ],
            ),

            const SizedBox(height: 40),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => IslandScreen(points: points),
                  ),
                );
              },
              child: const Text("Go to Island 🏝️"),
            )
          ],
        ),
      ),
    );
  }
}

class IslandScreen extends StatelessWidget {
  final int points;

  const IslandScreen({super.key, required this.points});

  @override
  Widget build(BuildContext context) {
    String stage;
    String emoji;

    if (points < 20) {
      stage = "Tiny Island";
      emoji = "🌱";
    } else if (points < 50) {
      stage = "Growing Island";
      emoji = "🌳";
    } else {
      stage = "Big Island";
      emoji = "🏝️";
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Island"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 80),
            ),
            const SizedBox(height: 20),
            Text(
              stage,
              style: const TextStyle(fontSize: 28),
            ),
          ],
        ),
      ),
    );
  }
}