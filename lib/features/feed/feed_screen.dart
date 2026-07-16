import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:practice1/router/router_names.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(title: Text('News Feed')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Back to login'),
            SizedBox(height: 10),
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
