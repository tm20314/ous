import 'package:flutter/material.dart';

class TextSection extends StatelessWidget {
  final String title;
  final String? content;

  const TextSection({super.key, required this.title, this.content});

  @override
  Widget build(BuildContext context) {
    if (content == null || content!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).hintColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            content!,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
