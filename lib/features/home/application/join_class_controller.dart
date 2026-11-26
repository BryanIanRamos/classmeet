import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/study_class.dart';
import '../../../data/providers.dart';

/// Why a join attempt stopped, shown under the code field (13.1).
enum JoinClassError {
  /// Join was tapped with nothing typed. Provisional copy.
  emptyCode('Enter your class code.'),

  /// The code is unknown, or the lookup or the join failed. Provisional copy.
  notFound("We couldn't find a class with that code. Check it and try again.");

  const JoinClassError(this.message);

  final String message;
}

/// A class found by its code, ready to be confirmed in the sheet (GAP-20).
final class JoinPreview {
  const JoinPreview({
    required this.code,
    required this.studyClass,
    required this.alreadyJoined,
  });

  /// The code as typed, trimmed. [JoinClassController.join] takes it back.
  final String code;
  final StudyClass studyClass;

  /// The student is in this class already, so there is nothing to join.
  final bool alreadyJoined;
}

/// What Join a class (13.1) shows while it works and after it failed.
final class JoinClassState {
  const JoinClassState({
    this.checking = false,
    this.joining = false,
    this.error,
  });

  /// A lookup is running; the Join button is disabled.
  final bool checking;

  /// The student confirmed and the join is running (the sheet is open).
  final bool joining;

  final JoinClassError? error;

  bool get busy => checking || joining;
}

/// Drives Join a class (13.1): looks a class up by its code without joining
/// it, then joins it once the student confirms.
///
/// Every answer is checked before it touches the state: the provider is
/// auto-disposed, so leaving the screen mid-request drops the answer, and
/// editing the field drops a lookup for the code that is no longer there.
class JoinClassController extends Notifier<JoinClassState> {
  /// Counts lookups and field edits; a lookup is current while its number is.
  int _run = 0;

  @override
  JoinClassState build() => const JoinClassState();

  /// The field was edited: an error goes away, and a lookup still running is
  /// dropped, so Join works again at once. While the join itself is running
  /// there is neither, so an edit changes nothing.
  void edited() {
    _run++;
    if (state.checking || state.error != null) state = const JoinClassState();
  }

  /// Looks up the class behind [typed] and whether the student is in it
  /// already. Returns null, with [JoinClassState.error] set, when nothing was
  /// typed or the lookup failed, and null without a change when the answer is
  /// no longer wanted (the screen closed, the field changed).
  Future<JoinPreview?> lookUp(String typed) async {
    if (state.busy) return null;
    final code = typed.trim();
    if (code.isEmpty) {
      state = const JoinClassState(error: JoinClassError.emptyCode);
      return null;
    }
    final run = ++_run;
    state = const JoinClassState(checking: true);
    final classes = ref.read(classRepositoryProvider);
    try {
      final found = await classes.findClassByCode(code);
      if (!ref.mounted || run != _run) return null;
      final joined = await classes.fetchClasses();
      if (!ref.mounted || run != _run) return null;
      state = const JoinClassState();
      return JoinPreview(
        code: code,
        studyClass: found,
        alreadyJoined: joined.any((c) => c.id == found.id),
      );
    } on Object {
      if (!ref.mounted || run != _run) return null;
      state = const JoinClassState(error: JoinClassError.notFound);
      return null;
    }
  }

  /// Joins the class behind [code] (a [JoinPreview.code]). True when the
  /// student is in the class now; false, with the error set, when it failed.
  Future<bool> join(String code) async {
    if (state.joining) return false;
    state = const JoinClassState(joining: true);
    final classes = ref.read(classRepositoryProvider);
    try {
      await classes.joinClass(code);
      if (!ref.mounted) return false;
      state = const JoinClassState();
      return true;
    } on Object {
      if (!ref.mounted) return false;
      state = const JoinClassState(error: JoinClassError.notFound);
      return false;
    }
  }
}

final joinClassControllerProvider =
    NotifierProvider.autoDispose<JoinClassController, JoinClassState>(
      JoinClassController.new,
    );
