import 'dart:async';
import 'package:flutter/material.dart';

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
        scaffoldBackgroundColor: const Color(0xFFF5F7F2),
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
  static const int initialSeconds = 25 * 60;

  int remainingSeconds = initialSeconds;
  int points = 0;
  Timer? timer;
  bool isRunning = false;

  String get formattedTime {
    final minutes = (remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void startTimer() {
    if (isRunning) return;

    setState(() {
      isRunning = true;
    });

    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds > 0) {
        setState(() {
          remainingSeconds--;
        });
      } else {
        timer.cancel();
        setState(() {
          isRunning = false;
          points += 10;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Great job! You earned 10 points 🌱'),
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
      remainingSeconds = initialSeconds;
    });
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
        title: const Text('Focus Island'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Points Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 10,
                    color: Colors.black12,
                    offset: Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'Your Points',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$points',
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Timer Card
            Expanded(
              child: Center(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [
                      BoxShadow(
                        blurRadius: 12,
                        color: Colors.black12,
                        offset: Offset(0, 4),
                      )
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Focus Session',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        formattedTime,
                        style: const TextStyle(
                          fontSize: 56,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 30),

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
              ),
            ),

            const SizedBox(height: 20),

            // Island Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Island screen coming soon 🏝️'),
                    ),
                  );
                },
                child: const Text('Open Island'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}