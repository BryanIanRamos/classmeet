import 'package:practice1/models/user/user_dob.dart';
import 'package:practice1/models/user/user_name.dart';
import 'package:practice1/models/user/user_picture.dart';

class User {
  final String gender;
  final String email;
  final UserName name;
  final UserPicture pic;
  final UserDob dob;

  User({
    required this.gender,
    required this.email,
    required this.name,
    required this.pic,
    required this.dob,
  });

  factory User.fromMap(Map<String, dynamic> data) {
    final name = UserName(
      title: data['name']['title'],
      first: data['name']['first'],
      last: data['name']['last'],
    );

    final pic = UserPicture(
      large: data['picture']['large'],
      medium: data['picture']['medium'],
      thumbnail: data['picture']['thumbnail'],
    );

    final date = DateTime.parse(data['dob']['date']);

    final dob = UserDob(date: date, age: data['dob']['age']);

    return User(
      gender: data['gender'],
      email: data['email'],
      name: name,
      pic: pic,
      dob: dob,
    );
  }

  String get fullname {
    return '${name.title} | ${name.first} ${name.last}';
  }
}
