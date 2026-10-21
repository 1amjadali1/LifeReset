import 'package:flutter/material.dart';

import '../core/constants/app_strings.dart';
import '../features/shell/main_shell_screen.dart';
import '../logic/app_state.dart';
import 'app_theme.dart';

/// The root application widget for Life Reset.
class LifeResetApp extends StatelessWidget {
  const LifeResetApp({super.key, required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    return AppStateScope(
      appState: appState,
      child: MaterialApp(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const MainShellScreen(),
      ),
    );
  }
}
