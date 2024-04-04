//ユーザーデータを取得するProviderを定義

// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Project imports:
import 'package:ous/gen/user_data.dart';

final userStreamProvider = StreamProvider<UserData?>((ref) {
  return FirebaseAuth.instance.authStateChanges().asyncMap((user) async {
    if (user == null) {
      return null;
    }

    await Future.delayed(const Duration(seconds: 2)); // Add a 2-second delay

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    final data = snapshot.data();
    if (data == null) {
      throw Exception('ユーザーデータが存在しません。');
    }

    return UserData.fromJson(data);
  });
});
