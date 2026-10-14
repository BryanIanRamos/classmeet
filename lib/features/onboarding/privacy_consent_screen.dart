import 'package:classmeet/core/router/routes.dart';
import 'package:classmeet/core/session/app_session.dart';
import 'package:classmeet/shared/widgets/dispose.logger.dart';
import 'package:classmeet/shared/widgets/placeholder.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PrivacyConsentScreen extends StatelessWidget {
  const PrivacyConsentScreen({super.key});

  void _onAgree(BuildContext context) {
    appSession.completeOnboarding();

    context.go(Routes.home);
  }

  @override
  Widget build(BuildContext context) {
    return DisposeLogger(
      name: 'PrivacyConsent',
      child: Scaffold(
        appBar: AppBar(title: const Text('Privacy Consent')),
        body: PlaceholderBody(
          title: 'Privacy Consent (4/4)',
          actions: [
            FilledButton(
              onPressed: () => _onAgree(context),
              child: const Text('I agree, take me home'),
            ),
          ],
        ),
      ),
    );
  }
}
