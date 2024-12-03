// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'detail_presensi.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

DetailPresensi _$DetailPresensiFromJson(Map<String, dynamic> json) {
  return _DetailPresensi.fromJson(json);
}

/// @nodoc
mixin _$DetailPresensi {
  String get programId => throw _privateConstructorUsedError;
  String get programName => throw _privateConstructorUsedError;
  String get kelas => throw _privateConstructorUsedError;
  String get pengajarName => throw _privateConstructorUsedError;
  List<PresensiDetailItem> get pertemuan => throw _privateConstructorUsedError;
  PresensiSummary? get summary => throw _privateConstructorUsedError;

  /// Serializes this DetailPresensi to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DetailPresensi
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DetailPresensiCopyWith<DetailPresensi> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DetailPresensiCopyWith<$Res> {
  factory $DetailPresensiCopyWith(
          DetailPresensi value, $Res Function(DetailPresensi) then) =
      _$DetailPresensiCopyWithImpl<$Res, DetailPresensi>;
  @useResult
  $Res call(
      {String programId,
      String programName,
      String kelas,
      String pengajarName,
      List<PresensiDetailItem> pertemuan,
      PresensiSummary? summary});

  $PresensiSummaryCopyWith<$Res>? get summary;
}

/// @nodoc
class _$DetailPresensiCopyWithImpl<$Res, $Val extends DetailPresensi>
    implements $DetailPresensiCopyWith<$Res> {
  _$DetailPresensiCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DetailPresensi
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? programId = null,
    Object? programName = null,
    Object? kelas = null,
    Object? pengajarName = null,
    Object? pertemuan = null,
    Object? summary = freezed,
  }) {
    return _then(_value.copyWith(
      programId: null == programId
          ? _value.programId
          : programId // ignore: cast_nullable_to_non_nullable
              as String,
      programName: null == programName
          ? _value.programName
          : programName // ignore: cast_nullable_to_non_nullable
              as String,
      kelas: null == kelas
          ? _value.kelas
          : kelas // ignore: cast_nullable_to_non_nullable
              as String,
      pengajarName: null == pengajarName
          ? _value.pengajarName
          : pengajarName // ignore: cast_nullable_to_non_nullable
              as String,
      pertemuan: null == pertemuan
          ? _value.pertemuan
          : pertemuan // ignore: cast_nullable_to_non_nullable
              as List<PresensiDetailItem>,
      summary: freezed == summary
          ? _value.summary
          : summary // ignore: cast_nullable_to_non_nullable
              as PresensiSummary?,
    ) as $Val);
  }

  /// Create a copy of DetailPresensi
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PresensiSummaryCopyWith<$Res>? get summary {
    if (_value.summary == null) {
      return null;
    }

    return $PresensiSummaryCopyWith<$Res>(_value.summary!, (value) {
      return _then(_value.copyWith(summary: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$DetailPresensiImplCopyWith<$Res>
    implements $DetailPresensiCopyWith<$Res> {
  factory _$$DetailPresensiImplCopyWith(_$DetailPresensiImpl value,
          $Res Function(_$DetailPresensiImpl) then) =
      __$$DetailPresensiImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String programId,
      String programName,
      String kelas,
      String pengajarName,
      List<PresensiDetailItem> pertemuan,
      PresensiSummary? summary});

  @override
  $PresensiSummaryCopyWith<$Res>? get summary;
}

/// @nodoc
class __$$DetailPresensiImplCopyWithImpl<$Res>
    extends _$DetailPresensiCopyWithImpl<$Res, _$DetailPresensiImpl>
    implements _$$DetailPresensiImplCopyWith<$Res> {
  __$$DetailPresensiImplCopyWithImpl(
      _$DetailPresensiImpl _value, $Res Function(_$DetailPresensiImpl) _then)
      : super(_value, _then);

  /// Create a copy of DetailPresensi
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? programId = null,
    Object? programName = null,
    Object? kelas = null,
    Object? pengajarName = null,
    Object? pertemuan = null,
    Object? summary = freezed,
  }) {
    return _then(_$DetailPresensiImpl(
      programId: null == programId
          ? _value.programId
          : programId // ignore: cast_nullable_to_non_nullable
              as String,
      programName: null == programName
          ? _value.programName
          : programName // ignore: cast_nullable_to_non_nullable
              as String,
      kelas: null == kelas
          ? _value.kelas
          : kelas // ignore: cast_nullable_to_non_nullable
              as String,
      pengajarName: null == pengajarName
          ? _value.pengajarName
          : pengajarName // ignore: cast_nullable_to_non_nullable
              as String,
      pertemuan: null == pertemuan
          ? _value._pertemuan
          : pertemuan // ignore: cast_nullable_to_non_nullable
              as List<PresensiDetailItem>,
      summary: freezed == summary
          ? _value.summary
          : summary // ignore: cast_nullable_to_non_nullable
              as PresensiSummary?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DetailPresensiImpl implements _DetailPresensi {
  _$DetailPresensiImpl(
      {required this.programId,
      required this.programName,
      required this.kelas,
      required this.pengajarName,
      required final List<PresensiDetailItem> pertemuan,
      this.summary})
      : _pertemuan = pertemuan;

  factory _$DetailPresensiImpl.fromJson(Map<String, dynamic> json) =>
      _$$DetailPresensiImplFromJson(json);

  @override
  final String programId;
  @override
  final String programName;
  @override
  final String kelas;
  @override
  final String pengajarName;
  final List<PresensiDetailItem> _pertemuan;
  @override
  List<PresensiDetailItem> get pertemuan {
    if (_pertemuan is EqualUnmodifiableListView) return _pertemuan;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_pertemuan);
  }

  @override
  final PresensiSummary? summary;

  @override
  String toString() {
    return 'DetailPresensi(programId: $programId, programName: $programName, kelas: $kelas, pengajarName: $pengajarName, pertemuan: $pertemuan, summary: $summary)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DetailPresensiImpl &&
            (identical(other.programId, programId) ||
                other.programId == programId) &&
            (identical(other.programName, programName) ||
                other.programName == programName) &&
            (identical(other.kelas, kelas) || other.kelas == kelas) &&
            (identical(other.pengajarName, pengajarName) ||
                other.pengajarName == pengajarName) &&
            const DeepCollectionEquality()
                .equals(other._pertemuan, _pertemuan) &&
            (identical(other.summary, summary) || other.summary == summary));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, programId, programName, kelas,
      pengajarName, const DeepCollectionEquality().hash(_pertemuan), summary);

  /// Create a copy of DetailPresensi
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DetailPresensiImplCopyWith<_$DetailPresensiImpl> get copyWith =>
      __$$DetailPresensiImplCopyWithImpl<_$DetailPresensiImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DetailPresensiImplToJson(
      this,
    );
  }
}

abstract class _DetailPresensi implements DetailPresensi {
  factory _DetailPresensi(
      {required final String programId,
      required final String programName,
      required final String kelas,
      required final String pengajarName,
      required final List<PresensiDetailItem> pertemuan,
      final PresensiSummary? summary}) = _$DetailPresensiImpl;

  factory _DetailPresensi.fromJson(Map<String, dynamic> json) =
      _$DetailPresensiImpl.fromJson;

  @override
  String get programId;
  @override
  String get programName;
  @override
  String get kelas;
  @override
  String get pengajarName;
  @override
  List<PresensiDetailItem> get pertemuan;
  @override
  PresensiSummary? get summary;

  /// Create a copy of DetailPresensi
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DetailPresensiImplCopyWith<_$DetailPresensiImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PresensiDetailItem _$PresensiDetailItemFromJson(Map<String, dynamic> json) {
  return _PresensiDetailItem.fromJson(json);
}

/// @nodoc
mixin _$PresensiDetailItem {
  int get pertemuanKe => throw _privateConstructorUsedError;
  PresensiStatus get status =>
      throw _privateConstructorUsedError; // Gunakan enum
  @TimestampConverter()
  DateTime get tanggal => throw _privateConstructorUsedError;
  String? get materi => throw _privateConstructorUsedError;
  String? get keterangan => throw _privateConstructorUsedError;

  /// Serializes this PresensiDetailItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PresensiDetailItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PresensiDetailItemCopyWith<PresensiDetailItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PresensiDetailItemCopyWith<$Res> {
  factory $PresensiDetailItemCopyWith(
          PresensiDetailItem value, $Res Function(PresensiDetailItem) then) =
      _$PresensiDetailItemCopyWithImpl<$Res, PresensiDetailItem>;
  @useResult
  $Res call(
      {int pertemuanKe,
      PresensiStatus status,
      @TimestampConverter() DateTime tanggal,
      String? materi,
      String? keterangan});
}

/// @nodoc
class _$PresensiDetailItemCopyWithImpl<$Res, $Val extends PresensiDetailItem>
    implements $PresensiDetailItemCopyWith<$Res> {
  _$PresensiDetailItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PresensiDetailItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? pertemuanKe = null,
    Object? status = null,
    Object? tanggal = null,
    Object? materi = freezed,
    Object? keterangan = freezed,
  }) {
    return _then(_value.copyWith(
      pertemuanKe: null == pertemuanKe
          ? _value.pertemuanKe
          : pertemuanKe // ignore: cast_nullable_to_non_nullable
              as int,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as PresensiStatus,
      tanggal: null == tanggal
          ? _value.tanggal
          : tanggal // ignore: cast_nullable_to_non_nullable
              as DateTime,
      materi: freezed == materi
          ? _value.materi
          : materi // ignore: cast_nullable_to_non_nullable
              as String?,
      keterangan: freezed == keterangan
          ? _value.keterangan
          : keterangan // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PresensiDetailItemImplCopyWith<$Res>
    implements $PresensiDetailItemCopyWith<$Res> {
  factory _$$PresensiDetailItemImplCopyWith(_$PresensiDetailItemImpl value,
          $Res Function(_$PresensiDetailItemImpl) then) =
      __$$PresensiDetailItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int pertemuanKe,
      PresensiStatus status,
      @TimestampConverter() DateTime tanggal,
      String? materi,
      String? keterangan});
}

/// @nodoc
class __$$PresensiDetailItemImplCopyWithImpl<$Res>
    extends _$PresensiDetailItemCopyWithImpl<$Res, _$PresensiDetailItemImpl>
    implements _$$PresensiDetailItemImplCopyWith<$Res> {
  __$$PresensiDetailItemImplCopyWithImpl(_$PresensiDetailItemImpl _value,
      $Res Function(_$PresensiDetailItemImpl) _then)
      : super(_value, _then);

  /// Create a copy of PresensiDetailItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? pertemuanKe = null,
    Object? status = null,
    Object? tanggal = null,
    Object? materi = freezed,
    Object? keterangan = freezed,
  }) {
    return _then(_$PresensiDetailItemImpl(
      pertemuanKe: null == pertemuanKe
          ? _value.pertemuanKe
          : pertemuanKe // ignore: cast_nullable_to_non_nullable
              as int,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as PresensiStatus,
      tanggal: null == tanggal
          ? _value.tanggal
          : tanggal // ignore: cast_nullable_to_non_nullable
              as DateTime,
      materi: freezed == materi
          ? _value.materi
          : materi // ignore: cast_nullable_to_non_nullable
              as String?,
      keterangan: freezed == keterangan
          ? _value.keterangan
          : keterangan // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PresensiDetailItemImpl implements _PresensiDetailItem {
  _$PresensiDetailItemImpl(
      {required this.pertemuanKe,
      required this.status,
      @TimestampConverter() required this.tanggal,
      this.materi,
      this.keterangan});

  factory _$PresensiDetailItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$PresensiDetailItemImplFromJson(json);

  @override
  final int pertemuanKe;
  @override
  final PresensiStatus status;
// Gunakan enum
  @override
  @TimestampConverter()
  final DateTime tanggal;
  @override
  final String? materi;
  @override
  final String? keterangan;

  @override
  String toString() {
    return 'PresensiDetailItem(pertemuanKe: $pertemuanKe, status: $status, tanggal: $tanggal, materi: $materi, keterangan: $keterangan)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PresensiDetailItemImpl &&
            (identical(other.pertemuanKe, pertemuanKe) ||
                other.pertemuanKe == pertemuanKe) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.tanggal, tanggal) || other.tanggal == tanggal) &&
            (identical(other.materi, materi) || other.materi == materi) &&
            (identical(other.keterangan, keterangan) ||
                other.keterangan == keterangan));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, pertemuanKe, status, tanggal, materi, keterangan);

  /// Create a copy of PresensiDetailItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PresensiDetailItemImplCopyWith<_$PresensiDetailItemImpl> get copyWith =>
      __$$PresensiDetailItemImplCopyWithImpl<_$PresensiDetailItemImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PresensiDetailItemImplToJson(
      this,
    );
  }
}

abstract class _PresensiDetailItem implements PresensiDetailItem {
  factory _PresensiDetailItem(
      {required final int pertemuanKe,
      required final PresensiStatus status,
      @TimestampConverter() required final DateTime tanggal,
      final String? materi,
      final String? keterangan}) = _$PresensiDetailItemImpl;

  factory _PresensiDetailItem.fromJson(Map<String, dynamic> json) =
      _$PresensiDetailItemImpl.fromJson;

  @override
  int get pertemuanKe;
  @override
  PresensiStatus get status; // Gunakan enum
  @override
  @TimestampConverter()
  DateTime get tanggal;
  @override
  String? get materi;
  @override
  String? get keterangan;

  /// Create a copy of PresensiDetailItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PresensiDetailItemImplCopyWith<_$PresensiDetailItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
