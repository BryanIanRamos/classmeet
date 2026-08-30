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
                    title: Text('name'),
                    subtitle: Text("Description"),
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

  Future<void> fetchData() async {
    const uri = "http://localhost:8000/api/v1/public-tasks/";
    final url = Uri.parse(uri);
    try {
      final response = await http.get(url);
      // print("Data: \n Code: ${response.statusCode} | Data: ${json}");
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map;
        final result = json['items'] as List;
        setState(() {
          items = result;
        });
      } else {}
    } catch (e) {
      debugPrint("Network Error: $e");
    }
  }

  void showMessageResponse(String message, bool isError) {
    final snackBar = SnackBar(
      content: Text(message, style: TextStyle(color: Colors.white)),
      backgroundColor: isError == true ? Colors.red : Colors.green,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
