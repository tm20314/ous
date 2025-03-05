import 'package:flutter_riverpod/flutter_riverpod.dart';

// アップロードエラーを管理するプロバイダー
final uploadErrorProvider = StateProvider<String?>((ref) => null);

// アップロード状態を管理するプロバイダー
final uploadingProvider = StateProvider<bool>((ref) => false);

// アップロード成功メッセージを管理するプロバイダー
final uploadSuccessProvider = StateProvider<String?>((ref) => null);
