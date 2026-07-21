import 'package:flutter/material.dart';
import 'package:practice1/core/router/app_router.dart';
import 'package:provider/provider.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: const [],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: true,
        title: 'ClassMeet',
        // theme: AppBarTheme.lightTheme,
        routerConfig: AppRouter.instance,
      ),
    );
  }
}
