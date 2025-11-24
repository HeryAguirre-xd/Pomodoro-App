import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

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

enum TimerMode { work, shortBreak, longBreak }

class PomodoroTimer extends StatefulWidget {
  const PomodoroTimer({super.key});

  @override
  State<PomodoroTimer> createState() => _PomodoroTimerState();
}

class _PomodoroTimerState extends State<PomodoroTimer>
    with TickerProviderStateMixin {
  // Timer settings (in minutes)
  static const int workDuration = 25;
  static const int shortBreakDuration = 5;
  static const int longBreakDuration = 15;

  Timer? _timer;
  int _secondsRemaining = workDuration * 60;
  int _totalSeconds = workDuration * 60;
  bool _isRunning = false;
  TimerMode _currentMode = TimerMode.work;
  int _completedSessions = 0;

  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
  }

  void _startTimer() {
    if (_isRunning) return;

    setState(() => _isRunning = true);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _onTimerComplete();
        }
      });
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() => _isRunning = false);
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _secondsRemaining = _totalSeconds;
    });
  }

  void _onTimerComplete() {
    _timer?.cancel();
    setState(() => _isRunning = false);

    if (_currentMode == TimerMode.work) {
      _completedSessions++;
      // After 4 work sessions, take a long break
      if (_completedSessions % 4 == 0) {
        _switchMode(TimerMode.longBreak);
      } else {
        _switchMode(TimerMode.shortBreak);
      }
    } else {
      _switchMode(TimerMode.work);
    }
  }

  void _switchMode(TimerMode newMode) {
    setState(() {
      _currentMode = newMode;
      switch (newMode) {
        case TimerMode.work:
          _totalSeconds = workDuration * 60;
          break;
        case TimerMode.shortBreak:
          _totalSeconds = shortBreakDuration * 60;
          break;
        case TimerMode.longBreak:
          _totalSeconds = longBreakDuration * 60;
          break;
      }
      _secondsRemaining = _totalSeconds;
    });
  }

  Color _getModeColor() {
    switch (_currentMode) {
      case TimerMode.work:
        return Colors.red.shade400;
      case TimerMode.shortBreak:
        return Colors.green.shade400;
      case TimerMode.longBreak:
        return Colors.blue.shade400;
    }
  }

  String _getModeTitle() {
    switch (_currentMode) {
      case TimerMode.work:
        return 'Focus Time';
      case TimerMode.shortBreak:
        return 'Short Break';
      case TimerMode.longBreak:
        return 'Long Break';
    }
  }

  String _getMotivationalText() {
    if (_currentMode == TimerMode.work) {
      return 'Stay focused and crush your goals!';
    } else {
      return 'Relax and recharge your mind!';
    }
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = 1 - (_secondsRemaining / _totalSeconds);
    final modeColor = _getModeColor();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('🎯 FocusLoop'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Mode selector chips
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _ModeChip(
                    label: 'Work',
                    icon: Icons.work_outline,
                    isSelected: _currentMode == TimerMode.work,
                    color: Colors.red.shade400,
                    onTap: () => _switchMode(TimerMode.work),
                  ),
                  const SizedBox(width: 12),
                  _ModeChip(
                    label: 'Break',
                    icon: Icons.coffee_outlined,
                    isSelected: _currentMode == TimerMode.shortBreak,
                    color: Colors.green.shade400,
                    onTap: () => _switchMode(TimerMode.shortBreak),
                  ),
                  const SizedBox(width: 12),
                  _ModeChip(
                    label: 'Long',
                    icon: Icons.beach_access_outlined,
                    isSelected: _currentMode == TimerMode.longBreak,
                    color: Colors.blue.shade400,
                    onTap: () => _switchMode(TimerMode.longBreak),
                  ),
                ],
              ),
              const Spacer(),

              // Circular progress timer
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 280,
                    height: 280,
                    child: AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return CustomPaint(
                          painter: _CircularProgressPainter(
                            progress: progress,
                            color: modeColor,
                            isRunning: _isRunning,
                            pulseValue: _pulseController.value,
                          ),
                        );
                      },
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _getModeTitle(),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatTime(_secondsRemaining),
                        style: TextStyle(
                          fontSize: 56,
                          fontWeight: FontWeight.bold,
                          color: modeColor,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Spacer(),

              // Motivational text
              Text(
                _getMotivationalText(),
                style: TextStyle(
                  fontSize: 16,
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Sessions completed indicator
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, color: modeColor, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Sessions completed: $_completedSessions',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),

              // Control buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Reset button
                  IconButton(
                    onPressed: _resetTimer,
                    icon: const Icon(Icons.refresh),
                    iconSize: 32,
                    color: theme.textTheme.bodyMedium?.color,
                  ),
                  const SizedBox(width: 32),
                  // Play/Pause button
                  GestureDetector(
                    onTap: _isRunning ? _pauseTimer : _startTimer,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: modeColor,
                        boxShadow: [
                          BoxShadow(
                            color: modeColor.withOpacity(0.4),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Icon(
                        _isRunning ? Icons.pause : Icons.play_arrow,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 32),
                  // Skip button
                  IconButton(
                    onPressed: _onTimerComplete,
                    icon: const Icon(Icons.skip_next),
                    iconSize: 32,
                    color: theme.textTheme.bodyMedium?.color,
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _ModeChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade400,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : Colors.grey.shade600,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final bool isRunning;
  final double pulseValue;

  _CircularProgressPainter({
    required this.progress,
    required this.color,
    required this.isRunning,
    required this.pulseValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;

    // Background circle
    final bgPaint = Paint()
      ..color = color.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 15;
    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 15
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );

    // Pulse effect when running
    if (isRunning) {
      final pulsePaint = Paint()
        ..color = color.withOpacity(0.3 * (1 - pulseValue))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawCircle(center, radius + 10 + (pulseValue * 10), pulsePaint);
    }
  }

  @override
  bool shouldRepaint(_CircularProgressPainter oldDelegate) =>
      progress != oldDelegate.progress ||
      isRunning != oldDelegate.isRunning ||
      pulseValue != oldDelegate.pulseValue;
}
