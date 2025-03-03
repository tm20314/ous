// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserDataImpl _$$UserDataImplFromJson(Map<String, dynamic> json) =>
    _$UserDataImpl(
      displayName: json['displayName'] as String,
      email: json['email'] as String,
      uid: json['uid'] as String,
      photoURL: json['photoURL'] as String?,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
      createdAt: const DateTimeTimestampConverter()
          .fromJson(json['createdAt'] as Timestamp),
    );

Map<String, dynamic> _$$UserDataImplToJson(_$UserDataImpl instance) =>
    <String, dynamic>{
      'displayName': instance.displayName,
      'email': instance.email,
      'uid': instance.uid,
      'photoURL': instance.photoURL,
      'reviewCount': instance.reviewCount,
      'createdAt':
          const DateTimeTimestampConverter().toJson(instance.createdAt),
    };
