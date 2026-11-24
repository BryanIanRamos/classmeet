import '../../models/mistake.dart';
import 'quiz_samples.dart';

MistakeEntry _entry(
  String id,
  String prompt,
  String code, {
  required int missed,
  int streak = 0,
}) => MistakeEntry(
  questionId: id,
  prompt: prompt,
  classCode: code,
  missCount: missed,
  correctStreak: streak,
);

// Further prompts, 11 per course, interleaved ITE13 / CSC126 / IS109 below.
const _ite13 = [
  'What is the main function of an operating system?',
  'What is the difference between hardware and software?',
  'What does CPU stand for?',
  'Name two input devices',
  'Convert decimal 10 to binary',
  'How many bits are in one byte?',
  'What does URL stand for?',
  'What is the difference between RAM and storage?',
  'Define the term algorithm',
  'What is a web browser used for?',
  'Name two output devices',
];

const _csc126 = [
  'What is a variable in C?',
  'Which data type stores whole numbers in C?',
  'What does the printf function do in C?',
  'What is the difference between = and == in C?',
  'How many times does for (i = 0; i < 5; i++) run?',
  'What does a return statement do in a function?',
  'What is an array in C?',
  'Which character ends most statements in C?',
  'What does the main function do in a C program?',
  'What is a loop used for?',
  'What does #include <stdio.h> do?',
];

const _is109 = [
  'What is the derivative of x squared?',
  'What is the integral of 2x?',
  'What is the limit of 1/x as x approaches infinity?',
  'What is the derivative of a constant?',
  'What is the slope of a horizontal line?',
  'What is the derivative of sin(x)?',
  'What is the value of 5 factorial?',
  'What does the derivative of a function measure?',
  'What is the limit of x as x approaches 3?',
  'What is the power rule for derivatives?',
  'What is the derivative of e to the x?',
];

/// 127 "Mistake Bank": 38 questions, 12 mastered, across ITE13 / CSC126 /
/// IS109. The first five are the design's rows (the "Calculus" row uses
/// IS109, the third course chip); the other 33 are generated from the lists
/// above, the last 12 of them mastered. The summary is derived from these.
final List<MistakeEntry> sampleMistakes = () {
  final extra = <MistakeEntry>[];
  for (var i = 0; i < 33; i++) {
    final (code, prompts) = switch (i % 3) {
      0 => ('ITE13', _ite13),
      1 => ('CSC126', _csc126),
      _ => ('IS109', _is109),
    };
    final mastered = i >= 21;
    extra.add(
      _entry(
        'mistake-${code.toLowerCase()}-${i ~/ 3 + 1}',
        prompts[i ~/ 3],
        code,
        missed: mastered ? 1 + i % 2 : 1 + i % 3,
        streak: mastered ? MistakeEntry.masteryStreak : i % 2,
      ),
    );
  }
  return [
    // The id is the "What does RAM stand for?" question of the sample quiz.
    _entry('$sampleQuizId-q3', 'What does RAM stand for?', 'ITE13', missed: 3),
    _entry(
      'mistake-ite13-functions',
      'List four functions of a computer',
      'ITE13',
      missed: 2,
    ),
    _entry(
      'mistake-csc126-ifelse',
      'Explain the if–else syntax in C',
      'CSC126',
      missed: 2,
    ),
    _entry(
      'mistake-is109-limit',
      'Evaluate the limit of sin(x)/x',
      'IS109',
      missed: 1,
    ),
    _entry(
      'mistake-ite13-binary',
      'Convert binary 1011 to decimal',
      'ITE13',
      missed: 1,
    ),
    ...extra,
  ];
}();
