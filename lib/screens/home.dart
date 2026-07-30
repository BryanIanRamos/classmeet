import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> users = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("HomeScreen")),
      floatingActionButton: FloatingActionButton(
        onPressed: fetchData,
        child: Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          final name = user['name']['first'];
          final email = user['email'];
          return ListTile(
            leading: CircleAvatar(child: Text("$index")),
            title: Text("$name"),
            subtitle: Text("$email"),
          );
        },
      ),
    );
  }

  Future<void> fetchData() async {
    try {
      const url = 'https://randomuser.me/api/?results=10';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        setState(() {
          users = json['results'];
        });

        print("Fetched Data: $users");
      } else {
        debugPrint("Http Error: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Network Error: $e");
    }
  }
}
