import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../assets/app_icons.dart';

/// The tab shell around Home, Study, Play and Friends.
///
/// Temporary: a plain Material bar so the four branches can be switched.
/// Task 3.2 replaces it with `AppBottomNav` (5 slots, line selector, the
/// centre "+" that opens the Create overlay and turns into ✕).
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  /// Tapping the current tab again returns it to its root.
  void _onTap(int index) => navigationShell.goBranch(
    index,
    initialLocation: index == navigationShell.currentIndex,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onTap,
        destinations: const [
          NavigationDestination(icon: Icon(AppIcons.house), label: 'Home'),
          NavigationDestination(icon: Icon(AppIcons.bookOpen), label: 'Study'),
          NavigationDestination(icon: Icon(AppIcons.gamepad2), label: 'Play'),
          NavigationDestination(icon: Icon(AppIcons.users), label: 'Friends'),
        ],
      ),
    );
  }
}
