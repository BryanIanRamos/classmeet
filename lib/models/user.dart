class User {
  final String gender;
  final String email;
  final UserName name;
  final UserDob dob;
  final UserLocation location;

  User({
    required this.gender,
    required this.email,
    required this.name,
    required this.dob,
    required this.location,
  });

  String get fullName {
    return '${name.title} ${name.first} ${name.last}';
  }
}

class UserName {
  final String title;
  final String first;
  final String last;

  UserName({required this.title, required this.first, required this.last});
}

class UserDob {
  final DateTime date;
  final int age;

  UserDob({required this.date, required this.age});
}

class UserLocation {
  final String city;
  final String state;
  final String country;
  final String postcode;

  UserLocation({
    required this.city,
    required this.state,
    required this.country,
    required this.postcode,
  });
}
