import '../models/comment.dart';
import '../repositories/comment_repository.dart';
import '../repositories/repository_exception.dart';
import 'fake_config.dart';
import 'samples/comment_samples.dart';

/// In-memory [CommentRepository]. New comments are posted as the signed-in
/// user and show up first.
class FakeCommentRepository implements CommentRepository {
  FakeCommentRepository(this._config, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now {
    _comments = sampleComments(_clock());
  }

  final FakeConfig _config;
  final DateTime Function() _clock;
  late List<Comment> _comments;
  final Set<String> _markedHelpful = {};
  var _nextId = 14;

  @override
  Future<List<Comment>> fetchComments(
    String questionId, {
    CommentFilter filter = CommentFilter.all,
  }) => _config.answerList('fetchComments', () {
    final all = _comments.where((c) => c.questionId == questionId);
    return switch (filter) {
      CommentFilter.all => all.toList(),
      CommentFilter.mostHelpful =>
        all.where((c) => c.tags.contains(CommentTag.mostHelpful)).toList()
          ..sort((a, b) => b.helpfulCount.compareTo(a.helpfulCount)),
      CommentFilter.fromCreator =>
        all.where((c) => c.tags.contains(CommentTag.creator)).toList(),
    };
  });

  @override
  Future<Comment> postComment(String questionId, String body) =>
      _config.answer('postComment', () {
        final text = body.trim();
        if (text.isEmpty) {
          throw const RepositoryException('A comment cannot be empty');
        }
        final comment = Comment(
          id: 'comment-${_nextId++}',
          questionId: questionId,
          authorId: sampleMeId,
          authorName: 'Bryan Ramos',
          authorMeta: 'BSIT - II',
          postedAt: _clock(),
          body: text,
        );
        _comments = [comment, ..._comments];
        return comment;
      });

  /// Marks a comment helpful once per comment; asking again returns it
  /// unchanged.
  @override
  Future<Comment> markHelpful(String commentId) =>
      _config.answer('markHelpful', () {
        final index = _comments.indexWhere((c) => c.id == commentId);
        if (index < 0) {
          throw RepositoryException('Comment "$commentId" not found');
        }
        if (_markedHelpful.add(commentId)) {
          _comments[index] = _comments[index].copyWith(
            helpfulCount: _comments[index].helpfulCount + 1,
          );
        }
        return _comments[index];
      });
}
