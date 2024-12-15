// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'santri_statistics.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SantriStatistics _$SantriStatisticsFromJson(Map<String, dynamic> json) {
  return _SantriStatistics.fromJson(json);
}

/// @nodoc
mixin _$SantriStatistics {
  String get santriId => throw _privateConstructorUsedError;
  String get santriName => throw _privateConstructorUsedError;
  int get totalKehadiran => throw _privateConstructorUsedError;
  int get totalPertemuan => throw _privateConstructorUsedError;
  Map<PresensiStatus, int> get statusCount =>
      throw _privateConstructorUsedError;
  double get persentaseKehadiran => throw _privateConstructorUsedError;

  /// Serializes this SantriStatistics to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SantriStatistics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SantriStatisticsCopyWith<SantriStatistics> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SantriStatisticsCopyWith<$Res> {
  factory $SantriStatisticsCopyWith(
          SantriStatistics value, $Res Function(SantriStatistics) then) =
      _$SantriStatisticsCopyWithImpl<$Res, SantriStatistics>;
  @useResult
  $Res call(
      {String santriId,
      String santriName,
      int totalKehadiran,
      int totalPertemuan,
      Map<PresensiStatus, int> statusCount,
      double persentaseKehadiran});
}

/// @nodoc
class _$SantriStatisticsCopyWithImpl<$Res, $Val extends SantriStatistics>
    implements $SantriStatisticsCopyWith<$Res> {
  _$SantriStatisticsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SantriStatistics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? santriId = null,
    Object? santriName = null,
    Object? totalKehadiran = null,
    Object? totalPertemuan = null,
    Object? statusCount = null,
    Object? persentaseKehadiran = null,
  }) {
    return _then(_value.copyWith(
      santriId: null == santriId
          ? _value.santriId
          : santriId // ignore: cast_nullable_to_non_nullable
              as String,
      santriName: null == santriName
          ? _value.santriName
          : santriName // ignore: cast_nullable_to_non_nullable
              as String,
      totalKehadiran: null == totalKehadiran
          ? _value.totalKehadiran
          : totalKehadiran // ignore: cast_nullable_to_non_nullable
              as int,
      totalPertemuan: null == totalPertemuan
          ? _value.totalPertemuan
          : totalPertemuan // ignore: cast_nullable_to_non_nullable
              as int,
      statusCount: null == statusCount
          ? _value.statusCount
          : statusCount // ignore: cast_nullable_to_non_nullable
              as Map<PresensiStatus, int>,
      persentaseKehadiran: null == persentaseKehadiran
          ? _value.persentaseKehadiran
          : persentaseKehadiran // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SantriStatisticsImplCopyWith<$Res>
    implements $SantriStatisticsCopyWith<$Res> {
  factory _$$SantriStatisticsImplCopyWith(_$SantriStatisticsImpl value,
          $Res Function(_$SantriStatisticsImpl) then) =
      __$$SantriStatisticsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String santriId,
      String santriName,
      int totalKehadiran,
      int totalPertemuan,
      Map<PresensiStatus, int> statusCount,
      double persentaseKehadiran});
}

/// @nodoc
class __$$SantriStatisticsImplCopyWithImpl<$Res>
    extends _$SantriStatisticsCopyWithImpl<$Res, _$SantriStatisticsImpl>
    implements _$$SantriStatisticsImplCopyWith<$Res> {
  __$$SantriStatisticsImplCopyWithImpl(_$SantriStatisticsImpl _value,
      $Res Function(_$SantriStatisticsImpl) _then)
      : super(_value, _then);

  /// Create a copy of SantriStatistics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? santriId = null,
    Object? santriName = null,
    Object? totalKehadiran = null,
    Object? totalPertemuan = null,
    Object? statusCount = null,
    Object? persentaseKehadiran = null,
  }) {
    return _then(_$SantriStatisticsImpl(
      santriId: null == santriId
          ? _value.santriId
          : santriId // ignore: cast_nullable_to_non_nullable
              as String,
      santriName: null == santriName
          ? _value.santriName
          : santriName // ignore: cast_nullable_to_non_nullable
              as String,
      totalKehadiran: null == totalKehadiran
          ? _value.totalKehadiran
          : totalKehadiran // ignore: cast_nullable_to_non_nullable
              as int,
      totalPertemuan: null == totalPertemuan
          ? _value.totalPertemuan
          : totalPertemuan // ignore: cast_nullable_to_non_nullable
              as int,
      statusCount: null == statusCount
          ? _value._statusCount
          : statusCount // ignore: cast_nullable_to_non_nullable
              as Map<PresensiStatus, int>,
      persentaseKehadiran: null == persentaseKehadiran
          ? _value.persentaseKehadiran
          : persentaseKehadiran // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SantriStatisticsImpl implements _SantriStatistics {
  _$SantriStatisticsImpl(
      {required this.santriId,
      required this.santriName,
      required this.totalKehadiran,
      required this.totalPertemuan,
      required final Map<PresensiStatus, int> statusCount,
      required this.persentaseKehadiran})
      : _statusCount = statusCount;

  factory _$SantriStatisticsImpl.fromJson(Map<String, dynamic> json) =>
      _$$SantriStatisticsImplFromJson(json);

  @override
  final String santriId;
  @override
  final String santriName;
  @override
  final int totalKehadiran;
  @override
  final int totalPertemuan;
  final Map<PresensiStatus, int> _statusCount;
  @override
  Map<PresensiStatus, int> get statusCount {
    if (_statusCount is EqualUnmodifiableMapView) return _statusCount;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_statusCount);
  }

  @override
  final double persentaseKehadiran;

  @override
  String toString() {
    return 'SantriStatistics(santriId: $santriId, santriName: $santriName, totalKehadiran: $totalKehadiran, totalPertemuan: $totalPertemuan, statusCount: $statusCount, persentaseKehadiran: $persentaseKehadiran)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SantriStatisticsImpl &&
            (identical(other.santriId, santriId) ||
                other.santriId == santriId) &&
            (identical(other.santriName, santriName) ||
                other.santriName == santriName) &&
            (identical(other.totalKehadiran, totalKehadiran) ||
                other.totalKehadiran == totalKehadiran) &&
            (identical(other.totalPertemuan, totalPertemuan) ||
                other.totalPertemuan == totalPertemuan) &&
            const DeepCollectionEquality()
                .equals(other._statusCount, _statusCount) &&
            (identical(other.persentaseKehadiran, persentaseKehadiran) ||
                other.persentaseKehadiran == persentaseKehadiran));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      santriId,
      santriName,
      totalKehadiran,
      totalPertemuan,
      const DeepCollectionEquality().hash(_statusCount),
      persentaseKehadiran);

  /// Create a copy of SantriStatistics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SantriStatisticsImplCopyWith<_$SantriStatisticsImpl> get copyWith =>
      __$$SantriStatisticsImplCopyWithImpl<_$SantriStatisticsImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SantriStatisticsImplToJson(
      this,
    );
  }
}

abstract class _SantriStatistics implements SantriStatistics {
  factory _SantriStatistics(
      {required final String santriId,
      required final String santriName,
      required final int totalKehadiran,
      required final int totalPertemuan,
      required final Map<PresensiStatus, int> statusCount,
      required final double persentaseKehadiran}) = _$SantriStatisticsImpl;

  factory _SantriStatistics.fromJson(Map<String, dynamic> json) =
      _$SantriStatisticsImpl.fromJson;

  @override
  String get santriId;
  @override
  String get santriName;
  @override
  int get totalKehadiran;
  @override
  int get totalPertemuan;
  @override
  Map<PresensiStatus, int> get statusCount;
  @override
  double get persentaseKehadiran;

  /// Create a copy of SantriStatistics
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SantriStatisticsImplCopyWith<_$SantriStatisticsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
