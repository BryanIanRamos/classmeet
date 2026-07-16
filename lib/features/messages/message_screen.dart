import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:practice1/router/router_names.dart';

class MessageScreen extends StatelessWidget {
  const MessageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Message Screen')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('back to login'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                context.goNamed(RouterNames.welcome);
              },
              child: Text('Back'),
            ),
          ],
        ),
      ),
    );
  }
}
