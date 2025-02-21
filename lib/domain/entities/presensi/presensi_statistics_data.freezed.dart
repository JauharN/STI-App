// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'presensi_statistics_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PresensiStatisticsData _$PresensiStatisticsDataFromJson(
    Map<String, dynamic> json) {
  return _PresensiStatisticsData.fromJson(json);
}

/// @nodoc
mixin _$PresensiStatisticsData {
  String get programId => throw _privateConstructorUsedError;
  int get totalPertemuan => throw _privateConstructorUsedError;
  int get totalSantri => throw _privateConstructorUsedError;
  Map<String, double> get trendKehadiran => throw _privateConstructorUsedError;
  Map<PresensiStatus, int> get totalByStatus =>
      throw _privateConstructorUsedError;
  List<SantriStatistics> get santriStats => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get lastUpdated => throw _privateConstructorUsedError;

  /// Serializes this PresensiStatisticsData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PresensiStatisticsData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PresensiStatisticsDataCopyWith<PresensiStatisticsData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PresensiStatisticsDataCopyWith<$Res> {
  factory $PresensiStatisticsDataCopyWith(PresensiStatisticsData value,
          $Res Function(PresensiStatisticsData) then) =
      _$PresensiStatisticsDataCopyWithImpl<$Res, PresensiStatisticsData>;
  @useResult
  $Res call(
      {String programId,
      int totalPertemuan,
      int totalSantri,
      Map<String, double> trendKehadiran,
      Map<PresensiStatus, int> totalByStatus,
      List<SantriStatistics> santriStats,
      @TimestampConverter() DateTime? lastUpdated});
}

/// @nodoc
class _$PresensiStatisticsDataCopyWithImpl<$Res,
        $Val extends PresensiStatisticsData>
    implements $PresensiStatisticsDataCopyWith<$Res> {
  _$PresensiStatisticsDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PresensiStatisticsData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? programId = null,
    Object? totalPertemuan = null,
    Object? totalSantri = null,
    Object? trendKehadiran = null,
    Object? totalByStatus = null,
    Object? santriStats = null,
    Object? lastUpdated = freezed,
  }) {
    return _then(_value.copyWith(
      programId: null == programId
          ? _value.programId
          : programId // ignore: cast_nullable_to_non_nullable
              as String,
      totalPertemuan: null == totalPertemuan
          ? _value.totalPertemuan
          : totalPertemuan // ignore: cast_nullable_to_non_nullable
              as int,
      totalSantri: null == totalSantri
          ? _value.totalSantri
          : totalSantri // ignore: cast_nullable_to_non_nullable
              as int,
      trendKehadiran: null == trendKehadiran
          ? _value.trendKehadiran
          : trendKehadiran // ignore: cast_nullable_to_non_nullable
              as Map<String, double>,
      totalByStatus: null == totalByStatus
          ? _value.totalByStatus
          : totalByStatus // ignore: cast_nullable_to_non_nullable
              as Map<PresensiStatus, int>,
      santriStats: null == santriStats
          ? _value.santriStats
          : santriStats // ignore: cast_nullable_to_non_nullable
              as List<SantriStatistics>,
      lastUpdated: freezed == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PresensiStatisticsDataImplCopyWith<$Res>
    implements $PresensiStatisticsDataCopyWith<$Res> {
  factory _$$PresensiStatisticsDataImplCopyWith(
          _$PresensiStatisticsDataImpl value,
          $Res Function(_$PresensiStatisticsDataImpl) then) =
      __$$PresensiStatisticsDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String programId,
      int totalPertemuan,
      int totalSantri,
      Map<String, double> trendKehadiran,
      Map<PresensiStatus, int> totalByStatus,
      List<SantriStatistics> santriStats,
      @TimestampConverter() DateTime? lastUpdated});
}

/// @nodoc
class __$$PresensiStatisticsDataImplCopyWithImpl<$Res>
    extends _$PresensiStatisticsDataCopyWithImpl<$Res,
        _$PresensiStatisticsDataImpl>
    implements _$$PresensiStatisticsDataImplCopyWith<$Res> {
  __$$PresensiStatisticsDataImplCopyWithImpl(
      _$PresensiStatisticsDataImpl _value,
      $Res Function(_$PresensiStatisticsDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of PresensiStatisticsData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? programId = null,
    Object? totalPertemuan = null,
    Object? totalSantri = null,
    Object? trendKehadiran = null,
    Object? totalByStatus = null,
    Object? santriStats = null,
    Object? lastUpdated = freezed,
  }) {
    return _then(_$PresensiStatisticsDataImpl(
      programId: null == programId
          ? _value.programId
          : programId // ignore: cast_nullable_to_non_nullable
              as String,
      totalPertemuan: null == totalPertemuan
          ? _value.totalPertemuan
          : totalPertemuan // ignore: cast_nullable_to_non_nullable
              as int,
      totalSantri: null == totalSantri
          ? _value.totalSantri
          : totalSantri // ignore: cast_nullable_to_non_nullable
              as int,
      trendKehadiran: null == trendKehadiran
          ? _value._trendKehadiran
          : trendKehadiran // ignore: cast_nullable_to_non_nullable
              as Map<String, double>,
      totalByStatus: null == totalByStatus
          ? _value._totalByStatus
          : totalByStatus // ignore: cast_nullable_to_non_nullable
              as Map<PresensiStatus, int>,
      santriStats: null == santriStats
          ? _value._santriStats
          : santriStats // ignore: cast_nullable_to_non_nullable
              as List<SantriStatistics>,
      lastUpdated: freezed == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PresensiStatisticsDataImpl implements _PresensiStatisticsData {
  _$PresensiStatisticsDataImpl(
      {required this.programId,
      required this.totalPertemuan,
      required this.totalSantri,
      required final Map<String, double> trendKehadiran,
      required final Map<PresensiStatus, int> totalByStatus,
      required final List<SantriStatistics> santriStats,
      @TimestampConverter() this.lastUpdated = null})
      : _trendKehadiran = trendKehadiran,
        _totalByStatus = totalByStatus,
        _santriStats = santriStats;

  factory _$PresensiStatisticsDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$PresensiStatisticsDataImplFromJson(json);

  @override
  final String programId;
  @override
  final int totalPertemuan;
  @override
  final int totalSantri;
  final Map<String, double> _trendKehadiran;
  @override
  Map<String, double> get trendKehadiran {
    if (_trendKehadiran is EqualUnmodifiableMapView) return _trendKehadiran;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_trendKehadiran);
  }

  final Map<PresensiStatus, int> _totalByStatus;
  @override
  Map<PresensiStatus, int> get totalByStatus {
    if (_totalByStatus is EqualUnmodifiableMapView) return _totalByStatus;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_totalByStatus);
  }

  final List<SantriStatistics> _santriStats;
  @override
  List<SantriStatistics> get santriStats {
    if (_santriStats is EqualUnmodifiableListView) return _santriStats;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_santriStats);
  }

  @override
  @JsonKey()
  @TimestampConverter()
  final DateTime? lastUpdated;

  @override
  String toString() {
    return 'PresensiStatisticsData(programId: $programId, totalPertemuan: $totalPertemuan, totalSantri: $totalSantri, trendKehadiran: $trendKehadiran, totalByStatus: $totalByStatus, santriStats: $santriStats, lastUpdated: $lastUpdated)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PresensiStatisticsDataImpl &&
            (identical(other.programId, programId) ||
                other.programId == programId) &&
            (identical(other.totalPertemuan, totalPertemuan) ||
                other.totalPertemuan == totalPertemuan) &&
            (identical(other.totalSantri, totalSantri) ||
                other.totalSantri == totalSantri) &&
            const DeepCollectionEquality()
                .equals(other._trendKehadiran, _trendKehadiran) &&
            const DeepCollectionEquality()
                .equals(other._totalByStatus, _totalByStatus) &&
            const DeepCollectionEquality()
                .equals(other._santriStats, _santriStats) &&
            (identical(other.lastUpdated, lastUpdated) ||
                other.lastUpdated == lastUpdated));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      programId,
      totalPertemuan,
      totalSantri,
      const DeepCollectionEquality().hash(_trendKehadiran),
      const DeepCollectionEquality().hash(_totalByStatus),
      const DeepCollectionEquality().hash(_santriStats),
      lastUpdated);

  /// Create a copy of PresensiStatisticsData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PresensiStatisticsDataImplCopyWith<_$PresensiStatisticsDataImpl>
      get copyWith => __$$PresensiStatisticsDataImplCopyWithImpl<
          _$PresensiStatisticsDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PresensiStatisticsDataImplToJson(
      this,
    );
  }
}

abstract class _PresensiStatisticsData implements PresensiStatisticsData {
  factory _PresensiStatisticsData(
          {required final String programId,
          required final int totalPertemuan,
          required final int totalSantri,
          required final Map<String, double> trendKehadiran,
          required final Map<PresensiStatus, int> totalByStatus,
          required final List<SantriStatistics> santriStats,
          @TimestampConverter() final DateTime? lastUpdated}) =
      _$PresensiStatisticsDataImpl;

  factory _PresensiStatisticsData.fromJson(Map<String, dynamic> json) =
      _$PresensiStatisticsDataImpl.fromJson;

  @override
  String get programId;
  @override
  int get totalPertemuan;
  @override
  int get totalSantri;
  @override
  Map<String, double> get trendKehadiran;
  @override
  Map<PresensiStatus, int> get totalByStatus;
  @override
  List<SantriStatistics> get santriStats;
  @override
  @TimestampConverter()
  DateTime? get lastUpdated;

  /// Create a copy of PresensiStatisticsData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PresensiStatisticsDataImplCopyWith<_$PresensiStatisticsDataImpl>
      get copyWith => throw _privateConstructorUsedError;
}
