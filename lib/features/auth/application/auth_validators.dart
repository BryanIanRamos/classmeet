/// Field checks of the auth forms (provisional: the design shows no error
/// copy, so these rules and messages are assumptions, GAP-01/02).
abstract final class AuthValidators {
  static const usernameMinLength = 3;
  static const passwordMinLength = 8;

  static final _email = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  /// The error for [value], or null when it is fine.
  static String? username(String value) =>
      value.trim().length < usernameMinLength
      ? 'Username needs at least $usernameMinLength characters'
      : null;

  static String? email(String value) =>
      _email.hasMatch(value.trim()) ? null : 'Enter a valid email address';

  static String? password(String value) => value.length < passwordMinLength
      ? 'Password needs at least $passwordMinLength characters'
      : null;
}
