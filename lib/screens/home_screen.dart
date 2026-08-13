import 'package:flutter/material.dart';
import 'package:practice1/services/user_api.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> users = [];

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Home Screen")),
      body: Center(
        child: Column(
          children: [
            Text("Information"),
            Expanded(
              child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  final email = user.email;
                  final gender = user.gender;
              
                  return ListTile(
                    title: Text('$email'),
                    subtitle: Text('$gender'),
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
