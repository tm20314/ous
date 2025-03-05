import 'package:cloud_firestore/cloud_firestore.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ユーザー名を更新
  Future<void> updateUserName(String userId, String newName) async {
    // ユーザードキュメントを更新
    await _firestore.collection('users').doc(userId).update({
      'displayName': newName,
    });

    // このユーザーが投稿したすべてのコメントのuserNameも更新
    final batch = _firestore.batch();
    final commentsQuery = await _firestore
        .collection('comments')
        .where('userId', isEqualTo: userId)
        .get();

    // バッチ処理で一括更新
    for (final doc in commentsQuery.docs) {
      batch.update(doc.reference, {'userName': newName});
    }

    await batch.commit();

    print('ユーザー名とコメントの名前を更新しました: $userId, $newName');
  }
}
