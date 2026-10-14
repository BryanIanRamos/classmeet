import 'package:classmeet/shared/widgets/dispose.logger.dart';
import 'package:classmeet/shared/widgets/placeholder.dart';
import 'package:flutter/material.dart';

class PlayScreen extends StatelessWidget {
  const PlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DisposeLogger(
      name: 'Play',
      child: Scaffold(
        appBar: AppBar(title: const Text('Play')),
        body: const PlaceholderBody(title: 'Play'),
      ),
    );
  }
}
