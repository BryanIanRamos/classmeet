abstract final class Routes {
  // Public (Logout)
  static const welcome = '/welcome';
  static const login = '/welcome/login';
  static const signup = '/welcome/signup';

  // Onboarding (logged in, not finished setup)
  static const setProfile = '/onboarding/profile';
  static const pickSubject = '/onboarding/subjects';
  static const studyStyle = '/onboarding/study-style';
  static const privacyConsent = '/onboarding/consent';

  //Main app (bottom navigation tabs)
  static const home = '/home';
  static const study = '/study';
  static const play = '/play';
  static const friends = '/friends';
}
