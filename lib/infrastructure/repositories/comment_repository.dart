import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ous/domain/models/comment.dart';

class CommentRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // コメントを追加
  Future<void> addComment({
    required String reviewId,
    required String collectionName,
    required String content,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('ユーザーがログインしていません');
    }

    // Firestoreからユーザー情報を取得
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    // Firestoreの表示名を優先して使用
    final displayName = userDoc.exists && userDoc.data()?['displayName'] != null
        ? userDoc.data()!['displayName'] as String
        : user.displayName ?? 'Unknown';

    final comment = Comment(
      id: '', // Firestoreで自動生成
      reviewId: reviewId,
      collectionName: collectionName,
      userId: user.uid,
      userName: displayName, // Firestoreの名前を使用
      content: content,
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now(),
      likes: 0,
      isEdited: false,
      isApproved: true,
    );

    // 独立したcommentsコレクションにコメントを追加
    await _firestore.collection('comments').add(comment.toJson());
  }

  // コメントを削除
  Future<void> deleteComment(String commentId) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('ログインが必要です');
    }

    final commentDoc =
        await _firestore.collection('comments').doc(commentId).get();

    if (!commentDoc.exists) {
      throw Exception('コメントが見つかりません');
    }

    final comment = Comment.fromFirestore(commentDoc.data()!, commentDoc.id);

    // 自分のコメントか管理者のみ削除可能
    if (comment.userId != user.uid && !user.email!.endsWith('admin@ous.jp')) {
      throw Exception('自分のコメントのみ削除できます');
    }

    await _firestore.collection('comments').doc(commentId).delete();
  }

  // レビューに対するコメントを取得
  Stream<List<Comment>> getCommentsForReview(String reviewId) {
    return _firestore
        .collection('comments')
        .where('reviewId', isEqualTo: reviewId)
        .where('isApproved', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Comment.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  }

  // いいねを追加/削除
  Future<void> toggleLike(String commentId) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('ログインが必要です');
    }

    final commentRef = _firestore.collection('comments').doc(commentId);
    final likeRef = commentRef.collection('likes').doc(user.uid);

    // 現在の状態を確認
    final likeDoc = await likeRef.get();
    final commentDoc = await commentRef.get();

    if (!commentDoc.exists) {
      throw Exception('コメントが見つかりません');
    }

    final currentLikes = commentDoc.data()!['likes'] as int;
    final hasLiked = likeDoc.exists;

    print(
      'いいねトグル前: commentId=$commentId, userId=${user.uid}, hasLiked=$hasLiked, currentLikes=$currentLikes',
    );

    // トランザクションを使わずに直接更新
    try {
      if (hasLiked) {
        // いいねを削除
        await likeRef.delete();
        await commentRef.update({'likes': FieldValue.increment(-1)});
        print('いいねを削除: $commentId, 現在のいいね数: ${currentLikes - 1}');
      } else {
        // いいねを追加
        await likeRef.set({'createdAt': Timestamp.now()});
        await commentRef.update({'likes': FieldValue.increment(1)});
        print('いいねを追加: $commentId, 現在のいいね数: ${currentLikes + 1}');
      }
      print('いいねトグル完了: $commentId, 新しい状態: ${!hasLiked}');
      return;
    } catch (error) {
      print('いいねトグルエラー: $error');
      rethrow;
    }
  }

  // コメントを編集
  Future<void> updateComment(String commentId, String newContent) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('ログインが必要です');
    }

    final commentDoc =
        await _firestore.collection('comments').doc(commentId).get();

    if (!commentDoc.exists) {
      throw Exception('コメントが見つかりません');
    }

    final comment = Comment.fromFirestore(
      commentDoc.data()!,
      commentDoc.id,
    );

    if (comment.userId != user.uid) {
      throw Exception('自分のコメントのみ編集できます');
    }

    await _firestore.collection('comments').doc(commentId).update({
      'content': newContent,
      'updatedAt': Timestamp.now(),
      'isEdited': true,
    });
  }
}
