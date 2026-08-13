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

  String get fullname {
    return '${name.title} | ${name.first} ${name.last}';
  }
}
