import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ous/gen/review_data.dart';

class ReviewRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // IDを指定して特定のレビューを取得するメソッド
  Future<Review?> getReviewById(
      String collectionName, String documentId) async {
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
}
