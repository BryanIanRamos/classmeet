import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:practice1/router/router_names.dart';

class GenerateScreen extends StatelessWidget {
  const GenerateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(title: Text('Generate Screen')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Back to login"),
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
