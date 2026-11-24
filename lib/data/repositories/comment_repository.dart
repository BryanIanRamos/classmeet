import '../models/comment.dart';

/// Class discussion under a question (126, 128).
abstract interface class CommentRepository {
  Future<List<Comment>> fetchComments(
    String questionId, {
    CommentFilter filter = CommentFilter.all,
  });

  Future<Comment> postComment(String questionId, String body);

  /// Marks a comment helpful and returns it with the new count.
  Future<Comment> markHelpful(String commentId);
}
