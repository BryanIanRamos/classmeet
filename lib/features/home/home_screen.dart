import 'package:classmeet/core/session/app_session.dart';
import 'package:classmeet/shared/widgets/dispose.logger.dart';
import 'package:classmeet/shared/widgets/placeholder.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DisposeLogger(
      name: 'Home',
      child: Scaffold(
        appBar: AppBar(title: const Text("Home")),
        body: PlaceholderBody(
          title: 'Home',
          actions: [
            OutlinedButton(
              onPressed: appSession.logOut,
              child: const Text('Log out (Testing)'),
            ),
          ],
        ),
      ),
    );
  }
}
