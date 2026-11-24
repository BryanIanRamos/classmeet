import 'package:classmeet/app.dart';
import 'package:classmeet/features/onboarding/presentation/screens/splash_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('a fresh launch opens the splash screen', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: ClassMeetApp()));
    await tester.pumpAndSettle();

    expect(find.byType(SplashScreen), findsOneWidget);
  });
}
