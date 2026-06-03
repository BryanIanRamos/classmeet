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
              Expanded(
                flex: 2,
                child: square(
                  child: Padding(
                    padding: const EdgeInsets.all(30),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,

                          // ❗ FIX 2: Row is fine, but now it will properly align
                          children: [
                            Container(
                              height: 65,
                              width: 70,
                              decoration: BoxDecoration(border: Border.all()),
                            ),
                            const SizedBox(width: 10),
                            SizedBox(
                              height: 65,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Welcome User",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Text("Free Trial"),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // square() already returns a Container
              Expanded(
                flex: 1,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [Text("asdasd"), Text("asdasd"), Text("asdasd")],
                ),
              ),

              const SizedBox(height: 10),

              Expanded(
                flex: 7,
                child: square(child: const Center(child: Text("Top 2"))),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget square({required Widget child}) {
  return Container(
    width: double.infinity,
    height: double.infinity,
    decoration: BoxDecoration(
      color: const Color.fromARGB(255, 70, 186, 103),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: const Color.fromARGB(31, 255, 0, 0), width: 2),
    ),
    child: child,
  );
}
