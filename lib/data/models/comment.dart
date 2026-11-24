/// Badge on a comment tile (126, 128).
enum CommentTag {
  mostHelpful('Most helpful'),
  creator('Creator');

  const CommentTag(this.label);
  final String label;
}

/// Filter chips in the discussion sheet (128).
enum CommentFilter {
  all('All'),
  mostHelpful('Most helpful'),
  fromCreator('From creator');

  const CommentFilter(this.label);
  final String label;
}

/// A comment tile in the class discussion (126, 128).
final class Comment {
  const Comment({
    required this.id,
    required this.questionId,
    required this.authorId,
    required this.authorName,
    required this.authorMeta,
    required this.postedAt,
    required this.body,
    this.helpfulCount = 0,
    this.tags = const {},
    this.replyCount = 0,
  });

  final String id;
  final String questionId;
  final String authorId;
  final String authorName;

  /// e.g. "BSIT - II".
  final String authorMeta;
  final DateTime postedAt;
  final String body;
  final int helpfulCount;
  final Set<CommentTag> tags;
  final int replyCount;

  Comment copyWith({
    String? id,
    String? questionId,
    String? authorId,
    String? authorName,
    String? authorMeta,
    DateTime? postedAt,
    String? body,
    int? helpfulCount,
    Set<CommentTag>? tags,
    int? replyCount,
  }) => Comment(
    id: id ?? this.id,
    questionId: questionId ?? this.questionId,
    authorId: authorId ?? this.authorId,
    authorName: authorName ?? this.authorName,
    authorMeta: authorMeta ?? this.authorMeta,
    postedAt: postedAt ?? this.postedAt,
    body: body ?? this.body,
    helpfulCount: helpfulCount ?? this.helpfulCount,
    tags: tags ?? this.tags,
    replyCount: replyCount ?? this.replyCount,
  );
}
