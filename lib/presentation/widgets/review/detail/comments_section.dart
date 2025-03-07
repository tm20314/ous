import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ous/domain/comment_provider.dart' as comment_provider;
import 'package:ous/domain/models/comment.dart';
import 'package:ous/domain/user_provider.dart' as user_provider;
import 'package:ous/presentation/pages/account/account_screen_edit.dart';

// コメントの編集・削除メニュー
class CommentActions extends ConsumerWidget {
  final Comment comment;

  const CommentActions({
    super.key,
    required this.comment,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      onSelected: (value) async {
        if (value == 'edit') {
          _showEditDialog(context, ref);
        } else if (value == 'delete') {
          _showDeleteDialog(context, ref);
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'edit',
          child: Text('編集'),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Text('削除'),
        ),
      ],
    );
  }

  Future<void> _showDeleteDialog(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('コメントを削除'),
          content: const Text('このコメントを削除してもよろしいですか？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('削除'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      try {
        await ref
            .read(comment_provider.deleteCommentProvider(comment.id).future);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('コメントの削除に失敗しました: $e')),
          );
        }
      }
    }
  }

  Future<void> _showEditDialog(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController(text: comment.content);

    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('コメントを編集'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'コメントを入力...',
            ),
            maxLines: 5,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text('保存'),
            ),
          ],
        );
      },
    );

    if (result != null && result.trim().isNotEmpty) {
      try {
        await ref.read(
          comment_provider.updateCommentProvider(
            (commentId: comment.id, content: result.trim()),
          ).future,
        );
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('コメントの編集に失敗しました: $e')),
          );
        }
      }
    }

    controller.dispose();
  }
}

// コメント入力フォーム
class CommentInputForm extends ConsumerStatefulWidget {
  final String reviewId;
  final String collectionName;

  const CommentInputForm({
    super.key,
    required this.reviewId,
    required this.collectionName,
  });

  @override
  ConsumerState<CommentInputForm> createState() => _CommentInputFormState();
}

// 個別コメント表示
class CommentItem extends ConsumerWidget {
  final Comment comment;

  const CommentItem({
    super.key,
    required this.comment,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ユーザー情報を取得
    final user = FirebaseAuth.instance.currentUser;

    // 自分のコメントかどうか
    final isOwner = user != null && comment.userId == user.uid;

    // いいね数を取得
    final likesCountAsync = ref.watch(
      comment_provider.commentLikesCountProvider(comment.id),
    );
    final likesCount = likesCountAsync.value ?? comment.likesCount;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ユーザー情報
            Row(
              children: [
                // ユーザー名
                Text(
                  comment.userName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(width: 8),

                // 投稿日時
                Text(
                  _formatDate(comment.createdAt),
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),

                // 編集済みマーク
                if (comment.isEdited)
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Text(
                      '(編集済み)',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 8),

            // コメント本文
            Text(
              comment.content,
              style: const TextStyle(fontSize: 15),
            ),

            const SizedBox(height: 8),

            // いいねボタンとカウント
            Row(
              children: [
                // いいねボタン
                LikeButton(
                  commentId: comment.id,
                  likes: likesCount,
                ),

                const Spacer(),

                // 自分のコメントの場合は編集・削除メニュー
                if (isOwner) CommentActions(comment: comment),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 日付フォーマット
  String _formatDate(Timestamp timestamp) {
    final date = timestamp.toDate(); // Timestamp を DateTime に変換
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays < 1) {
      if (difference.inHours < 1) {
        return '${difference.inMinutes}分前';
      }
      return '${difference.inHours}時間前';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}日前';
    } else {
      return '${date.year}/${date.month}/${date.day}';
    }
  }
}

// コメントセクション
class CommentsSection extends ConsumerStatefulWidget {
  final String reviewId;
  final String collectionName;

  const CommentsSection({
    super.key,
    required this.reviewId,
    required this.collectionName,
  });

  @override
  ConsumerState<CommentsSection> createState() => _CommentsSectionState();
}

// いいねボタン
class LikeButton extends ConsumerWidget {
  final String commentId;
  final int likes;

  const LikeButton({
    super.key,
    required this.commentId,
    required this.likes,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // いいね状態を監視
    final hasLikedAsync =
        ref.watch(comment_provider.commentLikeStatusProvider(commentId));

    // いいね数を状態として管理
    final likesCountAsync =
        ref.watch(comment_provider.commentLikesCountProvider(commentId));

    // AsyncValueから実際の値を取得
    final likesCount = likesCountAsync.value ?? likes;

    // デバッグ出力
    print(
      'LikeButton build: commentId=$commentId, hasLiked=${hasLikedAsync.value}, likesCount=$likesCount',
    );

    return Row(
      children: [
        IconButton(
          icon: Icon(
            hasLikedAsync.value == true
                ? Icons.thumb_up
                : Icons.thumb_up_outlined,
            color: hasLikedAsync.value == true ? Colors.blue : Colors.grey,
            size: 20,
          ),
          onPressed: hasLikedAsync.isLoading
              ? null // ロード中は無効化
              : () async {
                  print(
                    'いいねボタンが押されました: $commentId, 現在の状態: ${hasLikedAsync.value}',
                  );

                  try {
                    // いいねトグル
                    await ref.read(
                      comment_provider.toggleLikeProvider(commentId).future,
                    );

                    // すべての関連プロバイダーを無効化
                    ref.invalidate(
                      comment_provider.commentLikeStatusProvider(commentId),
                    );
                    ref.invalidate(
                      comment_provider.commentLikesCountProvider(commentId),
                    );
                    ref.invalidate(
                      comment_provider.commentsProvider,
                    );

                    print('いいねトグル完了: $commentId');
                  } catch (e) {
                    print('いいねトグルエラー: $e');
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('いいねの処理に失敗しました: $e')),
                      );
                    }
                  }
                },
          padding: EdgeInsets.zero,
          tooltip: 'いいね！',
        ),
        const SizedBox(width: 4),
        Text(
          likesCount.toString(),
          style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

class _CommentInputFormState extends ConsumerState<CommentInputForm> {
  final TextEditingController _controller = TextEditingController();
  bool _isSubmitting = false;
  bool _checkedRealName = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: TextField(
        controller: _controller,
        decoration: InputDecoration(
          hintText: 'コメントを入力...',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24.0),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Theme.of(context)
              .colorScheme
              .surfaceContainerHighest
              .withOpacity(0.5),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          // 送信ボタンを右側に配置
          suffixIcon: IconButton(
            icon: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2.0),
                  )
                : const Icon(Icons.send),
            onPressed: _isSubmitting ? null : _submitComment,
          ),
        ),
        maxLines: 3,
        minLines: 1,
        textInputAction: TextInputAction.send,
        onSubmitted: (_) => _submitComment(),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // コンポーネントがマウントされたら本名チェックを実行
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkIfUsingRealName();
    });
  }

  // 本名を使用しているかチェックする
  Future<void> _checkIfUsingRealName() async {
    if (_checkedRealName) return; // 既にチェック済みなら実行しない

    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.isAnonymous) return;

    try {
      // Firestoreからユーザー情報を取得
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      // hasSetNicknameフラグを確認
      final hasSetNickname =
          userDoc.data()?['hasSetNickname'] as bool? ?? false;

      // フラグがfalseの場合のみ警告を表示
      if (!hasSetNickname) {
        final displayName = userDoc.data()?['displayName'] as String? ??
            user.displayName ??
            'Unknown';

        print('警告: ニックネーム未設定 - "$displayName"');

        if (mounted) {
          // 警告ダイアログを表示
          _showRealNameWarning(context, displayName);
        }
      }

      setState(() {
        _checkedRealName = true;
      });
    } catch (e) {
      print('本名チェックエラー: $e');
    }
  }

  // 本名警告ダイアログを表示
  Future<bool> _showRealNameWarning(
      BuildContext context, String displayName) async {
    // ダイアログの結果を返すための変数
    bool shouldProceed = false;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('本名を使用している可能性があります'),
        content: Text(
          'あなたは「$displayName」という名前でコメントします。これが本名の場合、プライバシー保護のためにニックネームに変更することをお勧めします。',
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () {
              shouldProceed = true; // そのまま送信
              Navigator.pop(context);
            },
            child: const Text('このまま送信'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // ダイアログを閉じる
            },
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () async {
              // 名前変更画面に遷移
              final result = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const MyPageEdit(),
                ),
              );

              // 名前変更画面から戻ってきた場合
              if (context.mounted) {
                Navigator.pop(context); // ダイアログを閉じる

                // 名前が変更された場合は送信を続行
                if (result == true) {
                  shouldProceed = true;
                }
              }
            },
            child: const Text('名前を変更する'),
          ),
        ],
      ),
    );

    return shouldProceed;
  }

  Future<void> _submitComment() async {
    final content = _controller.text.trim();
    if (content.isEmpty) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      // 本名チェックを実行
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && !user.isAnonymous && !_checkedRealName) {
        // Firestoreからユーザー情報を取得
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        // hasSetNicknameフラグを確認
        final hasSetNickname =
            userDoc.data()?['hasSetNickname'] as bool? ?? false;

        // フラグがfalseの場合のみ警告を表示
        if (!hasSetNickname && mounted) {
          final displayName = userDoc.data()?['displayName'] as String? ??
              user.displayName ??
              'Unknown';

          // 警告ダイアログを表示し、続行するかどうかを確認
          final shouldProceed =
              await _showRealNameWarning(context, displayName);

          // 続行しない場合は処理を中断
          if (!shouldProceed) {
            setState(() {
              _isSubmitting = false;
            });
            return;
          }

          // チェック済みフラグを設定
          setState(() {
            _checkedRealName = true;
          });
        }
      }

      // コメントを送信
      await ref.read(
        comment_provider.addCommentProvider(
          (
            reviewId: widget.reviewId,
            collectionName: widget.collectionName,
            content: content,
          ),
        ).future,
      );
      _controller.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('コメントの投稿に失敗しました: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}

class _CommentsSectionState extends ConsumerState<CommentsSection> {
  // 表示するコメントの最大数（初期値）
  static const int _initialCommentCount = 3;

  // すべてのコメントを表示するかどうか
  bool _showAllComments = false;

  @override
  Widget build(BuildContext context) {
    final commentsAsync =
        ref.watch(comment_provider.commentsProvider(widget.reviewId));
    final sortedComments =
        ref.watch(comment_provider.sortedCommentsProvider(widget.reviewId));
    final sortOrder = ref.watch(comment_provider.commentSortOrderProvider);
    final commentCount = commentsAsync.value?.length ?? 0;

    // ユーザー情報を取得
    final isOusUser = ref.watch(user_provider.isOusUserProvider);

    // デバッグ情報
    print(
      'CommentsSection build: reviewId=${widget.reviewId}, commentCount=$commentCount',
    );
    print(
        'CommentsSection sortedComments: hasValue=${sortedComments.hasValue}, '
        'hasError=${sortedComments.hasError}, '
        'isLoading=${sortedComments.isLoading}');

    if (sortedComments.hasValue && sortedComments.value != null) {
      print(
        'CommentsSection sortedComments.value.length=${sortedComments.value?.length}',
      );
    }

    if (sortedComments.hasError) {
      print('CommentsSection sortedComments.error=${sortedComments.error}');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // コメントヘッダー
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text(
                    'コメント',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$commentCount',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              // ソートボタン
              DropdownButton<comment_provider.CommentSortOrder>(
                value: sortOrder,
                underline: const SizedBox(),
                icon: const Icon(Icons.sort),
                onChanged: (value) {
                  if (value != null) {
                    ref
                        .read(
                          comment_provider.commentSortOrderProvider.notifier,
                        )
                        .state = value;
                  }
                },
                items: const [
                  DropdownMenuItem(
                    value: comment_provider.CommentSortOrder.newest,
                    child: Text('新しい順'),
                  ),
                  DropdownMenuItem(
                    value: comment_provider.CommentSortOrder.oldest,
                    child: Text('古い順'),
                  ),
                  DropdownMenuItem(
                    value: comment_provider.CommentSortOrder.mostLiked,
                    child: Text('いいね順'),
                  ),
                ],
              ),
            ],
          ),
        ),

        // コメント入力フィールドの表示条件を確認
        if (isOusUser)
          // 学内ユーザー向けのコメント入力フィールドを表示
          CommentInputForm(
            reviewId: widget.reviewId,
            collectionName: widget.collectionName,
          )
        else
          // 学外ユーザー向けのメッセージを表示
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text('学内ユーザーのみコメントを投稿できます'),
          ),

        // コメントリストを表示
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: sortedComments.when(
            data: (comments) {
              if (comments.isEmpty) {
                return const Center(
                  child: Text('コメントはまだありません'),
                );
              }

              // 表示するコメントの数を決定
              final displayComments = _showAllComments
                  ? comments
                  : comments.take(_initialCommentCount).toList();

              return Column(
                children: [
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: displayComments.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final comment = displayComments[index];
                      return CommentItem(comment: comment);
                    },
                  ),

                  // 「もっと見る」ボタンの表示条件
                  if (comments.length > _initialCommentCount)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _showAllComments = !_showAllComments;
                          });
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest
                                .withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Center(
                            child: Text(
                              _showAllComments
                                  ? '折りたたむ'
                                  : '${comments.length - _initialCommentCount}件のコメントをもっと見る',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            error: (error, stack) => Center(
              child: Text('エラーが発生しました: $error'),
            ),
          ),
        ),
      ],
    );
  }
}
