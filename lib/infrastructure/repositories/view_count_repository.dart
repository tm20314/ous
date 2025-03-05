import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ous/infrastructure/repositories/review_repository.dart';

class ViewCountRepository {
  // 閲覧履歴を記録するコレクション名
  static const String _viewHistoryCollection = 'viewHistory';
  // 再閲覧とみなさない時間（分）
  static const int _viewCooldownMinutes = 30;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 古い閲覧履歴を削除（例：90日以上前の履歴）
  Future<void> cleanupOldViewHistory() async {
    try {
      final cutoffDate = DateTime.now().subtract(const Duration(days: 90));
      final cutoffTimestamp = Timestamp.fromDate(cutoffDate);

      final batch = _firestore.batch();
      final snapshot = await _firestore
          .collection(_viewHistoryCollection)
          .where('lastViewedAt', isLessThan: cutoffTimestamp)
          .limit(500) // Firestoreのバッチ制限
          .get();

      if (snapshot.docs.isEmpty) {
        print('削除対象の古い閲覧履歴はありません');
        return;
      }

      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      print('${snapshot.docs.length}件の古い閲覧履歴を削除しました');

      // 500件以上ある場合は再帰的に呼び出す
      if (snapshot.docs.length == 500) {
        await cleanupOldViewHistory();
      }
    } catch (e) {
      print('古い閲覧履歴の削除に失敗しました: $e');
    }
  }

  // 閲覧履歴をクリア（テスト用）
  Future<void> clearViewHistory(String userId) async {
    try {
      final batch = _firestore.batch();
      final snapshot = await _firestore
          .collection(_viewHistoryCollection)
          .where('userId', isEqualTo: userId)
          .get();

      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      print('ユーザー $userId の閲覧履歴をクリアしました');
    } catch (e) {
      print('閲覧履歴のクリアに失敗しました: $e');
    }
  }

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

  // 人気のレビューを取得
  Future<List<Map<String, dynamic>>> getPopularReviews(int limit) async {
    try {
      final snapshot = await _firestore
          .collection('viewCounts')
          .orderBy('count', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        final collectionName = data['collectionName'] ?? '';
        return {
          'reviewId': doc.id,
          'count': data['count'] ?? 0,
          'collectionName': collectionName,
          'path': data['path'] ?? '$collectionName/${doc.id}',
          'internalId': data['internalId'],
        };
      }).toList();
    } catch (e) {
      print('人気レビューの取得に失敗しました: $e');
      return [];
    }
  }

  // 閲覧数を取得
  Future<int> getViewCount(String reviewId) async {
    try {
      // viewCountsコレクションから閲覧数を取得
      final doc = await _firestore.collection('viewCounts').doc(reviewId).get();

      if (!doc.exists) {
        print('閲覧数データが存在しません: $reviewId');
        return 0;
      }

      final count = doc.data()?['count'] as int? ?? 0;
      print('閲覧数を取得: $reviewId = $count');
      return count;
    } catch (e) {
      print('閲覧数の取得に失敗しました: $e');
      return 0;
    }
  }

  // 閲覧数をインクリメント
  Future<void> incrementViewCount(
    String documentId,
    String collectionName,
  ) async {
    try {
      // 現在のユーザーIDを取得（匿名認証も含む）
      final userId = _auth.currentUser?.uid ?? 'anonymous';

      // 実際のドキュメントIDを取得
      final reviewRepository = ReviewRepository();
      final actualDocId =
          await reviewRepository.getDocumentIdByInternalId(documentId);

      if (actualDocId == null) {
        print('内部ID $documentId に対応する実際のドキュメントIDが見つかりませんでした');
        // 内部IDをそのまま使用
        await _incrementViewCountWithId(documentId, collectionName, userId);
        return;
      }

      print('内部ID $documentId の実際のドキュメントID: $actualDocId を使用します');
      // 実際のドキュメントIDを使用
      await _incrementViewCountWithId(actualDocId, collectionName, userId);
    } catch (e) {
      print('閲覧数の更新に失敗しました: $e');
      rethrow;
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

  // 実際の閲覧数更新処理
  Future<void> _incrementViewCountWithId(
    String docId,
    String collectionName,
    String userId,
  ) async {
    try {
      // 閲覧履歴のドキュメントID
      final historyId = '${userId}_$docId';
      final historyRef =
          _firestore.collection(_viewHistoryCollection).doc(historyId);

      // 閲覧履歴を確認
      final historyDoc = await historyRef.get();
      final now = DateTime.now();

      // 前回の閲覧時間を取得
      DateTime? lastViewedAt;
      if (historyDoc.exists) {
        final timestamp = historyDoc.data()?['lastViewedAt'] as Timestamp?;
        if (timestamp != null) {
          lastViewedAt = timestamp.toDate();
        }
      }

      // 前回の閲覧から30分以内なら閲覧数を増やさない
      final shouldIncrement = lastViewedAt == null ||
          now.difference(lastViewedAt).inMinutes > _viewCooldownMinutes;

      // 閲覧履歴を更新
      await historyRef.set(
        {
          'userId': userId,
          'reviewId': docId,
          'collectionName': collectionName,
          'lastViewedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      if (!shouldIncrement) {
        print(
            '前回の閲覧から$_viewCooldownMinutes分以内のため、閲覧数を増やしません: $docId (ユーザー: $userId)');
        return;
      }

      print('閲覧数を増やします: $docId (ユーザー: $userId)');

      // viewCountsコレクションのドキュメントを参照
      final docRef = _firestore.collection('viewCounts').doc(docId);

      print('閲覧数更新開始: viewCounts/$docId (元コレクション: $collectionName)');

      try {
        // 実際のドキュメントIDを確認
        final reviewDoc =
            await _firestore.collection(collectionName).doc(docId).get();

        if (!reviewDoc.exists) {
          print('レビューが存在しません: $collectionName/$docId - 閲覧数を更新せずに終了します');
          // レビューが存在しなくても閲覧数を記録する
          await docRef.set({
            'count': 1,
            'reviewId': docId,
            'collectionName': collectionName,
            'path': '$collectionName/$docId',
            'lastUpdated': FieldValue.serverTimestamp(),
            'error': 'レビューが存在しません',
          });
          return;
        }

        // 内部IDを取得（デバッグ用）
        final internalId = reviewDoc.data()?['ID'];
        print('レビュー内部ID: $internalId, ドキュメントID: $docId');

        // ドキュメントが存在するか確認
        final docSnapshot = await docRef.get();

        if (docSnapshot.exists) {
          // 既存のドキュメントを更新
          await docRef.update({
            'count': FieldValue.increment(1),
            'lastUpdated': FieldValue.serverTimestamp(),
            'collectionName': collectionName,
            'internalId': internalId,
            'path': '$collectionName/$docId',
          });

          final newCount = (docSnapshot.data()?['count'] as int? ?? 0) + 1;
          print('閲覧数を更新しました: viewCounts/$docId, 新しい閲覧数: $newCount');
        } else {
          // 新しいドキュメントを作成
          await docRef.set({
            'count': 1,
            'reviewId': docId,
            'internalId': internalId,
            'collectionName': collectionName,
            'path': '$collectionName/$docId',
            'lastUpdated': FieldValue.serverTimestamp(),
          });

          print('閲覧数を新規作成しました: viewCounts/$docId, 閲覧数: 1');
        }
      } catch (e) {
        print('レビュー確認中にエラーが発生しました: $e - 閲覧数のみ更新します');

        // エラーが発生しても閲覧数は記録する
        await docRef.set(
          {
            'count': 1,
            'reviewId': docId,
            'collectionName': collectionName,
            'path': '$collectionName/$docId',
            'lastUpdated': FieldValue.serverTimestamp(),
            'error': e.toString(),
          },
          SetOptions(merge: true),
        );
      }

      // 確認のためにデータを再取得
      final updatedDoc = await docRef.get();
      print('更新後のデータ: ${updatedDoc.data()}');
    } catch (e) {
      print('閲覧数の更新に失敗しました: $e');
      rethrow;
    }
  }
}
