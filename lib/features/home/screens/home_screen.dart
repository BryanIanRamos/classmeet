import 'package:flutter/material.dart';
import 'package:practice1/router/route_names.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to Practice 1',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () =>
                  Navigator.pushNamed(context, RouteNames.dashboard),
              child: const Text('Go to Dashboard'),
            ),
            ElevatedButton(
              onPressed: () =>
                  Navigator.pushNamed(context, RouteNames.announcement),
              child: const Text('Go to Announcements'),
            ),
          ],
        ),
      ),
    );
  }
}
