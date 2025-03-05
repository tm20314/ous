import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ous/domain/converters/date_time_timestamp_converter.dart';

part 'like_data.freezed.dart';
part 'like_data.g.dart';

@freezed
class Like with _$Like {
  const factory Like({
    String? userId,
    String? reviewId,
    String? reviewInternalId,
    String? collectionName,
    @DateTimeTimestampConverter() DateTime? createdAt,
    Map<String, dynamic>? reviewData,
  }) = _Like;

  factory Like.fromJson(Map<String, dynamic> json) => _$LikeFromJson(json);
}

@freezed
class ReviewLike with _$ReviewLike {
  const factory ReviewLike({
    int? count,
    String? collectionName,
    @DateTimeTimestampConverter() DateTime? lastUpdated,
  }) = _ReviewLike;

  factory ReviewLike.fromJson(Map<String, dynamic> json) =>
      _$ReviewLikeFromJson(json);
}

@freezed
class UserLike with _$UserLike {
  const factory UserLike({
    String? likeId,
    @DateTimeTimestampConverter() DateTime? likedAt,
    String? collectionName,
  }) = _UserLike;

  factory UserLike.fromJson(Map<String, dynamic> json) =>
      _$UserLikeFromJson(json);
}
