import 'package:go_router/go_router.dart';

import '../../core/router/coming_soon_route.dart';
import '../../core/router/routes.dart';
import 'presentation/screens/forgot_password_screen.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/sign_up_screen.dart';

/// Sign up (3.1/3.2), the provisional log-in and forgot-password screens
/// (GAP-01/02), and the not-yet-designed Carsu sign-in and legal pages.
final authRoutes = <RouteBase>[
  GoRoute(path: Routes.signUp, builder: (_, _) => const SignUpScreen()),
  GoRoute(path: Routes.login, builder: (_, _) => const LoginScreen()),
  GoRoute(
    path: Routes.forgotPassword,
    builder: (_, _) => const ForgotPasswordScreen(),
  ),
  comingSoonRoute(
    Routes.carsuSignIn,
    title: 'Continue with Carsu',
    gapId: 'GAP-03',
  ),
  comingSoonRoute(Routes.terms, title: 'Terms', gapId: 'GAP-04'),
  comingSoonRoute(Routes.privacy, title: 'Privacy Policy', gapId: 'GAP-04'),
];
