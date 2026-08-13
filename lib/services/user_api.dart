import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:practice1/models/user/user.dart';

class UserApi {
  Future<List<User>> fetchUsers() async {
    try {
      const url = 'https://randomuser.me/api/?results=10';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final data = json['results'] as List<dynamic>;
        final user = data.map((data) {
          return User.fromMap(data);
        }).toList();

        return user;
      } else {
        debugPrint("Http error: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      debugPrint("Network Error: $e");
      return [];
    }
  }
}
