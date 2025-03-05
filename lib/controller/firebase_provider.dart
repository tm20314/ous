// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'firebase_provider.g.dart';

// 認証状態の変更を監視するプロバイダー
final authStateChangeProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

// 現在のユーザーを取得するプロバイダー
final currentUserProvider = Provider<User?>((ref) {
  return FirebaseAuth.instance.currentUser;
});

// 認証状態を監視するプロバイダー
@riverpod
Stream<User?> authStateChange(AuthStateChangeRef ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
}

// FirebaseAuthのプロバイダー
@riverpod
FirebaseAuth firebaseAuth(FirebaseAuthRef ref) {
  return FirebaseAuth.instance;
}

// flutter pub run build_runner watch --delete-conflicting-outputs

// Cloud Firestoreのプロバイダー
@riverpod
FirebaseFirestore firebaseFirestore(FirebaseFirestoreRef ref) {
  return FirebaseFirestore.instance;
}

// uidを取得するプロバイダー
@riverpod
String uid(UidRef ref) {
  return ref.watch(firebaseAuthProvider).currentUser!.uid;
}
