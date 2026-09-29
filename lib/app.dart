import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'screens/profile_setup_screen.dart';
import 'screens/settings_screen.dart';
import 'services/profile_store.dart';
import 'services/theme_store.dart';
import 'theme/app_theme.dart';

class SikoApp extends StatelessWidget {
  const SikoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeStore.instance,
      builder: (context, _) => MaterialApp(
        title: 'Siko AI',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeStore.instance.isDark ? ThemeMode.dark : ThemeMode.light,
        home: ListenableBuilder(
          listenable: ProfileStore.instance,
          builder: (context, _) {
            final profile = ProfileStore.instance.profile;
            if (profile == null) return const ProfileSetupScreen();
            return const HomeScreen();
          },
        ),
        routes: {
          '/home': (_) => const HomeScreen(),
          '/profile': (_) => const ProfileSetupScreen(editMode: true),
          '/settings': (_) => const SettingsScreen(),
        },
      ),
    );
  }
}
