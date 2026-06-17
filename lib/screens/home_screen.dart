import "package:flutter/material.dart";
import "package:practice1/screens/welcome_screen.dart";

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amberAccent,
        title: Text("Hello Bryan"),
        centerTitle: true,
        leading: IconButton(onPressed: () {}, icon: Icon(Icons.menu)),
        actions: <Widget>[
          IconButton(onPressed: () {}, icon: Icon(Icons.notifications)),
          IconButton(onPressed: () {}, icon: Icon(Icons.message)),
        ],
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => WelcomeScreen()),
            );
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent),
          child: Text(
            "Back to Login",
            style: TextStyle(color: Colors.blueAccent, fontSize: 34),
          ),
        ),
      ),
    );
  }
}
