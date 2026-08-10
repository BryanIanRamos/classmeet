import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:practice1/models/user.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<User> users = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Home Screen")),
      floatingActionButton: FloatingActionButton(onPressed: fetchUsers),
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          final email = user.email;
          final color = user.gender == 'male'
              ? const Color.fromARGB(255, 121, 194, 253)
              : const Color.fromRGBO(232, 119, 111, 1);
          return ListTile(title: Text(email), tileColor: color);
        },
      ),
    );
  }

  Future<void> fetchUsers() async {
    try {
      const url = 'https://randomuser.me/api/?results=10';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final result = json['results'] as List<dynamic>;
        final transformed = result.map((data) {
          return User(
            gender: data['gender'],
            email: data['email'],
            cell: data['cell'],
            nat: data['nat'],
          );
        }).toList();

        setState(() {
          users = transformed;
        });
      } else {
        debugPrint('Http error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("Network Error: $e");
    }
  }
}
