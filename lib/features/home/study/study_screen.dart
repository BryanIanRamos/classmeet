import 'package:classmeet/shared/widgets/dispose.logger.dart';
import 'package:classmeet/shared/widgets/placeholder.dart';
import 'package:flutter/material.dart';

class StudyScreen extends StatelessWidget {
  const StudyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DisposeLogger(
      name: 'Study',
      child: Scaffold(
        appBar: AppBar(title: const Text('Study ')),
        body: const PlaceholderBody(title: 'Study'),
      ),
    );
  }
}
