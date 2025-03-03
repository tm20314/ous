import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ous/domain/models/comment.dart';
import 'package:ous/infrastructure/repositories/comment_repository.dart';

// コメント追加用のプロバイダー
final addCommentProvider = FutureProvider.family<void,
    ({String reviewId, String collectionName, String content})>(
  (ref, params) async {
    final repository = ref.watch(commentRepositoryProvider);
    await repository.addComment(
      reviewId: params.reviewId,
      collectionName: params.collectionName,
      content: params.content,
    );
  },
);

final commentRepositoryProvider = Provider<CommentRepository>((ref) {
  return CommentRepository();
});

// コメントの並び順を管理するプロバイダー
final commentSortOrderProvider = StateProvider<CommentSortOrder>((ref) {
  return CommentSortOrder.newest;
});

final commentsProvider =
    StreamProvider.family<List<Comment>, String>((ref, reviewId) {
  final repository = ref.watch(commentRepositoryProvider);
  return repository.getCommentsForReview(reviewId);
});

// コメント削除用のプロバイダー
final deleteCommentProvider = FutureProvider.family<void, String>(
  (ref, commentId) async {
    final repository = ref.watch(commentRepositoryProvider);
    await repository.deleteComment(commentId);
  },
);

// 並び順を考慮したコメント取得プロバイダー
final sortedCommentsProvider =
    Provider.family<List<Comment>?, String>((ref, reviewId) {
  final commentsAsync = ref.watch(commentsProvider(reviewId));
  final sortOrder = ref.watch(commentSortOrderProvider);

  if (commentsAsync.value == null) return null;

  final comments = List<Comment>.from(commentsAsync.value!);

  switch (sortOrder) {
    case CommentSortOrder.newest:
      comments.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      break;
    case CommentSortOrder.oldest:
      comments.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      break;
    case CommentSortOrder.mostLiked:
      comments.sort((a, b) => b.likes.compareTo(a.likes));
      break;
  }

  return comments;
});

// いいね切り替え用のプロバイダー
final toggleLikeProvider = FutureProvider.family<void, String>(
  (ref, commentId) async {
    final repository = ref.watch(commentRepositoryProvider);
    await repository.toggleLike(commentId);
  },
);

// コメント編集用のプロバイダー
final updateCommentProvider =
    FutureProvider.family<void, ({String commentId, String content})>(
  (ref, params) async {
    final repository = ref.watch(commentRepositoryProvider);
    await repository.updateComment(params.commentId, params.content);
  },
);

enum CommentSortOrder {
  newest,
  oldest,
  mostLiked,
}
