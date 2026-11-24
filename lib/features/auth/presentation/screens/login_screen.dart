import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/assets/app_icons.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/theme/app_semantic_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/feedback/app_alert.dart';
import '../../../../core/widgets/inputs/app_text_field.dart';
import '../../../../data/providers.dart';
import '../../application/auth_validators.dart';
import '../../application/session_controller.dart';
import '../widgets/auth_scaffold.dart';

/// Log in (GAP-01, provisional): the look of Create account (3.1) with an
/// Email and a Password field, a "Forgot password?" link, "Log in" and
/// "Continue with Carsu". Success signs in and goes Home; a failure shows an
/// error alert and keeps the form.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  late final TapGestureRecognizer _forgot = TapGestureRecognizer()
    ..onTap = () => context.push(Routes.forgotPassword);
  bool _attempted = false;
  bool _busy = false;
  bool _failed = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _forgot.dispose();
    super.dispose();
  }

  bool get _filled =>
      _email.text.trim().isNotEmpty && _password.text.isNotEmpty;

  Future<void> _submit() async {
    setState(() => _attempted = true);
    if (AuthValidators.email(_email.text) != null) return;
    setState(() {
      _busy = true;
      _failed = false;
    });
    try {
      await ref
          .read(authRepositoryProvider)
          .logIn(email: _email.text.trim(), password: _password.text);
    } on Exception {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _failed = true;
      });
      return;
    }
    if (!mounted) return;
    ref.read(sessionProvider.notifier).signedIn();
    context.go(Routes.home);
  }

  @override
  Widget build(BuildContext context) {
    final link = AppTypography.c1.copyWith(color: context.colors.textLinks);
    return AuthScaffold(
      title: 'Log in',
      caption: 'Welcome back! Log in to continue your study session.',
      onBack: Navigator.canPop(context)
          ? () => Navigator.maybePop(context)
          : null,
      fields: [
        AppTextField(
          controller: _email,
          placeholder: 'Email',
          accentColor: AuthScaffold.fieldAccent,
          errorText: _attempted ? AuthValidators.email(_email.text) : null,
          textInputAction: TextInputAction.next,
          keyboardType: TextInputType.emailAddress,
          onChanged: (_) => setState(() {}),
        ),
        AppTextField.password(
          controller: _password,
          placeholder: 'Password',
          accentColor: AuthScaffold.fieldAccent,
          textInputAction: TextInputAction.done,
          onChanged: (_) => setState(() {}),
          onSubmitted: (_) => _filled && !_busy ? _submit() : null,
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Text.rich(
            TextSpan(
              text: 'Forgot password?',
              recognizer: _forgot,
              style: link,
            ),
          ),
        ),
      ],
      alert: _failed
          ? const AppAlert(
              title: 'Could not log you in',
              message: 'Something went wrong. Please try again.',
              tone: AppAlertTone.error,
              icon: AppIcons.circleX,
            )
          : null,
      primaryLabel: 'Log in',
      onPrimary: _filled && !_busy ? _submit : null,
      onCarsu: () => context.push(Routes.carsuSignIn),
    );
  }
}
