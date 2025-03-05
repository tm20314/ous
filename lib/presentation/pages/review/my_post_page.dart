import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ous/domain/review_user_posts_provider.dart';
import 'package:ous/gen/assets.gen.dart';
import 'package:ous/presentation/pages/review/edit_view.dart';

class UserPostsScreen extends ConsumerWidget {
  const UserPostsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewAsyncValue = ref.watch(fetchUserReviews);

    return Scaffold(
      appBar: AppBar(
        title: const Text('自分の投稿'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.refresh(fetchUserReviews);
        },
        child: reviewAsyncValue.when(
          data: (userPosts) {
            if (userPosts.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Assets.icon.found.image(width: 150),
                    const SizedBox(height: 16),
                    Text(
                      '投稿した講義がありません',
                      style: TextStyle(color: Theme.of(context).hintColor),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              itemCount: userPosts.length,
              itemBuilder: (context, index) {
                final post = userPosts[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(post.zyugyoumei ?? '無題'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(post.kousimei ?? ''),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.star, size: 16, color: Colors.amber),
                            Text(' ${post.sougouhyouka?.toInt() ?? 0}/5'),
                          ],
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditScreen(
                            review: post,
                          ),
                        ),
                      );
                      // 投稿後にデータを再取得
                      ref.refresh(fetchUserReviews);
                    },
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) {
            debugPrint('エラーが発生しました: $error');
            debugPrint('スタックトレース: $stackTrace');
            return Center(child: Text('エラーが発生しました: $error'));
          },
        ),
      ),
    );
  }
}
