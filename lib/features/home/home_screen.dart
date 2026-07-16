import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:practice1/router/router_names.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home Screen')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Navigate"),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // GoRouter.of(context).go('/');
                context.goNamed(RouterNames.home);
              },
              child: Text("Welcome Screen"),
            ),

            SizedBox(height: 25),

            ElevatedButton(
              onPressed: () {
                context.goNamed(RouterNames.dashboard);
              },
              child: Text('Dashboard Screen'),
            ),

            ElevatedButton(
              onPressed: () {
                context.goNamed(
                  RouterNames.study,
                  pathParameters: {'name': 'Bryan'},
                );
              },
              child: Text('Study Screen'),
            ),

            ElevatedButton(
              onPressed: () {
                context.goNamed(RouterNames.generate);
              },
              child: Text('Generate Screen'),
            ),

            ElevatedButton(
              onPressed: () {
                context.goNamed(RouterNames.feed);
              },
              child: Text('Feed Screen'),
            ),

            ElevatedButton(
              onPressed: () {
                context.goNamed(RouterNames.messages);
              },
              child: Text('Messages Screen'),
            ),
          ],
        ),
      ),
    );
  }
}
