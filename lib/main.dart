import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app/app_colors.dart';
import 'app/life_reset_app.dart';
import 'logic/app_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI style (transparent status bar with dark icons for light background)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppColors.cardBackground,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  final appState = await AppState.create();

  runApp(LifeResetApp(appState: appState));
}
