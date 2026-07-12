import 'package:flutter/material.dart';
import 'package:practice1/features/welcome_screen.dart';

void main() {
  runApp(const WelcomeApp());
}

// Box Layout Widget
// Temporary Widget
class BoxLayout extends StatelessWidget {
  final double width;
  final double height;
  final String title;

  const BoxLayout({
    super.key,
    required this.width,
    required this.height,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(border: Border.all(color: Colors.amber)),
      child: Center(child: Text(title)),
    );
  }
}
