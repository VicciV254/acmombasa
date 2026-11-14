import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../core/sync/sync_controller.dart';
import '../../auth/presentation/sign_in_screen.dart';
import '../../directory/presentation/visitors_directory_screen.dart';
import '../../history/presentation/visit_history_screen.dart';
import '../../programs/presentation/programs_screen.dart';
import '../../reports/presentation/reports_screen.dart';
import '../../dashboard/presentation/dashboard_screen.dart';
import '../domain/nav_destination.dart';
import 'placeholder_screen.dart';
import 'widgets/app_sidebar.dart';
import 'widgets/app_top_bar.dart';

/// Top bar + sidebar + the currently selected module.
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  NavDestination _selected = NavDestination.dashboard;

  @override
  void initState() {
    super.initState();
    // Begin background cloud sync (does nothing when cloud isn't configured).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(syncControllerProvider.notifier).start();
    });
  }

  Future<void> _signOut() async {
    await ref.read(sessionProvider.notifier).signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => SignInScreen(
          mode: AuthMode.signIn,
          onSignedIn: (ctx) => Navigator.of(ctx).pushReplacement(
            MaterialPageRoute<void>(builder: (_) => const AppShell()),
          ),
        ),
      ),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 960;
          return Column(
            children: [
              AppTopBar(compact: compact, onSignOut: _signOut),
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
        NavDestination.visitorsDirectory => const VisitorsDirectoryScreen(),
        NavDestination.visitHistory => const VisitHistoryScreen(),
        NavDestination.programsAndActivities => const ProgramsScreen(),
        NavDestination.reports => const ReportsScreen(),
        _ => const SizedBox.shrink(),
      };
    }
    return PlaceholderScreen(title: _selected.label, icon: _selected.icon);
  }
}
