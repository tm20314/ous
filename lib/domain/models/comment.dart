import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'comment.freezed.dart';
part 'comment.g.dart';

@freezed
class Comment with _$Comment {
  const factory Comment({
    required String id,
    required String reviewId,
    required String collectionName,
    required String userId,
    required String userName,
    required String content,
    @TimestampConverter() required Timestamp createdAt,
    @TimestampConverter() required Timestamp updatedAt,
    required bool isEdited,
    required int likes,
    required bool isApproved,
  }) = _Comment;

  factory Comment.fromFirestore(Map<String, dynamic> json, String id) {
    return Comment(
      id: id,
      reviewId: json['reviewId'] as String,
      collectionName: json['collectionName'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      content: json['content'] as String,
      createdAt: json['createdAt'] as Timestamp,
      updatedAt: json['updatedAt'] as Timestamp,
      isEdited: json['isEdited'] as bool,
      likes: json['likes'] as int,
      isApproved: json['isApproved'] as bool,
    );
  }

  factory Comment.fromJson(Map<String, dynamic> json) =>
      _$CommentFromJson(json);

  const Comment._();

  @override
  Map<String, dynamic> toJson() {
    return {
      'reviewId': reviewId,
      'collectionName': collectionName,
      'userId': userId,
      'userName': userName,
      'content': content,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'isEdited': isEdited,
      'likes': likes,
      'isApproved': isApproved,
    };
  }

  Map<String, dynamic> toMap() {
    return toJson();
  }
}

class TimestampConverter implements JsonConverter<Timestamp, Timestamp> {
  const TimestampConverter();

  @override
  Timestamp fromJson(Timestamp timestamp) => timestamp;

  @override
  Timestamp toJson(Timestamp timestamp) => timestamp;
}
