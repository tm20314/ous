import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ous/domain/view_count_provider.dart';

class ViewCountDisplay extends ConsumerWidget {
  final String documentId;

  const ViewCountDisplay({
    super.key,
    required this.documentId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewCountAsync = ref.watch(viewCountProvider(documentId));

    return viewCountAsync.when(
      data: (count) => Text(
        '閲覧数: $count',
        style: TextStyle(
          fontSize: 12,
          color: Theme.of(context).hintColor,
        ),
      ),
      loading: () => const SizedBox(
        width: 12,
        height: 12,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      error: (_, __) => const Text(
        '閲覧数: -',
        style: TextStyle(fontSize: 12),
      ),
    );
  }
}
