import 'timer_mode.dart';

class Session {
  final String taskLabel;
  final DateTime completedAt;
  final int durationMinutes;
  final TimerMode mode;

  Session({
    required this.taskLabel,
    required this.completedAt,
    required this.durationMinutes,
    required this.mode,
  });

  String get formattedTime {
    final hour = completedAt.hour.toString().padLeft(2, '0');
    final minute = completedAt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String get formattedDate {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[completedAt.month - 1]} ${completedAt.day}';
  }
}

/// Global in-memory session history
class SessionHistory {
  static final List<Session> _sessions = [];

  static List<Session> get sessions => List.unmodifiable(_sessions);

  static void add(Session session) {
    _sessions.insert(0, session); // Most recent first
  }

  static void clear() {
    _sessions.clear();
  }

  static int get totalFocusMinutes {
    return _sessions
        .where((s) => s.mode == TimerMode.work)
        .fold(0, (sum, s) => sum + s.durationMinutes);
  }

  static int get sessionCount =>
      _sessions.where((s) => s.mode == TimerMode.work).length;
}
