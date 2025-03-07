import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ous/domain/view_count_provider.dart' as view_count_provider;

class ViewCountDisplay extends ConsumerWidget {
  final String documentId;
  final String collectionName;
  final TextStyle? style;

  const ViewCountDisplay({
    super.key,
    required this.documentId,
    required this.collectionName,
    this.style,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 閲覧数を取得
    final viewCountAsync = ref.watch(
      view_count_provider.viewCountProvider((documentId, collectionName)),
    );

    // デバッグ出力
    print(
      'ViewCountDisplay: documentId=$documentId, collectionName=$collectionName, '
      'viewCount=${viewCountAsync.value}, hasError=${viewCountAsync.hasError}, '
      'isLoading=${viewCountAsync.isLoading}',
    );

    if (viewCountAsync.hasError) {
      print('ViewCountDisplay エラー: ${viewCountAsync.error}');
    }

    return Row(
      children: [
        const Icon(Icons.visibility, size: 16, color: Colors.grey),
        const SizedBox(width: 4),
        viewCountAsync.when(
          data: (count) => Text(
            count == 1 ? '1 view' : '$count views',
            style: style,
          ),
          loading: () =>
              const Text('...', style: TextStyle(color: Colors.grey)),
          error: (error, stack) {
            print('ViewCountDisplay エラー詳細: $error');
            return const Text('Error', style: TextStyle(color: Colors.grey));
          },
        ),
        // 更新ボタンを追加
        IconButton(
          icon: const Icon(Icons.refresh, size: 14, color: Colors.grey),
          onPressed: () {
            // 閲覧数を更新
            ref.invalidate(
              view_count_provider
                  .viewCountProvider((documentId, collectionName)),
            );

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('閲覧数を更新しました'),
                duration: Duration(seconds: 1),
              ),
            );
          },
        ),
      ],
    );
  }
}
