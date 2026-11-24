import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app_bottom_nav.dart';
import 'create_sheet_overlay.dart';

/// The tab shell around Home, Study, Play and Friends: the tab content, the
/// [AppBottomNav] and the Create overlay (opened by the centre "+").
///
/// The overlay covers the tab content only; the bar stays visible below it
/// with the "+" turned into "x". The system back button closes the overlay
/// before it leaves the tab.
class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  bool _createOpen = false;

  void _setCreateOpen(bool open) {
    if (_createOpen != open) setState(() => _createOpen = open);
  }

  /// Tapping the current tab again returns it to its root. A tab tap also
  /// closes the Create overlay.
  void _onTab(int index) {
    _setCreateOpen(false);
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_createOpen,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _setCreateOpen(false);
      },
      child: Scaffold(
        body: Column(
          children: [
            Expanded(
              child: MediaQuery.removePadding(
                context: context,
                removeBottom: true,
                child: Stack(
                  children: [
                    Positioned.fill(child: widget.navigationShell),
                    Positioned.fill(
                      child: CreateSheetOverlay(
                        open: _createOpen,
                        onClose: () => _setCreateOpen(false),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AppBottomNav(
              currentIndex: widget.navigationShell.currentIndex,
              onTabSelected: _onTab,
              createOpen: _createOpen,
              onCreatePressed: () => _setCreateOpen(!_createOpen),
            ),
          ],
        ),
      ),
    );
  }
}
