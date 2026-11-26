import 'dart:async';

import 'package:classmeet/core/router/routes.dart';
import 'package:classmeet/core/theme/app_colors.dart';
import 'package:classmeet/core/theme/app_theme.dart';
import 'package:classmeet/core/widgets/buttons/app_button.dart';
import 'package:classmeet/core/widgets/display/app_card.dart';
import 'package:classmeet/core/widgets/feedback/coming_soon_screen.dart';
import 'package:classmeet/core/widgets/inputs/app_text_field.dart';
import 'package:classmeet/data/fakes/fake_class_repository.dart';
import 'package:classmeet/data/fakes/fake_config.dart';
import 'package:classmeet/data/models/study_class.dart';
import 'package:classmeet/data/providers.dart';
import 'package:classmeet/data/repositories/class_repository.dart';
import 'package:classmeet/data/repositories/repository_exception.dart';
import 'package:classmeet/features/home/application/join_class_controller.dart';
import 'package:classmeet/features/home/presentation/screens/join_class_screen.dart';
import 'package:classmeet/features/home/presentation/widgets/join_banner.dart';
import 'package:classmeet/features/home/presentation/widgets/join_confirm_sheet.dart';
import 'package:classmeet/features/home/presentation/widgets/join_info.dart';
import 'package:classmeet/features/home/presentation/widgets/join_scan_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show RenderParagraph;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/app_fonts.dart';
import 'home_test_helpers.dart';

const _sampleCode = 'ITE16-2026';
const _notFound =
    "We couldn't find a class with that code. Check it and try again.";
const _enterCode = 'Enter your class code.';
const _alreadyJoined = "You're already in this class.";
const _note =
    "Check the class name and teacher before confirming. You'll then see the "
    'class in My Classes.';
const _bannerLine =
    'Join your class to access shared materials, quizzes, and announcements.';

/// A repository whose calls can be held at a gate, to keep a request in
/// flight, and that records the codes it was asked about.
class _GatedClasses implements ClassRepository {
  _GatedClasses({this.failJoin = false})
    : _inner = FakeClassRepository(FakeConfig.instant);

  final FakeClassRepository _inner;
  final bool failJoin;

  /// While set, [findClassByCode] / [joinClass] wait for it.
  Completer<void>? lookupGate;
  Completer<void>? joinGate;

  final lookedUp = <String>[];
  final joined = <String>[];

  /// Puts the student in the class without it counting as a [joinClass] call.
  Future<void> joinQuietly(String code) => _inner.joinClass(code);

  @override
  Future<List<StudyClass>> fetchClasses() => _inner.fetchClasses();

  @override
  Future<StudyClass> fetchClass(String classId) => _inner.fetchClass(classId);

  @override
  Future<StudyClass> findClassByCode(String code) async {
    lookedUp.add(code);
    await lookupGate?.future;
    return _inner.findClassByCode(code);
  }

  @override
  Future<StudyClass> joinClass(String code) async {
    joined.add(code);
    await joinGate?.future;
    if (failJoin) throw const RepositoryException('join failed');
    return _inner.joinClass(code);
  }
}

Override _using(ClassRepository repo) =>
    classRepositoryProvider.overrideWithValue(repo);

/// A page with a button that opens the screen, so there is a route to go back
/// to.
class _OpensJoin extends StatelessWidget {
  const _OpensJoin();

  @override
  Widget build(BuildContext context) => Scaffold(
    body: TextButton(
      onPressed: () => Navigator.of(
        context,
      ).push(MaterialPageRoute<void>(builder: (_) => const JoinClassScreen())),
      child: const Text('open'),
    ),
  );
}

/// The screen alone, in a plain app with no router: for everything that does
/// not leave it. [keyboard] is the height of the keyboard in dp; [onTop] pushes
/// the screen over another page, so Back works.
Future<void> pumpJoin(
  WidgetTester tester, {
  FakeConfig config = FakeConfig.instant,
  Size size = const Size(428, 926),
  double keyboard = 0,
  List<Override> overrides = const [],
  bool onTop = false,
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  tester.view.viewInsets = FakeViewPadding(bottom: keyboard * 3);
  addTearDown(tester.view.resetViewInsets);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [fakeConfigProvider.overrideWithValue(config), ...overrides],
      retry: (_, _) => null,
      child: MaterialApp(
        theme: AppTheme.light,
        home: onTop ? const _OpensJoin() : const JoinClassScreen(),
      ),
    ),
  );
  if (onTop) {
    await tester.tap(find.text('open'));
    await tester.pump(); // build the route
    await tester.pump(const Duration(seconds: 3)); // route in
  }
  await tester.pumpAndSettle();
}

final _field = find.byType(TextField);

Finder _button(String label) =>
    find.byWidgetPredicate((w) => w is AppButton && w.label == label);

AppButton _appButton(WidgetTester tester, String label) =>
    tester.widget<AppButton>(_button(label));

AppTextField _appField(WidgetTester tester) =>
    tester.widget<AppTextField>(find.byType(AppTextField));

/// Types [code] and taps Join, then lets the lookup and the sheet finish.
Future<void> join(WidgetTester tester, String code) async {
  await tester.enterText(_field, code);
  await tester.ensureVisible(_button('Join'));
  await tester.pumpAndSettle();
  await tester.tap(_button('Join'));
  await tester.pumpAndSettle();
}

/// Joins the sample class all the way: its code, Join, then "Join class".
Future<void> joinSampleClass(WidgetTester tester) async {
  await join(tester, _sampleCode);
  await tester.tap(_button('Join class'));
  await tester.pumpAndSettle();
}

Future<List<String>> _idsIn(ProviderContainer container) async => [
  for (final c in await container.read(classRepositoryProvider).fetchClasses())
    c.id,
];

/// The ids of the classes the student is in now, in the running app.
Future<List<String>> _joinedIds(WidgetTester tester) =>
    _idsIn(ProviderScope.containerOf(tester.element(find.byType(MaterialApp))));

void main() {
  // Real type, so wraps and heights are the shipped ones.
  setUpAll(loadAppFonts);

  group('the screen', () {
    testWidgets('default: banner, field, scan card and notes', (tester) async {
      await pumpJoin(tester);
      expect(find.text('Join a class'), findsOneWidget);
      expect(find.text('Learn together'), findsOneWidget);
      expect(find.text(_bannerLine), findsOneWidget);
      expect(find.text('Enter code'), findsOneWidget);
      expect(find.text('Join'), findsOneWidget);
      expect(find.text('or scan a qr code'), findsOneWidget);
      expect(find.text('Scan a class QR code'), findsOneWidget);
      expect(
        find.text('Use the code provided by your instructor.'),
        findsOneWidget,
      );
      expect(find.text('Before you join'), findsOneWidget);
      expect(richLine(_note), findsOneWidget);
      expect(
        find.text(
          "Don't have a code? Ask your teacher or class administrator.",
        ),
        findsOneWidget,
      );
      // Quiet: no message, no sheet. Join is enabled with the field empty, as
      // the design shows it.
      expect(_appField(tester).errorText, isNull);
      expect(find.byType(JoinConfirmSheet), findsNothing);
      expect(_appButton(tester, 'Join').onPressed, isNotNull);
    });

    testWidgets('uses the Talon look of the design', (tester) async {
      await pumpJoin(tester);
      final field = _appField(tester);
      expect(field.placeholder, 'Enter code');
      expect(field.accentColor, AppColors.talon700);
      expect(field.size, AppTextFieldSize.large);
      expect(field.style, AppTextFieldStyle.outline);
      // A class code is typed in capitals.
      expect(
        tester.widget<TextField>(_field).textCapitalization,
        TextCapitalization.characters,
      );

      final join = _appButton(tester, 'Join');
      expect(join.tone, AppButtonTone.talon);
      expect(join.style, AppButtonStyle.filled);
      expect(join.size, AppButtonSize.large);
      expect(join.expand, isTrue);

      final card = tester.widget<AppCard>(
        find.descendant(
          of: find.byType(JoinScanCard),
          matching: find.byType(AppCard),
        ),
      );
      expect(card.color, AppColors.white);
      expect(card.borderColor, AppColors.talon700);
    });

    testWidgets('a wrong code shows the message, which clears on edit', (
      tester,
    ) async {
      await pumpJoin(tester);
      await join(tester, 'NOPE-0000');
      expect(find.text(_notFound), findsOneWidget);
      expect(_appField(tester).errorText, _notFound);
      expect(find.byType(JoinConfirmSheet), findsNothing);
      // Join works again straight away.
      expect(_appButton(tester, 'Join').onPressed, isNotNull);

      await tester.enterText(_field, 'NOPE-00001');
      await tester.pump();
      expect(find.text(_notFound), findsNothing);
      expect(_appField(tester).errorText, isNull);
    });

    testWidgets('an empty or blank field asks for the code, until the next '
        'edit', (tester) async {
      await pumpJoin(tester);
      await tester.tap(_button('Join'));
      await tester.pumpAndSettle();
      expect(find.text(_enterCode), findsOneWidget);
      expect(find.byType(JoinConfirmSheet), findsNothing);

      await tester.enterText(_field, 'I');
      await tester.pump();
      expect(find.text(_enterCode), findsNothing);

      // Spaces alone count as nothing.
      await join(tester, '   ');
      expect(find.text(_enterCode), findsOneWidget);
    });

    testWidgets('the keyboard done key joins like the button, with the code '
        'trimmed', (tester) async {
      final repo = _GatedClasses();
      await pumpJoin(tester, overrides: [_using(repo)]);
      await tester.enterText(_field, '  ite16-2026 ');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(find.byType(JoinConfirmSheet), findsOneWidget);
      // Looked up as typed, trimmed; case is left to the repository.
      expect(repo.lookedUp, ['ite16-2026']);
      expect(repo.joined, isEmpty);
    });

    testWidgets('the Join button waits while the lookup runs', (tester) async {
      final repo = _GatedClasses()..lookupGate = Completer<void>();
      await pumpJoin(tester, overrides: [_using(repo)]);
      await tester.enterText(_field, _sampleCode);
      await tester.tap(_button('Join'));
      await tester.pump();
      expect(_appButton(tester, 'Join').onPressed, isNull);

      // A second tap does nothing.
      await tester.tap(_button('Join'), warnIfMissed: false);
      await tester.pump();
      expect(repo.lookedUp, [_sampleCode]);

      repo.lookupGate!.complete();
      await tester.pumpAndSettle();
      expect(find.byType(JoinConfirmSheet), findsOneWidget);
      expect(_appButton(tester, 'Join').onPressed, isNotNull);
      expect(repo.lookedUp, [_sampleCode]);
    });

    testWidgets('editing the field drops a lookup that is still running', (
      tester,
    ) async {
      final repo = _GatedClasses()..lookupGate = Completer<void>();
      await pumpJoin(tester, overrides: [_using(repo)]);
      await tester.enterText(_field, _sampleCode);
      await tester.tap(_button('Join'));
      await tester.pump();
      expect(_appButton(tester, 'Join').onPressed, isNull);

      // The student changes the code: Join works again at once.
      await tester.enterText(_field, 'ITE13-2026');
      await tester.pump();
      expect(_appButton(tester, 'Join').onPressed, isNotNull);

      // The answer for the old code arrives and is ignored.
      repo.lookupGate!.complete();
      await tester.pumpAndSettle();
      expect(find.byType(JoinConfirmSheet), findsNothing);
      expect(_appField(tester).errorText, isNull);
      expect(tester.takeException(), isNull);
    });
  });

  group('the confirmation sheet', () {
    testWidgets('shows the class and its teacher', (tester) async {
      await pumpJoin(tester);
      await join(tester, _sampleCode);
      expect(find.byType(JoinConfirmSheet), findsOneWidget);
      expect(find.text('Join this class?'), findsOneWidget);
      expect(find.text('ITE16'), findsOneWidget);
      expect(find.text('Database Management Systems'), findsOneWidget);
      expect(find.text('Prof. Dave Ramos'), findsOneWidget);
      expect(
        find.text("You'll then see the class in My Classes."),
        findsOneWidget,
      );
      expect(_appButton(tester, 'Join class').tone, AppButtonTone.talon);
      expect(_appButton(tester, 'Cancel').style, AppButtonStyle.clear);
      expect(find.text(_alreadyJoined), findsNothing);
      // Nothing is joined until the student confirms.
      expect(await _joinedIds(tester), isNot(contains('ite16')));
    });

    testWidgets('Cancel and tapping outside close it, keeping the screen and '
        'the code', (tester) async {
      await pumpJoin(tester);
      final dismissals = <Future<void> Function()>[
        () => tester.tap(_button('Cancel')),
        () => tester.tapAt(const Offset(214, 40)), // the scrim
      ];
      for (final dismiss in dismissals) {
        await join(tester, _sampleCode);
        expect(find.byType(JoinConfirmSheet), findsOneWidget);
        await dismiss();
        await tester.pumpAndSettle();
        expect(find.byType(JoinConfirmSheet), findsNothing);
        expect(find.byType(JoinClassScreen), findsOneWidget);
        expect(find.widgetWithText(TextField, _sampleCode), findsOneWidget);
        expect(_appField(tester).errorText, isNull);
        expect(await _joinedIds(tester), isNot(contains('ite16')));
      }
    });

    testWidgets('says so when the student is in the class already', (
      tester,
    ) async {
      final repo = _GatedClasses();
      await repo.joinQuietly(_sampleCode);
      await pumpJoin(tester, overrides: [_using(repo)]);
      await join(tester, _sampleCode);
      expect(find.text(_alreadyJoined), findsOneWidget);
      expect(find.text('Database Management Systems'), findsOneWidget);
      expect(find.text('Prof. Dave Ramos'), findsOneWidget);
      expect(_button('Open My Classes'), findsOneWidget);
      expect(_button('Join class'), findsNothing);
      expect(find.text('Join this class?'), findsNothing);

      await tester.tap(_button('Cancel'));
      await tester.pumpAndSettle();
      expect(find.byType(JoinConfirmSheet), findsNothing);
      expect(repo.joined, isEmpty); // nothing was joined a second time
    });

    testWidgets('both buttons wait while the join runs, and a failed join '
        'closes it with the message', (tester) async {
      final repo = _GatedClasses(failJoin: true)..joinGate = Completer<void>();
      await pumpJoin(tester, overrides: [_using(repo)]);
      await join(tester, _sampleCode);
      await tester.tap(_button('Join class'));
      await tester.pump();
      expect(_appButton(tester, 'Join class').onPressed, isNull);
      expect(_appButton(tester, 'Cancel').onPressed, isNull);
      expect(find.byType(JoinConfirmSheet), findsOneWidget);

      repo.joinGate!.complete();
      await tester.pumpAndSettle();
      expect(repo.joined, [_sampleCode]);
      expect(find.byType(JoinConfirmSheet), findsNothing);
      expect(find.byType(JoinClassScreen), findsOneWidget);
      expect(find.text(_notFound), findsOneWidget);
      expect(_appButton(tester, 'Join').onPressed, isNotNull);
      expect(tester.takeException(), isNull);
    });

    // The route ignores taps once it slides away, so these press each button
    // twice in one frame by calling its handler, as a double tap would have to.
    testWidgets('pressing Cancel twice closes the sheet, not the screen', (
      tester,
    ) async {
      await pumpJoin(tester, onTop: true);
      await join(tester, _sampleCode);
      final cancel = _appButton(tester, 'Cancel').onPressed!;
      cancel();
      cancel();
      await tester.pumpAndSettle();
      expect(find.byType(JoinConfirmSheet), findsNothing);
      expect(find.byType(JoinClassScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('pressing Join class twice joins once and waits for it', (
      tester,
    ) async {
      final repo = _GatedClasses()..joinGate = Completer<void>();
      await pumpHome(
        tester,
        location: Routes.joinClass,
        overrides: [_using(repo)],
      );
      await join(tester, _sampleCode);
      final joinClass = _appButton(tester, 'Join class').onPressed!;
      joinClass();
      joinClass();
      await tester.pumpAndSettle();
      // The join is still running: the sheet stays, the class is asked once.
      expect(find.byType(JoinConfirmSheet), findsOneWidget);
      expect(repo.joined, [_sampleCode]);

      repo.joinGate!.complete();
      await tester.pumpAndSettle();
      expect(location(tester), Routes.studyClasses);
      expect(repo.joined, [_sampleCode]);
      expect(tester.takeException(), isNull);
    });
  });

  group('navigation', () {
    testWidgets('confirming joins the class and opens My Classes', (
      tester,
    ) async {
      await pumpHome(tester, location: Routes.joinClass);
      expect(find.byType(JoinClassScreen), findsOneWidget);
      expect(await _joinedIds(tester), hasLength(3));

      await joinSampleClass(tester);

      expect(location(tester), Routes.studyClasses);
      expect(find.byType(JoinClassScreen), findsNothing);
      expect(find.byType(JoinConfirmSheet), findsNothing);
      final ids = await _joinedIds(tester);
      expect(ids, hasLength(4));
      expect(ids, contains('ite16'));
    });

    testWidgets('coming back with the same code says it is joined already', (
      tester,
    ) async {
      await pumpHome(tester, location: Routes.joinClass);
      await joinSampleClass(tester);
      expect(location(tester), Routes.studyClasses);

      unawaited(router(tester).push(Routes.joinClass));
      await tester.pumpAndSettle();
      await join(tester, _sampleCode);
      expect(find.text(_alreadyJoined), findsOneWidget);
      expect(_button('Join class'), findsNothing);

      await tester.tap(_button('Open My Classes'));
      await tester.pumpAndSettle();
      expect(location(tester), Routes.studyClasses);
      expect(find.byType(JoinClassScreen), findsNothing);
      // Still four classes: it was not joined twice.
      expect(await _joinedIds(tester), hasLength(4));
    });

    testWidgets('the scan card opens the scanner page', (tester) async {
      await pumpHome(tester, location: Routes.joinClass);
      await tester.tap(find.text('Scan a class QR code'));
      await tester.pumpAndSettle();
      expect(location(tester), Routes.joinClassScan);
      expect(find.byType(ComingSoonScreen), findsOneWidget);
    });

    testWidgets('the My Classes link opens My Classes', (tester) async {
      await pumpHome(tester, location: Routes.joinClass);
      await tester.ensureVisible(find.text('Before you join'));
      await tester.pumpAndSettle();
      await tester.tapOnText(find.textRange.ofSubstring('My Classes'));
      await tester.pumpAndSettle();
      expect(location(tester), Routes.studyClasses);
      expect(find.byType(JoinClassScreen), findsNothing);
    });

    testWidgets('back returns to Home', (tester) async {
      await pumpHome(tester, location: Routes.joinClass);
      await tester.tap(find.bySemanticsLabel('Back'));
      await tester.pumpAndSettle();
      expect(location(tester), Routes.home);
      expect(find.byType(JoinClassScreen), findsNothing);
    });
  });

  group('scenarios', () {
    testWidgets('empty: a wrong code is not found, the right one joins as '
        'the only class', (tester) async {
      await pumpHome(tester, config: emptyConfig, location: Routes.joinClass);
      expect(await _joinedIds(tester), isEmpty);
      await join(tester, 'NOPE');
      expect(find.text(_notFound), findsOneWidget);

      await joinSampleClass(tester);
      expect(location(tester), Routes.studyClasses);
      expect(await _joinedIds(tester), ['ite16']);
    });

    testWidgets('error: every lookup fails with the message, and an empty '
        'field still asks for the code', (tester) async {
      await pumpHome(tester, config: errorConfig, location: Routes.joinClass);
      await tester.tap(_button('Join'));
      await tester.pumpAndSettle();
      expect(find.text(_enterCode), findsOneWidget);

      await join(tester, _sampleCode);
      expect(find.text(_notFound), findsOneWidget);
      expect(find.byType(JoinConfirmSheet), findsNothing);
      expect(location(tester), Routes.joinClass);

      // It can be tried again, and fails the same way.
      await tester.tap(_button('Join'));
      await tester.pumpAndSettle();
      expect(find.text(_notFound), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('leaving while a request is in flight', () {
    const slow = FakeConfig(latency: Duration(seconds: 2));
    const slowError = FakeConfig(
      scenario: FakeScenario.error,
      latency: Duration(seconds: 2),
    );

    Future<void> leave(WidgetTester tester) async {
      await tester.tap(find.bySemanticsLabel('Back'));
      await tester.pump(); // the pop starts
      await tester.pump(const Duration(seconds: 1)); // route out
      await tester.pump(); // removed; the provider is disposed
      expect(find.byType(JoinClassScreen), findsNothing);
    }

    // Each request takes 2 s: leaving at 0 s is during the lookup, at 2.5 s
    // during the check for classes already joined; the third one fails late.
    for (final (name, config, wait) in [
      ('during the lookup', slow, Duration.zero),
      (
        'during the check for classes already joined',
        slow,
        const Duration(milliseconds: 2500),
      ),
      ('when the lookup fails after leaving', slowError, Duration.zero),
    ]) {
      testWidgets('$name does not throw', (tester) async {
        await pumpJoin(tester, config: config, onTop: true);
        await tester.enterText(_field, _sampleCode);
        await tester.tap(_button('Join'));
        await tester.pump(wait);
        expect(_appButton(tester, 'Join').onPressed, isNull);
        await leave(tester);
        await tester.pump(const Duration(seconds: 5)); // late answers land
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('during the join, with the sheet open', (tester) async {
      final repo = _GatedClasses()..joinGate = Completer<void>();
      await pumpHome(
        tester,
        location: Routes.joinClass,
        overrides: [_using(repo)],
      );
      await join(tester, _sampleCode);
      await tester.tap(_button('Join class'));
      await tester.pump();
      expect(_appButton(tester, 'Join class').onPressed, isNull);

      // Another page takes over while the join is running.
      router(tester).go(Routes.home);
      await tester.pumpAndSettle();
      expect(find.byType(JoinClassScreen), findsNothing);
      expect(find.byType(JoinConfirmSheet), findsNothing);

      repo.joinGate!.complete();
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(location(tester), Routes.home);
    });
  });

  group('layout', () {
    testWidgets('matches the 428 frame', (tester) async {
      await pumpJoin(tester);
      // Banner: full width, 154 high, right under the bar (48).
      expect(tester.getSize(find.byType(JoinBanner)), const Size(428, 154));
      expect(tester.getTopLeft(find.byType(JoinBanner)).dy, 48);

      // Field and button: 32 from the sides, 32 under the banner, 16 apart.
      final field = tester.getRect(find.byKey(AppTextField.boxKey));
      final button = tester.getRect(_button('Join'));
      expect(field.height, 48);
      expect(button.height, 48);
      expect(field.left, 32);
      expect(field.width, 428 - 64);
      expect(button.left, field.left);
      expect(button.width, field.width);
      expect(field.top, 48 + 154 + 32);
      expect(button.top - field.bottom, 16);

      // Scan card: 86 high, in line with the field, 16 under "or scan".
      final orScan = tester.getRect(find.text('or scan a qr code'));
      final card = tester.getRect(find.byType(JoinScanCard));
      expect(orScan.height, 20);
      expect(orScan.top - button.bottom, 16);
      expect(card.height, 86);
      expect(card.left, field.left);
      expect(card.width, field.width);
      expect(card.top - orScan.bottom, 16);

      // "Before you join" sits 88 under the card.
      final heading = tester.getRect(find.text('Before you join'));
      expect(heading.top - card.bottom, 88);
      expect(heading.height, 20);
    });

    testWidgets('the banner copy is two blocks, 4 apart, centred', (
      tester,
    ) async {
      await pumpJoin(tester);
      final title = tester.getRect(find.text('Learn together'));
      final line = tester.getRect(find.text(_bannerLine));
      expect(title.height, 28);
      expect(line.height, 48);
      expect(line.top - title.bottom, 4);
      // Left edge: the block's 194 and its padding of 12.
      expect(title.left, JoinBanner.copyStart + 12);
      expect(line.left, title.left);
      // Centred in the 154 under the bar (48), with the block's padding of 12.
      final above = title.top - 12 - 48;
      final below = 48 + 154 - (line.bottom + 12);
      expect(above, below);
    });

    testWidgets('the note breaks after "before", as in the design', (
      tester,
    ) async {
      await pumpJoin(tester);
      final note = tester.renderObject<RenderParagraph>(richLine(_note));
      expect(note.size.width, lessThanOrEqualTo(JoinInfo.noteWidth));
      // Two lines of 16: "…teacher before" (234 wide) and "confirming. …
      // My Classes." (279 wide); with "confirming." the first would be 301.
      expect(note.size.height, 32);
      double topOf(String word) {
        final start = _note.indexOf(word);
        return note
            .getBoxesForSelection(
              TextSelection(baseOffset: start, extentOffset: start + 4),
            )
            .first
            .top;
      }

      final first = topOf('before');
      expect(topOf('teacher'), first);
      expect(topOf('confirming'), closeTo(first + 16, 0.01));
      expect(topOf('My Classes'), closeTo(first + 16, 0.01));
    });

    for (final size in const [Size(428, 926), Size(360, 800)]) {
      testWidgets('does not overflow at ${size.width.toInt()}dp', (
        tester,
      ) async {
        await pumpJoin(tester, size: size);
        await tester.ensureVisible(find.text('Before you join'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('scrolls with the keyboard up at 360dp, the message and both '
        'sheets included', (tester) async {
      final repo = _GatedClasses();
      await pumpJoin(
        tester,
        size: const Size(360, 800),
        keyboard: 300,
        overrides: [_using(repo)],
      );
      expect(tester.takeException(), isNull);

      // The notes are below the keyboard's edge until the page is scrolled.
      final lastLine = find.textContaining("Don't have a code?");
      expect(tester.getRect(lastLine).top, greaterThan(800 - 300));
      await tester.ensureVisible(lastLine);
      await tester.pumpAndSettle();
      expect(tester.getRect(lastLine).bottom, lessThanOrEqualTo(800 - 300));

      // The message under the field fits, and so do both sheets.
      await join(tester, 'NOPE');
      expect(find.text(_notFound), findsOneWidget);
      await join(tester, _sampleCode);
      expect(find.text('Join this class?'), findsOneWidget);
      await tester.tap(_button('Cancel'));
      await tester.pumpAndSettle();
      await repo.joinQuietly(_sampleCode);
      await join(tester, _sampleCode);
      expect(find.text(_alreadyJoined), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('JoinClassController', () {
    ProviderContainer makeContainer({
      FakeConfig config = FakeConfig.instant,
      List<Override> overrides = const [],
    }) {
      final container = ProviderContainer(
        overrides: [fakeConfigProvider.overrideWithValue(config), ...overrides],
      );
      addTearDown(container.dispose);
      // Keep the auto-disposed provider alive for the test.
      container.listen(joinClassControllerProvider, (_, _) {});
      return container;
    }

    JoinClassState stateOf(ProviderContainer container) =>
        container.read(joinClassControllerProvider);

    test('nothing typed, an unknown code and a failing repository each set '
        'an error that an edit clears', () async {
      final container = makeContainer();
      final controller = container.read(joinClassControllerProvider.notifier);
      expect(stateOf(container).busy, isFalse);

      expect(await controller.lookUp('  '), isNull);
      expect(stateOf(container).error, JoinClassError.emptyCode);
      controller.edited();
      expect(stateOf(container).error, isNull);

      expect(await controller.lookUp('NOPE'), isNull);
      expect(stateOf(container).error, JoinClassError.notFound);
      expect(stateOf(container).error!.message, _notFound);
      expect(stateOf(container).busy, isFalse);
      controller.edited();
      expect(stateOf(container).error, isNull);

      // A repository that fails reads the same, for the lookup and the join.
      final failing = makeContainer(config: errorConfig);
      final failingController = failing.read(
        joinClassControllerProvider.notifier,
      );
      expect(await failingController.lookUp(_sampleCode), isNull);
      expect(stateOf(failing).error, JoinClassError.notFound);
      expect(await failingController.join(_sampleCode), isFalse);
      expect(stateOf(failing).error, JoinClassError.notFound);
      expect(stateOf(failing).busy, isFalse);
    });

    test('a lookup previews the class without joining it; joining adds it, '
        'and the next lookup says so', () async {
      final container = makeContainer();
      final controller = container.read(joinClassControllerProvider.notifier);

      final preview = (await controller.lookUp(' $_sampleCode '))!;
      expect(preview.code, _sampleCode); // trimmed
      expect(preview.studyClass.id, 'ite16');
      expect(preview.studyClass.title, 'Database Management Systems');
      expect(preview.alreadyJoined, isFalse);
      expect(stateOf(container).busy, isFalse);
      expect(await _idsIn(container), isNot(contains('ite16')));

      expect(await controller.join(preview.code), isTrue);
      expect(stateOf(container).busy, isFalse);
      expect(await _idsIn(container), contains('ite16'));

      final again = (await controller.lookUp(_sampleCode.toLowerCase()))!;
      expect(again.alreadyJoined, isTrue);
      // Joining again is harmless.
      expect(await controller.join(again.code), isTrue);
      expect(await _idsIn(container), hasLength(4));
    });

    test('an edit while joining changes nothing, and joining twice at once '
        'joins once', () async {
      final repo = _GatedClasses()..joinGate = Completer<void>();
      final container = makeContainer(overrides: [_using(repo)]);
      final controller = container.read(joinClassControllerProvider.notifier);

      final joining = controller.join(_sampleCode);
      expect(stateOf(container).joining, isTrue);
      controller.edited();
      expect(stateOf(container).joining, isTrue);
      expect(await controller.join(_sampleCode), isFalse);
      expect(repo.joined, hasLength(1));

      repo.joinGate!.complete();
      expect(await joining, isTrue);
      expect(stateOf(container).joining, isFalse);
    });
  });
}
