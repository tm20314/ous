// Flutter imports:
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
// Project imports:
import 'package:ous/domain/user_providers.dart';
import 'package:ous/gen/assets.gen.dart';
import 'package:ous/main.dart';
import 'package:ous/presentation/pages/account/account_screen_edit.dart';
import 'package:ous/presentation/pages/account/login_screen.dart';
import 'package:ous/presentation/widgets/acount/custom_appbar.dart';

String getUserRole(String? email) {
  if (email == null) return '不明';
  if (email.endsWith('@ous.jp')) return '生徒';
  if (email.endsWith('@ous.ac.jp')) return '教職員';
  return '外部';
}

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userDataAsyncValue = ref.watch(userStreamProvider);
    return userDataAsyncValue.when(
      data: (userData) {
        // ゲストユーザーかどうかを確認
        final isGuest = FirebaseAuth.instance.currentUser?.isAnonymous ?? true;

        // ゲストの場合は表示名を「ゲスト」に
        final displayName = isGuest ? 'ゲスト' : (userData?.displayName ?? '');

        final createdAt = userData?.createdAt;
        final daysSinceCreation = createdAt != null
            ? DateTime.now().difference(createdAt).inDays
            : null;

        final userEmail = isGuest ? null : userData?.email;
        final userRole = isGuest ? 'ゲスト' : getUserRole(userEmail);

        return Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(160.0),
            child: AppBar(
              automaticallyImplyLeading: false,
              toolbarHeight: 150.0,
              backgroundColor: Theme.of(context).colorScheme.primary,
              elevation: 0.0,
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              title: PopScope(
                canPop: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      child: Row(
                        //アカウント画像
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Scrollbar(
                              child: SingleChildScrollView(
                                //for horizontal scrolling
                                scrollDirection: Axis.horizontal,
                                child: Text(
                                  displayName,
                                  maxLines: 1,
                                  style: GoogleFonts.notoSans(
                                    // フォントをnotoSansに指定(
                                    textStyle: const TextStyle(
                                      fontSize: 30,
                                      overflow: TextOverflow.ellipsis,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 100,
                            width: 100,
                            child: Stack(
                              clipBehavior: Clip.none,
                              fit: StackFit.expand,
                              children: [
                                CircleAvatar(
                                  backgroundImage: userData?.photoURL != ''
                                      ? CachedNetworkImageProvider(
                                          userData?.photoURL ?? '',
                                        )
                                      : null,
                                  child: userData?.photoURL == ''
                                      ? const Icon(
                                          Icons.person,
                                          size: 50,
                                        )
                                      : null,
                                ),
                                // ゲストの場合は設定ボタンを非表示
                                if (!isGuest)
                                  Positioned(
                                    bottom: 0,
                                    right: -25,
                                    child: RawMaterialButton(
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) => MyPageEdit(),
                                          ),
                                        );
                                      },
                                      elevation: 2.0,
                                      fillColor: const Color(0xFFF5F6F9),
                                      padding: const EdgeInsets.all(7.0),
                                      shape: const CircleBorder(),
                                      child: Icon(
                                        Icons.settings_outlined,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Align(
                          alignment: const Alignment(-0.9, 0.4),
                          child: Text(
                            '役職: $userRole',
                            maxLines: 1,
                            style: GoogleFonts.notoSans(
                              // フォントをnotoSansに指定(
                              textStyle: const TextStyle(
                                fontSize: 20,
                                overflow: TextOverflow.ellipsis,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          body: Stack(
            children: [
              ListView(
                children: [
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SizedBox(
                            width: 100,
                            height: 100,
                            child: Image.asset(Assets.icon.accounticon.path),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10, bottom: 30),
                            child: Text(
                              isGuest
                                  ? 'ゲストモードでご利用中です。\nアカウント登録するといいね機能などが使えるようになります。'
                                  : '$displayNameさんご愛用ありがとうございます\nアプリを${createdAt != null ? DateFormat('yyyy年MM月dd日').format(createdAt) : '不明'}から使い始めて\n${daysSinceCreation ?? '不明'}日が経過しました。',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.notoSans(
                                textStyle: const TextStyle(
                                  overflow: TextOverflow.ellipsis,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromRGBO(184, 189, 211, 1),
                                ),
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              // ログアウト処理
                              await ref.read(authServiceProvider).signOut();

                              // ログイン画面に遷移
                              if (context.mounted) {
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (_) => const Login(),
                                  ),
                                  (route) => false,
                                );
                              }
                            },
                            child: const Text('ログアウト'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              CustomPaint(
                painter: AppBarPainter(context),
                child: Container(height: 0),
              ),
            ],
          ),
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (error, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              Assets.icon.error.path,
              width: 150.0,
            ),
            Text('エラー: $error'),
          ],
        ),
      ),
    );
  }
}
