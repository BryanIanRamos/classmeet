import 'package:flutter/material.dart';

class PlaceholderBody extends StatelessWidget {
  const PlaceholderBody({
    super.key,
    required this.title,
    this.actions = const [],
  });

  final String title;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 32),
            for (final a in actions) ...[a, const SizedBox(height: 12)],
          ],
        ),
      ),
    );
  }
}
