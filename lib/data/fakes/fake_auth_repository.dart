import '../models/profile.dart';
import '../repositories/auth_repository.dart';
import '../repositories/repository_exception.dart';
import 'fake_config.dart';
import 'samples/profile_samples.dart';

/// In-memory [AuthRepository]. Starts signed out; [signUp] and [logIn] sign
/// in, [logOut] signs out. The session routing lives in the app, not here.
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository(this._config, {DateTime Function()? clock});

  final FakeConfig _config;
  UserProfile? _user;

  @override
  Future<UserProfile?> currentUser() =>
      _config.answer('currentUser', () => _user, empty: () => _user);

  @override
  Future<UserProfile> signUp({
    required String username,
    required String email,
    required String password,
  }) => _config.answer('signUp', () {
    if (username.trim().isEmpty || email.trim().isEmpty || password.isEmpty) {
      throw const RepositoryException('Name, email and password are required');
    }
    // A new student has no program or school yet (onboarding sets them).
    return _user = sampleUser.copyWith(
      username: username.trim(),
      email: email.trim(),
      programLabel: '',
      schoolShort: '',
    );
  });

  @override
  Future<UserProfile> logIn({
    required String email,
    required String password,
  }) => _config.answer('logIn', () {
    if (email.trim().isEmpty || password.isEmpty) {
      throw const RepositoryException('Email and password are required');
    }
    return _user = sampleUser.copyWith(email: email.trim());
  });

  @override
  Future<void> logOut() => _config.answer('logOut', () => _user = null);

  @override
  Future<void> requestPasswordReset(String email) =>
      _config.answer('requestPasswordReset', () {
        if (email.trim().isEmpty) {
          throw const RepositoryException('Email is required');
        }
      });
}
