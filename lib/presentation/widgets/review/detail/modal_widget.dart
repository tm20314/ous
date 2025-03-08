import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ous/domain/review_share_service.dart';
import 'package:ous/gen/review_data.dart';
import 'package:ous/presentation/widgets/review/detail/share_gauge_section.dart';

class ModalWidget extends StatefulWidget {
  final Review review;
  const ModalWidget({super.key, required this.review});

  @override
  ModalWidgetState createState() => ModalWidgetState();
}

class ModalWidgetState extends State<ModalWidget> {
  final GlobalKey globalKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 500,
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              'この講義評価をシェア',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: RepaintBoundary(
                key: globalKey,
                child: Container(
                  height: 200,
                  width: 500,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(20.0),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        offset: Offset(0.0, 2.0),
                        blurRadius: 6.0,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ShareGaugeSection(
                            title: '講義の面白さ',
                            value: widget.review.omosirosa?.toDouble() ?? 0,
                          ),
                          ShareGaugeSection(
                            title: '単位の取りやすさ',
                            value: widget.review.toriyasusa?.toDouble() ?? 0,
                          ),
                          ShareGaugeSection(
                            title: '総合評価',
                            value: widget.review.sougouhyouka?.toDouble() ?? 0,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    IconButton.filledTonal(
                      icon: const FaIcon(FontAwesomeIcons.twitter),
                      padding: const EdgeInsets.all(20),
                      onPressed: () =>
                          ShareService.shareToTwitter(widget.review, globalKey),
                    ),
                    const Text('Twitter(X)'),
                  ],
                ),
                Column(
                  children: [
                    IconButton.filledTonal(
                      icon: const FaIcon(FontAwesomeIcons.instagram),
                      padding: const EdgeInsets.all(20),
                      onPressed: () => ShareService.shareToInstagram(
                        widget.review,
                        globalKey,
                      ),
                    ),
                    const Text('Instagram'),
                  ],
                ),
                Column(
                  children: [
                    IconButton.filledTonal(
                      icon: const Icon(Icons.link),
                      padding: const EdgeInsets.all(20),
                      onPressed: () =>
                          ShareService.shareReview(widget.review, globalKey),
                    ),
                    const Text('その他'),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
