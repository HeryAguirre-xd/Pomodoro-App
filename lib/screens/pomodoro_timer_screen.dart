import 'dart:async';
import 'package:flutter/material.dart';
import '../models/timer_mode.dart';
import '../widgets/mode_chip.dart';
import '../widgets/circular_progress_painter.dart';
import 'settings_screen.dart';

class PomodoroTimer extends StatefulWidget {
  const PomodoroTimer({super.key});

  @override
  State<PomodoroTimer> createState() => _PomodoroTimerState();
}

class _PomodoroTimerState extends State<PomodoroTimer>
    with TickerProviderStateMixin {
  // Timer settings (in minutes) - now modifiable
  int workDuration = 25;
  int shortBreakDuration = 5;
  int longBreakDuration = 15;

  Timer? _timer;
  int _secondsRemaining = 25 * 60;
  int _totalSeconds = 25 * 60;
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

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsScreen(
          workDuration: workDuration,
          shortBreakDuration: shortBreakDuration,
          longBreakDuration: longBreakDuration,
          onSave: (work, shortBreak, longBreak) {
            setState(() {
              workDuration = work;
              shortBreakDuration = shortBreak;
              longBreakDuration = longBreak;

              // Update current timer if not running
              if (!_isRunning) {
                switch (_currentMode) {
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
              }
            });
          },
        ),
      ),
    );
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
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: _openSettings,
          ),
        ],
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
                  ModeChip(
                    label: 'Work',
                    icon: Icons.work_outline,
                    isSelected: _currentMode == TimerMode.work,
                    color: Colors.red.shade400,
                    onTap: () => _switchMode(TimerMode.work),
                  ),
                  const SizedBox(width: 12),
                  ModeChip(
                    label: 'Break',
                    icon: Icons.coffee_outlined,
                    isSelected: _currentMode == TimerMode.shortBreak,
                    color: Colors.green.shade400,
                    onTap: () => _switchMode(TimerMode.shortBreak),
                  ),
                  const SizedBox(width: 12),
                  ModeChip(
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
                          painter: CircularProgressPainter(
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
                  // ignore: deprecated_member_use
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
                  // ignore: deprecated_member_use
                  color: theme.colorScheme.surfaceContainerHighest.withOpacity(
                    0.3,
                  ),
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
                            // ignore: deprecated_member_use
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
