class User {
  final String gender;
  final String email;
  final String cell;
  final String nat;
  final Name? name;

  User({
    required this.gender,
    required this.email,
    required this.cell,
    required this.nat,
    this.name,
  });
}

class Name {
  final String title;
  final String first;
  final String last;

  Name({required this.title, required this.first, required this.last});
}
