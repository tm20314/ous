// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';
// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_review/in_app_review.dart';
// Project imports:
import 'package:ous/constant/urls.dart';
import 'package:ous/domain/theme_mode_provider.dart';
import 'package:ous/infrastructure/setting_service.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher_string.dart';

String _getThemeModeName(ThemeMode mode) {
  switch (mode) {
    case ThemeMode.system:
      return 'システム設定に従う';
    case ThemeMode.light:
      return 'ライト';
    case ThemeMode.dark:
      return 'ダーク';
    default:
      return '不明';
  }
}

class SettingPage extends ConsumerWidget {
  const SettingPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
      ),
      body: FutureBuilder<PackageInfo>(
        future: PackageInfo.fromPlatform(),
        builder: (context, snapshot) {
          final packageInfo = snapshot.data;
          return SettingsList(
            sections: [
              SettingsSection(
                title: const Text('テーマ設定'),
                tiles: <SettingsTile>[
                  SettingsTile.navigation(
                    title: const Text('テーマモード'),
                    leading: const Icon(Icons.color_lens),
                    trailing: Text(_getThemeModeName(theme.mode)),
                    onPressed: (context) async {
                      final selectedMode = await showDialog<ThemeMode>(
                        context: context,
                        builder: (context) => SimpleDialog(
                          title: const Text('テーマモードを選択'),
                          children: ThemeMode.values.map((mode) {
                            return SimpleDialogOption(
                              onPressed: () => Navigator.pop(context, mode),
                              child: Text(_getThemeModeName(mode)),
                            );
                          }).toList(),
                        ),
                      );
                      if (selectedMode != null) {
                        ref
                            .read(themeProvider.notifier)
                            .setThemeMode(selectedMode);
                      }
                    },
                  ),
                  SettingsTile.navigation(
                    title: const Text('テーマカラー'),
                    leading: const Icon(Icons.color_lens),
                    trailing: CircleAvatar(
                      radius: 12,
                      backgroundColor: theme.primarySwatch,
                    ),
                    onPressed: (_) async {
                      final selectedColor = await showDialog<MaterialColor>(
                        context: context,
                        builder: (context) => SimpleDialog(
                          title: const Text('テーマカラーを選択'),
                          children: Colors.primaries
                              .map(
                                (color) => SimpleDialogOption(
                                  onPressed: () =>
                                      Navigator.pop(context, color),
                                  child: Container(
                                    width: 24,
                                    height: 24,
                                    color: color,
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      );
                      if (selectedColor != null) {
                        ref
                            .read(themeProvider.notifier)
                            .setPrimaryColor(selectedColor);
                      }
                    },
                  ),
                ],
              ),
              SettingsSection(
                title: Text(
                  '基本的な設定',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                tiles: <SettingsTile>[
                  SettingsTile.navigation(
                    leading: const Icon(Icons.description),
                    title: const Text('利用規約について'),
                    onPressed: (context) {
                      launchUrlString(
                        SettingUrls.license,
                      );
                    },
                  ),
                  SettingsTile.navigation(
                    leading: const Icon(Icons.reply),
                    title: const Text('記事の掲載元'),
                    onPressed: (context) {
                      launchUrlString(
                        SettingUrls.source,
                      );
                    },
                  ),
                  SettingsTile.navigation(
                    leading: const Icon(Icons.email),
                    title: const Text('お問合わせ'),
                    onPressed: (context) {
                      launchUrlString(
                        SettingUrls.contact,
                      );
                    },
                  ),
                  SettingsTile.navigation(
                    leading: const Icon(Icons.terminal),
                    title: const Text('ライセンスについて'),
                    onPressed: (context) {
                      showLicensePage(
                        context: context,
                        applicationName: packageInfo?.appName ?? 'error',
                        applicationVersion: packageInfo?.version ?? 'error',
                        applicationIcon: const CircleAvatar(
                          backgroundImage: AssetImage(
                            'assets/icon/icon.png',
                          ), // アイコンのパスを指定
                          radius: 24,
                        ),
                        applicationLegalese:
                            ('@Gadgelogger\nアイコンは@CutterKnife_製作'),
                      );
                    },
                  ),
                  SettingsTile.navigation(
                    leading: const Icon(Icons.description),
                    title: const Text('開発ロードマップ'),
                    onPressed: (context) {
                      launchUrlString(
                        SettingUrls.loadMap,
                      );
                    },
                  ),
                  SettingsTile.navigation(
                    leading: const Icon(Icons.rate_review),
                    title: const Text('このアプリを評価する'),
                    onPressed: (BuildContext context) async {
                      final InAppReview inAppReview = InAppReview.instance;
                      if (await inAppReview.isAvailable()) {
                        inAppReview.requestReview();
                      }
                    },
                  ),
                  if (Platform.isIOS)
                    SettingsTile.navigation(
                      leading: const Icon(Icons.share),
                      title: const Text('このアプリをシェアする'),
                      onPressed: (BuildContext context) async {
                        Share.share(
                          StoreUrls.ios,
                        );
                      },
                    ),
                  if (Platform.isAndroid)
                    SettingsTile.navigation(
                      leading: const Icon(Icons.share),
                      title: const Text('このアプリをシェアする'),
                      onPressed: (BuildContext context) async {
                        Share.share(
                          StoreUrls.android,
                        );
                      },
                    ),
                  if (Platform.isIOS)
                    SettingsTile.navigation(
                      leading: const Icon(Icons.public_outlined),
                      title: const Text('アプリの公式サイト'),
                      onPressed: (context) {
                        launchUrlString(
                          SettingUrls.appWebSite,
                        );
                      },
                    ),
                ],
              ),
              SettingsSection(
                title: Text(
                  'アプリについて',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                tiles: <SettingsTile>[
                  SettingsTile(
                    title: const Text('バージョン'),
                    leading: const Icon(Icons.info_outline),
                    value: Text(packageInfo?.version ?? 'error'),
                  ),
                ],
              ),
              SettingsSection(
                title: Text(
                  'アカウント関連',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                tiles: <SettingsTile>[
                  SettingsTile.navigation(
                    leading: const Icon(Icons.exit_to_app),
                    title: const Text(
                      'ログアウトする',
                      style: TextStyle(color: Colors.red),
                    ),
                    onPressed: (BuildContext context) async {
                      SettingService.logoutDialog(context);
                    },
                  ),
                  SettingsTile.navigation(
                    leading: const Icon(Icons.exit_to_app),
                    title: const Text(
                      'アカウントを削除する。',
                      style: TextStyle(color: Colors.red),
                    ),
                    onPressed: (BuildContext context) async {
                      SettingService.deleteAccountDialog(context);
                    },
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
