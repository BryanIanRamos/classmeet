import "package:flutter/material.dart";
import "package:practice1/main.dart";

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 22, 189, 75),
        title: const Text("Profile Screen"),
        leading: IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MainScreen()),
            );
          },
          icon: Icon(Icons.arrow_back),
        ),
      ),
    );
  }
}
