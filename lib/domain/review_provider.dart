import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ous/gen/review_data.dart';
import 'package:ous/infrastructure/repositories/review_repository.dart';

// 閲覧数を更新するプロバイダー
final incrementViewCountProvider =
    FutureProvider.family<void, (String, String)>((ref, params) async {
  final (documentId, collectionName) = params;
  final repository = ref.watch(reviewRepositoryProvider);

  try {
    await repository.incrementViewCount(documentId, collectionName);
    // キャッシュを無効化して再取得を強制
    ref.invalidate(reviewViewCountProvider((documentId, collectionName)));
  } catch (e) {
    print('閲覧数の更新に失敗しました: $e');
    rethrow;
  }
});

// 特定のレビューを取得するプロバイダー
final reviewProvider =
    FutureProvider.family<Review?, String>((ref, documentId) async {
  final repository = ref.watch(reviewRepositoryProvider);

  // 複数のコレクションから検索
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

  for (final collection in collections) {
    final review = await repository.getReviewById(collection, documentId);
    if (review != null) {
      print('レビューを見つけました: $collection/$documentId');
      return review;
    }
  }

  print('どのコレクションにもレビューが見つかりませんでした: $documentId');
  return null;
});

// ReviewRepositoryのプロバイダーを追加
final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  return ReviewRepository();
});

// レビュー一覧を取得するプロバイダー
final reviewsProvider = StreamProvider.family<
    List<QueryDocumentSnapshot<Map<String, dynamic>>>,
    (String, String, String, String, String, String, String, String)>(
  (ref, params) {
    final (
      collectionName,
      bumon,
      gakki,
      tanni,
      zyugyoukeisiki,
      syusseki,
      searchQuery,
      dateOrder,
    ) = params;

    Query<Map<String, dynamic>> query =
        FirebaseFirestore.instance.collection(collectionName);

    if (bumon.isNotEmpty) {
      query = query.where('bumon', isEqualTo: bumon);
    }

    if (gakki.isNotEmpty) {
      query = query.where('gakki', isEqualTo: gakki);
    }

    if (tanni.isNotEmpty) {
      query = query.where('tannisuu', isEqualTo: tanni);
    }

    if (zyugyoukeisiki.isNotEmpty) {
      query = query.where('zyugyoukeisiki', isEqualTo: zyugyoukeisiki);
    }

    if (syusseki.isNotEmpty) {
      query = query.where('syusseki', isEqualTo: syusseki);
    }

    if (searchQuery.isNotEmpty) {
      query = query
          .where('zyugyoumei', isGreaterThanOrEqualTo: searchQuery)
          .where('zyugyoumei', isLessThan: '${searchQuery}z');
    }

    if (dateOrder == 'newest') {
      query = query.orderBy('date', descending: true);
    } else if (dateOrder == 'oldest') {
      query = query.orderBy('date', descending: false);
    }

    return query.snapshots().map((snapshot) => snapshot.docs);
  },
);

// 閲覧数を取得するプロバイダー（名前を変更）
final reviewViewCountProvider =
    StreamProvider.family<int, (String, String)>((ref, params) {
  final (documentId, collectionName) = params;
  final firestore = FirebaseFirestore.instance;

  print('閲覧数を監視: $collectionName/$documentId');

  return firestore
      .collection(collectionName)
      .doc(documentId)
      .snapshots()
      .map((snapshot) {
    if (!snapshot.exists) {
      print('ドキュメントが存在しません: $collectionName/$documentId');
      return 0;
    }

    final viewCount = snapshot.data()?['viewCount'];
    final count = viewCount is int ? viewCount : 0;

    print('閲覧数を取得: $collectionName/$documentId = $count');
    return count;
  });
});
