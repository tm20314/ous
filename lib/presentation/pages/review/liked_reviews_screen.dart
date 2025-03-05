import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ous/domain/like_provider.dart';
import 'package:ous/presentation/widgets/review/review_card.dart';

class LikedReviewsScreen extends ConsumerWidget {
  const LikedReviewsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('いいねしたレビュー')),
        body: const Center(
          child: Text('ログインしてください'),
        ),
      );
    }

    final likesAsync = ref.watch(userLikesProvider(userId));

    return Scaffold(
      appBar: AppBar(title: const Text('いいねしたレビュー')),
      body: likesAsync.when(
        data: (likes) {
          if (likes.isEmpty) {
            return const Center(
              child: Text('いいねしたレビューはありません'),
            );
          }

          return ListView.builder(
            itemCount: likes.length,
            itemBuilder: (context, index) {
              final like = likes[index];
              final review = like['review'];
              final reviewId = like['reviewId'];
              final collectionName = like['collectionName'];

              return ReviewCard(
                review: review,
                documentId: reviewId,
                collectionName: collectionName,
              );
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Text('エラーが発生しました: $error'),
        ),
      ),
    );
  }
}
