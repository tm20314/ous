// Flutter imports:
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Project imports:
import 'package:ous/domain/user_providers.dart';
import 'package:ous/presentation/pages/account/account_screen.dart';

class DrawerUserHeader extends ConsumerWidget {
  const DrawerUserHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userDataAsyncValue = ref.watch(userStreamProvider);
    return userDataAsyncValue.when(
      data: (userData) => _UserAccountsDrawerHeader(
        displayName: userData?.displayName ?? 'Guest',
        email: userData?.email ?? 'guest@example.com',
        photoUrl: userData?.photoURL,
        onTap: () => _navigateToAccountScreen(context),
      ),
      loading: () => const _LoadingView(),
      error: (error, _) => _ErrorView(error: error.toString()),
    );
  }

  void _navigateToAccountScreen(BuildContext context) {
    Navigator.of(context).pop();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AccountScreen(),
      ),
    );
  }
}

class _ErrorView extends ConsumerWidget {
  final String error;

  const _ErrorView({required this.error});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return UserAccountsDrawerHeader(
      accountName: const Text('読み込みエラー'),
      accountEmail: Text(
        '再試行してください',
        style: TextStyle(color: Colors.white70),
      ),
      currentAccountPicture: CircleAvatar(
        backgroundColor: Colors.red.withOpacity(0.2),
        child: IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: () => ref.refresh(userStreamProvider),
        ),
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return UserAccountsDrawerHeader(
      accountName: Row(
        children: [
          const Text('読み込み中'),
          const SizedBox(width: 8),
          SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white70,
            ),
          ),
        ],
      ),
      accountEmail: const Text(
        '',
        style: TextStyle(color: Colors.white),
      ),
      currentAccountPicture: const CircleAvatar(
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white70,
            ),
          ),
        ),
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

class _UserAccountsDrawerHeader extends StatelessWidget {
  final String displayName;
  final String email;
  final String? photoUrl;
  final VoidCallback onTap;

  const _UserAccountsDrawerHeader({
    required this.displayName,
    required this.email,
    this.photoUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: UserAccountsDrawerHeader(
        accountName: Text(displayName),
        accountEmail: Text(
          email,
          style: const TextStyle(color: Colors.white),
        ),
        currentAccountPicture: CircleAvatar(
          backgroundImage: photoUrl != ''
              ? CachedNetworkImageProvider(photoUrl ?? '')
              : null,
          child: photoUrl == ''
              ? const Icon(
                  Icons.person,
                )
              : null,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
