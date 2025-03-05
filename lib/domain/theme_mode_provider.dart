// theme_provider.dart

// Flutter imports:
import 'package:flutter/material.dart';
// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// テーマプロバイダー
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  // ここでエラーが発生する可能性がある
  // SharedPreferencesは非同期で初期化する必要があるが、
  // StateNotifierProviderは同期的に値を返す必要がある
  throw UnimplementedError('main.dartでoverrideする必要があります');
});

// テーマの状態を管理するNotifierクラス
class ThemeNotifier extends StateNotifier<ThemeState> {
  final SharedPreferences _prefs;

  ThemeNotifier(this._prefs)
      : super(
          ThemeState(
            mode: ThemeMode.system,
            primarySwatch: Colors.lightGreen,
          ),
        ) {
    // 初期化時に保存されたテーマを読み込む
    _loadTheme();
  }

  // プライマリカラーを設定する
  void setPrimaryColor(Color color) {
    _prefs.setInt('primary_color', color.value);
    state = state.copyWith(primarySwatch: color);
  }

  // テーマモードを設定する
  void setThemeMode(ThemeMode mode) {
    _prefs.setString('theme_mode', mode.toString());
    state = state.copyWith(mode: mode);
  }

  // 文字列からThemeModeを取得する
  ThemeMode _getThemeMode(String? mode) {
    switch (mode) {
      case 'ThemeMode.light':
        return ThemeMode.light;
      case 'ThemeMode.dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  // テーマを読み込む
  void _loadTheme() {
    final savedMode = _prefs.getString('theme_mode');
    final savedColor = _prefs.getInt('primary_color');

    state = ThemeState(
      mode: _getThemeMode(savedMode),
      primarySwatch: savedColor != null ? Color(savedColor) : Colors.lightGreen,
    );
  }
}

// テーマの状態を保持するクラス
class ThemeState {
  final ThemeMode mode;
  final Color primarySwatch;

  ThemeState({
    required this.mode,
    required this.primarySwatch,
  });

  // コピーメソッド
  ThemeState copyWith({
    ThemeMode? mode,
    Color? primarySwatch,
  }) {
    return ThemeState(
      mode: mode ?? this.mode,
      primarySwatch: primarySwatch ?? this.primarySwatch,
    );
  }
}
