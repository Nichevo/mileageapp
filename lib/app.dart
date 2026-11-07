import 'package:flutter/material.dart';

import 'data/repository.dart';
import 'settings.dart';
import 'ui/history_page.dart';
import 'ui/home_page.dart';
import 'ui/insights_page.dart';
import 'ui/more_page.dart';

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

class _ShellState extends State<Shell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = const [HomePage(), HistoryPage(), InsightsPage(), MorePage()];
    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.speed_outlined), selectedIcon: Icon(Icons.speed), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.history), label: 'History'),
          NavigationDestination(icon: Icon(Icons.insights_outlined), selectedIcon: Icon(Icons.insights), label: 'Insights'),
          NavigationDestination(icon: Icon(Icons.more_horiz), label: 'More'),
        ],
      ),
    );
  }
}
