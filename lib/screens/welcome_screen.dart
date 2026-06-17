import 'package:flutter/material.dart';
import 'package:practice1/main.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(12),
        child: Container(
          alignment: Alignment.center,
          child: Center(
            child:
                // Text("Hello World"),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(color: Colors.green, width: 200, height: 200),
                    SizedBox(height: 15),
                    Text(
                      "ClassMeet",
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight(500),
                      ),
                    ),
                    SizedBox(
                      width: 300,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MainScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            13,
                            96,
                            15,
                          ),
                        ),
                        child: Text(
                          "Sign in",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight(700),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
          ),
        ),
      ),
    );
  }
}
