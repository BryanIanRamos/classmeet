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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('To Add Page')),
      body: ListView(
        children: [
          TextField(
            controller: titleController,
            decoration: InputDecoration(hintText: 'Title'),
          ),
          TextField(
            controller: descriptionController,
            decoration: InputDecoration(hintText: 'Description'),
            keyboardType: TextInputType.multiline,
            minLines: 4,
            maxLines: 8,
          ),
          SizedBox(height: 20),
          ElevatedButton(onPressed: submitData, child: Text("Click")),
        ],
      ),
    );
  }

  void submitData() async {
    final title = titleController.text;
    final description = descriptionController.text;

    final body = {
      'title': title,
      'description': description,
      'status': 'pending',
    };

    try {
      const url = 'http://127.0.0.1:8000/api/v1/public-tasks/';
      final uri = Uri.parse(url);
      final response = await http.post(
        uri,
        body: jsonEncode(body),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 201) {
        titleController.text = '';
        descriptionController.text = '';

        showSuccessMessage('Added Successfully');
        print('Data Submitted');
      } else {
        showErrorMessage('Request Failed');
        print('Http request error: ${response.statusCode}');
      }
    } catch (e) {
      showErrorMessage('Request Failed');
      debugPrint('Network Error: $e');
    }
  }

  void showSuccessMessage(String message) {
    final snackBar = SnackBar(
      content: Text(message, style: TextStyle(color: Colors.white)),
      backgroundColor: Colors.greenAccent,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void showErrorMessage(String message) {
    final snackBar = SnackBar(
      content: Text(message, style: TextStyle(color: Colors.white)),
      duration: Duration(seconds: 1),
      backgroundColor: Colors.redAccent,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
