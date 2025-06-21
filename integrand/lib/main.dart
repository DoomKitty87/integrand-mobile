import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'config/dependencies.dart';
import 'config/app_settings.dart';
import 'ui/core/themes/integrand/theme.dart';

void main() {
  runApp(
    MultiProvider(
      providers: providerDependencies,
      child: MainApp(),
    )
  );
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: APP_NAME,
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      home: DefaultTextStyle(
        style: const TextStyle(
          fontFamily: 'Inter',
          color: Colors.white,
          decoration: TextDecoration.none,
        ),
        child: MediaQuery.withNoTextScaling(
          child: Text('Welcome to Integrand!'),
        ),
      ),
    );
  }
}