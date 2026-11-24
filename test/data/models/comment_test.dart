import 'package:classmeet/data/models/comment.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Comment', () {
    final c = Comment(
      id: 'c',
      questionId: 'q',
      authorId: 'u',
      authorName: 'Bryan Ramos',
      authorMeta: 'BSIT - II',
      postedAt: DateTime(2026),
      body: 'b',
      helpfulCount: 42,
      tags: const {CommentTag.mostHelpful},
      replyCount: 2,
    );
    final d = c.copyWith();
    expect(
      [d.id, d.questionId, d.authorId, d.authorName],
      ['c', 'q', 'u', 'Bryan Ramos'],
    );
    expect(
      [d.authorMeta, d.body, d.helpfulCount, d.replyCount],
      ['BSIT - II', 'b', 42, 2],
    );
    expect(d.postedAt, DateTime(2026));
    expect(d.tags, {CommentTag.mostHelpful});
    final e = c.copyWith(helpfulCount: 43);
    expect(e.helpfulCount, 43);
    expect(e.body, 'b');
  });

  test('enum labels', () {
    expect(CommentTag.values.map((e) => e.label), ['Most helpful', 'Creator']);
    expect(CommentFilter.values.map((e) => e.label), [
      'All',
      'Most helpful',
      'From creator',
    ]);
  });
}
