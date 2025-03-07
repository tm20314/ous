import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ous/gen/review_data.dart'; // Review型をインポート
import 'package:ous/infrastructure/repositories/like_repository.dart';

// いいねを追加するプロバイダー
final addLikeProvider = FutureProvider.family<void, (String, String, Review)>(
  (ref, params) async {
    final (reviewId, collectionName, review) = params;
    final repository = ref.read(likeRepositoryProvider);

    await repository.addLike(reviewId, collectionName, review);

    // キャッシュを更新
    ref.invalidate(hasUserLikedProvider(reviewId));
    ref.invalidate(likeCountProvider(reviewId));
    ref.invalidate(
      userLikesProvider(FirebaseAuth.instance.currentUser?.uid ?? ''),
    );
  },
);

// ユーザーがいいねしているかを取得するプロバイダー
final hasUserLikedProvider =
    FutureProvider.autoDispose.family<bool, String>((ref, reviewId) async {
  final repository = ref.read(likeRepositoryProvider);

  final result = await repository.hasUserLiked(reviewId);
  debugPrint('hasUserLiked($reviewId) = $result');
  return result;
});

// レビューのいいね数を取得するプロバイダー
final likeCountProvider =
    StreamProvider.autoDispose.family<int, String>((ref, reviewId) {
  final firestore = FirebaseFirestore.instance;

  return firestore
      .collection('reviewLikes')
      .doc(reviewId)
      .snapshots()
      .map((snapshot) {
    if (!snapshot.exists) {
      return 0;
    }
    return snapshot.data()?['count'] as int? ?? 0;
  });
});

// LikeRepositoryのプロバイダー
final likeRepositoryProvider = Provider<LikeRepository>((ref) {
  return LikeRepository();
});

// いいねを削除するプロバイダー
final removeLikeProvider = FutureProvider.family<void, String>(
  (ref, reviewId) async {
    final repository = ref.read(likeRepositoryProvider);

    await repository.removeLike(reviewId);

    // キャッシュを更新
    ref.invalidate(hasUserLikedProvider(reviewId));
    ref.invalidate(likeCountProvider(reviewId));
    ref.invalidate(
      userLikesProvider(FirebaseAuth.instance.currentUser?.uid ?? ''),
    );
  },
);

// ユーザーのいいね一覧を取得するプロバイダー
final userLikesProvider =
    StreamProvider.family<List<Map<String, dynamic>>, String>((ref, userId) {
  final repository = ref.watch(likeRepositoryProvider);
  return repository.getUserLikes(userId);
});
