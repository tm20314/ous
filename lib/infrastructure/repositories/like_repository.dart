import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

      print('いいね追加: reviewId=$reviewId, collectionName=$collectionName');

      // トランザクションを使用して整合性を保つ
      await _firestore.runTransaction((transaction) async {
        // 既存のいいねを確認
        final userLikeRef = _firestore
            .collection('userLikes')
            .doc(userId)
            .collection('likedReviews')
            .doc(reviewId);

        final userLikeDoc = await transaction.get(userLikeRef);

        // 既にいいねしている場合は何もしない
        if (userLikeDoc.exists) {
          print('既にいいねしています: $reviewId');
          return;
        }

        // 新しいいいねを作成
        final likeRef = _firestore.collection('likes').doc();
        final likeId = likeRef.id;

        // レビューのいいね数を更新
        final reviewLikeRef =
            _firestore.collection('reviewLikes').doc(reviewId);
        final reviewLikeDoc = await transaction.get(reviewLikeRef);

        if (reviewLikeDoc.exists) {
          transaction.update(reviewLikeRef, {
            'count': FieldValue.increment(1),
            'lastUpdated': FieldValue.serverTimestamp(),
          });
        } else {
          transaction.set(reviewLikeRef, {
            'count': 1,
            'collectionName': collectionName,
            'lastUpdated': FieldValue.serverTimestamp(),
          });
        }

        // いいね情報を保存
        transaction.set(likeRef, {
          'userId': userId,
          'reviewId': reviewId,
          'reviewInternalId': review.ID,
          'collectionName': collectionName,
          'createdAt': FieldValue.serverTimestamp(),
          'reviewData': {
            'title': review.zyugyoumei,
            'professor': review.kousimei,
            'rating': review.sougouhyouka,
          },
        });

        // ユーザーのいいね一覧に追加
        transaction.set(userLikeRef, {
          'likeId': likeId,
          'likedAt': FieldValue.serverTimestamp(),
          'collectionName': collectionName,
        });
      });

      print('いいねを追加しました: $reviewId');
    } catch (e) {
      print('いいねの追加に失敗しました: $e');
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
        .orderBy('likedAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      final likes = <Map<String, dynamic>>[];

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final reviewId = doc.id;
        final collectionName = data['collectionName'] as String? ?? '';

        try {
          // レビュー情報を取得
          final reviewDoc =
              await _firestore.collection(collectionName).doc(reviewId).get();

          if (reviewDoc.exists && reviewDoc.data() != null) {
            final review = Review.fromJson(reviewDoc.data()!);

            likes.add({
              'reviewId': reviewId,
              'collectionName': collectionName,
              'likedAt': data['likedAt'],
              'review': review,
            });
          }
        } catch (e) {
          print('レビュー情報の取得に失敗しました: $e');
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

      // 内部IDとドキュメントIDの両方をチェック
      final docByDocId = await _firestore
          .collection('userLikes')
          .doc(userId)
          .collection('likedReviews')
          .doc(reviewId)
          .get();

      if (docByDocId.exists) {
        return true;
      }

      // 内部IDでも検索
      final queryByInternalId = await _firestore
          .collection('likes')
          .where('userId', isEqualTo: userId)
          .where('reviewInternalId', isEqualTo: reviewId)
          .limit(1)
          .get();

      return queryByInternalId.docs.isNotEmpty;
    } catch (e) {
      print('いいねチェックに失敗しました: $e');
      return false;
    }
  }

  // いいねを削除
  Future<void> removeLike(String reviewId) async {
    try {
      final user = _auth.currentUser;

      // ゲストユーザーまたは未ログインの場合はエラーを投げる
      if (user == null || user.isAnonymous) {
        throw Exception('ゲストユーザーはいいねできません。ログインしてください。');
      }

      final userId = user.uid;

      print('いいね削除: reviewId=$reviewId');

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
          print('いいねが存在しません: $reviewId');
          return;
        }

        // likeIdを取得
        final likeId = userLikeDoc.data()?['likeId'] as String?;
        if (likeId == null) {
          print('いいねIDが見つかりません');
          return;
        }

        // レビューのいいね数を取得
        final reviewLikeRef =
            _firestore.collection('reviewLikes').doc(reviewId);
        final reviewLikeDoc = await transaction.get(reviewLikeRef);

        // 2. すべての読み取りが完了した後で書き込み操作を行う

        // いいね情報を削除
        final likeRef = _firestore.collection('likes').doc(likeId);
        transaction.delete(likeRef);

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

      print('いいねを削除しました: $reviewId');
    } catch (e) {
      print('いいねの削除に失敗しました: $e');
      rethrow;
    }
  }
}
