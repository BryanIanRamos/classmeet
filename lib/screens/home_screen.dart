import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:practice1/screens/add_page.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> items = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

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
      body: Center(
        child: Column(
          children: [
            Text('Tasks'),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(items[index]["title"] ?? "No title"),
                    subtitle: Text(
                      items[index]["description"] ?? "No description",
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void navigationToAddPage() {
    final route = MaterialPageRoute(builder: (context) => ToAddPage());
    Navigator.push(context, route);
  }

  // const uri = "http://localhost:8000/api/v1/public-tasks/";

  Future<void> fetchData() async {
    const url = "http://localhost:8000/api/v1/public-tasks/";
    final uri = Uri.parse(url);
    debugPrint("Code Running");

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as List;
        // final result = json['items'] as List;

        setState(() {
          items = json;
        });
        snackBar('Data fetch Successfully');

        debugPrint("Request Success | $json");
      }
    } catch (e) {
      snackBar('Error no data found');
      debugPrint("Network Error: $e");
    } finally {}
  }

  void snackBar(String message, {bool isError = false}) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.redAccent : Colors.greenAccent,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
