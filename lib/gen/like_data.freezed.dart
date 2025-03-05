// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'like_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Like _$LikeFromJson(Map<String, dynamic> json) {
  return _Like.fromJson(json);
}

/// @nodoc
mixin _$Like {
  String? get userId => throw _privateConstructorUsedError;
  String? get reviewId => throw _privateConstructorUsedError;
  String? get reviewInternalId => throw _privateConstructorUsedError;
  String? get collectionName => throw _privateConstructorUsedError;
  @DateTimeTimestampConverter()
  DateTime? get createdAt => throw _privateConstructorUsedError;
  Map<String, dynamic>? get reviewData => throw _privateConstructorUsedError;

  /// Serializes this Like to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Like
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LikeCopyWith<Like> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LikeCopyWith<$Res> {
  factory $LikeCopyWith(Like value, $Res Function(Like) then) =
      _$LikeCopyWithImpl<$Res, Like>;
  @useResult
  $Res call(
      {String? userId,
      String? reviewId,
      String? reviewInternalId,
      String? collectionName,
      @DateTimeTimestampConverter() DateTime? createdAt,
      Map<String, dynamic>? reviewData});
}

/// @nodoc
class _$LikeCopyWithImpl<$Res, $Val extends Like>
    implements $LikeCopyWith<$Res> {
  _$LikeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Like
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = freezed,
    Object? reviewId = freezed,
    Object? reviewInternalId = freezed,
    Object? collectionName = freezed,
    Object? createdAt = freezed,
    Object? reviewData = freezed,
  }) {
    return _then(_value.copyWith(
      userId: freezed == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String?,
      reviewId: freezed == reviewId
          ? _value.reviewId
          : reviewId // ignore: cast_nullable_to_non_nullable
              as String?,
      reviewInternalId: freezed == reviewInternalId
          ? _value.reviewInternalId
          : reviewInternalId // ignore: cast_nullable_to_non_nullable
              as String?,
      collectionName: freezed == collectionName
          ? _value.collectionName
          : collectionName // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      reviewData: freezed == reviewData
          ? _value.reviewData
          : reviewData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LikeImplCopyWith<$Res> implements $LikeCopyWith<$Res> {
  factory _$$LikeImplCopyWith(
          _$LikeImpl value, $Res Function(_$LikeImpl) then) =
      __$$LikeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? userId,
      String? reviewId,
      String? reviewInternalId,
      String? collectionName,
      @DateTimeTimestampConverter() DateTime? createdAt,
      Map<String, dynamic>? reviewData});
}

/// @nodoc
class __$$LikeImplCopyWithImpl<$Res>
    extends _$LikeCopyWithImpl<$Res, _$LikeImpl>
    implements _$$LikeImplCopyWith<$Res> {
  __$$LikeImplCopyWithImpl(_$LikeImpl _value, $Res Function(_$LikeImpl) _then)
      : super(_value, _then);

  /// Create a copy of Like
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = freezed,
    Object? reviewId = freezed,
    Object? reviewInternalId = freezed,
    Object? collectionName = freezed,
    Object? createdAt = freezed,
    Object? reviewData = freezed,
  }) {
    return _then(_$LikeImpl(
      userId: freezed == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String?,
      reviewId: freezed == reviewId
          ? _value.reviewId
          : reviewId // ignore: cast_nullable_to_non_nullable
              as String?,
      reviewInternalId: freezed == reviewInternalId
          ? _value.reviewInternalId
          : reviewInternalId // ignore: cast_nullable_to_non_nullable
              as String?,
      collectionName: freezed == collectionName
          ? _value.collectionName
          : collectionName // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      reviewData: freezed == reviewData
          ? _value._reviewData
          : reviewData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LikeImpl implements _Like {
  const _$LikeImpl(
      {this.userId,
      this.reviewId,
      this.reviewInternalId,
      this.collectionName,
      @DateTimeTimestampConverter() this.createdAt,
      final Map<String, dynamic>? reviewData})
      : _reviewData = reviewData;

  factory _$LikeImpl.fromJson(Map<String, dynamic> json) =>
      _$$LikeImplFromJson(json);

  @override
  final String? userId;
  @override
  final String? reviewId;
  @override
  final String? reviewInternalId;
  @override
  final String? collectionName;
  @override
  @DateTimeTimestampConverter()
  final DateTime? createdAt;
  final Map<String, dynamic>? _reviewData;
  @override
  Map<String, dynamic>? get reviewData {
    final value = _reviewData;
    if (value == null) return null;
    if (_reviewData is EqualUnmodifiableMapView) return _reviewData;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'Like(userId: $userId, reviewId: $reviewId, reviewInternalId: $reviewInternalId, collectionName: $collectionName, createdAt: $createdAt, reviewData: $reviewData)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LikeImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.reviewId, reviewId) ||
                other.reviewId == reviewId) &&
            (identical(other.reviewInternalId, reviewInternalId) ||
                other.reviewInternalId == reviewInternalId) &&
            (identical(other.collectionName, collectionName) ||
                other.collectionName == collectionName) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            const DeepCollectionEquality()
                .equals(other._reviewData, _reviewData));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      userId,
      reviewId,
      reviewInternalId,
      collectionName,
      createdAt,
      const DeepCollectionEquality().hash(_reviewData));

  /// Create a copy of Like
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LikeImplCopyWith<_$LikeImpl> get copyWith =>
      __$$LikeImplCopyWithImpl<_$LikeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LikeImplToJson(
      this,
    );
  }
}

abstract class _Like implements Like {
  const factory _Like(
      {final String? userId,
      final String? reviewId,
      final String? reviewInternalId,
      final String? collectionName,
      @DateTimeTimestampConverter() final DateTime? createdAt,
      final Map<String, dynamic>? reviewData}) = _$LikeImpl;

  factory _Like.fromJson(Map<String, dynamic> json) = _$LikeImpl.fromJson;

  @override
  String? get userId;
  @override
  String? get reviewId;
  @override
  String? get reviewInternalId;
  @override
  String? get collectionName;
  @override
  @DateTimeTimestampConverter()
  DateTime? get createdAt;
  @override
  Map<String, dynamic>? get reviewData;

  /// Create a copy of Like
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LikeImplCopyWith<_$LikeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ReviewLike _$ReviewLikeFromJson(Map<String, dynamic> json) {
  return _ReviewLike.fromJson(json);
}

/// @nodoc
mixin _$ReviewLike {
  int? get count => throw _privateConstructorUsedError;
  String? get collectionName => throw _privateConstructorUsedError;
  @DateTimeTimestampConverter()
  DateTime? get lastUpdated => throw _privateConstructorUsedError;

  /// Serializes this ReviewLike to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ReviewLike
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReviewLikeCopyWith<ReviewLike> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReviewLikeCopyWith<$Res> {
  factory $ReviewLikeCopyWith(
          ReviewLike value, $Res Function(ReviewLike) then) =
      _$ReviewLikeCopyWithImpl<$Res, ReviewLike>;
  @useResult
  $Res call(
      {int? count,
      String? collectionName,
      @DateTimeTimestampConverter() DateTime? lastUpdated});
}

/// @nodoc
class _$ReviewLikeCopyWithImpl<$Res, $Val extends ReviewLike>
    implements $ReviewLikeCopyWith<$Res> {
  _$ReviewLikeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReviewLike
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? count = freezed,
    Object? collectionName = freezed,
    Object? lastUpdated = freezed,
  }) {
    return _then(_value.copyWith(
      count: freezed == count
          ? _value.count
          : count // ignore: cast_nullable_to_non_nullable
              as int?,
      collectionName: freezed == collectionName
          ? _value.collectionName
          : collectionName // ignore: cast_nullable_to_non_nullable
              as String?,
      lastUpdated: freezed == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ReviewLikeImplCopyWith<$Res>
    implements $ReviewLikeCopyWith<$Res> {
  factory _$$ReviewLikeImplCopyWith(
          _$ReviewLikeImpl value, $Res Function(_$ReviewLikeImpl) then) =
      __$$ReviewLikeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int? count,
      String? collectionName,
      @DateTimeTimestampConverter() DateTime? lastUpdated});
}

/// @nodoc
class __$$ReviewLikeImplCopyWithImpl<$Res>
    extends _$ReviewLikeCopyWithImpl<$Res, _$ReviewLikeImpl>
    implements _$$ReviewLikeImplCopyWith<$Res> {
  __$$ReviewLikeImplCopyWithImpl(
      _$ReviewLikeImpl _value, $Res Function(_$ReviewLikeImpl) _then)
      : super(_value, _then);

  /// Create a copy of ReviewLike
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? count = freezed,
    Object? collectionName = freezed,
    Object? lastUpdated = freezed,
  }) {
    return _then(_$ReviewLikeImpl(
      count: freezed == count
          ? _value.count
          : count // ignore: cast_nullable_to_non_nullable
              as int?,
      collectionName: freezed == collectionName
          ? _value.collectionName
          : collectionName // ignore: cast_nullable_to_non_nullable
              as String?,
      lastUpdated: freezed == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ReviewLikeImpl implements _ReviewLike {
  const _$ReviewLikeImpl(
      {this.count,
      this.collectionName,
      @DateTimeTimestampConverter() this.lastUpdated});

  factory _$ReviewLikeImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReviewLikeImplFromJson(json);

  @override
  final int? count;
  @override
  final String? collectionName;
  @override
  @DateTimeTimestampConverter()
  final DateTime? lastUpdated;

  @override
  String toString() {
    return 'ReviewLike(count: $count, collectionName: $collectionName, lastUpdated: $lastUpdated)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReviewLikeImpl &&
            (identical(other.count, count) || other.count == count) &&
            (identical(other.collectionName, collectionName) ||
                other.collectionName == collectionName) &&
            (identical(other.lastUpdated, lastUpdated) ||
                other.lastUpdated == lastUpdated));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, count, collectionName, lastUpdated);

  /// Create a copy of ReviewLike
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReviewLikeImplCopyWith<_$ReviewLikeImpl> get copyWith =>
      __$$ReviewLikeImplCopyWithImpl<_$ReviewLikeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReviewLikeImplToJson(
      this,
    );
  }
}

abstract class _ReviewLike implements ReviewLike {
  const factory _ReviewLike(
          {final int? count,
          final String? collectionName,
          @DateTimeTimestampConverter() final DateTime? lastUpdated}) =
      _$ReviewLikeImpl;

  factory _ReviewLike.fromJson(Map<String, dynamic> json) =
      _$ReviewLikeImpl.fromJson;

  @override
  int? get count;
  @override
  String? get collectionName;
  @override
  @DateTimeTimestampConverter()
  DateTime? get lastUpdated;

  /// Create a copy of ReviewLike
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReviewLikeImplCopyWith<_$ReviewLikeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UserLike _$UserLikeFromJson(Map<String, dynamic> json) {
  return _UserLike.fromJson(json);
}

/// @nodoc
mixin _$UserLike {
  String? get likeId => throw _privateConstructorUsedError;
  @DateTimeTimestampConverter()
  DateTime? get likedAt => throw _privateConstructorUsedError;
  String? get collectionName => throw _privateConstructorUsedError;

  /// Serializes this UserLike to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserLike
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserLikeCopyWith<UserLike> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserLikeCopyWith<$Res> {
  factory $UserLikeCopyWith(UserLike value, $Res Function(UserLike) then) =
      _$UserLikeCopyWithImpl<$Res, UserLike>;
  @useResult
  $Res call(
      {String? likeId,
      @DateTimeTimestampConverter() DateTime? likedAt,
      String? collectionName});
}

/// @nodoc
class _$UserLikeCopyWithImpl<$Res, $Val extends UserLike>
    implements $UserLikeCopyWith<$Res> {
  _$UserLikeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserLike
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? likeId = freezed,
    Object? likedAt = freezed,
    Object? collectionName = freezed,
  }) {
    return _then(_value.copyWith(
      likeId: freezed == likeId
          ? _value.likeId
          : likeId // ignore: cast_nullable_to_non_nullable
              as String?,
      likedAt: freezed == likedAt
          ? _value.likedAt
          : likedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      collectionName: freezed == collectionName
          ? _value.collectionName
          : collectionName // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserLikeImplCopyWith<$Res>
    implements $UserLikeCopyWith<$Res> {
  factory _$$UserLikeImplCopyWith(
          _$UserLikeImpl value, $Res Function(_$UserLikeImpl) then) =
      __$$UserLikeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? likeId,
      @DateTimeTimestampConverter() DateTime? likedAt,
      String? collectionName});
}

/// @nodoc
class __$$UserLikeImplCopyWithImpl<$Res>
    extends _$UserLikeCopyWithImpl<$Res, _$UserLikeImpl>
    implements _$$UserLikeImplCopyWith<$Res> {
  __$$UserLikeImplCopyWithImpl(
      _$UserLikeImpl _value, $Res Function(_$UserLikeImpl) _then)
      : super(_value, _then);

  /// Create a copy of UserLike
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? likeId = freezed,
    Object? likedAt = freezed,
    Object? collectionName = freezed,
  }) {
    return _then(_$UserLikeImpl(
      likeId: freezed == likeId
          ? _value.likeId
          : likeId // ignore: cast_nullable_to_non_nullable
              as String?,
      likedAt: freezed == likedAt
          ? _value.likedAt
          : likedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      collectionName: freezed == collectionName
          ? _value.collectionName
          : collectionName // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserLikeImpl implements _UserLike {
  const _$UserLikeImpl(
      {this.likeId,
      @DateTimeTimestampConverter() this.likedAt,
      this.collectionName});

  factory _$UserLikeImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserLikeImplFromJson(json);

  @override
  final String? likeId;
  @override
  @DateTimeTimestampConverter()
  final DateTime? likedAt;
  @override
  final String? collectionName;

  @override
  String toString() {
    return 'UserLike(likeId: $likeId, likedAt: $likedAt, collectionName: $collectionName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserLikeImpl &&
            (identical(other.likeId, likeId) || other.likeId == likeId) &&
            (identical(other.likedAt, likedAt) || other.likedAt == likedAt) &&
            (identical(other.collectionName, collectionName) ||
                other.collectionName == collectionName));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, likeId, likedAt, collectionName);

  /// Create a copy of UserLike
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserLikeImplCopyWith<_$UserLikeImpl> get copyWith =>
      __$$UserLikeImplCopyWithImpl<_$UserLikeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserLikeImplToJson(
      this,
    );
  }
}

abstract class _UserLike implements UserLike {
  const factory _UserLike(
      {final String? likeId,
      @DateTimeTimestampConverter() final DateTime? likedAt,
      final String? collectionName}) = _$UserLikeImpl;

  factory _UserLike.fromJson(Map<String, dynamic> json) =
      _$UserLikeImpl.fromJson;

  @override
  String? get likeId;
  @override
  @DateTimeTimestampConverter()
  DateTime? get likedAt;
  @override
  String? get collectionName;

  /// Create a copy of UserLike
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserLikeImplCopyWith<_$UserLikeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
