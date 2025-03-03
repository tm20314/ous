// Dart imports:
// Flutter imports:
import 'package:flutter/material.dart';
// Project imports:
import 'package:ous/gen/review_data.dart';
import 'package:ous/infrastructure/repositories/view_count_repository.dart';
import 'package:ous/presentation/widgets/review/detail/comments_section.dart';
import 'package:ous/presentation/widgets/review/detail/date_section.dart';
import 'package:ous/presentation/widgets/review/detail/gauge_section.dart';
import 'package:ous/presentation/widgets/review/detail/modal_widget.dart';
import 'package:ous/presentation/widgets/review/detail/outdated_post_info.dart';
import 'package:ous/presentation/widgets/review/detail/report_button.dart';
import 'package:ous/presentation/widgets/review/detail/text_section.dart';
import 'package:ous/presentation/widgets/review/detail/view_count_display.dart';

class DetailScreen extends StatefulWidget {
  final Review review;
  final String collectionName;
  final String documentId;

  const DetailScreen({
    super.key,
    required this.review,
    required this.collectionName,
    required this.documentId,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final ViewCountRepository _viewCountRepository = ViewCountRepository();

  @override
  Widget build(BuildContext context) {
    final review = widget.review;
    return Scaffold(
      appBar: AppBar(
        title: Text(review.zyugyoumei ?? '不明'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  return ModalWidget(review: review);
                },
              );
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // 画面幅に基づいてレイアウトを調整
          final isWideScreen = constraints.maxWidth > 600;

          return Container(
            margin: EdgeInsets.all(isWideScreen ? 24 : 15),
            child: SingleChildScrollView(
              child: isWideScreen
                  ? _buildWideLayout(review)
                  : _buildNormalLayout(review),
            ),
          );
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // 画面表示時に閲覧数をインクリメント
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _incrementViewCount();
    });
  }

  // 通常画面用のレイアウト
  Widget _buildNormalLayout(Review review) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OutdatedPostInfo(review: review),

        // 基本情報セクション
        _buildSection(
          title: '講義基本情報',
          children: [
            TextSection(title: '講義名', content: review.zyugyoumei),
            TextSection(title: '講師名', content: review.kousimei),
            TextSection(title: '年度', content: review.nenndo),
            TextSection(title: '単位数', content: review.tannisuu?.toString()),
          ],
        ),

        // 授業形式セクション
        _buildSection(
          title: '授業形式',
          children: [
            TextSection(title: '授業形式', content: review.zyugyoukeisiki),
            TextSection(title: '出席確認の有無', content: review.syusseki),
            TextSection(title: '教科書の有無', content: review.kyoukasyo),
            TextSection(title: 'テスト形式', content: review.tesutokeisiki),
          ],
        ),

        // 評価セクション
        _buildSection(
          title: '評価',
          children: [
            GaugeSection(
              title: '講義の面白さ',
              value: review.omosirosa?.toDouble() ?? 0,
            ),
            GaugeSection(
              title: '単位の取りやすさ',
              value: review.toriyasusa?.toDouble() ?? 0,
            ),
            GaugeSection(
              title: '総合評価',
              value: review.sougouhyouka?.toDouble() ?? 0,
            ),
          ],
        ),

        // コメントセクション
        _buildSection(
          title: 'レビュー',
          children: [
            TextSection(title: '講義に関するコメント', content: review.komento),
            TextSection(title: 'テスト傾向', content: review.tesutokeikou),
          ],
        ),

        // 投稿情報セクション
        _buildPostInfoSection(review),

        const SizedBox(height: 20.0),
        const Center(child: ReportButton()),
        const SizedBox(height: 20.0),

        // コメントセクションを追加
        CommentsSection(
          reviewId: widget.documentId,
          collectionName: widget.collectionName,
        ),
      ],
    );
  }

  // 投稿情報セクションを構築するヘルパーメソッド
  Widget _buildPostInfoSection(Review review) {
    return _buildSection(
      title: '投稿情報',
      children: [
        TextSection(title: 'ニックネーム', content: review.name),
        DateSection(title: '投稿日・更新日', date: review.date),
        if (review.senden?.isNotEmpty ?? false)
          TextSection(title: '宣伝', content: review.senden),
        const SizedBox(height: 8),
        ViewCountDisplay(documentId: widget.documentId),
      ],
    );
  }

  // セクションを構築するヘルパーメソッド
  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Center(
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ...children,
            ],
          ),
        ),
      ),
    );
  }

  // 幅広画面用のレイアウト
  Widget _buildWideLayout(Review review) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 左側のカラム（基本情報と評価）
        Expanded(
          flex: 1,
          child: Column(
            children: [
              _buildSection(
                title: '講義基本情報',
                children: [
                  TextSection(title: '講義名', content: review.zyugyoumei),
                  TextSection(title: '講師名', content: review.kousimei),
                  TextSection(title: '年度', content: review.nenndo),
                  TextSection(
                    title: '単位数',
                    content: review.tannisuu?.toString(),
                  ),
                ],
              ),
              _buildSection(
                title: '評価',
                children: [
                  GaugeSection(
                    title: '講義の面白さ',
                    value: review.omosirosa?.toDouble() ?? 0,
                  ),
                  GaugeSection(
                    title: '単位の取りやすさ',
                    value: review.toriyasusa?.toDouble() ?? 0,
                  ),
                  GaugeSection(
                    title: '総合評価',
                    value: review.sougouhyouka?.toDouble() ?? 0,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 24),
        // 右側のカラム（授業形式とレビュー）

        Expanded(
          flex: 1,
          child: Column(
            children: [
              _buildSection(
                title: '授業形式',
                children: [
                  TextSection(title: '授業形式', content: review.zyugyoukeisiki),
                  TextSection(title: '出席確認の有無', content: review.syusseki),
                  TextSection(title: '教科書の有無', content: review.kyoukasyo),
                  TextSection(title: 'テスト形式', content: review.tesutokeisiki),
                ],
              ),
              _buildSection(
                title: 'レビュー',
                children: [
                  TextSection(title: '講義に関するコメント', content: review.komento),
                  TextSection(title: 'テスト傾向', content: review.tesutokeikou),
                ],
              ),
              _buildPostInfoSection(review),
              const Center(child: ReportButton()),
            ],
          ),
        ),
      ],
    );
  }

  void _incrementViewCount() async {
    await _viewCountRepository.incrementViewCount(
      widget.documentId,
      widget.collectionName,
    );
  }
}
