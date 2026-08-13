import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:practice1/models/user/user.dart';
import 'package:practice1/models/user/user_dob.dart';
import 'package:practice1/models/user/user_name.dart';
import 'package:practice1/models/user/user_picture.dart';

class UserApi {
  Future<List<User>> fetchUsers() async {
    try {
      const url = 'https://randomuser.me/api/?results=10';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final data = json['results'] as List<dynamic>;
        final user = data.map((data) {
          final name = UserName.fromMap(data['name']);
          final pic = UserPicture.fromMap(data['picture']);
          final dob = UserDob.fromMap(data['dob']);

          return User(
            gender: data['gender'],
            email: data['email'],
            name: name,
            pic: pic,
            dob: dob,
          );
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
