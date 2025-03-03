import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ous/domain/comment_provider.dart';
import 'package:ous/domain/models/comment.dart';
import 'package:ous/domain/user_provider.dart';
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
        await ref.read(deleteCommentProvider(comment.id).future);
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
          updateCommentProvider(
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
    // ユーザー情報を取得するプロバイダーを使用
    final userAsync = ref.watch(userProvider(comment.userId));
    final currentUser = FirebaseAuth.instance.currentUser;
    final isOwner = currentUser?.uid == comment.userId;

    // 日付フォーマット
    final formattedDate = DateFormat('yyyy/MM/dd HH:mm').format(
      comment.createdAt.toDate(),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ユーザーアバター
          userAsync.when(
                data: (user) => CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage: user?.photoURL != null
                      ? NetworkImage(user!.photoURL!)
                      : null,
                  child: user?.photoURL == null
                      ? Icon(Icons.person, color: Colors.grey.shade700)
                      : null,
                ),
                loading: () => const CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.grey,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                error: (_, __) => CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.grey.shade300,
                  child: Icon(Icons.person, color: Colors.grey.shade700),
                ),
              ) ??
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.grey.shade300,
                child: Icon(Icons.person, color: Colors.grey.shade700),
              ),

          const SizedBox(width: 12),

          // コメント内容
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ユーザー名と日付
                Row(
                  children: [
                    // ユーザー名
                    userAsync.when(
                      data: (user) => Text(
                        user?.displayName ?? comment.userName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      loading: () => const Text('読み込み中...'),
                      error: (_, __) => Text(
                        comment.userName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    // 投稿日時
                    Text(
                      formattedDate,
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

                const SizedBox(height: 4),

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
                    LikeButton(commentId: comment.id, likes: comment.likes),

                    const Spacer(),

                    // 自分のコメントの場合は編集・削除メニュー
                    if (isOwner) CommentActions(comment: comment),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// CommentsSection クラスの定義を追加
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
    final hasLiked = ref.watch(hasLikedCommentProvider(commentId));

    return Row(
      children: [
        IconButton(
          icon: Icon(
            hasLiked.value ?? false ? Icons.thumb_up : Icons.thumb_up_outlined,
            size: 18,
          ),
          onPressed: () async {
            // いいねトグル後にプロバイダーを明示的に更新
            await ref.read(toggleLikeProvider(commentId).future);
            // キャッシュを無効化して再取得を強制
            ref.invalidate(hasLikedCommentProvider(commentId));
          },
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          splashRadius: 18,
        ),
        const SizedBox(width: 4),
        Text(
          likes.toString(),
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
  final _controller = TextEditingController();
  bool _isSubmitting = false;
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    // 現在のユーザー状態を取得
    final user = FirebaseAuth.instance.currentUser;
    final isAnonymous = user?.isAnonymous ?? true;
    final isLoggedIn = user != null && !isAnonymous;
    final userAsync = isLoggedIn ? ref.watch(userProvider(user.uid)) : null;

    // ゲストユーザーの場合はログインを促すメッセージを表示
    if (!isLoggedIn) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('学外orゲストの方はコメントを投稿できません'),
            const SizedBox(height: 8),
          ],
        ),
      );
    }

    // YouTubeスタイルのコメント入力フォーム
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ユーザーアバター
          userAsync?.when(
                data: (profile) => CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage: profile?.photoURL != null
                      ? NetworkImage(profile!.photoURL!)
                      : null,
                  child: profile?.photoURL == null
                      ? Icon(Icons.person, color: Colors.grey.shade700)
                      : null,
                ),
                loading: () => CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.grey.shade300,
                  child: const SizedBox(
                    width: 15,
                    height: 15,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                error: (_, __) => CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.grey.shade300,
                  child: Icon(Icons.person, color: Colors.grey.shade700),
                ),
              ) ??
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.grey.shade300,
                child: Icon(Icons.person, color: Colors.grey.shade700),
              ),

          const SizedBox(width: 12),

          // コメント入力フィールド
          Expanded(
            child: Focus(
              onFocusChange: (hasFocus) {
                setState(() {
                  _isFocused = hasFocus;
                });
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'コメントを追加...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(
                          color: _isFocused
                              ? Theme.of(context).primaryColor
                              : Colors.grey.shade300,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    maxLines: 3,
                    minLines: 1,
                  ),

                  // 送信ボタン (フォーカス時のみ表示)
                  if (_isFocused)
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _submitComment,
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('コメント'),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ニックネームチェックメソッド
  Future<bool> _checkDisplayName() async {
    // 最新のユーザー情報を取得するために再認証
    await FirebaseAuth.instance.currentUser?.reload();
    final user = FirebaseAuth.instance.currentUser;

    if (user == null || user.isAnonymous) {
      print("User is null or anonymous");
      return true; // 匿名ユーザーの場合はチェックしない
    }

    // Firestoreから最新のユーザー情報を取得
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    // Firestoreのデータを取得
    final firestoreDisplayName =
        userDoc.exists && userDoc.data()?['displayName'] != null
            ? userDoc.data()!['displayName'] as String
            : null;

    // Googleアカウント側の表示名
    final googleDisplayName = user.displayName;

    // デバッグ情報をコンソールに出力
    print("FirebaseAuth名前: $googleDisplayName");
    print("Firestore名前: $firestoreDisplayName");

    // メールアドレスが@ous.jpで終わる場合のみチェック
    if (user.email != null && user.email!.endsWith('@ous.jp')) {
      // 本名らしい名前かどうかをチェック
      final isLikelyRealName = googleDisplayName != null &&
          (googleDisplayName.contains(' ') || // スペースを含む
              (user.email != null &&
                  googleDisplayName ==
                      user.email!.split('@').first) || // メールアドレスの@前と一致
              (googleDisplayName.length >= 2 &&
                  googleDisplayName.length <= 4 &&
                  RegExp(r'[\u4e00-\u9faf]')
                      .hasMatch(googleDisplayName)) // 漢字を含む2〜4文字の名前
          );

      // Firestoreに既にニックネームが設定されているかどうか
      final hasCustomNickname = firestoreDisplayName != null &&
          firestoreDisplayName != googleDisplayName;

      // 本名らしい名前で、かつカスタムニックネームが設定されていない場合
      if (isLikelyRealName && !hasCustomNickname) {
        print("本名らしい名前です。ポップアップを表示します。");

        // ダイアログを表示して結果を待つ
        final result = await showDialog<String>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('ニックネームの設定'),
            content: Text(
              'コメントには現在の表示名「$googleDisplayName」が使用されます。プライバシー保護のため、ニックネームの使用をおすすめします。',
            ),
            actionsAlignment: MainAxisAlignment.end, // ボタンを右寄せに
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, 'cancel'), // キャンセル
                child: const Text('キャンセル'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, 'continue'), // このまま送信
                child: const Text('このまま送信'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, 'change'); // 変更する
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MyPageEdit()),
                  );
                },
                child: const Text('名前を変更'),
              ),
            ],
          ),
        );

        if (result == 'change') {
          // 名前変更画面に遷移し、結果を待つ
          final nameChanged = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (context) => MyPageEdit()),
          );

          // 名前を変更して戻ってきた場合は投稿を続行
          return nameChanged == true;
        }

        return result == 'continue'; // 「このまま送信」の場合のみtrue
      } else {
        print("本名ではないか、既にニックネームが設定されています。ポップアップを表示しません。");
      }
    }

    return true; // 条件に該当しない場合は投稿を続行
  }

  Future<void> _submitComment() async {
    if (_controller.text.trim().isEmpty) return;

    // コメント投稿前にニックネームチェック
    final shouldContinue = await _checkDisplayName();
    if (!shouldContinue) return; // ユーザーが「後で」を選択した場合は投稿をキャンセル

    setState(() {
      _isSubmitting = true;
    });

    try {
      await ref.read(
        addCommentProvider(
          (
            reviewId: widget.reviewId,
            collectionName: widget.collectionName,
            content: _controller.text.trim(),
          ),
        ).future,
      );

      _controller.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('コメントの投稿に失敗しました: $e')),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }
}

class _CommentsSectionState extends ConsumerState<CommentsSection> {
  // 表示するコメント数の初期値
  static const int _initialCommentCount = 3;
  bool _showAllComments = false;

  @override
  Widget build(BuildContext context) {
    final commentsAsync = ref.watch(commentsProvider(widget.reviewId));
    final sortedComments = ref.watch(sortedCommentsProvider(widget.reviewId));
    final sortOrder = ref.watch(commentSortOrderProvider);
    final commentCount = commentsAsync.value?.length ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // コメントヘッダー
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const Text(
                'コメント',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              if (commentsAsync.hasValue)
                Text(
                  '($commentCount)',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
              const Spacer(),
              // 並べ替えドロップダウン
              if (commentCount > 1)
                DropdownButton<CommentSortOrder>(
                  value: sortOrder,
                  underline: const SizedBox(),
                  icon: const Icon(Icons.sort),
                  onChanged: (CommentSortOrder? newValue) {
                    if (newValue != null) {
                      ref.read(commentSortOrderProvider.notifier).state =
                          newValue;
                    }
                  },
                  items: [
                    DropdownMenuItem(
                      value: CommentSortOrder.newest,
                      child: const Text('新しい順'),
                    ),
                    DropdownMenuItem(
                      value: CommentSortOrder.oldest,
                      child: const Text('古い順'),
                    ),
                    DropdownMenuItem(
                      value: CommentSortOrder.mostLiked,
                      child: const Text('人気順'),
                    ),
                  ],
                ),
            ],
          ),
        ),

        // コメント入力フォーム
        CommentInputForm(
          reviewId: widget.reviewId,
          collectionName: widget.collectionName,
        ),

        const Divider(),

        // コメント一覧
        commentsAsync.when(
          data: (comments) {
            if (comments.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: Text('まだコメントはありません'),
                ),
              );
            }

            // 並べ替え済みのコメントを使用
            final sortedList = sortedComments ?? comments;

            // 表示するコメントのリスト
            final displayedComments = _showAllComments
                ? sortedList
                : sortedList.take(_initialCommentCount).toList();

            return Column(
              children: [
                // コメントリスト
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: displayedComments.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final comment = displayedComments[index];
                    return CommentItem(comment: comment);
                  },
                ),

                // もっと見るボタン
                if (sortedList.length > _initialCommentCount)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          _showAllComments = !_showAllComments;
                        });
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _showAllComments
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _showAllComments
                                ? '折りたたむ'
                                : '${sortedList.length - _initialCommentCount}件のコメントをもっと見る',
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (error, stack) {
            // エラーをコンソールに出力
            print('コメント取得エラー: $error');
            print('スタックトレース: $stack');

            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text('エラーが発生しました: $error'),
                    TextButton(
                      onPressed: () =>
                          ref.refresh(commentsProvider(widget.reviewId)),
                      child: const Text('再読み込み'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
