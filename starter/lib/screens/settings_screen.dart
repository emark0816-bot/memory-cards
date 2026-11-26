import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/reminder_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _enabled = false;
  TimeOfDay _time = const TimeOfDay(hour: 20, minute: 0);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _enabled = prefs.getBool('reminderOn') ?? false;
      _time = TimeOfDay(
        hour: prefs.getInt('reminderHour') ?? 20,
        minute: prefs.getInt('reminderMinute') ?? 0,
      );
    });
  }

  // Apply the setting and save it
  Future<void> _update(bool enabled, TimeOfDay time) async {
    try {
      if (enabled) {
        final allowed = await requestPermission();
        if (!allowed) {
          _message('Please allow notifications in your phone settings');
          return;
        }
        await scheduleDailyReminder(time.hour, time.minute);
      } else {
        await cancelReminder();
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('reminderOn', enabled);
      await prefs.setInt('reminderHour', time.hour);
      await prefs.setInt('reminderMinute', time.minute);
      if (!mounted) return;
      setState(() {
        _enabled = enabled;
        _time = time;
      });
    } catch (e) {
      _message('Reminder error: $e');
    }
  }

  void _message(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null) await _update(_enabled, picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text('Daily reminder'),
            value: _enabled,
            onChanged: (value) => _update(value, _time),
          ),
          ListTile(
            title: const Text('Reminder time'),
            subtitle: Text(_time.format(context)),
            trailing: const Icon(Icons.access_time),
            onTap: _pickTime,
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () async {
              await requestPermission();
              await showTestNotification();
            },
            child: const Text('Send test notification'),
          ),
        ],
      ),
    );
  }
}