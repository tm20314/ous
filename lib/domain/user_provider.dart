import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// コメントにいいねしているかを確認するプロバイダー
final hasLikedCommentProvider =
    StreamProvider.family<bool, String>((ref, commentId) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    return Stream.value(false);
  }

  return FirebaseFirestore.instance
      .collection('comments')
      .doc(commentId)
      .collection('likes')
      .doc(user.uid)
      .snapshots()
      .map((snapshot) => snapshot.exists);
});

// ユーザー情報を取得するプロバイダー
final userProvider =
    FutureProvider.family<UserProfile?, String>((ref, userId) async {
  final doc =
      await FirebaseFirestore.instance.collection('users').doc(userId).get();

  if (!doc.exists || doc.data() == null) {
    return null;
  }

  return UserProfile.fromFirestore(doc.data()!, doc.id);
});

// ユーザー情報の簡易モデル
class UserProfile {
  final String uid;
  final String? displayName;
  final String? photoURL;

  UserProfile({
    required this.uid,
    this.displayName,
    this.photoURL,
  });

  factory UserProfile.fromFirestore(Map<String, dynamic> data, String id) {
    return UserProfile(
      uid: id,
      displayName: data['displayName'] as String?,
      photoURL: data['photoURL'] as String?,
    );
  }
}
