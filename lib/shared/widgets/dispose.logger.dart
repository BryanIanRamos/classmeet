import 'package:flutter/material.dart';

class DisposeLogger extends StatefulWidget {
  const DisposeLogger({super.key, required this.name, required this.child});

  final String name;
  final Widget child;

  @override
  State<DisposeLogger> createState() => _DisposeLoggerState();
}

class _DisposeLoggerState extends State<DisposeLogger> {
  @override
  void initState() {
    super.initState();
    super.initState();
    debugPrint('[INIT] ${widget.name}');
  }

  @override
  void dispose() {
    debugPrint('[DISPOSE] ${widget.name}');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
