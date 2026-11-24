import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/routes.dart';
import '../../../../core/theme/app_semantic_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

/// "By signing up you agree to the Terms and Privacy Policy." with the two
/// links, which open the Terms and Privacy placeholders (GAP-04).
class AuthTermsText extends StatefulWidget {
  const AuthTermsText({super.key});

  @override
  State<AuthTermsText> createState() => _AuthTermsTextState();
}

class _AuthTermsTextState extends State<AuthTermsText> {
  late final TapGestureRecognizer _terms = TapGestureRecognizer()
    ..onTap = () => context.push(Routes.terms);
  late final TapGestureRecognizer _privacy = TapGestureRecognizer()
    ..onTap = () => context.push(Routes.privacy);

  @override
  void dispose() {
    _terms.dispose();
    _privacy.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final base = AppTypography.c1.copyWith(color: colors.textPrimary);
    final link = AppTypography.c1.copyWith(color: colors.textLinks);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Text.rich(
        TextSpan(
          text: 'By signing up you agree to the ',
          style: base,
          children: [
            TextSpan(text: 'Terms', recognizer: _terms, style: link),
            const TextSpan(text: ' and '),
            TextSpan(text: 'Privacy Policy', recognizer: _privacy, style: link),
            const TextSpan(text: '.'),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
