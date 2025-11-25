import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  final int workDuration;
  final int shortBreakDuration;
  final int longBreakDuration;
  final Function(int, int, int) onSave;

  const SettingsScreen({
    super.key,
    required this.workDuration,
    required this.shortBreakDuration,
    required this.longBreakDuration,
    required this.onSave,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late int _workDuration;
  late int _shortBreakDuration;
  late int _longBreakDuration;

  @override
  void initState() {
    super.initState();
    _workDuration = widget.workDuration;
    _shortBreakDuration = widget.shortBreakDuration;
    _longBreakDuration = widget.longBreakDuration;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          TextButton(
            onPressed: () {
              widget.onSave(
                _workDuration,
                _shortBreakDuration,
                _longBreakDuration,
              );
              Navigator.pop(context);
            },
            child: const Text('Save', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Timer Durations',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          _buildDurationCard(
            'Focus Time',
            _workDuration,
            Colors.red.shade400,
            Icons.work_outline,
            (value) => setState(() => _workDuration = value),
          ),
          const SizedBox(height: 16),
          _buildDurationCard(
            'Short Break',
            _shortBreakDuration,
            Colors.green.shade400,
            Icons.coffee_outlined,
            (value) => setState(() => _shortBreakDuration = value),
          ),
          const SizedBox(height: 16),
          _buildDurationCard(
            'Long Break',
            _longBreakDuration,
            Colors.blue.shade400,
            Icons.beach_access_outlined,
            (value) => setState(() => _longBreakDuration = value),
          ),
        ],
      ),
    );
  }

  Widget _buildDurationCard(
    String title,
    int value,
    Color color,
    IconData icon,
    Function(int) onChanged,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: value > 1 ? () => onChanged(value - 1) : null,
                  icon: const Icon(Icons.remove_circle_outline),
                  iconSize: 36,
                  color: color,
                ),
                Text(
                  '$value min',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                IconButton(
                  onPressed: value < 90 ? () => onChanged(value + 1) : null,
                  icon: const Icon(Icons.add_circle_outline),
                  iconSize: 36,
                  color: color,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
