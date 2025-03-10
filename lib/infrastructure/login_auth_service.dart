// Flutter imports:

// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

export 'auth_service.dart'; // This will make AuthService from auth_service.dart available

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final SharedPreferences _prefs;

  AuthService(this._prefs);

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
      return null;
    }
  }

  // Appleログイン
  Future<UserCredential?> signInWithApple() async {
    try {
      final rawNonce = generateNonce();
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      if (appleCredential.identityToken == null) {
        throw Exception('Apple SignIn Aborted');
      }
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
      );
      final authResult = await _auth.signInWithCredential(oauthCredential);
      _updateUserProfile(authResult.user);
      return authResult;
    } catch (e) {
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
      debugPrint('Google SignIn Error: $e'); // ログを追加
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
        await userRef.set(
          {
            'uid': user.uid,
            'email': user.email ?? '未設定',
            'displayName': user.displayName ?? '名前未設定',
            'photoURL': user.photoURL ?? '',
            'createdAt': DateTime.now(),
          },
        );
      } else {
        // ユーザーが既に存在する場合（2回目以降のログイン）
        await userRef.update(
          {
            'email': user.email ?? '未設定',
            'displayName': user.displayName ?? '名前未設定',
            'photoURL': user.photoURL ?? '',
          },
        );
      }
    }
  }
}
