import '../../models/comment.dart';
import 'quiz_samples.dart';

/// The signed-in user (Bryan Ramos in 126, 128). New comments use this id.
const sampleMeId = 'me';

/// The quiz creator (a "Creator" chip in 128).
const sampleCreatorId = 'user-rhea';

/// Class discussion under the design's question. 126 and 128 both say
/// "Class discussion (13)", so there are 13 comments (128's "24 comments"
/// caption is ignored). The first two are the tiles shown in 126.
List<Comment> sampleComments(DateTime now) {
  Comment c(
    int n,
    String authorId,
    String name,
    String meta,
    Duration ago,
    String body,
    int helpful, [
    Set<CommentTag> tags = const {},
  ]) => Comment(
    id: 'comment-$n',
    questionId: sampleQuestionId,
    authorId: authorId,
    authorName: name,
    authorMeta: meta,
    postedAt: now.subtract(ago),
    body: body,
    helpfulCount: helpful,
    tags: tags,
  );
  return [
    c(
      1,
      sampleMeId,
      'Bryan Ramos',
      'BSIT - II',
      const Duration(days: 3),
      'Think of the CPU as the part that follows instructions, while the '
          'keyboard sends input and the monitor shows output.',
      42,
      {CommentTag.mostHelpful},
    ),
    c(
      2,
      'user-ara',
      'Ara Matias',
      'BSIT - III',
      const Duration(hours: 1),
      'I mixed it up with RAM too. RAM stores, CPU executes.',
      2,
    ),
    c(
      3,
      sampleCreatorId,
      'Rhea Beye',
      'BSIT - I',
      const Duration(days: 2),
      'My trick: keyboard = input, CPU = processing, monitor = output.',
      21,
      {CommentTag.creator},
    ),
    c(
      4,
      'user-joshua',
      'Joshua Rosales',
      'BSIT - III',
      const Duration(minutes: 30),
      'Remember the fetch–decode–execute cycle from Week 2. The CPU '
          'carries out the instructions one step at a time.',
      1,
    ),
    c(
      5,
      'user-mika',
      'Mika Santos',
      'BSIT - II',
      const Duration(hours: 5),
      'Easy way to remember: the CPU is the brain of the computer.',
      5,
    ),
    c(
      6,
      'user-paolo',
      'Paolo Reyes',
      'BSIT - I',
      const Duration(hours: 6),
      'I picked Hard drive at first, but that only stores your files.',
      3,
    ),
    c(
      7,
      'user-liza',
      'Liza Cruz',
      'BSIT - III',
      const Duration(days: 1),
      'The CPU is also called the processor.',
      8,
    ),
    c(
      8,
      'user-dan',
      'Dan Villar',
      'BSIT - II',
      const Duration(days: 1, hours: 2),
      'The monitor only shows output. It does not run any instructions.',
      4,
    ),
    c(
      9,
      'user-jen',
      'Jen Ocampo',
      'BSIT - I',
      const Duration(days: 2, hours: 3),
      'Clock speed, measured in GHz, tells you how fast the CPU works.',
      6,
    ),
    c(
      10,
      sampleCreatorId,
      'Rhea Beye',
      'BSIT - I',
      const Duration(days: 2, hours: 5),
      'Heads up: Week 2 goes deeper into how the CPU works, so keep this '
          'one in mind.',
      9,
      {CommentTag.creator},
    ),
    c(
      11,
      'user-marco',
      'Marco Dizon',
      'BSIT - III',
      const Duration(days: 3, hours: 4),
      'The keyboard is an input device, so it cannot be the answer.',
      2,
    ),
    c(
      12,
      'user-kai',
      'Kai Mendoza',
      'BSIT - II',
      const Duration(days: 4),
      'Good one to review before the exam.',
      1,
    ),
    c(
      13,
      'user-tin',
      'Tin Alvarez',
      'BSIT - I',
      const Duration(days: 5),
      'Got it right on my second try!',
      0,
    ),
  ];
}
