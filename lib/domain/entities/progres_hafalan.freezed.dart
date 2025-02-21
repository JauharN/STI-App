// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'progres_hafalan.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ProgresHafalan _$ProgresHafalanFromJson(Map<String, dynamic> json) {
  return _ProgresHafalan.fromJson(json);
}

/// @nodoc
mixin _$ProgresHafalan {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get programId =>
      throw _privateConstructorUsedError; // 'TAHFIDZ' atau 'GMM'
  @TimestampConverter()
  DateTime get tanggal => throw _privateConstructorUsedError; // Fields Tahfidz
  int? get juz => throw _privateConstructorUsedError;
  int? get halaman => throw _privateConstructorUsedError;
  int? get ayat => throw _privateConstructorUsedError;
  String? get surah => throw _privateConstructorUsedError;
  String? get statusPenilaian =>
      throw _privateConstructorUsedError; // Lancar/Belum/Perlu Perbaikan
// Fields GMM
  String? get iqroLevel => throw _privateConstructorUsedError; // Level 1-6
  int? get iqroHalaman => throw _privateConstructorUsedError;
  String? get statusIqro => throw _privateConstructorUsedError; // Lancar/Belum
  String? get mutabaahTarget => throw _privateConstructorUsedError;
  String? get statusMutabaah =>
      throw _privateConstructorUsedError; // Tercapai/Belum
  String? get catatan => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  String? get createdBy => throw _privateConstructorUsedError;
  String? get updatedBy => throw _privateConstructorUsedError;

  /// Serializes this ProgresHafalan to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProgresHafalan
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProgresHafalanCopyWith<ProgresHafalan> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProgresHafalanCopyWith<$Res> {
  factory $ProgresHafalanCopyWith(
          ProgresHafalan value, $Res Function(ProgresHafalan) then) =
      _$ProgresHafalanCopyWithImpl<$Res, ProgresHafalan>;
  @useResult
  $Res call(
      {String id,
      String userId,
      String programId,
      @TimestampConverter() DateTime tanggal,
      int? juz,
      int? halaman,
      int? ayat,
      String? surah,
      String? statusPenilaian,
      String? iqroLevel,
      int? iqroHalaman,
      String? statusIqro,
      String? mutabaahTarget,
      String? statusMutabaah,
      String? catatan,
      @TimestampConverter() DateTime? createdAt,
      @TimestampConverter() DateTime? updatedAt,
      String? createdBy,
      String? updatedBy});
}

/// @nodoc
class _$ProgresHafalanCopyWithImpl<$Res, $Val extends ProgresHafalan>
    implements $ProgresHafalanCopyWith<$Res> {
  _$ProgresHafalanCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProgresHafalan
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? programId = null,
    Object? tanggal = null,
    Object? juz = freezed,
    Object? halaman = freezed,
    Object? ayat = freezed,
    Object? surah = freezed,
    Object? statusPenilaian = freezed,
    Object? iqroLevel = freezed,
    Object? iqroHalaman = freezed,
    Object? statusIqro = freezed,
    Object? mutabaahTarget = freezed,
    Object? statusMutabaah = freezed,
    Object? catatan = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? createdBy = freezed,
    Object? updatedBy = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      programId: null == programId
          ? _value.programId
          : programId // ignore: cast_nullable_to_non_nullable
              as String,
      tanggal: null == tanggal
          ? _value.tanggal
          : tanggal // ignore: cast_nullable_to_non_nullable
              as DateTime,
      juz: freezed == juz
          ? _value.juz
          : juz // ignore: cast_nullable_to_non_nullable
              as int?,
      halaman: freezed == halaman
          ? _value.halaman
          : halaman // ignore: cast_nullable_to_non_nullable
              as int?,
      ayat: freezed == ayat
          ? _value.ayat
          : ayat // ignore: cast_nullable_to_non_nullable
              as int?,
      surah: freezed == surah
          ? _value.surah
          : surah // ignore: cast_nullable_to_non_nullable
              as String?,
      statusPenilaian: freezed == statusPenilaian
          ? _value.statusPenilaian
          : statusPenilaian // ignore: cast_nullable_to_non_nullable
              as String?,
      iqroLevel: freezed == iqroLevel
          ? _value.iqroLevel
          : iqroLevel // ignore: cast_nullable_to_non_nullable
              as String?,
      iqroHalaman: freezed == iqroHalaman
          ? _value.iqroHalaman
          : iqroHalaman // ignore: cast_nullable_to_non_nullable
              as int?,
      statusIqro: freezed == statusIqro
          ? _value.statusIqro
          : statusIqro // ignore: cast_nullable_to_non_nullable
              as String?,
      mutabaahTarget: freezed == mutabaahTarget
          ? _value.mutabaahTarget
          : mutabaahTarget // ignore: cast_nullable_to_non_nullable
              as String?,
      statusMutabaah: freezed == statusMutabaah
          ? _value.statusMutabaah
          : statusMutabaah // ignore: cast_nullable_to_non_nullable
              as String?,
      catatan: freezed == catatan
          ? _value.catatan
          : catatan // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdBy: freezed == createdBy
          ? _value.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
              as String?,
      updatedBy: freezed == updatedBy
          ? _value.updatedBy
          : updatedBy // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ProgresHafalanImplCopyWith<$Res>
    implements $ProgresHafalanCopyWith<$Res> {
  factory _$$ProgresHafalanImplCopyWith(_$ProgresHafalanImpl value,
          $Res Function(_$ProgresHafalanImpl) then) =
      __$$ProgresHafalanImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String programId,
      @TimestampConverter() DateTime tanggal,
      int? juz,
      int? halaman,
      int? ayat,
      String? surah,
      String? statusPenilaian,
      String? iqroLevel,
      int? iqroHalaman,
      String? statusIqro,
      String? mutabaahTarget,
      String? statusMutabaah,
      String? catatan,
      @TimestampConverter() DateTime? createdAt,
      @TimestampConverter() DateTime? updatedAt,
      String? createdBy,
      String? updatedBy});
}

/// @nodoc
class __$$ProgresHafalanImplCopyWithImpl<$Res>
    extends _$ProgresHafalanCopyWithImpl<$Res, _$ProgresHafalanImpl>
    implements _$$ProgresHafalanImplCopyWith<$Res> {
  __$$ProgresHafalanImplCopyWithImpl(
      _$ProgresHafalanImpl _value, $Res Function(_$ProgresHafalanImpl) _then)
      : super(_value, _then);

  /// Create a copy of ProgresHafalan
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? programId = null,
    Object? tanggal = null,
    Object? juz = freezed,
    Object? halaman = freezed,
    Object? ayat = freezed,
    Object? surah = freezed,
    Object? statusPenilaian = freezed,
    Object? iqroLevel = freezed,
    Object? iqroHalaman = freezed,
    Object? statusIqro = freezed,
    Object? mutabaahTarget = freezed,
    Object? statusMutabaah = freezed,
    Object? catatan = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? createdBy = freezed,
    Object? updatedBy = freezed,
  }) {
    return _then(_$ProgresHafalanImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      programId: null == programId
          ? _value.programId
          : programId // ignore: cast_nullable_to_non_nullable
              as String,
      tanggal: null == tanggal
          ? _value.tanggal
          : tanggal // ignore: cast_nullable_to_non_nullable
              as DateTime,
      juz: freezed == juz
          ? _value.juz
          : juz // ignore: cast_nullable_to_non_nullable
              as int?,
      halaman: freezed == halaman
          ? _value.halaman
          : halaman // ignore: cast_nullable_to_non_nullable
              as int?,
      ayat: freezed == ayat
          ? _value.ayat
          : ayat // ignore: cast_nullable_to_non_nullable
              as int?,
      surah: freezed == surah
          ? _value.surah
          : surah // ignore: cast_nullable_to_non_nullable
              as String?,
      statusPenilaian: freezed == statusPenilaian
          ? _value.statusPenilaian
          : statusPenilaian // ignore: cast_nullable_to_non_nullable
              as String?,
      iqroLevel: freezed == iqroLevel
          ? _value.iqroLevel
          : iqroLevel // ignore: cast_nullable_to_non_nullable
              as String?,
      iqroHalaman: freezed == iqroHalaman
          ? _value.iqroHalaman
          : iqroHalaman // ignore: cast_nullable_to_non_nullable
              as int?,
      statusIqro: freezed == statusIqro
          ? _value.statusIqro
          : statusIqro // ignore: cast_nullable_to_non_nullable
              as String?,
      mutabaahTarget: freezed == mutabaahTarget
          ? _value.mutabaahTarget
          : mutabaahTarget // ignore: cast_nullable_to_non_nullable
              as String?,
      statusMutabaah: freezed == statusMutabaah
          ? _value.statusMutabaah
          : statusMutabaah // ignore: cast_nullable_to_non_nullable
              as String?,
      catatan: freezed == catatan
          ? _value.catatan
          : catatan // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdBy: freezed == createdBy
          ? _value.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
              as String?,
      updatedBy: freezed == updatedBy
          ? _value.updatedBy
          : updatedBy // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ProgresHafalanImpl implements _ProgresHafalan {
  _$ProgresHafalanImpl(
      {required this.id,
      required this.userId,
      required this.programId,
      @TimestampConverter() required this.tanggal,
      this.juz,
      this.halaman,
      this.ayat,
      this.surah,
      this.statusPenilaian,
      this.iqroLevel,
      this.iqroHalaman,
      this.statusIqro,
      this.mutabaahTarget,
      this.statusMutabaah,
      this.catatan,
      @TimestampConverter() this.createdAt,
      @TimestampConverter() this.updatedAt,
      this.createdBy,
      this.updatedBy});

  factory _$ProgresHafalanImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProgresHafalanImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String programId;
// 'TAHFIDZ' atau 'GMM'
  @override
  @TimestampConverter()
  final DateTime tanggal;
// Fields Tahfidz
  @override
  final int? juz;
  @override
  final int? halaman;
  @override
  final int? ayat;
  @override
  final String? surah;
  @override
  final String? statusPenilaian;
// Lancar/Belum/Perlu Perbaikan
// Fields GMM
  @override
  final String? iqroLevel;
// Level 1-6
  @override
  final int? iqroHalaman;
  @override
  final String? statusIqro;
// Lancar/Belum
  @override
  final String? mutabaahTarget;
  @override
  final String? statusMutabaah;
// Tercapai/Belum
  @override
  final String? catatan;
  @override
  @TimestampConverter()
  final DateTime? createdAt;
  @override
  @TimestampConverter()
  final DateTime? updatedAt;
  @override
  final String? createdBy;
  @override
  final String? updatedBy;

  @override
  String toString() {
    return 'ProgresHafalan(id: $id, userId: $userId, programId: $programId, tanggal: $tanggal, juz: $juz, halaman: $halaman, ayat: $ayat, surah: $surah, statusPenilaian: $statusPenilaian, iqroLevel: $iqroLevel, iqroHalaman: $iqroHalaman, statusIqro: $statusIqro, mutabaahTarget: $mutabaahTarget, statusMutabaah: $statusMutabaah, catatan: $catatan, createdAt: $createdAt, updatedAt: $updatedAt, createdBy: $createdBy, updatedBy: $updatedBy)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProgresHafalanImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.programId, programId) ||
                other.programId == programId) &&
            (identical(other.tanggal, tanggal) || other.tanggal == tanggal) &&
            (identical(other.juz, juz) || other.juz == juz) &&
            (identical(other.halaman, halaman) || other.halaman == halaman) &&
            (identical(other.ayat, ayat) || other.ayat == ayat) &&
            (identical(other.surah, surah) || other.surah == surah) &&
            (identical(other.statusPenilaian, statusPenilaian) ||
                other.statusPenilaian == statusPenilaian) &&
            (identical(other.iqroLevel, iqroLevel) ||
                other.iqroLevel == iqroLevel) &&
            (identical(other.iqroHalaman, iqroHalaman) ||
                other.iqroHalaman == iqroHalaman) &&
            (identical(other.statusIqro, statusIqro) ||
                other.statusIqro == statusIqro) &&
            (identical(other.mutabaahTarget, mutabaahTarget) ||
                other.mutabaahTarget == mutabaahTarget) &&
            (identical(other.statusMutabaah, statusMutabaah) ||
                other.statusMutabaah == statusMutabaah) &&
            (identical(other.catatan, catatan) || other.catatan == catatan) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            (identical(other.updatedBy, updatedBy) ||
                other.updatedBy == updatedBy));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        userId,
        programId,
        tanggal,
        juz,
        halaman,
        ayat,
        surah,
        statusPenilaian,
        iqroLevel,
        iqroHalaman,
        statusIqro,
        mutabaahTarget,
        statusMutabaah,
        catatan,
        createdAt,
        updatedAt,
        createdBy,
        updatedBy
      ]);

  /// Create a copy of ProgresHafalan
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProgresHafalanImplCopyWith<_$ProgresHafalanImpl> get copyWith =>
      __$$ProgresHafalanImplCopyWithImpl<_$ProgresHafalanImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProgresHafalanImplToJson(
      this,
    );
  }
}

abstract class _ProgresHafalan implements ProgresHafalan {
  factory _ProgresHafalan(
      {required final String id,
      required final String userId,
      required final String programId,
      @TimestampConverter() required final DateTime tanggal,
      final int? juz,
      final int? halaman,
      final int? ayat,
      final String? surah,
      final String? statusPenilaian,
      final String? iqroLevel,
      final int? iqroHalaman,
      final String? statusIqro,
      final String? mutabaahTarget,
      final String? statusMutabaah,
      final String? catatan,
      @TimestampConverter() final DateTime? createdAt,
      @TimestampConverter() final DateTime? updatedAt,
      final String? createdBy,
      final String? updatedBy}) = _$ProgresHafalanImpl;

  factory _ProgresHafalan.fromJson(Map<String, dynamic> json) =
      _$ProgresHafalanImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get programId; // 'TAHFIDZ' atau 'GMM'
  @override
  @TimestampConverter()
  DateTime get tanggal; // Fields Tahfidz
  @override
  int? get juz;
  @override
  int? get halaman;
  @override
  int? get ayat;
  @override
  String? get surah;
  @override
  String? get statusPenilaian; // Lancar/Belum/Perlu Perbaikan
// Fields GMM
  @override
  String? get iqroLevel; // Level 1-6
  @override
  int? get iqroHalaman;
  @override
  String? get statusIqro; // Lancar/Belum
  @override
  String? get mutabaahTarget;
  @override
  String? get statusMutabaah; // Tercapai/Belum
  @override
  String? get catatan;
  @override
  @TimestampConverter()
  DateTime? get createdAt;
  @override
  @TimestampConverter()
  DateTime? get updatedAt;
  @override
  String? get createdBy;
  @override
  String? get updatedBy;

  /// Create a copy of ProgresHafalan
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProgresHafalanImplCopyWith<_$ProgresHafalanImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
