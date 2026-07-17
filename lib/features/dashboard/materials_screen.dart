import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MaterialsScreen extends StatelessWidget {
  const MaterialsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Materials Page')),
      body: Center(
        child: Column(
          children: [
            Text('Materials Screen'),
            ElevatedButton(
              onPressed: () {
                context.goNamed('home');
              },
              child: Text('Go home'),
            ),
          ],
        ),
      ),
    );
  }
}
