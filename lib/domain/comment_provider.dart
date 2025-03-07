import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

// コメントのいいね数を監視するプロバイダー
final commentLikesCountProvider =
    StreamProvider.family<int, String>((ref, commentId) {
  final firestore = FirebaseFirestore.instance;

  print('いいね数を監視: $commentId');

  return firestore
      .collection('comments')
      .doc(commentId)
      .snapshots()
      .map((snapshot) {
    if (!snapshot.exists) {
      print('コメントが存在しません: $commentId');
      return 0;
    }
    final likes = snapshot.data()?['likes'];
    final result = likes is int ? likes : 0;
    print('いいね数を取得: $commentId = $result');
    return result;
  });
});

// いいねしているかを確認するプロバイダー
final commentLikeStatusProvider =
    StreamProvider.family<bool, String>((ref, commentId) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    return Stream.value(false);
  }

  final firestore = FirebaseFirestore.instance;

  print('いいね状態を監視: $commentId, ユーザー: ${user.uid}');

  // キャッシュを使わないようにする
  return firestore
      .collection('comments')
      .doc(commentId)
      .collection('likes')
      .doc(user.uid)
      .snapshots(includeMetadataChanges: true) // メタデータの変更も含める
      .map((snapshot) {
    final exists = snapshot.exists;
    final fromCache = snapshot.metadata.isFromCache;
    print(
      'いいね状態: $commentId, ユーザー: ${user.uid}, いいね済み: $exists, キャッシュから: $fromCache',
    );
    return exists;
  });
});

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

// ソート済みコメントプロバイダー
final sortedCommentsProvider =
    Provider.family<AsyncValue<List<Comment>>, String>(
  (ref, reviewId) {
    final commentsAsync = ref.watch(commentsProvider(reviewId));
    final sortOrder = ref.watch(commentSortOrderProvider);

    return commentsAsync.whenData((comments) {
      final sortedComments = List<Comment>.from(comments);

      // ソート順に応じてコメントをソート
      switch (sortOrder) {
        case CommentSortOrder.newest:
          sortedComments.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          break;
        case CommentSortOrder.oldest:
          sortedComments.sort((a, b) => a.createdAt.compareTo(b.createdAt));
          break;
        case CommentSortOrder.mostLiked:
          sortedComments.sort((a, b) => b.likesCount.compareTo(a.likesCount));
          break;
      }

      return sortedComments;
    });
  },
);

// いいね切り替え用のプロバイダー
final toggleLikeProvider = FutureProvider.family<void, String>(
  (ref, commentId) async {
    try {
      final repository = ref.watch(commentRepositoryProvider);
      await repository.toggleLike(commentId);

      // 関連するすべてのプロバイダーを無効化
      ref.invalidateSelf(); // 自分自身を無効化
      ref.invalidate(commentLikeStatusProvider(commentId));
      ref.invalidate(commentLikesCountProvider(commentId));
      ref.invalidate(commentsProvider);

      print('toggleLikeProvider: プロバイダーを無効化しました');
    } catch (e) {
      print('toggleLikeProvider エラー: $e');
      rethrow;
    }
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
