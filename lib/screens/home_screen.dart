import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:practice1/models/user.dart';
import 'package:practice1/services/user_api.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<User> users = [];

  void initState() {
    super.initState();
    fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Home Screen")),
      floatingActionButton: FloatingActionButton(onPressed: fetchUsers),
      body: Center(
        child: Column(
          children: [
            Text('Displayed Data'),
            SizedBox(),
            Expanded(
              child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  final email = user.email;
                  final gender = user.gender;
                  final fullname = user.fullName;
                  return ListTile(
                    tileColor: gender == 'male'
                        ? Colors.blueAccent
                        : Colors.pinkAccent,
                    title: Text('$email'),
                    subtitle: Text('$fullname'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void fetchUsers() async {
    final data = await UserApi().fetchUsers();

    setState(() {
      users = data;
    });
  }
}
