import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/assets/app_icons.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/widgets/feedback/app_alert.dart';
import '../../../../core/widgets/inputs/app_text_field.dart';
import '../../../../data/providers.dart';
import '../../application/auth_validators.dart';
import '../../application/session_controller.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/auth_terms_text.dart';

/// Create account (frames 3.1 and 3.2).
///
/// 3.2 is the focused state of 3.1 (INC-1: the first field focused), so this
/// is one screen. Both are titled "Create account". The first field asks
/// Username instead of "Full name" (D-19). Continue works once all three
/// fields are filled; then a submit checks them (username 3+ characters, a
/// valid email, password 8+), shows the errors under the fields, and signs
/// up. A failure shows an error alert above the button. On success the
/// session moves to onboarding and `go` replaces the stack with step 96, so
/// it has no back chevron.
class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _attempted = false;
  bool _busy = false;
  bool _failed = false;

  @override
  void dispose() {
    _username.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  bool get _filled =>
      _username.text.trim().isNotEmpty &&
      _email.text.trim().isNotEmpty &&
      _password.text.isNotEmpty;

  String? _error(String? Function(String) check, TextEditingController c) =>
      _attempted ? check(c.text) : null;

  Future<void> _submit() async {
    setState(() => _attempted = true);
    if (AuthValidators.username(_username.text) != null ||
        AuthValidators.email(_email.text) != null ||
        AuthValidators.password(_password.text) != null) {
      return;
    }
    setState(() {
      _busy = true;
      _failed = false;
    });
    try {
      await ref
          .read(authRepositoryProvider)
          .signUp(
            username: _username.text.trim(),
            email: _email.text.trim(),
            password: _password.text,
          );
    } on Exception {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _failed = true;
      });
      return;
    }
    if (!mounted) return;
    ref.read(sessionProvider.notifier).signedUp();
    // `go`, not `push`: step 96 starts the flow, with no way back here.
    context.go(Routes.onboardingAcademic);
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Create account',
      caption: 'Sign up to get you ready for your next study session.',
      onBack: Navigator.canPop(context)
          ? () => Navigator.maybePop(context)
          : null,
      fields: [
        AppTextField(
          controller: _username,
          placeholder: 'Username',
          accentColor: AuthScaffold.fieldAccent,
          errorText: _error(AuthValidators.username, _username),
          textInputAction: TextInputAction.next,
          keyboardType: TextInputType.name,
          onChanged: (_) => setState(() {}),
        ),
        AppTextField(
          controller: _email,
          placeholder: 'Email',
          accentColor: AuthScaffold.fieldAccent,
          errorText: _error(AuthValidators.email, _email),
          textInputAction: TextInputAction.next,
          keyboardType: TextInputType.emailAddress,
          onChanged: (_) => setState(() {}),
        ),
        AppTextField.password(
          controller: _password,
          placeholder: 'Password',
          accentColor: AuthScaffold.fieldAccent,
          errorText: _error(AuthValidators.password, _password),
          textInputAction: TextInputAction.done,
          onChanged: (_) => setState(() {}),
          onSubmitted: (_) => _filled && !_busy ? _submit() : null,
        ),
      ],
      alert: _failed
          ? const AppAlert(
              title: 'Could not create your account',
              message: 'Something went wrong. Please try again.',
              tone: AppAlertTone.error,
              icon: AppIcons.circleX,
            )
          : null,
      primaryLabel: 'Continue',
      onPrimary: _filled && !_busy ? _submit : null,
      onCarsu: () => context.push(Routes.carsuSignIn),
      footer: const AuthTermsText(),
    );
  }
}
