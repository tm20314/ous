import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:ous/gen/review_data.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class ShareService {
  static Future<void> shareReview(Review review, GlobalKey globalKey) async {
    try {
      final imageFile = await _captureWidget(globalKey);
      if (imageFile == null) return;

      final text = _generateShareText(review);
      await Share.shareXFiles(
        [XFile(imageFile.path)],
        text: text,
      );
    } catch (e) {
      print('シェアに失敗しました: $e');
    }
  }

  static Future<void> shareToInstagram(Review review, GlobalKey key) async {
    File? imageFile;
    try {
      imageFile = await _captureWidget(key);
      if (imageFile == null) return;

      // Instagramストーリーを開くためのURL
      final instagramUrl = 'instagram://library';

      if (await canLaunchUrl(Uri.parse(instagramUrl))) {
        // まずInstagramアプリを開く
        await launchUrl(
          Uri.parse(instagramUrl),
          mode: LaunchMode.externalApplication,
        );
      } else {
        // アプリがない場合は通常のシェアを使用
        _fallbackShare(review, imageFile);
      }
    } catch (e) {
      print('Instagramシェアに失敗しました: $e');
      _fallbackShare(review, imageFile);
    }
  }

  static Future<void> shareToTwitter(Review review, GlobalKey key) async {
    File? imageFile;
    try {
      imageFile = await _captureWidget(key);
      if (imageFile == null) return;

      final text = _generateShareText(review);
      final encodedText = Uri.encodeComponent(text);

      // Twitter(X)アプリを開くためのURL
      final twitterUrl = Platform.isIOS
          ? 'twitter://post?message=$encodedText'
          : 'twitter://intent/tweet?text=$encodedText';

      // まずTwitterアプリで開こうとする
      if (await canLaunchUrl(Uri.parse(twitterUrl))) {
        await launchUrl(
          Uri.parse(twitterUrl),
          mode: LaunchMode.externalApplication,
        );
      } else {
        // アプリが開けない場合はブラウザで開く
        final webUrl = 'https://twitter.com/intent/tweet?text=$encodedText';
        await launchUrl(
          Uri.parse(webUrl),
          mode: LaunchMode.externalApplication,
        );
      }
    } catch (e) {
      print('Twitterシェアに失敗しました: $e');
      // 失敗した場合は通常のシェアを使用
      _fallbackShare(review, imageFile);
    }
  }

  static Future<File?> _captureWidget(GlobalKey key) async {
    try {
      final boundary =
          key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return null;

      final bytes = byteData.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/review_share.png');
      await file.writeAsBytes(bytes);
      return file;
    } catch (e) {
      print('画像キャプチャに失敗しました: $e');
      return null;
    }
  }

  // フォールバックのシェア機能
  static void _fallbackShare(Review review, File? imageFile) async {
    if (imageFile == null) return;

    final text = _generateShareText(review);
    await Share.shareXFiles(
      [XFile(imageFile.path)],
      text: text,
    );
  }

  static String _generateShareText(Review review) {
    final subjectName = review.zyugyoumei ?? '無題';
    final teacherName = review.kousimei ?? '不明';

    return '【講義評価】$subjectName ($teacherName)\n'
        '面白さ: ${review.omosirosa ?? 0}/5\n'
        '単位の取りやすさ: ${review.toriyasusa ?? 0}/5\n'
        '総合評価: ${review.sougouhyouka ?? 0}/5\n'
        '#岡山理科大学 #OUS #講義評価';
  }
}
