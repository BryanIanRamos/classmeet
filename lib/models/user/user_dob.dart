class UserDob {
  final DateTime date;
  final int age;

  UserDob({required this.date, required this.age});

  factory UserDob.fromMap(Map<String, dynamic> data) {
    final date = DateTime.parse(data['date']);
    return UserDob(date: date, age: data['age']);
  }
}
