// Dart imports:
// Flutter imports:
import 'dart:async';

import 'package:badges/badges.dart' as badges;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ous/domain/comment_provider.dart' as comment_provider;
import 'package:ous/domain/like_provider.dart';
import 'package:ous/domain/review_provider.dart' as review_provider;
import 'package:ous/domain/view_count_provider.dart' as view_count_provider;
// Project imports:
import 'package:ous/gen/review_data.dart';
import 'package:ous/infrastructure/repositories/view_count_repository.dart';
import 'package:ous/presentation/widgets/review/detail/comments_section.dart';
import 'package:ous/presentation/widgets/review/detail/date_section.dart';
import 'package:ous/presentation/widgets/review/detail/gauge_section.dart';
import 'package:ous/presentation/widgets/review/detail/modal_widget.dart';
import 'package:ous/presentation/widgets/review/detail/outdated_post_info.dart';
import 'package:ous/presentation/widgets/review/detail/text_section.dart';
import 'package:ous/presentation/widgets/review/detail/view_count_display.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailScreen extends ConsumerStatefulWidget {
  final Review review;
  final String collectionName;
  final String documentId; // これはFirestoreのドキュメントID

  const DetailScreen({
    super.key,
    required this.review,
    required this.collectionName,
    required this.documentId,
  });

  @override
  ConsumerState<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends ConsumerState<DetailScreen> {
  final ViewCountRepository _viewCountRepository = ViewCountRepository();
  Timer? _refreshTimer;

  @override
  Widget build(BuildContext context) {
    // いいね数を取得
    final likeCountAsync = ref.watch(likeCountProvider(widget.documentId));
    // ユーザーがいいねしているかを取得
    final hasLikedAsync = ref.watch(hasUserLikedProvider(widget.documentId));

    // ユーザー情報を取得
    final user = FirebaseAuth.instance.currentUser;

    // 学内ユーザーかどうかを確認（ous.jpドメインのメールアドレスを持つユーザー）
    final isOusUser = user != null &&
        !user.isAnonymous &&
        user.email != null &&
        user.email!.endsWith('@ous.jp');

    return Scaffold(
      appBar: AppBar(
        title: const Text('講義詳細'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  return ModalWidget(review: widget.review);
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.report_problem_outlined),
            tooltip: 'この投稿を報告',
            onPressed: () async {
              launchUrl(
                Uri.parse(
                  'https://docs.google.com/forms/d/e/1FAIpQLSepC82BWAoARJVh4WeGCFOuIpWLyaPfqqXn524SqxyBSA9LwQ/viewform',
                ),
              );
            },
          ),
        ],
      ),
      // FloatingActionButtonを学内ユーザーのみに表示
      floatingActionButton: isOusUser
          ? badges.Badge(
              position: badges.BadgePosition.topEnd(top: -12, end: -5),
              badgeContent: likeCountAsync.when(
                data: (count) => Text(
                  count.toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
                loading: () => const Text(
                  '...',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
                error: (_, __) => const Text(
                  '0',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
              badgeStyle: const badges.BadgeStyle(
                badgeColor: Colors.red,
                padding: EdgeInsets.all(5),
              ),
              child: FloatingActionButton(
                onPressed: () async {
                  final hasLiked = await ref.read(
                    hasUserLikedProvider(widget.documentId).future,
                  );

                  if (hasLiked) {
                    // いいねを削除
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('いいねを取り消しました'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                    await ref
                        .read(likeRepositoryProvider)
                        .removeLike(widget.documentId);

                    // キャッシュを更新して UI を再描画
                    ref.invalidate(hasUserLikedProvider(widget.documentId));
                    ref.invalidate(likeCountProvider(widget.documentId));
                  } else {
                    // いいねを追加
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('いいねしました'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                    await ref.read(likeRepositoryProvider).addLike(
                          widget.documentId,
                          widget.collectionName,
                          widget.review,
                        );

                    // キャッシュを更新して UI を再描画
                    ref.invalidate(hasUserLikedProvider(widget.documentId));
                    ref.invalidate(likeCountProvider(widget.documentId));
                  }
                },
                child: hasLikedAsync.when(
                  data: (hasLiked) => Icon(
                    hasLiked ? Icons.favorite : Icons.favorite_border,
                    color: hasLiked ? Colors.white : null,
                  ),
                  loading: () => const CircularProgressIndicator(
                    color: Colors.white,
                  ),
                  error: (_, __) => const Icon(Icons.favorite_border),
                ),
              ),
            )
          : null, // 学内ユーザー以外は表示しない
      body: RefreshIndicator(
        onRefresh: () async {
          // 各プロバイダーを無効化して再取得を強制
          ref.invalidate(review_provider.reviewProvider(widget.documentId));
          ref.invalidate(comment_provider.commentsProvider(widget.documentId));
          ref.invalidate(
            view_count_provider
                .viewCountProvider((widget.documentId, widget.collectionName)),
          );

          // いいね関連のプロバイダーも無効化
          ref.invalidate(hasUserLikedProvider(widget.documentId));
          ref.invalidate(likeCountProvider(widget.documentId));

          // 少し待機して確実にデータが更新されるようにする
          await Future.delayed(const Duration(milliseconds: 300));

          // 更新完了メッセージを表示
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('データを更新しました'),
                duration: Duration(seconds: 1),
              ),
            );
          }
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: LayoutBuilder(
            builder: (context, constraints) {
              // 画面幅に基づいてレイアウトを調整
              final isWideScreen = constraints.maxWidth > 600;

              return Container(
                margin: EdgeInsets.all(isWideScreen ? 24 : 15),
                child: SingleChildScrollView(
                  child: isWideScreen
                      ? _buildWideLayout(widget.review)
                      : _buildNormalLayout(widget.review),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // タイマーを解放
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    // 画面表示時にデータを更新
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _refreshData();

      // 閲覧数を更新
      _incrementViewCount();

      // 自動更新タイマーを設定（60秒ごとに更新）
      _refreshTimer = Timer.periodic(const Duration(seconds: 60), (_) {
        if (mounted) {
          _refreshData();
        }
      });
    });
  }

  // CommentsSection ウィジェットを追加する部分
  Widget _buildCommentsSection() {
    return CommentsSection(
      reviewId: widget.documentId,
      collectionName: 'comments',
    );
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

        // コメントセクションを追加
        _buildCommentsSection(),
      ],
    );
  }

  // 投稿情報セクションを構築するヘルパーメソッド
  Widget _buildPostInfoSection(Review review) {
    // いいね数を取得
    final likeCountAsync = ref.watch(likeCountProvider(widget.documentId));

    return _buildSection(
      title: '投稿情報',
      children: [
        TextSection(title: 'ニックネーム', content: review.name),
        DateSection(title: '投稿日・更新日', date: review.date),
        if (review.senden?.isNotEmpty ?? false)
          TextSection(title: '宣伝', content: review.senden),
        const SizedBox(height: 8),

        // 閲覧数とイイね数をカードで表示
        Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // 閲覧数
                Column(
                  children: [
                    const Icon(Icons.visibility, color: Colors.blue),
                    const SizedBox(height: 4),
                    const Text('閲覧数'),
                    const SizedBox(height: 4),
                    ViewCountDisplay(
                      documentId: widget.documentId,
                      collectionName: widget.collectionName,
                    ),
                  ],
                ),

                // いいね数
                Column(
                  children: [
                    const Icon(Icons.favorite, color: Colors.red),
                    const SizedBox(height: 4),
                    const Text('いいね数'),
                    const SizedBox(height: 4),
                    likeCountAsync.when(
                      data: (count) => Text(
                        count.toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      loading: () => const Text('...'),
                      error: (_, __) => const Text('0'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
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
            ],
          ),
        ),
      ],
    );
  }

  // デバッグ用：閲覧数データを直接確認
  Future<void> _checkViewCountData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('viewCounts')
          .doc(widget.documentId)
          .get();

      if (doc.exists) {
        print('閲覧数データ確認: ${doc.data()}');
      } else {
        print('閲覧数データが存在しません: viewCounts/${widget.documentId}');
      }
    } catch (e) {
      print('閲覧数データの確認に失敗しました: $e');
    }
  }

  // 閲覧数を更新するメソッド
  void _incrementViewCount() async {
    try {
      print('閲覧数更新開始: ${widget.documentId} (${widget.collectionName})');

      // ViewCountRepositoryを直接使用して閲覧数を更新
      await _viewCountRepository.incrementViewCount(
        widget.documentId,
        widget.collectionName,
      );

      // プロバイダーを無効化して再取得を強制
      ref.invalidate(
        view_count_provider
            .viewCountProvider((widget.documentId, widget.collectionName)),
      );

      print('閲覧数更新処理完了: ${widget.documentId}');
    } catch (e) {
      print('閲覧数の更新に失敗しました: $e');
    }
  }

  // データ更新メソッド
  void _refreshData() {
    ref.invalidate(review_provider.reviewProvider(widget.documentId));
    ref.invalidate(comment_provider.commentsProvider(widget.documentId));
    ref.invalidate(
      view_count_provider
          .viewCountProvider((widget.documentId, widget.collectionName)),
    );

    // いいね関連のプロバイダーも無効化
    ref.invalidate(hasUserLikedProvider(widget.documentId));
    ref.invalidate(likeCountProvider(widget.documentId));

    // ユーザーのいいね一覧も更新
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && !user.isAnonymous) {
      ref.invalidate(userLikesProvider(user.uid));
    }
  }
}
