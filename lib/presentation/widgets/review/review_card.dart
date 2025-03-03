import 'package:flutter/material.dart';
import 'package:ous/gen/review_data.dart';
import 'package:rotated_corner_decoration/rotated_corner_decoration.dart';

class ReviewCard extends StatelessWidget {
  final Review review;
  final String collectionName;

  const ReviewCard({
    super.key,
    required this.review,
    required this.collectionName,
  });

  @override
  Widget build(BuildContext context) {
    final isBackgroundBright = Theme.of(context).brightness == Brightness.light;
    final textColor = isBackgroundBright ? Colors.white : Colors.black;

    // 現在の日付と投稿日の差を計算
    final now = DateTime.now();
    final postDate = DateTime.parse(review.date.toString());
    final isNew = now.difference(postDate).inDays <= 365;

    return SizedBox(
      width: 200,
      height: 300,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(15),
              child: Align(
                alignment: const Alignment(-0.8, -0.5),
                child: Text(
                  review.zyugyoumei ?? '不明',
                  style: const TextStyle(fontSize: 20),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            Align(
              alignment: const Alignment(-0.8, 0.4),
              child: Text(
                review.gakki ?? '不明',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 15,
                ),
              ),
            ),
            Align(
              alignment: const Alignment(-0.8, 0.8),
              child: Text(
                review.kousimei ?? '不明',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 15),
              ),
            ),
            Positioned(
              top: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 4,
                  horizontal: 6,
                ),
                decoration: BoxDecoration(
                  color: review.bumon == 'エグ単'
                      ? Colors.red
                      : Theme.of(context).colorScheme.primary,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
                child: Text(
                  review.bumon ?? '不明',
                  style: TextStyle(
                    fontSize: 15,
                    color: textColor,
                  ),
                ),
              ),
            ),
            if (isNew)
              Container(
                foregroundDecoration: RotatedCornerDecoration.withColor(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                  spanBaselineShift: 4,
                  badgeSize: const Size(50, 50),
                  badgeCornerRadius: const Radius.circular(8),
                  badgePosition: BadgePosition.topEnd,
                  textSpan: const TextSpan(
                    text: 'NEW',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      letterSpacing: 1,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
