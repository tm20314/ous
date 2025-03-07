import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // プロフィール画像のURLを更新する
  Future<void> updateProfileImageUrl(String imageUrl) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('ユーザーがログインしていません');
    }

    try {
      // Firestoreのユーザードキュメントを更新
      await _firestore.collection('users').doc(user.uid).update({
        'photoURL': imageUrl,
      });

      // Firebase AuthのphotoURLも更新
      await user.updatePhotoURL(imageUrl);

      print('プロフィール画像を更新しました: $imageUrl');
    } catch (e) {
      print('プロフィール画像の更新に失敗しました: $e');
      throw Exception('プロフィール画像の更新に失敗しました: $e');
    }
  }

  // ユーザー名を更新する
  Future<void> updateUserName(String newName) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('ユーザーがログインしていません');
    }

    try {
      // Firestoreのユーザードキュメントを更新
      await _firestore.collection('users').doc(user.uid).update({
        'displayName': newName,
        'hasSetNickname': true,
      });

      // Firebase AuthのdisplayNameも更新
      await user.updateDisplayName(newName);

      // コメントコレクション内のユーザー名も一括更新
      await _updateCommentsUserName(user.uid, newName);

      print('ユーザー名を更新しました: $newName');
    } catch (e) {
      print('ユーザー名の更新に失敗しました: $e');
      throw Exception('ユーザー名の更新に失敗しました: $e');
    }
  }

  // コメントコレクション内のユーザー名を一括更新
  Future<void> _updateCommentsUserName(String userId, String newName) async {
    try {
      // ユーザーIDに一致するコメントを検索
      final commentsQuery = await _firestore
          .collection('comments')
          .where('userId', isEqualTo: userId)
          .get();

      // バッチ処理で一括更新
      final batch = _firestore.batch();

      for (final doc in commentsQuery.docs) {
        batch.update(doc.reference, {'userName': newName});
      }

      // バッチ処理を実行
      await batch.commit();

      print('${commentsQuery.docs.length}件のコメントのユーザー名を更新しました');
    } catch (e) {
      print('コメントのユーザー名更新中にエラーが発生しました: $e');
      // メインの処理は続行させるためにここでは例外をスローしない
    }
  }
}
