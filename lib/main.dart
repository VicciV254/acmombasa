import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/services/app_initializer.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/sign_in_screen.dart';
import 'features/shell/presentation/app_shell.dart';
import 'features/splash/presentation/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: AmericanCornerApp()));
}

class AmericanCornerApp extends StatelessWidget {
  const AmericanCornerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'American Corner Mombasa',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const SplashScreen(destinationBuilder: _destinationFor),
    );
  }
}

Widget _destinationFor(BuildContext context, StartupDestination destination) {
  void openShell(BuildContext ctx) => Navigator.of(ctx).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const AppShell()),
      );

  return switch (destination) {
    StartupDestination.dashboard => const AppShell(),
    StartupDestination.signIn =>
      SignInScreen(mode: AuthMode.signIn, onSignedIn: openShell),
    StartupDestination.setup =>
      SignInScreen(mode: AuthMode.setup, onSignedIn: openShell),
  };
}
