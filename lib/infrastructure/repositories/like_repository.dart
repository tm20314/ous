import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:ous/gen/review_data.dart';

class LikeRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // いいねを追加
  Future<void> addLike(
    String reviewId,
    String collectionName,
    Review review,
  ) async {
    try {
      final user = _auth.currentUser;

      // ゲストユーザーまたは未ログインの場合はエラーを投げる
      if (user == null || user.isAnonymous) {
        throw Exception('ゲストユーザーはいいねできません。ログインしてください。');
      }

      final userId = user.uid;

      debugPrint('いいね追加: reviewId=$reviewId, collectionName=$collectionName');

      // 既にいいねしているか確認
      final userLikeRef = _firestore
          .collection('userLikes')
          .doc(userId)
          .collection('likedReviews')
          .doc(reviewId);

      final userLikeDoc = await userLikeRef.get();

      if (userLikeDoc.exists) {
        debugPrint('既にいいねしています: $reviewId');
        // 既にいいねしている場合は削除する（いいね取り消し）
        await removeLike(reviewId);
        return;
      }

      // いいねが存在しない場合は新規追加
      // トランザクションを使用して整合性を保つ
      await _firestore.runTransaction((transaction) async {
        // レビューのいいね数を更新
        final reviewLikeRef =
            _firestore.collection('reviewLikes').doc(reviewId);
        final reviewLikeDoc = await transaction.get(reviewLikeRef);

        // ユーザーのいいね一覧に追加
        transaction.set(userLikeRef, {
          'reviewId': reviewId,
          'collectionName': collectionName,
          'review': review.toJson(),
          'timestamp': FieldValue.serverTimestamp(),
        });

        // レビューのいいね数を更新
        if (reviewLikeDoc.exists) {
          transaction.update(reviewLikeRef, {
            'count': FieldValue.increment(1),
            'lastUpdated': FieldValue.serverTimestamp(),
          });
        } else {
          transaction.set(reviewLikeRef, {
            'count': 1,
            'lastUpdated': FieldValue.serverTimestamp(),
          });
        }
      });

      debugPrint('いいねを追加しました: $reviewId');
    } catch (e) {
      debugPrint('いいね追加エラー: $e');
      rethrow;
    }
  }

  // レビューのいいね数を取得
  Future<int> getLikeCount(String reviewId) async {
    try {
      final doc =
          await _firestore.collection('reviewLikes').doc(reviewId).get();

      if (!doc.exists) {
        return 0;
      }

      return doc.data()?['count'] as int? ?? 0;
    } catch (e) {
      print('いいね数の取得に失敗しました: $e');
      return 0;
    }
  }

  // ユーザーのいいね一覧を取得
  Stream<List<Map<String, dynamic>>> getUserLikes(String userId) {
    return _firestore
        .collection('userLikes')
        .doc(userId)
        .collection('likedReviews')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      final likes = <Map<String, dynamic>>[];

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final reviewId = doc.id;
        final collectionName = data['collectionName'] as String? ?? '';
        final reviewData = data['review'] as Map<String, dynamic>?;

        if (reviewData != null) {
          // reviewデータが直接保存されている場合はそれを使用
          final review = Review.fromJson(reviewData);
          likes.add({
            'reviewId': reviewId,
            'collectionName': collectionName,
            'likedAt': data['timestamp'],
            'review': review,
          });
        } else {
          try {
            // レビュー情報を取得
            final reviewDoc =
                await _firestore.collection(collectionName).doc(reviewId).get();

            if (reviewDoc.exists && reviewDoc.data() != null) {
              final review = Review.fromJson(reviewDoc.data()!);

              likes.add({
                'reviewId': reviewId,
                'collectionName': collectionName,
                'likedAt': data['timestamp'],
                'review': review,
              });
            }
          } catch (e) {
            debugPrint('レビュー情報の取得に失敗しました: $e');
          }
        }
      }

      return likes;
    });
  }

  // ユーザーがいいねしているかチェック
  Future<bool> hasUserLiked(String reviewId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        return false;
      }

      // userLikesコレクションでチェック
      final docRef = await _firestore
          .collection('userLikes')
          .doc(userId)
          .collection('likedReviews')
          .doc(reviewId)
          .get();

      return docRef.exists;
    } catch (e) {
      debugPrint('いいねチェックに失敗しました: $e');
      return false;
    }
  }

  // いいねを削除
  Future<void> removeLike(String reviewId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('ユーザーがログインしていません');
      }

      final userId = user.uid;
      debugPrint('いいね削除: reviewId=$reviewId');

      // トランザクションを使用して整合性を保つ
      await _firestore.runTransaction((transaction) async {
        // 1. すべての読み取り操作を先に行う
        final userLikeRef = _firestore
            .collection('userLikes')
            .doc(userId)
            .collection('likedReviews')
            .doc(reviewId);

        final userLikeDoc = await transaction.get(userLikeRef);

        // いいねしていない場合は何もしない
        if (!userLikeDoc.exists) {
          debugPrint('いいねが存在しません: $reviewId');
          return;
        }

        // レビューのいいね数を取得
        final reviewLikeRef =
            _firestore.collection('reviewLikes').doc(reviewId);
        final reviewLikeDoc = await transaction.get(reviewLikeRef);

        // 2. すべての読み取りが完了した後で書き込み操作を行う

        // ユーザーのいいね一覧から削除
        transaction.delete(userLikeRef);

        // レビューのいいね数を更新
        if (reviewLikeDoc.exists) {
          final currentCount = reviewLikeDoc.data()?['count'] as int? ?? 0;
          if (currentCount > 0) {
            transaction.update(reviewLikeRef, {
              'count': FieldValue.increment(-1),
              'lastUpdated': FieldValue.serverTimestamp(),
            });
          }
        }
      });

      debugPrint('いいねを削除しました: $reviewId');
    } catch (e) {
      debugPrint('いいねの削除に失敗しました: $e');
      rethrow;
    }
  }
}
