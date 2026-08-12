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
        final rawData = json['results'] as List<dynamic>;
        final users = rawData.map((data) {
          final name = UserName(
            title: data['name']['title'],
            first: data['name']['first'],
            last: data['name']['last'],
          );

          final date = DateTime.parse(data['dob']['date']);

          final dob = UserDob(date: date, age: data['dob']['age']);

          final location = UserLocation(
            city: data['location']['city'],
            state: data['location']['state'],
            country: data['location']['country'],
            postcode: data['location']['postcode'].toString(),
          );

          return User(
            gender: data['gender'],
            email: data['email'],
            name: name,
            dob: dob,
            location: location,
          );
        }).toList();

        return users;

        // setState(() {
        //   users = transform;
        // });
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
