import 'package:flutter/material.dart';

import 'data/repository.dart';
import 'settings.dart';
import 'ui/history_page.dart';
import 'ui/home_page.dart';
import 'ui/insights_page.dart';
import 'ui/more_page.dart';
import 'ui/trips_page.dart';
import 'trips/recorder.dart';
import 'trips/trip_lookups.dart';
import 'platform/home_sync.dart';
import 'ui/care_page.dart';
import 'ui/fillup_form.dart';

/// Gives every page access to the repository and settings.
class AppScope extends InheritedWidget {
  final Repository repo;
  final Settings settings;
  const AppScope({super.key, required this.repo, required this.settings, required super.child});

  static AppScope of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<AppScope>()!;

  @override
  bool updateShouldNotify(AppScope oldWidget) => false;
}

class MileageApp extends StatelessWidget {
  final Repository repo;
  final Settings settings;
  const MileageApp({super.key, required this.repo, required this.settings});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF1F6F3F);
    return AppScope(
      repo: repo,
      settings: settings,
      child: MaterialApp(
        title: 'MileageLog',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: seed),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark),
          useMaterial3: true,
        ),
        // Keep every page clear of the phone's navigation bar. The strip
        // underneath matches the bottom menu's colour.
        builder: (context, child) => ColoredBox(
          color: Theme.of(context).colorScheme.surfaceContainer,
          child: SafeArea(top: false, left: false, right: false, child: child ?? const SizedBox()),
        ),
        home: ValueListenableBuilder<String?>(
          valueListenable: settings.activeVehicle,
          builder: (context, id, _) => Shell(key: ValueKey(id)),
        ),
      ),
    );
  }
}

class Shell extends StatefulWidget {
  const Shell({super.key});
  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> with WidgetsBindingObserver {
  int _index = 0;
  HomeSyncWatcher? _watcher;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _onOpen());
  }

  @override
  void dispose() {
    _watcher?.stop();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _onOpen();
  }

  /// Opens the screen a widget or notification asked for.
  Future<void> _handleLaunchAction() async {
    final action = await HomeSync.consumeLaunchAction();
    if (action == null || !mounted) return;
    final nav = Navigator.of(context);
    nav.popUntil((r) => r.isFirst);
    switch (action) {
      case 'fillup':
        setState(() => _index = 0);
        nav.push(MaterialPageRoute(builder: (_) => const FillUpForm()));
      case 'trips':
        setState(() => _index = 2);
      case 'care':
        nav.push(MaterialPageRoute(builder: (_) => const CarCarePage()));
      default:
        setState(() => _index = 0);
    }
  }

  /// Saves any trips that finished while the app was closed, and handles the
  /// "Connected to your car, tap to start" notification.
  Future<void> _onOpen() async {
    if (!TripRecorder.supported || !mounted) return;
    final scope = AppScope.of(context);
    if (_watcher == null) {
      _watcher = HomeSyncWatcher(scope.repo, scope.settings)..start();
    } else {
      _watcher!.poke(); // dates move on; refresh widgets and reminders
    }
    try {
      await _handleLaunchAction();
      await TripRecorder.ingest(scope.repo, scope.settings.activeVehicleId!);
      lookUpRecentTrips(scope.repo, scope.settings);
      if (await TripRecorder.consumeStartRequest()) {
        if (mounted) setState(() => _index = 2);
        if (await TripRecorder.currentTripId() == null) await TripRecorder.startManual();
      }
    } catch (_) {
      // Never block the app opening on trip housekeeping.
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = const [HomePage(), HistoryPage(), TripsPage(), InsightsPage(), MorePage()];
    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.speed_outlined), selectedIcon: Icon(Icons.speed), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.history), label: 'History'),
          NavigationDestination(icon: Icon(Icons.route_outlined), selectedIcon: Icon(Icons.route), label: 'Trips'),
          NavigationDestination(icon: Icon(Icons.insights_outlined), selectedIcon: Icon(Icons.insights), label: 'Insights'),
          NavigationDestination(icon: Icon(Icons.more_horiz), label: 'More'),
        ],
      ),
    );
  }
}
