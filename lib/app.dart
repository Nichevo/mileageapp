import 'package:flutter/material.dart';

import 'data/repository.dart';
import 'settings.dart';
import 'ui/history_page.dart';
import 'ui/home_page.dart';
import 'ui/insights_page.dart';
import 'ui/more_page.dart';
import 'ui/trips_page.dart';
import 'trips/recorder.dart';

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
        home: const Shell(),
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _onOpen());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _onOpen();
  }

  /// Saves any trips that finished while the app was closed, and handles the
  /// "Connected to your car, tap to start" notification.
  Future<void> _onOpen() async {
    if (!TripRecorder.supported || !mounted) return;
    final scope = AppScope.of(context);
    try {
      await TripRecorder.ingest(scope.repo, scope.settings.activeVehicleId!);
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
