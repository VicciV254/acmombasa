import 'package:flutter/material.dart';

import '../../dashboard/presentation/dashboard_screen.dart';
import '../domain/nav_destination.dart';
import 'placeholder_screen.dart';
import 'widgets/app_sidebar.dart';
import 'widgets/app_top_bar.dart';

/// Top bar + sidebar + the currently selected module.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  NavDestination _selected = NavDestination.dashboard;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 960;
          return Column(
            children: [
              AppTopBar(compact: compact),
              Expanded(
                child: Row(
                  children: [
                    AppSidebar(
                      selected: _selected,
                      compact: compact,
                      onSelected: (d) => setState(() => _selected = d),
                    ),
                    Expanded(child: _buildContent()),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContent() {
    if (_selected.isImplemented) {
      return switch (_selected) {
        NavDestination.dashboard => const DashboardScreen(),
        _ => const SizedBox.shrink(),
      };
    }
    return PlaceholderScreen(title: _selected.label, icon: _selected.icon);
  }
}
