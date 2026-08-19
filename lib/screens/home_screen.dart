import 'package:flutter/material.dart';
import 'package:practice1/screens/add_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(96, 50, 50, 50),
        centerTitle: true,
        title: Text('Todo list', style: TextStyle(color: Colors.white)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: navigationToAddPage,
        label: Text('To do'),
      ),
      body: Text('Test1'),
    );
  }

  // void navigationToAddPage() {
  //   final route = MaterialPageRoute(builder: (context) => ToAddPage());
  //   Navigator.push(context, route);
  // }

  void navigationToAddPage() {
    final route = MaterialPageRoute(builder: (context) => ToAddPage());
    Navigator.push(context, route);
  }
}
