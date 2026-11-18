import 'package:flutter_test/flutter_test.dart';

import 'package:practice1/app.dart';

void main() {
  testWidgets('app starts and shows the placeholder home', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('ClassMeet'), findsOneWidget);
  });
}
