import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:practice1/router/router_names.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dashboard Screen')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Navigate to'),
            ElevatedButton(
              onPressed: () {
                context.goNamed('materials');
              },
              child: Text('Go to sub routes'),
            ),
            SizedBox(height: 5),
            ElevatedButton(
              onPressed: () {
                context.goNamed(RouterNames.welcome);
              },
              child: Text('Back Home'),
            ),
          ],
        ),
      ),
    );
  }
}
