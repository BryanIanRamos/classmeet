import 'package:flutter/material.dart';
import 'package:practice1/core/constants/app_theme.dart';

void main() {
  runApp(const WelcomeApp());
}

class WelcomeApp extends StatelessWidget {
  const WelcomeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.themeData,
      home: SafeArea(
        child: Scaffold(body: Center(child: Text('Hhead'))),
      ),
    );
  }
}
