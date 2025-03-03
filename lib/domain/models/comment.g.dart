// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CommentImpl _$$CommentImplFromJson(Map<String, dynamic> json) =>
    _$CommentImpl(
      id: json['id'] as String,
      reviewId: json['reviewId'] as String,
      collectionName: json['collectionName'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      content: json['content'] as String,
      createdAt:
          const TimestampConverter().fromJson(json['createdAt'] as Timestamp),
      updatedAt:
          const TimestampConverter().fromJson(json['updatedAt'] as Timestamp),
      isEdited: json['isEdited'] as bool,
      likes: (json['likes'] as num).toInt(),
      isApproved: json['isApproved'] as bool,
    );

Map<String, dynamic> _$$CommentImplToJson(_$CommentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'reviewId': instance.reviewId,
      'collectionName': instance.collectionName,
      'userId': instance.userId,
      'userName': instance.userName,
      'content': instance.content,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
      'isEdited': instance.isEdited,
      'likes': instance.likes,
      'isApproved': instance.isApproved,
    };
