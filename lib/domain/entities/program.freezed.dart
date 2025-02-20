// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'program.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Program _$ProgramFromJson(Map<String, dynamic> json) {
  return _Program.fromJson(json);
}

/// @nodoc
mixin _$Program {
  String get id => throw _privateConstructorUsedError;
  String get nama => throw _privateConstructorUsedError;
  String get deskripsi => throw _privateConstructorUsedError;
  List<String> get jadwal => throw _privateConstructorUsedError;
  String? get lokasi => throw _privateConstructorUsedError;
  List<String> get pengajarIds => throw _privateConstructorUsedError;
  List<String> get pengajarNames => throw _privateConstructorUsedError;
  String? get kelas => throw _privateConstructorUsedError;
  int? get totalPertemuan => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  List<String> get enrolledSantriIds => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;

  /// Serializes this Program to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Program
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProgramCopyWith<Program> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProgramCopyWith<$Res> {
  factory $ProgramCopyWith(Program value, $Res Function(Program) then) =
      _$ProgramCopyWithImpl<$Res, Program>;
  @useResult
  $Res call(
      {String id,
      String nama,
      String deskripsi,
      List<String> jadwal,
      String? lokasi,
      List<String> pengajarIds,
      List<String> pengajarNames,
      String? kelas,
      int? totalPertemuan,
      @TimestampConverter() DateTime? createdAt,
      @TimestampConverter() DateTime? updatedAt,
      List<String> enrolledSantriIds,
      bool isActive});
}

/// @nodoc
class _$ProgramCopyWithImpl<$Res, $Val extends Program>
    implements $ProgramCopyWith<$Res> {
  _$ProgramCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Program
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nama = null,
    Object? deskripsi = null,
    Object? jadwal = null,
    Object? lokasi = freezed,
    Object? pengajarIds = null,
    Object? pengajarNames = null,
    Object? kelas = freezed,
    Object? totalPertemuan = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? enrolledSantriIds = null,
    Object? isActive = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      nama: null == nama
          ? _value.nama
          : nama // ignore: cast_nullable_to_non_nullable
              as String,
      deskripsi: null == deskripsi
          ? _value.deskripsi
          : deskripsi // ignore: cast_nullable_to_non_nullable
              as String,
      jadwal: null == jadwal
          ? _value.jadwal
          : jadwal // ignore: cast_nullable_to_non_nullable
              as List<String>,
      lokasi: freezed == lokasi
          ? _value.lokasi
          : lokasi // ignore: cast_nullable_to_non_nullable
              as String?,
      pengajarIds: null == pengajarIds
          ? _value.pengajarIds
          : pengajarIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      pengajarNames: null == pengajarNames
          ? _value.pengajarNames
          : pengajarNames // ignore: cast_nullable_to_non_nullable
              as List<String>,
      kelas: freezed == kelas
          ? _value.kelas
          : kelas // ignore: cast_nullable_to_non_nullable
              as String?,
      totalPertemuan: freezed == totalPertemuan
          ? _value.totalPertemuan
          : totalPertemuan // ignore: cast_nullable_to_non_nullable
              as int?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      enrolledSantriIds: null == enrolledSantriIds
          ? _value.enrolledSantriIds
          : enrolledSantriIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ProgramImplCopyWith<$Res> implements $ProgramCopyWith<$Res> {
  factory _$$ProgramImplCopyWith(
          _$ProgramImpl value, $Res Function(_$ProgramImpl) then) =
      __$$ProgramImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String nama,
      String deskripsi,
      List<String> jadwal,
      String? lokasi,
      List<String> pengajarIds,
      List<String> pengajarNames,
      String? kelas,
      int? totalPertemuan,
      @TimestampConverter() DateTime? createdAt,
      @TimestampConverter() DateTime? updatedAt,
      List<String> enrolledSantriIds,
      bool isActive});
}

/// @nodoc
class __$$ProgramImplCopyWithImpl<$Res>
    extends _$ProgramCopyWithImpl<$Res, _$ProgramImpl>
    implements _$$ProgramImplCopyWith<$Res> {
  __$$ProgramImplCopyWithImpl(
      _$ProgramImpl _value, $Res Function(_$ProgramImpl) _then)
      : super(_value, _then);

  /// Create a copy of Program
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nama = null,
    Object? deskripsi = null,
    Object? jadwal = null,
    Object? lokasi = freezed,
    Object? pengajarIds = null,
    Object? pengajarNames = null,
    Object? kelas = freezed,
    Object? totalPertemuan = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? enrolledSantriIds = null,
    Object? isActive = null,
  }) {
    return _then(_$ProgramImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      nama: null == nama
          ? _value.nama
          : nama // ignore: cast_nullable_to_non_nullable
              as String,
      deskripsi: null == deskripsi
          ? _value.deskripsi
          : deskripsi // ignore: cast_nullable_to_non_nullable
              as String,
      jadwal: null == jadwal
          ? _value._jadwal
          : jadwal // ignore: cast_nullable_to_non_nullable
              as List<String>,
      lokasi: freezed == lokasi
          ? _value.lokasi
          : lokasi // ignore: cast_nullable_to_non_nullable
              as String?,
      pengajarIds: null == pengajarIds
          ? _value._pengajarIds
          : pengajarIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      pengajarNames: null == pengajarNames
          ? _value._pengajarNames
          : pengajarNames // ignore: cast_nullable_to_non_nullable
              as List<String>,
      kelas: freezed == kelas
          ? _value.kelas
          : kelas // ignore: cast_nullable_to_non_nullable
              as String?,
      totalPertemuan: freezed == totalPertemuan
          ? _value.totalPertemuan
          : totalPertemuan // ignore: cast_nullable_to_non_nullable
              as int?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      enrolledSantriIds: null == enrolledSantriIds
          ? _value._enrolledSantriIds
          : enrolledSantriIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ProgramImpl extends _Program {
  _$ProgramImpl(
      {required this.id,
      required this.nama,
      required this.deskripsi,
      required final List<String> jadwal,
      this.lokasi,
      final List<String> pengajarIds = const [],
      final List<String> pengajarNames = const [],
      this.kelas,
      this.totalPertemuan,
      @TimestampConverter() this.createdAt,
      @TimestampConverter() this.updatedAt,
      final List<String> enrolledSantriIds = const [],
      this.isActive = true})
      : _jadwal = jadwal,
        _pengajarIds = pengajarIds,
        _pengajarNames = pengajarNames,
        _enrolledSantriIds = enrolledSantriIds,
        super._();

  factory _$ProgramImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProgramImplFromJson(json);

  @override
  final String id;
  @override
  final String nama;
  @override
  final String deskripsi;
  final List<String> _jadwal;
  @override
  List<String> get jadwal {
    if (_jadwal is EqualUnmodifiableListView) return _jadwal;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_jadwal);
  }

  @override
  final String? lokasi;
  final List<String> _pengajarIds;
  @override
  @JsonKey()
  List<String> get pengajarIds {
    if (_pengajarIds is EqualUnmodifiableListView) return _pengajarIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_pengajarIds);
  }

  final List<String> _pengajarNames;
  @override
  @JsonKey()
  List<String> get pengajarNames {
    if (_pengajarNames is EqualUnmodifiableListView) return _pengajarNames;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_pengajarNames);
  }

  @override
  final String? kelas;
  @override
  final int? totalPertemuan;
  @override
  @TimestampConverter()
  final DateTime? createdAt;
  @override
  @TimestampConverter()
  final DateTime? updatedAt;
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
  final bool isActive;

  @override
  String toString() {
    return 'Program(id: $id, nama: $nama, deskripsi: $deskripsi, jadwal: $jadwal, lokasi: $lokasi, pengajarIds: $pengajarIds, pengajarNames: $pengajarNames, kelas: $kelas, totalPertemuan: $totalPertemuan, createdAt: $createdAt, updatedAt: $updatedAt, enrolledSantriIds: $enrolledSantriIds, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProgramImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.nama, nama) || other.nama == nama) &&
            (identical(other.deskripsi, deskripsi) ||
                other.deskripsi == deskripsi) &&
            const DeepCollectionEquality().equals(other._jadwal, _jadwal) &&
            (identical(other.lokasi, lokasi) || other.lokasi == lokasi) &&
            const DeepCollectionEquality()
                .equals(other._pengajarIds, _pengajarIds) &&
            const DeepCollectionEquality()
                .equals(other._pengajarNames, _pengajarNames) &&
            (identical(other.kelas, kelas) || other.kelas == kelas) &&
            (identical(other.totalPertemuan, totalPertemuan) ||
                other.totalPertemuan == totalPertemuan) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            const DeepCollectionEquality()
                .equals(other._enrolledSantriIds, _enrolledSantriIds) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      nama,
      deskripsi,
      const DeepCollectionEquality().hash(_jadwal),
      lokasi,
      const DeepCollectionEquality().hash(_pengajarIds),
      const DeepCollectionEquality().hash(_pengajarNames),
      kelas,
      totalPertemuan,
      createdAt,
      updatedAt,
      const DeepCollectionEquality().hash(_enrolledSantriIds),
      isActive);

  /// Create a copy of Program
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProgramImplCopyWith<_$ProgramImpl> get copyWith =>
      __$$ProgramImplCopyWithImpl<_$ProgramImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProgramImplToJson(
      this,
    );
  }
}

abstract class _Program extends Program {
  factory _Program(
      {required final String id,
      required final String nama,
      required final String deskripsi,
      required final List<String> jadwal,
      final String? lokasi,
      final List<String> pengajarIds,
      final List<String> pengajarNames,
      final String? kelas,
      final int? totalPertemuan,
      @TimestampConverter() final DateTime? createdAt,
      @TimestampConverter() final DateTime? updatedAt,
      final List<String> enrolledSantriIds,
      final bool isActive}) = _$ProgramImpl;
  _Program._() : super._();

  factory _Program.fromJson(Map<String, dynamic> json) = _$ProgramImpl.fromJson;

  @override
  String get id;
  @override
  String get nama;
  @override
  String get deskripsi;
  @override
  List<String> get jadwal;
  @override
  String? get lokasi;
  @override
  List<String> get pengajarIds;
  @override
  List<String> get pengajarNames;
  @override
  String? get kelas;
  @override
  int? get totalPertemuan;
  @override
  @TimestampConverter()
  DateTime? get createdAt;
  @override
  @TimestampConverter()
  DateTime? get updatedAt;
  @override
  List<String> get enrolledSantriIds;
  @override
  bool get isActive;

  /// Create a copy of Program
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProgramImplCopyWith<_$ProgramImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
