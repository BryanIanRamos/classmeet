class UserPicture {
  final String large;
  final String medium;
  final String thumbnail;

  UserPicture({
    required this.large,
    required this.medium,
    required this.thumbnail,
  });

  factory UserPicture.fromMap(Map<String, dynamic> data) {
    return UserPicture(
      large: data['large'],
      medium: data['medium'],
      thumbnail: data['thumbnail'],
    );
  }
}
