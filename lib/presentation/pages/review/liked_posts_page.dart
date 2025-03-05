import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ous/domain/like_provider.dart';
import 'package:ous/gen/assets.gen.dart';
import 'package:ous/presentation/pages/review/detail_view.dart';

class LikedPostsScreen extends ConsumerWidget {
  const LikedPostsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('いいねした投稿')),
        body: const Center(
          child: Text('ログインしてください'),
        ),
      );
    }

    final likedPostsAsync = ref.watch(userLikesProvider(userId));

    return Scaffold(
      appBar: AppBar(title: const Text('いいねした投稿')),
      body: likedPostsAsync.when(
        data: (likedPosts) {
          if (likedPosts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Assets.icon.found.image(width: 150),
                  const SizedBox(height: 16),
                  Text(
                    'いいねした投稿はありません',
                    style: TextStyle(color: Theme.of(context).hintColor),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: likedPosts.length,
            itemBuilder: (context, index) {
              final post = likedPosts[index];
              final review = post['review'];
              final reviewId = post['reviewId'];
              final collectionName = post['collectionName'];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(review.zyugyoumei ?? '無題'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(review.kousimei ?? ''),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.star, size: 16, color: Colors.amber),
                          Text(' ${review.sougouhyouka?.toInt() ?? 0}/5'),
                        ],
                      ),
                    ],
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
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
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('エラーが発生しました: $error'),
        ),
      ),
    );
  }
}
