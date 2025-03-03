import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ous/infrastructure/repositories/view_count_repository.dart';

// 人気のレビューを提供するプロバイダー
final popularReviewsProvider =
    FutureProvider.family<List<Map<String, dynamic>>, int>((ref, limit) async {
  final repository = ref.watch(viewCountRepositoryProvider);
  return repository.getPopularReviews(limit);
});

// 特定のレビューの閲覧数を提供するプロバイダー
final viewCountProvider =
    FutureProvider.family<int, String>((ref, reviewId) async {
  final repository = ref.watch(viewCountRepositoryProvider);
  return repository.getViewCount(reviewId);
});

final viewCountRepositoryProvider = Provider<ViewCountRepository>((ref) {
  return ViewCountRepository();
});
