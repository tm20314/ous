import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ous/infrastructure/repositories/review_repository.dart';
import 'package:ous/infrastructure/repositories/view_count_repository.dart';

// 人気のレビューを提供するプロバイダー
final popularReviewsProvider =
    FutureProvider.family<List<Map<String, dynamic>>, int>((ref, limit) async {
  final repository = ref.watch(viewCountRepositoryProvider);
  return repository.getPopularReviews(limit);
});

// 閲覧数を取得するプロバイダー
final viewCountProvider =
    StreamProvider.family<int, (String, String)>((ref, params) async* {
  final (internalId, collectionName) = params;
  final firestore = FirebaseFirestore.instance;

  // 実際のドキュメントIDを取得
  final reviewRepository = ReviewRepository();
  final actualDocId =
      await reviewRepository.getDocumentIdByInternalId(internalId);

  final docId = actualDocId ?? internalId;

  print(
      '閲覧数を監視: viewCounts/$docId (内部ID: $internalId, コレクション: $collectionName)');

  // Streamを作成
  final stream = firestore.collection('viewCounts').doc(docId).snapshots();

  // Streamを購読
  await for (final snapshot in stream) {
    if (!snapshot.exists) {
      print('閲覧数データが存在しません: viewCounts/$docId');
      yield 0;
      continue;
    }

    final count = snapshot.data()?['count'];
    final result = count is int ? count : 0;

    print(
        '閲覧数を取得: viewCounts/$docId = $result, パス: ${snapshot.data()?['path']}');
    yield result;
  }
});

final viewCountRepositoryProvider = Provider<ViewCountRepository>((ref) {
  return ViewCountRepository();
});
