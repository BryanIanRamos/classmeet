import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ToAddPage extends StatefulWidget {
  const ToAddPage({super.key});

  @override
  State<ToAddPage> createState() => _ToAddPageState();
}

class _ToAddPageState extends State<ToAddPage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

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
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'title'),
              ),
              TextField(
                controller: descriptionController,
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

  //  const uri = 'http://127.0.0.1:8000/api/v1/public-tasks/';
  //   'title': 'title11',
  //   'desciption': 'description',
  //   'status': 'status11',

  Future<void> submitTask() async {
    const uri = 'http://127.0.0.1:8000/api/v1/public-tasks/';
    final url = Uri.parse(uri);

    final form = {
      'title': titleController.text,
      'description': descriptionController.text,
      'status': 'Pending',
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(form),
      );

      if (titleController.text.isEmpty && descriptionController.text.isEmpty) {
        snackBar("Please fill all the inputs", 'warning');
      } else if (response.statusCode == 201) {
        snackBar("Submitted!");
      } else {
        snackBar('Http error ${response.statusCode}', 'warning');
      }
      // debugPrint("Network Error: ");
    } catch (e) {
      snackBar('Network error ${e}', 'error');
    }
  }

  void snackBar(String message, [String status = '']) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: status == 'error'
          ? Colors.redAccent
          : status == 'warning'
          ? Colors.yellowAccent
          : Colors.greenAccent,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
