import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ous/domain/view_count_provider.dart';
import 'package:ous/infrastructure/repositories/review_repository.dart';
import 'package:ous/presentation/pages/review/detail_view.dart';

class PopularReviewsPage extends ConsumerWidget {
  const PopularReviewsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final popularReviewsAsync =
        ref.watch(popularReviewsProvider(10)); // 上位10件を取得

    return Scaffold(
      body: popularReviewsAsync.when(
        data: (popularReviews) {
          print('Popular reviews data: $popularReviews');
          if (popularReviews.isEmpty) {
            print('No popular reviews found');
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('まだ人気の講義評価はありません'),
                  SizedBox(height: 20),
                  Text('講義評価を閲覧すると、ここに表示されます'),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await ref.refresh(popularReviewsProvider(10).future);
            },
            child: ListView.builder(
              itemCount: popularReviews.length,
              itemBuilder: (context, index) {
                final reviewData = popularReviews[index];
                final reviewId = reviewData['reviewId'];
                final collectionName = reviewData['collectionName'];
                final viewCount = reviewData['count'];
                final rank = index + 1; // ランキング順位

                // レビューデータを取得するFutureBuilder
                return FutureBuilder(
                  future: ReviewRepository()
                      .getReviewById(collectionName, reviewId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text('$rank'),
                        ),
                        title: const Text('読み込み中...'),
                        trailing: const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    }

                    if (snapshot.hasError ||
                        !snapshot.hasData ||
                        snapshot.data == null) {
                      print('Error or no data: ${snapshot.error}');
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text('$rank'),
                        ),
                        title: const Text('この講義評価は利用できません'),
                        trailing: Text('閲覧数: $viewCount'),
                      );
                    }

                    final review = snapshot.data!;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 8,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getRankColor(rank),
                          child: Text(
                            '$rank',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          review.zyugyoumei ?? '不明',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(review.kousimei ?? ''),
                        trailing: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '閲覧数: $viewCount',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailScreen(
                                review: review,
                                collectionName: collectionName,
                                documentId: reviewId,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('エラーが発生しました: $error'),
        ),
      ),
    );
  }

  // ランキングに応じた色を返す
  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber; // 金色
      case 2:
        return Colors.blueGrey; // 銀色
      case 3:
        return Colors.brown; // 銅色
      default:
        return Colors.blue; // その他
    }
  }
}
