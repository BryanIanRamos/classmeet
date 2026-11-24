import '../models/profile.dart';

/// Sign-up, log-in and log-out (3.1, GAP-01/02). The fake keeps the session
/// in memory; a backend plugs in at `lib/data/providers.dart` (D-18).
abstract interface class AuthRepository {
  /// The signed-in user, or null when signed out.
  Future<UserProfile?> currentUser();

  Future<UserProfile> signUp({
    required String fullName,
    required String email,
    required String password,
  });

  Future<UserProfile> logIn({required String email, required String password});

  Future<void> logOut();

  /// Sends a reset link (GAP-02, provisional).
  Future<void> requestPasswordReset(String email);
}
