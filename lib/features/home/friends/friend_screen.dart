import 'package:classmeet/shared/widgets/dispose.logger.dart';
import 'package:classmeet/shared/widgets/placeholder.dart';
import 'package:flutter/material.dart';

class FriendScreen extends StatelessWidget {
  const FriendScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DisposeLogger(
      name: 'Friends',
      child: Scaffold(
        appBar: AppBar(title: const Text('Friends')),
        body: PlaceholderBody(title: 'Friends'),
      ),
    );
  }
}
