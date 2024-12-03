// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'presensi_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PresensiSummary _$PresensiSummaryFromJson(Map<String, dynamic> json) {
  return _PresensiSummary.fromJson(json);
}

/// @nodoc
mixin _$PresensiSummary {
  int get totalSantri => throw _privateConstructorUsedError;
  int get hadir => throw _privateConstructorUsedError;
  int get sakit => throw _privateConstructorUsedError;
  int get izin => throw _privateConstructorUsedError;
  int get alpha => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this PresensiSummary to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PresensiSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PresensiSummaryCopyWith<PresensiSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PresensiSummaryCopyWith<$Res> {
  factory $PresensiSummaryCopyWith(
          PresensiSummary value, $Res Function(PresensiSummary) then) =
      _$PresensiSummaryCopyWithImpl<$Res, PresensiSummary>;
  @useResult
  $Res call(
      {int totalSantri,
      int hadir,
      int sakit,
      int izin,
      int alpha,
      @TimestampConverter() DateTime? createdAt,
      @TimestampConverter() DateTime? updatedAt});
}

/// @nodoc
class _$PresensiSummaryCopyWithImpl<$Res, $Val extends PresensiSummary>
    implements $PresensiSummaryCopyWith<$Res> {
  _$PresensiSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PresensiSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalSantri = null,
    Object? hadir = null,
    Object? sakit = null,
    Object? izin = null,
    Object? alpha = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      totalSantri: null == totalSantri
          ? _value.totalSantri
          : totalSantri // ignore: cast_nullable_to_non_nullable
              as int,
      hadir: null == hadir
          ? _value.hadir
          : hadir // ignore: cast_nullable_to_non_nullable
              as int,
      sakit: null == sakit
          ? _value.sakit
          : sakit // ignore: cast_nullable_to_non_nullable
              as int,
      izin: null == izin
          ? _value.izin
          : izin // ignore: cast_nullable_to_non_nullable
              as int,
      alpha: null == alpha
          ? _value.alpha
          : alpha // ignore: cast_nullable_to_non_nullable
              as int,
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
abstract class _$$PresensiSummaryImplCopyWith<$Res>
    implements $PresensiSummaryCopyWith<$Res> {
  factory _$$PresensiSummaryImplCopyWith(_$PresensiSummaryImpl value,
          $Res Function(_$PresensiSummaryImpl) then) =
      __$$PresensiSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int totalSantri,
      int hadir,
      int sakit,
      int izin,
      int alpha,
      @TimestampConverter() DateTime? createdAt,
      @TimestampConverter() DateTime? updatedAt});
}

/// @nodoc
class __$$PresensiSummaryImplCopyWithImpl<$Res>
    extends _$PresensiSummaryCopyWithImpl<$Res, _$PresensiSummaryImpl>
    implements _$$PresensiSummaryImplCopyWith<$Res> {
  __$$PresensiSummaryImplCopyWithImpl(
      _$PresensiSummaryImpl _value, $Res Function(_$PresensiSummaryImpl) _then)
      : super(_value, _then);

  /// Create a copy of PresensiSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalSantri = null,
    Object? hadir = null,
    Object? sakit = null,
    Object? izin = null,
    Object? alpha = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$PresensiSummaryImpl(
      totalSantri: null == totalSantri
          ? _value.totalSantri
          : totalSantri // ignore: cast_nullable_to_non_nullable
              as int,
      hadir: null == hadir
          ? _value.hadir
          : hadir // ignore: cast_nullable_to_non_nullable
              as int,
      sakit: null == sakit
          ? _value.sakit
          : sakit // ignore: cast_nullable_to_non_nullable
              as int,
      izin: null == izin
          ? _value.izin
          : izin // ignore: cast_nullable_to_non_nullable
              as int,
      alpha: null == alpha
          ? _value.alpha
          : alpha // ignore: cast_nullable_to_non_nullable
              as int,
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
class _$PresensiSummaryImpl implements _PresensiSummary {
  _$PresensiSummaryImpl(
      {required this.totalSantri,
      required this.hadir,
      required this.sakit,
      required this.izin,
      required this.alpha,
      @TimestampConverter() this.createdAt,
      @TimestampConverter() this.updatedAt});

  factory _$PresensiSummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$PresensiSummaryImplFromJson(json);

  @override
  final int totalSantri;
  @override
  final int hadir;
  @override
  final int sakit;
  @override
  final int izin;
  @override
  final int alpha;
  @override
  @TimestampConverter()
  final DateTime? createdAt;
  @override
  @TimestampConverter()
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'PresensiSummary(totalSantri: $totalSantri, hadir: $hadir, sakit: $sakit, izin: $izin, alpha: $alpha, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PresensiSummaryImpl &&
            (identical(other.totalSantri, totalSantri) ||
                other.totalSantri == totalSantri) &&
            (identical(other.hadir, hadir) || other.hadir == hadir) &&
            (identical(other.sakit, sakit) || other.sakit == sakit) &&
            (identical(other.izin, izin) || other.izin == izin) &&
            (identical(other.alpha, alpha) || other.alpha == alpha) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, totalSantri, hadir, sakit, izin,
      alpha, createdAt, updatedAt);

  /// Create a copy of PresensiSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PresensiSummaryImplCopyWith<_$PresensiSummaryImpl> get copyWith =>
      __$$PresensiSummaryImplCopyWithImpl<_$PresensiSummaryImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PresensiSummaryImplToJson(
      this,
    );
  }
}

abstract class _PresensiSummary implements PresensiSummary {
  factory _PresensiSummary(
      {required final int totalSantri,
      required final int hadir,
      required final int sakit,
      required final int izin,
      required final int alpha,
      @TimestampConverter() final DateTime? createdAt,
      @TimestampConverter() final DateTime? updatedAt}) = _$PresensiSummaryImpl;

  factory _PresensiSummary.fromJson(Map<String, dynamic> json) =
      _$PresensiSummaryImpl.fromJson;

  @override
  int get totalSantri;
  @override
  int get hadir;
  @override
  int get sakit;
  @override
  int get izin;
  @override
  int get alpha;
  @override
  @TimestampConverter()
  DateTime? get createdAt;
  @override
  @TimestampConverter()
  DateTime? get updatedAt;

  /// Create a copy of PresensiSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PresensiSummaryImplCopyWith<_$PresensiSummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
