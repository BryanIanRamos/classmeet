import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/assets/app_icons.dart';
import '../../../../core/widgets/feedback/app_alert.dart';
import '../../../../core/widgets/inputs/app_text_field.dart';
import '../../../../data/providers.dart';
import '../../application/auth_validators.dart';
import '../widgets/auth_scaffold.dart';

/// Forgot password (GAP-02, provisional): the look of Create account (3.1)
/// with one Email field and "Send reset link". Success shows a success alert
/// and keeps the user here; a failure shows an error alert.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _email = TextEditingController();
  bool _attempted = false;
  bool _busy = false;
  bool? _sent;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _attempted = true);
    if (AuthValidators.email(_email.text) != null) return;
    setState(() {
      _busy = true;
      _sent = null;
    });
    try {
      await ref
          .read(authRepositoryProvider)
          .requestPasswordReset(_email.text.trim());
    } on Exception {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _sent = false;
      });
      return;
    }
    if (!mounted) return;
    setState(() {
      _busy = false;
      _sent = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Forgot password',
      caption:
          'Enter your email and we will send you a link to reset your '
          'password.',
      onBack: Navigator.canPop(context)
          ? () => Navigator.maybePop(context)
          : null,
      fields: [
        AppTextField(
          controller: _email,
          placeholder: 'Email',
          accentColor: AuthScaffold.fieldAccent,
          errorText: _attempted ? AuthValidators.email(_email.text) : null,
          textInputAction: TextInputAction.done,
          keyboardType: TextInputType.emailAddress,
          onChanged: (_) => setState(() {}),
          onSubmitted: (_) =>
              _email.text.trim().isNotEmpty && !_busy ? _submit() : null,
        ),
      ],
      alert: switch (_sent) {
        true => const AppAlert(
          title: 'Check your email',
          message:
              'If an account exists for that address, a reset link is on '
              'its way.',
          tone: AppAlertTone.success,
          icon: AppIcons.circleCheck,
        ),
        false => const AppAlert(
          title: 'Could not send the link',
          message: 'Something went wrong. Please try again.',
          tone: AppAlertTone.error,
          icon: AppIcons.circleX,
        ),
        null => null,
      },
      primaryLabel: 'Send reset link',
      onPrimary: _email.text.trim().isNotEmpty && !_busy ? _submit : null,
      showCarsu: false,
    );
  }
}
