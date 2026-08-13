class UserName {
  final String title;
  final String first;
  final String last;

  UserName({required this.title, required this.first, required this.last});

  factory UserName.fromMap(Map<String, dynamic> data) {
    return UserName(
      title: data['title'],
      first: data['first'],
      last: data['last'],
    );
  }
}
