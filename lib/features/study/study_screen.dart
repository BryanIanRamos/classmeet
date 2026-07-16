import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class StudyScreen extends StatelessWidget {
  final String name;
  const StudyScreen({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Welcome $name')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Study Screen'),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                GoRouter.of(context).go('/');
              },
              child: Text('Back to MainScreen'),
            ),
          ],
        ),
      ),
    );
  }
}
