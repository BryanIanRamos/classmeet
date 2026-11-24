import 'package:classmeet/data/fakes/fake_comment_repository.dart';
import 'package:classmeet/data/fakes/fake_config.dart';
import 'package:classmeet/data/models/comment.dart';
import 'package:classmeet/data/repositories/repository_exception.dart';
import 'package:flutter_test/flutter_test.dart';

const _empty = FakeConfig(scenario: FakeScenario.empty, latency: Duration.zero);
const _error = FakeConfig(scenario: FakeScenario.error, latency: Duration.zero);
const _q = 'intro-computing-q1';
final _now = DateTime(2026, 11, 24, 12);

void main() {
  late FakeCommentRepository repo;
  setUp(
    () => repo = FakeCommentRepository(FakeConfig.instant, clock: () => _now),
  );

  test('13 comments, the first two are the 126 tiles', () async {
    final all = await repo.fetchComments(_q);
    expect(all, hasLength(13));
    final bryan = all[0];
    expect(bryan.authorName, 'Bryan Ramos');
    expect(bryan.authorMeta, 'BSIT - II');
    expect(bryan.helpfulCount, 42);
    expect(bryan.tags, {CommentTag.mostHelpful});
    expect(bryan.postedAt, _now.subtract(const Duration(days: 3)));
    expect(bryan.body, startsWith('Think of the CPU as the part'));
    final ara = all[1];
    expect(ara.authorName, 'Ara Matias');
    expect(ara.authorMeta, 'BSIT - III');
    expect(ara.helpfulCount, 2);
    expect(ara.postedAt, _now.subtract(const Duration(hours: 1)));
    expect(ara.body, 'I mixed it up with RAM too. RAM stores, CPU executes.');
  });

  test('other questions have no comments', () async {
    expect(await repo.fetchComments('intro-computing-q2'), isEmpty);
  });

  test('filters', () async {
    final helpful = await repo.fetchComments(
      _q,
      filter: CommentFilter.mostHelpful,
    );
    expect(helpful, isNotEmpty);
    expect(
      helpful.every((c) => c.tags.contains(CommentTag.mostHelpful)),
      isTrue,
    );
    final creator = await repo.fetchComments(
      _q,
      filter: CommentFilter.fromCreator,
    );
    expect(creator.length, greaterThanOrEqualTo(1));
    expect(creator.every((c) => c.tags.contains(CommentTag.creator)), isTrue);
    expect(creator.first.authorName, 'Rhea Beye');
  });

  test('postComment adds first as the user; empty text fails', () async {
    final c = await repo.postComment(_q, '  Nice tip  ');
    expect(c.body, 'Nice tip');
    expect(c.authorName, 'Bryan Ramos');
    expect(c.postedAt, _now);
    final all = await repo.fetchComments(_q);
    expect(all, hasLength(14));
    expect(all.first.id, c.id);
    await expectLater(
      repo.postComment(_q, '   '),
      throwsA(isA<RepositoryException>()),
    );
  });

  test('markHelpful counts once per comment', () async {
    final once = await repo.markHelpful('comment-2');
    expect(once.helpfulCount, 3);
    expect((await repo.markHelpful('comment-2')).helpfulCount, 3);
    expect((await repo.fetchComments(_q))[1].helpfulCount, 3);
    await expectLater(
      repo.markHelpful('missing'),
      throwsA(isA<RepositoryException>()),
    );
  });

  test('empty scenario returns an empty list', () async {
    expect(await FakeCommentRepository(_empty).fetchComments(_q), isEmpty);
  });

  test('error scenario throws RepositoryException', () async {
    final r = FakeCommentRepository(_error);
    await expectLater(r.fetchComments(_q), throwsA(isA<RepositoryException>()));
    await expectLater(
      r.postComment(_q, 'x'),
      throwsA(isA<RepositoryException>()),
    );
    await expectLater(
      r.markHelpful('comment-1'),
      throwsA(isA<RepositoryException>()),
    );
  });
}
