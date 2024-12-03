// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'presensi_pertemuan.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PresensiPertemuan _$PresensiPertemuanFromJson(Map<String, dynamic> json) {
  return _PresensiPertemuan.fromJson(json);
}

/// @nodoc
mixin _$PresensiPertemuan {
  String get id => throw _privateConstructorUsedError;
  String get programId => throw _privateConstructorUsedError;
  int get pertemuanKe => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get tanggal => throw _privateConstructorUsedError;
  List<SantriPresensi> get daftarHadir => throw _privateConstructorUsedError;
  PresensiSummary get summary => throw _privateConstructorUsedError;
  String? get materi => throw _privateConstructorUsedError;
  String? get catatan => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this PresensiPertemuan to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PresensiPertemuan
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PresensiPertemuanCopyWith<PresensiPertemuan> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PresensiPertemuanCopyWith<$Res> {
  factory $PresensiPertemuanCopyWith(
          PresensiPertemuan value, $Res Function(PresensiPertemuan) then) =
      _$PresensiPertemuanCopyWithImpl<$Res, PresensiPertemuan>;
  @useResult
  $Res call(
      {String id,
      String programId,
      int pertemuanKe,
      @TimestampConverter() DateTime tanggal,
      List<SantriPresensi> daftarHadir,
      PresensiSummary summary,
      String? materi,
      String? catatan,
      @TimestampConverter() DateTime? createdAt,
      @TimestampConverter() DateTime? updatedAt});

  $PresensiSummaryCopyWith<$Res> get summary;
}

/// @nodoc
class _$PresensiPertemuanCopyWithImpl<$Res, $Val extends PresensiPertemuan>
    implements $PresensiPertemuanCopyWith<$Res> {
  _$PresensiPertemuanCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PresensiPertemuan
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? programId = null,
    Object? pertemuanKe = null,
    Object? tanggal = null,
    Object? daftarHadir = null,
    Object? summary = null,
    Object? materi = freezed,
    Object? catatan = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      programId: null == programId
          ? _value.programId
          : programId // ignore: cast_nullable_to_non_nullable
              as String,
      pertemuanKe: null == pertemuanKe
          ? _value.pertemuanKe
          : pertemuanKe // ignore: cast_nullable_to_non_nullable
              as int,
      tanggal: null == tanggal
          ? _value.tanggal
          : tanggal // ignore: cast_nullable_to_non_nullable
              as DateTime,
      daftarHadir: null == daftarHadir
          ? _value.daftarHadir
          : daftarHadir // ignore: cast_nullable_to_non_nullable
              as List<SantriPresensi>,
      summary: null == summary
          ? _value.summary
          : summary // ignore: cast_nullable_to_non_nullable
              as PresensiSummary,
      materi: freezed == materi
          ? _value.materi
          : materi // ignore: cast_nullable_to_non_nullable
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
    ) as $Val);
  }

  /// Create a copy of PresensiPertemuan
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PresensiSummaryCopyWith<$Res> get summary {
    return $PresensiSummaryCopyWith<$Res>(_value.summary, (value) {
      return _then(_value.copyWith(summary: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PresensiPertemuanImplCopyWith<$Res>
    implements $PresensiPertemuanCopyWith<$Res> {
  factory _$$PresensiPertemuanImplCopyWith(_$PresensiPertemuanImpl value,
          $Res Function(_$PresensiPertemuanImpl) then) =
      __$$PresensiPertemuanImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String programId,
      int pertemuanKe,
      @TimestampConverter() DateTime tanggal,
      List<SantriPresensi> daftarHadir,
      PresensiSummary summary,
      String? materi,
      String? catatan,
      @TimestampConverter() DateTime? createdAt,
      @TimestampConverter() DateTime? updatedAt});

  @override
  $PresensiSummaryCopyWith<$Res> get summary;
}

/// @nodoc
class __$$PresensiPertemuanImplCopyWithImpl<$Res>
    extends _$PresensiPertemuanCopyWithImpl<$Res, _$PresensiPertemuanImpl>
    implements _$$PresensiPertemuanImplCopyWith<$Res> {
  __$$PresensiPertemuanImplCopyWithImpl(_$PresensiPertemuanImpl _value,
      $Res Function(_$PresensiPertemuanImpl) _then)
      : super(_value, _then);

  /// Create a copy of PresensiPertemuan
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? programId = null,
    Object? pertemuanKe = null,
    Object? tanggal = null,
    Object? daftarHadir = null,
    Object? summary = null,
    Object? materi = freezed,
    Object? catatan = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$PresensiPertemuanImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      programId: null == programId
          ? _value.programId
          : programId // ignore: cast_nullable_to_non_nullable
              as String,
      pertemuanKe: null == pertemuanKe
          ? _value.pertemuanKe
          : pertemuanKe // ignore: cast_nullable_to_non_nullable
              as int,
      tanggal: null == tanggal
          ? _value.tanggal
          : tanggal // ignore: cast_nullable_to_non_nullable
              as DateTime,
      daftarHadir: null == daftarHadir
          ? _value._daftarHadir
          : daftarHadir // ignore: cast_nullable_to_non_nullable
              as List<SantriPresensi>,
      summary: null == summary
          ? _value.summary
          : summary // ignore: cast_nullable_to_non_nullable
              as PresensiSummary,
      materi: freezed == materi
          ? _value.materi
          : materi // ignore: cast_nullable_to_non_nullable
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
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PresensiPertemuanImpl implements _PresensiPertemuan {
  _$PresensiPertemuanImpl(
      {required this.id,
      required this.programId,
      required this.pertemuanKe,
      @TimestampConverter() required this.tanggal,
      required final List<SantriPresensi> daftarHadir,
      required this.summary,
      this.materi,
      this.catatan,
      @TimestampConverter() this.createdAt,
      @TimestampConverter() this.updatedAt})
      : _daftarHadir = daftarHadir;

  factory _$PresensiPertemuanImpl.fromJson(Map<String, dynamic> json) =>
      _$$PresensiPertemuanImplFromJson(json);

  @override
  final String id;
  @override
  final String programId;
  @override
  final int pertemuanKe;
  @override
  @TimestampConverter()
  final DateTime tanggal;
  final List<SantriPresensi> _daftarHadir;
  @override
  List<SantriPresensi> get daftarHadir {
    if (_daftarHadir is EqualUnmodifiableListView) return _daftarHadir;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_daftarHadir);
  }

  @override
  final PresensiSummary summary;
  @override
  final String? materi;
  @override
  final String? catatan;
  @override
  @TimestampConverter()
  final DateTime? createdAt;
  @override
  @TimestampConverter()
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'PresensiPertemuan(id: $id, programId: $programId, pertemuanKe: $pertemuanKe, tanggal: $tanggal, daftarHadir: $daftarHadir, summary: $summary, materi: $materi, catatan: $catatan, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PresensiPertemuanImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.programId, programId) ||
                other.programId == programId) &&
            (identical(other.pertemuanKe, pertemuanKe) ||
                other.pertemuanKe == pertemuanKe) &&
            (identical(other.tanggal, tanggal) || other.tanggal == tanggal) &&
            const DeepCollectionEquality()
                .equals(other._daftarHadir, _daftarHadir) &&
            (identical(other.summary, summary) || other.summary == summary) &&
            (identical(other.materi, materi) || other.materi == materi) &&
            (identical(other.catatan, catatan) || other.catatan == catatan) &&
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
      programId,
      pertemuanKe,
      tanggal,
      const DeepCollectionEquality().hash(_daftarHadir),
      summary,
      materi,
      catatan,
      createdAt,
      updatedAt);

  /// Create a copy of PresensiPertemuan
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PresensiPertemuanImplCopyWith<_$PresensiPertemuanImpl> get copyWith =>
      __$$PresensiPertemuanImplCopyWithImpl<_$PresensiPertemuanImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PresensiPertemuanImplToJson(
      this,
    );
  }
}

abstract class _PresensiPertemuan implements PresensiPertemuan {
  factory _PresensiPertemuan(
          {required final String id,
          required final String programId,
          required final int pertemuanKe,
          @TimestampConverter() required final DateTime tanggal,
          required final List<SantriPresensi> daftarHadir,
          required final PresensiSummary summary,
          final String? materi,
          final String? catatan,
          @TimestampConverter() final DateTime? createdAt,
          @TimestampConverter() final DateTime? updatedAt}) =
      _$PresensiPertemuanImpl;

  factory _PresensiPertemuan.fromJson(Map<String, dynamic> json) =
      _$PresensiPertemuanImpl.fromJson;

  @override
  String get id;
  @override
  String get programId;
  @override
  int get pertemuanKe;
  @override
  @TimestampConverter()
  DateTime get tanggal;
  @override
  List<SantriPresensi> get daftarHadir;
  @override
  PresensiSummary get summary;
  @override
  String? get materi;
  @override
  String? get catatan;
  @override
  @TimestampConverter()
  DateTime? get createdAt;
  @override
  @TimestampConverter()
  DateTime? get updatedAt;

  /// Create a copy of PresensiPertemuan
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PresensiPertemuanImplCopyWith<_$PresensiPertemuanImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
