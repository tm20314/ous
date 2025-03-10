import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ous/domain/like_provider.dart';
import 'package:ous/gen/review_data.dart';

class ReviewLikeButton extends ConsumerWidget {
  final String reviewId;
  final String collectionName;
  final Review review;

  const ReviewLikeButton({
    super.key,
    required this.reviewId,
    required this.collectionName,
    required this.review,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasLikedAsync = ref.watch(hasUserLikedProvider(reviewId));
    final likeCountAsync = ref.watch(likeCountProvider(reviewId));

    return Row(
      children: [
        hasLikedAsync.when(
          data: (hasLiked) => IconButton(
            icon: Icon(
              hasLiked ? Icons.favorite : Icons.favorite_border,
              color: hasLiked ? Colors.red : Colors.grey,
            ),
            onPressed: () async {
              if (hasLiked) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('いいねを取り消しました'),
                    duration: Duration(seconds: 1),
                  ),
                );
                await ref.read(likeRepositoryProvider).removeLike(reviewId);

                // キャッシュを更新して UI を再描画
                ref.invalidate(hasUserLikedProvider(reviewId));
                ref.invalidate(likeCountProvider(reviewId));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('いいねしました'),
                    duration: Duration(seconds: 1),
                  ),
                );
                await ref.read(likeRepositoryProvider).addLike(
                      reviewId,
                      collectionName,
                      review,
                    );

                // キャッシュを更新して UI を再描画
                ref.invalidate(hasUserLikedProvider(reviewId));
                ref.invalidate(likeCountProvider(reviewId));
              }
            },
          ),
          loading: () => const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          error: (_, __) => IconButton(
            icon: const Icon(Icons.favorite_border, color: Colors.grey),
            onPressed: () async {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('いいねしました'),
                  duration: Duration(seconds: 1),
                ),
              );
              ref.read(addLikeProvider((reviewId, collectionName, review)));

              // キャッシュを更新して UI を再描画
              ref.invalidate(hasUserLikedProvider(reviewId));
              ref.invalidate(likeCountProvider(reviewId));
            },
          ),
        ),
        const SizedBox(width: 4),
        likeCountAsync.when(
          data: (count) => Text(
            count.toString(),
            style: const TextStyle(color: Colors.grey),
          ),
          loading: () =>
              const Text('...', style: TextStyle(color: Colors.grey)),
          error: (_, __) =>
              const Text('0', style: TextStyle(color: Colors.grey)),
        ),
      ],
    );
  }
}
