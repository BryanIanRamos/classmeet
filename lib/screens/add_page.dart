import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ToAddPage extends StatefulWidget {
  const ToAddPage({super.key});

  @override
  State<ToAddPage> createState() => _ToAddPageState();
}

class _ToAddPageState extends State<ToAddPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Task Page")),
      body: Padding(
        padding: EdgeInsets.all(4),
        child: Center(
          child: Column(
            children: [
              Text('Please Fill the blanks'),
              TextField(decoration: InputDecoration(labelText: 'title')),
              TextField(
                decoration: InputDecoration(labelText: 'description'),
                keyboardType: TextInputType.multiline,
                minLines: 4,
                maxLines: 8,
                textAlign: TextAlign.start,
              ),
              ElevatedButton(onPressed: submitTask, child: Text('Submit data')),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print('Clicked!');
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Future<void> submitTask() async {
    const uri = 'http://127.0.0.1:8000/api/v1/public-tasks/';
    final body = {
      'title': 'title11',
      'desciption': 'description',
      'status': 'status11',
    };

    try {
      final url = Uri.parse(uri);
      final response = await http.post(
        url,
        body: jsonEncode(body),
        // headers: {'Content-Type': 'Application/json'},
      );

      if (response.statusCode == 201) {
        showMessageResponse('Success', false);
        print("Success");
      } else {
        showMessageResponse('Request Fail', true);
        print("Http Error: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint('Network Error: $e');
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
