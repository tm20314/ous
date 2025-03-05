import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FirebaseAuth _auth;
  final SharedPreferences _prefs;

  // コンストラクタを修正
  AuthService(this._prefs) : _auth = FirebaseAuth.instance;

  // 現在のユーザーを取得
  User? get currentUser => _auth.currentUser;

  // ユーザーIDを取得（匿名ユーザーも含む）
  Future<String> getUserId() async {
    if (_auth.currentUser == null) {
      // 匿名サインイン
      await signInAnonymously();
    }
    return _auth.currentUser?.uid ?? 'anonymous';
  }

  // 匿名サインイン
  Future<User?> signInAnonymously() async {
    try {
      final result = await _auth.signInAnonymously();
      return result.user;
    } catch (e) {
      print('匿名サインインに失敗しました: $e');
      return null;
    }
  }
}
