import 'package:flutter/material.dart';

import '../app.dart';
import '../platform/home_sync.dart';
import '../trips/recorder.dart';
import 'vehicle_page.dart';

class ReminderSettingsPage extends StatefulWidget {
  const ReminderSettingsPage({super.key});
  @override
  State<ReminderSettingsPage> createState() => _ReminderSettingsPageState();
}

class _ReminderSettingsPageState extends State<ReminderSettingsPage> with WidgetsBindingObserver {
  bool _notifications = true;
  double? _tank;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _check());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _check();
  }

  Future<void> _check() async {
    final scope = AppScope.of(context);
    final ok = await TripRecorder.hasPermission('notifications');
    final v = await scope.repo.vehicle(scope.settings.activeVehicleId!);
    if (mounted) {
      setState(() {
        _notifications = ok;
        _tank = v?.tankSize;
      });
    }
  }

  Future<void> _changed() async {
    final scope = AppScope.of(context);
    setState(() {});
    await HomeSync.refresh(scope.repo, scope.settings);
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context).settings;
    final t = Theme.of(context).textTheme;
    final time = TimeOfDay(hour: s.reminderHour, minute: s.reminderMinute);
    return Scaffold(
      appBar: AppBar(title: const Text('Reminders')),
      body: ListView(
        children: [
          if (!_notifications)
            Card(
              margin: const EdgeInsets.all(16),
              child: ListTile(
                leading: const Icon(Icons.notifications_off_outlined),
                title: const Text('Notifications are off for MileageLog'),
                trailing: TextButton(
                  onPressed: () async {
                    if (!await TripRecorder.requestPermission('notifications')) await TripRecorder.openAppSettings();
                    await _check();
                  },
                  child: const Text('Allow'),
                ),
              ),
            ),
          SwitchListTile(
            title: const Text('Remind me when things are due'),
            subtitle: const Text('Service items, WOF and rego (a month ahead too), insurance renewal and monthly tyre checks. A week before and on the day.'),
            value: s.remindersEnabled,
            onChanged: (v) async {
              await s.setRemindersEnabled(v);
              await _changed();
            },
          ),
          ListTile(
            enabled: s.remindersEnabled,
            leading: const Icon(Icons.schedule),
            title: const Text('Time of day'),
            subtitle: Text(time.format(context)),
            onTap: () async {
              final picked = await showTimePicker(context: context, initialTime: time);
              if (picked == null) return;
              await s.setReminderTime(picked.hour, picked.minute);
              await _changed();
            },
          ),
          SwitchListTile(
            title: const Text('Pay a toll'),
            subtitle: const Text('After a trip on a toll road, until a toll is logged for it. Turn off if a toll account pays for you.'),
            value: s.tollReminders && s.remindersEnabled,
            onChanged: !s.remindersEnabled
                ? null
                : (v) async {
                    await s.setTollReminders(v);
                    await _changed();
                  },
          ),
          SwitchListTile(
            title: const Text('Fuel getting low'),
            subtitle: Text(_tank == null
                ? 'Needs the tank size on the Vehicle page'
                : 'From your usual driving, when about 80 km of range is left'),
            value: s.fuelReminders && s.remindersEnabled,
            onChanged: !s.remindersEnabled
                ? null
                : (v) async {
                    await s.setFuelReminders(v);
                    await _changed();
                  },
          ),
          if (_tank == null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () async {
                    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const VehiclePage()));
                    await _check();
                  },
                  child: const Text('Set tank size'),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Reminders are worked out on the phone from your schedule and driving, and kept up to date whenever the app opens. They carry on after a restart.',
              style: t.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
