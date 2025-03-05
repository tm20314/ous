import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ous/gen/review_data.dart';

class ReviewRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 内部IDから実際のドキュメントIDを取得するメソッド
  Future<String?> getDocumentIdByInternalId(String internalId) async {
    try {
      // 全コレクションを検索
      final collections = [
        'keiei',
        'kiban',
        'kougakubu',
        'kyouiku',
        'kyousyoku',
        'rigaku',
        'seibutu',
        'seimei',
        'active',
        'zyouhou',
        'zyuui',
      ];

      for (final collectionName in collections) {
        final query = await _firestore
            .collection(collectionName)
            .where('ID', isEqualTo: internalId)
            .limit(1)
            .get();

        if (query.docs.isNotEmpty) {
          final actualDocId = query.docs.first.id;
          print(
            '内部ID $internalId の実際のドキュメントID: $actualDocId (コレクション: $collectionName)',
          );
          return actualDocId;
        }
      }

      print('内部ID $internalId に対応するドキュメントが見つかりませんでした');
      return null;
    } catch (e) {
      print('ドキュメントID検索中にエラーが発生しました: $e');
      return null;
    }
  }

  // レビューを取得するメソッド
  Future<Review?> getReview(String documentId, String collectionName) async {
    try {
      final doc =
          await _firestore.collection(collectionName).doc(documentId).get();

      if (!doc.exists) {
        return null;
      }

      final data = doc.data();
      if (data == null) {
        return null;
      }

      // ここでIDをセットしている可能性があります
      return Review.fromJson(data);
    } catch (e) {
      print('レビュー取得エラー: $e');
      return null;
    }
  }

  // IDを指定して特定のレビューを取得するメソッド
  Future<Review?> getReviewById(
    String collectionName,
    String documentId,
  ) async {
    try {
      final doc =
          await _firestore.collection(collectionName).doc(documentId).get();

      if (!doc.exists || doc.data() == null) {
        print('Review not found: $collectionName/$documentId');
        return null;
      }

      return Review.fromJson(doc.data()!);
    } catch (e) {
      print('Error fetching review: $e');
      return null;
    }
  }

  // 閲覧数を更新
  Future<void> incrementViewCount(
    String documentId,
    String collectionName,
  ) async {
    try {
      final docRef = _firestore.collection(collectionName).doc(documentId);

      // ドキュメントが存在するか確認
      final docSnapshot = await docRef.get();
      if (!docSnapshot.exists) {
        print('ドキュメントが存在しません: $collectionName/$documentId');
        return;
      }

      // 閲覧数フィールドを更新
      await docRef.update({
        'viewCount': FieldValue.increment(1),
      });

      print('閲覧数を更新しました: $collectionName/$documentId');
    } catch (e) {
      print('閲覧数の更新に失敗しました: $e');
      rethrow;
    }
  }
}
