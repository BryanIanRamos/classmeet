import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      title: "My Application",
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Column(
            children: [
              Expanded(flex: 2, child: Container(child: square())),
              SizedBox(height: 10),
              Expanded(flex: 1, child: Container(child: square())),
              SizedBox(height: 10),
              Expanded(flex: 7, child: Container(child: square())),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget square() {
  return Container(
    // width: 100,
    // height: 100,
    decoration: BoxDecoration(
      color: const Color.fromARGB(255, 70, 186, 103),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: const Color.fromARGB(31, 255, 0, 0), width: 2),
    ),
  );
}
