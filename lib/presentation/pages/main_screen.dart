// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ous/presentation/pages/account/login_screen.dart';
import 'package:ous/presentation/pages/home/home_screen.dart';
import 'package:ous/presentation/pages/info/info_screen.dart';
import 'package:ous/presentation/pages/review/review_screen.dart';

final baseTabViewProvider = StateProvider<ViewType>((ref) => ViewType.home);

// 簡易的なエラー画面
class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            const Text('エラーが発生しました'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const Login()),
                );
              },
              child: const Text('ログイン画面に戻る'),
            ),
          ],
        ),
      ),
    );
  }
}

// 簡易的なローディング画面
class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class MainScreen extends ConsumerWidget {
  final List<Widget> _widgets = const [
    Home(),
    Info(),
    ReviewTopScreen(),
  ];

  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewState = ref.watch(baseTabViewProvider);

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Center(
          child: _widgets[viewState.index],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: viewState.index,
          onDestinationSelected: (int index) {
            HapticFeedback.mediumImpact();
            ref.read(baseTabViewProvider.notifier).state =
                ViewType.values[index];
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              label: 'ホーム',
            ),
            NavigationDestination(
              icon: Icon(Icons.info_outline),
              label: 'お知らせ',
            ),
            NavigationDestination(
              icon: Icon(Icons.school_outlined),
              label: '講義評価',
            ),
          ],
        ),
      ),
    );
  }
}

enum ViewType { home, info, review }
