import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:practice1/models/user.dart';

class UserApi {
  Future<List<User>> fetchUsers() async {
    try {
      const url = 'https://randomuser.me/api/?results=10';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final decData = json['results'] as List<dynamic>;
        final users = decData.map((data) {
          return User(
            gender: data['gender'],
            email: data['email'],
            cell: data['cell'],
            nat: data['nat'],
          );
        }).toList();
        print('Data retrieved successfully');
        return users;
      } else {
        debugPrint('Http Error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('Network Error: $e');
      return [];
    }
  }
}
