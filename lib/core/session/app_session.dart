import 'package:flutter/foundation.dart';

class AppSession extends ChangeNotifier {
  bool _isLoggedIn = false;
  bool _onboardingDone = false;

  bool get isLoggedIn => _isLoggedIn;
  bool get onboardingDone => _onboardingDone;

  void logIn() {
    _isLoggedIn = true;
    notifyListeners();
  }

  void completeOnboarding() {
    _onboardingDone = true;
    notifyListeners();
  }

  void logOut() {
    _isLoggedIn = false;
    _onboardingDone = false;
    notifyListeners();
  }
}

final appSession = AppSession();
