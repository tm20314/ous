import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FirebaseAuth _auth;
  final SharedPreferences _prefs;

  AuthService(this._prefs) : _auth = FirebaseAuth.instance;

  // 現在のユーザーを取得
  User? get currentUser => _auth.currentUser;

  // ランダムな文字列を生成する（Apple認証用）
  String generateNonce() {
    final random = Random.secure();
    return List.generate(32, (_) => random.nextInt(16).toRadixString(16))
        .join();
  }

  // ユーザーIDを取得（匿名ユーザーも含む）
  Future<String> getUserId() async {
    if (_auth.currentUser == null) {
      // 匿名サインイン
      await signInAnonymously();
    }
    return _auth.currentUser?.uid ?? 'anonymous';
  }

  // 明示的なログイン時に呼び出す
  Future<void> resetLogoutState() async {
    await _prefs.setBool('user_logged_out', false);
  }

  // 自動ログイン判定
  Future<bool> shouldAutoLogin() async {
    // ユーザーが明示的にログアウトした場合は自動ログインしない
    final userLoggedOut = _prefs.getBool('user_logged_out') ?? false;
    return !userLoggedOut;
  }

  // 匿名ログイン
  Future<UserCredential?> signInAnonymously() async {
    try {
      final userCredential = await _auth.signInAnonymously();
      _updateUserProfile(userCredential.user);
      return userCredential;
    } catch (e) {
      debugPrint('匿名認証エラー: $e');
      return null;
    }
  }

  // Appleログイン（最新の方法）
  Future<UserCredential?> signInWithApple() async {
    try {
      debugPrint('Apple ログイン開始: 新しい方法');

      // AppleAuthProviderを作成
      final appleProvider = AppleAuthProvider();

      // サインイン処理
      final userCredential = await _auth.signInWithProvider(appleProvider);
      debugPrint('Apple ログイン: Firebase 認証完了');

      // ユーザープロファイルの更新
      _updateUserProfile(userCredential.user);

      return userCredential;
    } on FirebaseAuthException catch (e) {
      debugPrint(
          'Apple ログイン失敗 (FirebaseAuthException): ${e.code} - ${e.message}');
      return null;
    } catch (e) {
      debugPrint('Apple ログイン失敗: $e');
      return null;
    }
  }

  // Googleログイン
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(hostedDomain: 'ous.jp');
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) throw Exception('Google SignIn Aborted');
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );
      final authResult = await _auth.signInWithCredential(credential);
      _updateUserProfile(authResult.user);
      return authResult;
    } catch (e) {
      debugPrint('Google SignIn Error: $e');
      return null;
    }
  }

  // ログアウト処理
  Future<void> signOut() async {
    await _auth.signOut();
    // ログアウト状態を保存
    await _prefs.setBool('user_logged_out', true);
  }

  // ユーザープロファイルをFireStoreに保存
  void _updateUserProfile(User? user) async {
    if (user != null) {
      final userRef =
          FirebaseFirestore.instance.collection('users').doc(user.uid);
      final userSnapshot = await userRef.get();

      if (!userSnapshot.exists) {
        // ユーザーが存在しない場合（初回ログイン）
        await userRef.set({
          'uid': user.uid,
          'email': user.email ?? '未設定',
          'displayName': user.displayName ?? '名前未設定',
          'photoURL': user.photoURL ?? '',
          'createdAt': DateTime.now(),
        });
      } else {
        // ユーザーが既に存在する場合（2回目以降のログイン）
        await userRef.update({
          'email': user.email ?? '未設定',
          'displayName': user.displayName ?? '名前未設定',
          'photoURL': user.photoURL ?? '',
        });
      }
    }
  }
}
