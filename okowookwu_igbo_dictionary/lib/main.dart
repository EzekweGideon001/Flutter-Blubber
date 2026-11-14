import 'dart:ui';

import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'services/error_report_service.dart';
import 'views/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterError.onError = (details) {
    ErrorReportService.recordError(
      context: 'flutter.framework',
      error: details.exception,
      stackTrace: details.stack,
    );
    FlutterError.presentError(details);
  };
  PlatformDispatcher.instance.onError = (error, stackTrace) {
    ErrorReportService.recordError(
      context: 'flutter.platform',
      error: error,
      stackTrace: stackTrace,
    );
    return true;
  };
  ErrorWidget.builder = (_) =>
      const Center(child: Text('O nwe ihe ghara agha. Biko nwàgharịa.'));
  runApp(const IgboDictionaryApp());
}

class IgboDictionaryApp extends StatelessWidget {
  const IgboDictionaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ọkọwookwu',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
    );
  }
}
