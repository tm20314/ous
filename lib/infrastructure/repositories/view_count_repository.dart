import 'package:cloud_firestore/cloud_firestore.dart';

class ViewCountRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 既存のviewCountsデータを修正する関数を更新
  Future<void> fixViewCountsCollection() async {
    final snapshot = await _firestore.collection('viewCounts').get();

    print('Found ${snapshot.docs.length} view count records to check');

    for (final doc in snapshot.docs) {
      try {
        final data = doc.data();
        final reviewId = doc.id; // これはドキュメントID
        final collectionName = data['collectionName'] as String?;

        if (collectionName == null) continue;

        // ドキュメントIDで直接確認
        final reviewDoc =
            await _firestore.collection(collectionName).doc(reviewId).get();

        if (reviewDoc.exists) {
          print('Found valid review: $collectionName/$reviewId');
        } else {
          print('Invalid review reference: $collectionName/$reviewId');
          // 無効なレコードは削除するか、フラグを立てるなどの処理
        }
      } catch (e) {
        print('Error processing view count: $e');
      }
    }

    print('Finished checking view counts collection');
  }

  // 閲覧数の多い順にレビューIDを取得
  Future<List<Map<String, dynamic>>> getPopularReviews(int limit) async {
    final snapshot = await _firestore
        .collection('viewCounts')
        .orderBy('count', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs
        .map(
          (doc) => {
            'reviewId': doc.id,
            'count': doc.data()['count'],
            'collectionName': doc.data()['collectionName'],
          },
        )
        .toList();
  }

  // 特定のレビューの閲覧数を取得
  Future<int> getViewCount(String reviewId) async {
    final doc = await _firestore.collection('viewCounts').doc(reviewId).get();

    if (!doc.exists) {
      return 0;
    }

    return doc.data()?['count'] ?? 0;
  }

  // 閲覧数を増加させる
  Future<void> incrementViewCount(
    String reviewId,
    String collectionName,
  ) async {
    // Firestoreからレビューのドキュメントを取得してドキュメントIDを使用
    try {
      final reviewsSnapshot = await _firestore
          .collection(collectionName)
          .where('ID', isEqualTo: reviewId)
          .limit(1)
          .get();

      if (reviewsSnapshot.docs.isEmpty) {
        print(
          'Review not found with ID: $reviewId in collection: $collectionName',
        );
        return;
      }

      // ドキュメント自体のIDを使用
      final documentId = reviewsSnapshot.docs.first.id;
      final viewCountRef = _firestore.collection('viewCounts').doc(documentId);

      return _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(viewCountRef);

        if (!snapshot.exists) {
          // 初めての閲覧の場合は新規作成
          transaction.set(viewCountRef, {
            'count': 1,
            'reviewId': documentId,
            'collectionName': collectionName,
            'lastUpdated': FieldValue.serverTimestamp(),
            'lastViewed': {}, // ユーザーごとの最終閲覧時間を記録
          });
        } else {
          // 最終更新時間を確認
          final lastUpdated = snapshot.data()?['lastUpdated'] as Timestamp?;
          final now = Timestamp.now();

          // 前回の更新から1時間（3600秒）経過しているか確認
          final canUpdate =
              lastUpdated == null || now.seconds - lastUpdated.seconds >= 3600;

          if (canUpdate) {
            // 1時間以上経過していれば更新
            transaction.update(viewCountRef, {
              'count': snapshot.data()!['count'] + 1,
              'lastUpdated': FieldValue.serverTimestamp(),
            });
          }
        }
      });
    } catch (e) {
      print('Error incrementing view count: $e');
    }
  }

  // コレクション名を実際のFirestoreコレクション名に変換
  String _getActualCollectionName(String displayName) {
    // 表示名から実際のコレクション名へのマッピング
    final Map<String, String> collectionMapping = {
      'keiei': 'keiei',
      'kiban': 'kiban',
      'kougakubu': 'kougakubu',
      'kyouiku': 'kyouiku',
      'rigaku': 'rigaku',
      // 他のマッピングを追加
    };

    return collectionMapping[displayName] ?? displayName;
  }
}
