import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app.dart';
import '../data/database.dart';
import 'places_page.dart';
import '../trips/recorder.dart';

/// Walks through what Android needs for trips to start by themselves when
/// the phone connects to the car, and lets you pick the car.
class TripSettingsPage extends StatefulWidget {
  const TripSettingsPage({super.key});
  @override
  State<TripSettingsPage> createState() => _TripSettingsPageState();
}

class _TripSettingsPageState extends State<TripSettingsPage> with WidgetsBindingObserver {
  bool _location = false, _notifications = false, _background = false, _battery = false, _bluetooth = false;
  bool _autoStart = false;
  bool _loaded = false;
  List<Vehicle> _vehicles = const [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _check();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Coming back from a system settings screen: re-check everything.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _check();
  }

  Future<void> _check() async {
    final scope = AppScope.of(context);
    final r = await Future.wait([
      TripRecorder.hasPermission('location'),
      TripRecorder.hasPermission('notifications'),
      TripRecorder.hasPermission('backgroundLocation'),
      TripRecorder.batteryUnrestricted(),
      TripRecorder.hasPermission('bluetooth'),
    ]);
    final settings = scope.settings;
    final repo = scope.repo;
    await TripRecorder.syncCars(settings);
    final car = await TripRecorder.car();
    final vehicles = await repo.vehicles();
    if (!mounted) return;
    setState(() {
      _location = r[0];
      _notifications = r[1];
      _background = r[2];
      _battery = r[3];
      _bluetooth = r[4];
      _autoStart = car.autoStart;
      _vehicles = vehicles;
      _loaded = true;
    });
  }

  Future<void> _ask(String name) async {
    final ok = await TripRecorder.requestPermission(name);
    if (!ok && name == 'backgroundLocation') await TripRecorder.openAppSettings();
    await _check();
  }

  Future<void> _pickCar(Vehicle v) async {
    final settings = AppScope.of(context).settings;
    final mine = settings.vehicleCars[v.id];
    if (!_bluetooth && !await TripRecorder.requestPermission('bluetooth')) {
      await _check();
      return;
    }
    List<({String name, String address})> devices;
    try {
      devices = await TripRecorder.bondedDevices();
    } on PlatformException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? 'Bluetooth unavailable')));
      return;
    }
    if (!mounted) return;
    final picked = await showModalBottomSheet<({String name, String address})>(
      context: context,
      showDragHandle: true,
      builder: (c) => SafeArea(
        child: devices.isEmpty
            ? const Padding(padding: EdgeInsets.all(24), child: Text('No paired Bluetooth devices. Pair the phone with the car first.'))
            : ListView(
                shrinkWrap: true,
                children: [
                  Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 8), child: Text('Which Bluetooth is in the ${v.name}?')),
                  for (final d in devices)
                    ListTile(
                      leading: Icon(d.address == mine?.address ? Icons.check_circle : Icons.bluetooth),
                      title: Text(d.name),
                      subtitle: () {
                        final other = settings.vehicleForCar(d.address);
                        final name = _vehicles.where((x) => x.id == other && x.id != v.id).firstOrNull?.name;
                        return name == null ? null : Text('Now linked to $name');
                      }(),
                      onTap: () => Navigator.pop(c, d),
                    ),
                  if (mine != null)
                    ListTile(
                      leading: const Icon(Icons.link_off),
                      title: const Text('No Bluetooth for this vehicle'),
                      onTap: () => Navigator.pop(c, (name: '', address: '')),
                    ),
                ],
              ),
      ),
    );
    if (picked == null) return;
    await settings.setVehicleCar(v.id, picked.address.isEmpty ? null : (address: picked.address, name: picked.name));
    await TripRecorder.syncCars(settings);
    await _check();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cars = AppScope.of(context).settings.vehicleCars;
    final anyCar = cars.isNotEmpty;
    final ready = _location && _background && _battery && _bluetooth && anyCar;
    return Scaffold(
      appBar: AppBar(title: const Text('Auto-start with your car')),
      body: !_loaded
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Text('When the phone connects to the car\'s Bluetooth, a trip starts recording. It stops two minutes after the car disconnects, so a quick stop doesn\'t split the trip. Trips under 200 m are discarded.'),
                ),
                _step(1, 'Location while using the app', 'Needed for any trip recording.', _location, () => _ask('location')),
                _step(2, 'Notifications', 'Shows the recording notification with its Stop button.', _notifications, () => _ask('notifications')),
                _step(3, 'Location: Allow all the time', 'Lets a trip start while the app is closed. On the next screen choose "Allow all the time".', _background,
                    _location ? () => _ask('backgroundLocation') : null),
                _step(4, 'Battery: Unrestricted', 'Stops Android from blocking the recorder in the background.', _battery, () async {
                  await TripRecorder.requestBatteryUnrestricted();
                }),
                _step(5, 'Nearby devices (Bluetooth)', 'Only used to recognise the car connecting. No scanning.', _bluetooth, () => _ask('bluetooth')),
                ListTile(
                  leading: CircleAvatar(child: anyCar ? const Icon(Icons.check) : const Text('6')),
                  title: const Text('Each vehicle\'s Bluetooth'),
                  subtitle: const Text('Trips started by a vehicle\'s Bluetooth are saved to that vehicle, and the app switches to it while you drive.'),
                ),
                for (final v in _vehicles)
                  ListTile(
                    contentPadding: const EdgeInsets.only(left: 72, right: 16),
                    leading: Icon(cars[v.id] == null ? Icons.bluetooth_disabled : Icons.bluetooth_connected),
                    title: Text(v.name),
                    subtitle: Text(cars[v.id]?.name ?? 'Not linked'),
                    trailing: TextButton(onPressed: () => _pickCar(v), child: Text(cars[v.id] == null ? 'Choose' : 'Change')),
                  ),
                const Divider(),
                SwitchListTile(
                  title: const Text('Start trips automatically'),
                  subtitle: Text(ready
                      ? 'Ready'
                      : !anyCar
                          ? 'Choose a vehicle\'s Bluetooth first'
                          : 'Finish the steps above for this to work reliably'),
                  value: _autoStart,
                  onChanged: !anyCar
                      ? null
                      : (v) async {
                          await TripRecorder.setAutoStart(v);
                          await _check();
                        },
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Text(
                    'If Android still blocks a background start, you\'ll get a "Connected to your car" notification instead. Tap it to start the trip. Samsung phones: also check Settings > Battery > Background usage limits and make sure MileageLog isn\'t in "Sleeping apps".',
                    style: t.bodySmall,
                  ),
                ),
                const Divider(),
                SwitchListTile(
                  title: const Text('Traffic lights and road types'),
                  subtitle: const Text(
                      'After a trip, look up the roads you drove on OpenStreetMap to count traffic lights and split the distance by road type. '
                      'A simplified route is sent to the free Overpass service, leaving off the first and last 300 m.'),
                  value: AppScope.of(context).settings.roadLookup,
                  onChanged: (v) async {
                    await AppScope.of(context).settings.setRoadLookup(v);
                    setState(() {});
                  },
                ),
                SwitchListTile(
                  title: const Text('Weather and elevation'),
                  subtitle: const Text(
                      'After a trip, look up the weather at the time and the ground height along the route from the free Open-Meteo service. '
                      'The weather lookup sends a location rounded to about 1 km; the elevation lookup sends points along the route, leaving off the first and last 300 m.'),
                  value: AppScope.of(context).settings.weatherLookup,
                  onChanged: (v) async {
                    await AppScope.of(context).settings.setWeatherLookup(v);
                    setState(() {});
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.place_outlined),
                  title: const Text('Places'),
                  subtitle: Text('${AppScope.of(context).settings.places.length} named, such as Home and Work'),
                  onTap: () async {
                    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PlacesPage()));
                    setState(() {});
                  },
                ),
              ],
            ),
    );
  }

  Widget _step(int n, String title, String subtitle, bool done, VoidCallback? onFix) => ListTile(
        leading: CircleAvatar(
          backgroundColor: done ? Theme.of(context).colorScheme.primaryContainer : null,
          child: done ? const Icon(Icons.check) : Text('$n'),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: done ? null : TextButton(onPressed: onFix, child: const Text('Allow')),
      );
}
