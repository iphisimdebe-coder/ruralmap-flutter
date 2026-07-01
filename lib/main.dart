import 'package:flutter/material.dart';

import 'screens/app_shell_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const UmlalaziCensusApp());
}

class UmlalaziCensusApp extends StatelessWidget {
  const UmlalaziCensusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Umlalazi Census',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const AppShellScreen(),
    );
  }
}
