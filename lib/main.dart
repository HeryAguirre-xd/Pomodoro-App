import 'package:flutter/material.dart';
import 'screens/pomodoro_timer_screen.dart';

void main() {
  runApp(const FocusLoopApp());
}

class FocusLoopApp extends StatelessWidget {
  const FocusLoopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FocusLoop',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      home: const PomodoroTimer(),
    );
  }
}
