// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'program_detail.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ProgramDetail _$ProgramDetailFromJson(Map<String, dynamic> json) {
  return _ProgramDetail.fromJson(json);
}

/// @nodoc
mixin _$ProgramDetail {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  List<String> get schedule => throw _privateConstructorUsedError;
  int get totalMeetings => throw _privateConstructorUsedError;
  String? get location => throw _privateConstructorUsedError;
  List<String> get teacherIds => throw _privateConstructorUsedError;
  List<String> get teacherNames => throw _privateConstructorUsedError;
  List<String> get enrolledSantriIds => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this ProgramDetail to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProgramDetail
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProgramDetailCopyWith<ProgramDetail> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProgramDetailCopyWith<$Res> {
  factory $ProgramDetailCopyWith(
          ProgramDetail value, $Res Function(ProgramDetail) then) =
      _$ProgramDetailCopyWithImpl<$Res, ProgramDetail>;
  @useResult
  $Res call(
      {String id,
      String name,
      String description,
      List<String> schedule,
      int totalMeetings,
      String? location,
      List<String> teacherIds,
      List<String> teacherNames,
      List<String> enrolledSantriIds,
      @TimestampConverter() DateTime? createdAt,
      @TimestampConverter() DateTime? updatedAt});
}

/// @nodoc
class _$ProgramDetailCopyWithImpl<$Res, $Val extends ProgramDetail>
    implements $ProgramDetailCopyWith<$Res> {
  _$ProgramDetailCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProgramDetail
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? schedule = null,
    Object? totalMeetings = null,
    Object? location = freezed,
    Object? teacherIds = null,
    Object? teacherNames = null,
    Object? enrolledSantriIds = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      schedule: null == schedule
          ? _value.schedule
          : schedule // ignore: cast_nullable_to_non_nullable
              as List<String>,
      totalMeetings: null == totalMeetings
          ? _value.totalMeetings
          : totalMeetings // ignore: cast_nullable_to_non_nullable
              as int,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      teacherIds: null == teacherIds
          ? _value.teacherIds
          : teacherIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      teacherNames: null == teacherNames
          ? _value.teacherNames
          : teacherNames // ignore: cast_nullable_to_non_nullable
              as List<String>,
      enrolledSantriIds: null == enrolledSantriIds
          ? _value.enrolledSantriIds
          : enrolledSantriIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ProgramDetailImplCopyWith<$Res>
    implements $ProgramDetailCopyWith<$Res> {
  factory _$$ProgramDetailImplCopyWith(
          _$ProgramDetailImpl value, $Res Function(_$ProgramDetailImpl) then) =
      __$$ProgramDetailImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String description,
      List<String> schedule,
      int totalMeetings,
      String? location,
      List<String> teacherIds,
      List<String> teacherNames,
      List<String> enrolledSantriIds,
      @TimestampConverter() DateTime? createdAt,
      @TimestampConverter() DateTime? updatedAt});
}

/// @nodoc
class __$$ProgramDetailImplCopyWithImpl<$Res>
    extends _$ProgramDetailCopyWithImpl<$Res, _$ProgramDetailImpl>
    implements _$$ProgramDetailImplCopyWith<$Res> {
  __$$ProgramDetailImplCopyWithImpl(
      _$ProgramDetailImpl _value, $Res Function(_$ProgramDetailImpl) _then)
      : super(_value, _then);

  /// Create a copy of ProgramDetail
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? schedule = null,
    Object? totalMeetings = null,
    Object? location = freezed,
    Object? teacherIds = null,
    Object? teacherNames = null,
    Object? enrolledSantriIds = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$ProgramDetailImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      schedule: null == schedule
          ? _value._schedule
          : schedule // ignore: cast_nullable_to_non_nullable
              as List<String>,
      totalMeetings: null == totalMeetings
          ? _value.totalMeetings
          : totalMeetings // ignore: cast_nullable_to_non_nullable
              as int,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      teacherIds: null == teacherIds
          ? _value._teacherIds
          : teacherIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      teacherNames: null == teacherNames
          ? _value._teacherNames
          : teacherNames // ignore: cast_nullable_to_non_nullable
              as List<String>,
      enrolledSantriIds: null == enrolledSantriIds
          ? _value._enrolledSantriIds
          : enrolledSantriIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ProgramDetailImpl implements _ProgramDetail {
  _$ProgramDetailImpl(
      {required this.id,
      required this.name,
      required this.description,
      required final List<String> schedule,
      required this.totalMeetings,
      this.location,
      final List<String> teacherIds = const [],
      final List<String> teacherNames = const [],
      final List<String> enrolledSantriIds = const [],
      @TimestampConverter() this.createdAt = null,
      @TimestampConverter() this.updatedAt = null})
      : _schedule = schedule,
        _teacherIds = teacherIds,
        _teacherNames = teacherNames,
        _enrolledSantriIds = enrolledSantriIds;

  factory _$ProgramDetailImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProgramDetailImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String description;
  final List<String> _schedule;
  @override
  List<String> get schedule {
    if (_schedule is EqualUnmodifiableListView) return _schedule;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_schedule);
  }

  @override
  final int totalMeetings;
  @override
  final String? location;
  final List<String> _teacherIds;
  @override
  @JsonKey()
  List<String> get teacherIds {
    if (_teacherIds is EqualUnmodifiableListView) return _teacherIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_teacherIds);
  }

  final List<String> _teacherNames;
  @override
  @JsonKey()
  List<String> get teacherNames {
    if (_teacherNames is EqualUnmodifiableListView) return _teacherNames;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_teacherNames);
  }

  final List<String> _enrolledSantriIds;
  @override
  @JsonKey()
  List<String> get enrolledSantriIds {
    if (_enrolledSantriIds is EqualUnmodifiableListView)
      return _enrolledSantriIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_enrolledSantriIds);
  }

  @override
  @JsonKey()
  @TimestampConverter()
  final DateTime? createdAt;
  @override
  @JsonKey()
  @TimestampConverter()
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'ProgramDetail(id: $id, name: $name, description: $description, schedule: $schedule, totalMeetings: $totalMeetings, location: $location, teacherIds: $teacherIds, teacherNames: $teacherNames, enrolledSantriIds: $enrolledSantriIds, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProgramDetailImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality().equals(other._schedule, _schedule) &&
            (identical(other.totalMeetings, totalMeetings) ||
                other.totalMeetings == totalMeetings) &&
            (identical(other.location, location) ||
                other.location == location) &&
            const DeepCollectionEquality()
                .equals(other._teacherIds, _teacherIds) &&
            const DeepCollectionEquality()
                .equals(other._teacherNames, _teacherNames) &&
            const DeepCollectionEquality()
                .equals(other._enrolledSantriIds, _enrolledSantriIds) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      description,
      const DeepCollectionEquality().hash(_schedule),
      totalMeetings,
      location,
      const DeepCollectionEquality().hash(_teacherIds),
      const DeepCollectionEquality().hash(_teacherNames),
      const DeepCollectionEquality().hash(_enrolledSantriIds),
      createdAt,
      updatedAt);

  /// Create a copy of ProgramDetail
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProgramDetailImplCopyWith<_$ProgramDetailImpl> get copyWith =>
      __$$ProgramDetailImplCopyWithImpl<_$ProgramDetailImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProgramDetailImplToJson(
      this,
    );
  }
}

abstract class _ProgramDetail implements ProgramDetail {
  factory _ProgramDetail(
      {required final String id,
      required final String name,
      required final String description,
      required final List<String> schedule,
      required final int totalMeetings,
      final String? location,
      final List<String> teacherIds,
      final List<String> teacherNames,
      final List<String> enrolledSantriIds,
      @TimestampConverter() final DateTime? createdAt,
      @TimestampConverter() final DateTime? updatedAt}) = _$ProgramDetailImpl;

  factory _ProgramDetail.fromJson(Map<String, dynamic> json) =
      _$ProgramDetailImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get description;
  @override
  List<String> get schedule;
  @override
  int get totalMeetings;
  @override
  String? get location;
  @override
  List<String> get teacherIds;
  @override
  List<String> get teacherNames;
  @override
  List<String> get enrolledSantriIds;
  @override
  @TimestampConverter()
  DateTime? get createdAt;
  @override
  @TimestampConverter()
  DateTime? get updatedAt;

  /// Create a copy of ProgramDetail
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProgramDetailImplCopyWith<_$ProgramDetailImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
