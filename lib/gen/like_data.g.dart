// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'like_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LikeImpl _$$LikeImplFromJson(Map<String, dynamic> json) => _$LikeImpl(
      userId: json['userId'] as String?,
      reviewId: json['reviewId'] as String?,
      reviewInternalId: json['reviewInternalId'] as String?,
      collectionName: json['collectionName'] as String?,
      createdAt: _$JsonConverterFromJson<Timestamp, DateTime>(
          json['createdAt'], const DateTimeTimestampConverter().fromJson),
      reviewData: json['reviewData'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$LikeImplToJson(_$LikeImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'reviewId': instance.reviewId,
      'reviewInternalId': instance.reviewInternalId,
      'collectionName': instance.collectionName,
      'createdAt': _$JsonConverterToJson<Timestamp, DateTime>(
          instance.createdAt, const DateTimeTimestampConverter().toJson),
      'reviewData': instance.reviewData,
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) =>
    json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) =>
    value == null ? null : toJson(value);

_$ReviewLikeImpl _$$ReviewLikeImplFromJson(Map<String, dynamic> json) =>
    _$ReviewLikeImpl(
      count: (json['count'] as num?)?.toInt(),
      collectionName: json['collectionName'] as String?,
      lastUpdated: _$JsonConverterFromJson<Timestamp, DateTime>(
          json['lastUpdated'], const DateTimeTimestampConverter().fromJson),
    );

Map<String, dynamic> _$$ReviewLikeImplToJson(_$ReviewLikeImpl instance) =>
    <String, dynamic>{
      'count': instance.count,
      'collectionName': instance.collectionName,
      'lastUpdated': _$JsonConverterToJson<Timestamp, DateTime>(
          instance.lastUpdated, const DateTimeTimestampConverter().toJson),
    };

_$UserLikeImpl _$$UserLikeImplFromJson(Map<String, dynamic> json) =>
    _$UserLikeImpl(
      likeId: json['likeId'] as String?,
      likedAt: _$JsonConverterFromJson<Timestamp, DateTime>(
          json['likedAt'], const DateTimeTimestampConverter().fromJson),
      collectionName: json['collectionName'] as String?,
    );

Map<String, dynamic> _$$UserLikeImplToJson(_$UserLikeImpl instance) =>
    <String, dynamic>{
      'likeId': instance.likeId,
      'likedAt': _$JsonConverterToJson<Timestamp, DateTime>(
          instance.likedAt, const DateTimeTimestampConverter().toJson),
      'collectionName': instance.collectionName,
    };
