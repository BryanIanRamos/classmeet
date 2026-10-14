import 'package:flutter/material.dart';

import 'core/router/app_router.dart';

class ClassMeetApp extends StatelessWidget {
  const ClassMeetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ClassMeet',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      routerConfig: appRouter,
    );
  }
}
