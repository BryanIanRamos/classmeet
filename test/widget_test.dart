import 'package:classmeet/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('app starts on the temporary home route', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: ClassMeetApp()));
    await tester.pumpAndSettle();

    expect(find.text('ClassMeet'), findsOneWidget);
  });
}
