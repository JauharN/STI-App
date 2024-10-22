// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sesi.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Sesi _$SesiFromJson(Map<String, dynamic> json) {
  return _Sesi.fromJson(json);
}

/// @nodoc
mixin _$Sesi {
  String get id => throw _privateConstructorUsedError;
  String get programId => throw _privateConstructorUsedError;
  DateTime get waktuMulai => throw _privateConstructorUsedError;
  DateTime get waktuSelesai => throw _privateConstructorUsedError;
  String get pengajarId => throw _privateConstructorUsedError;
  String? get materi => throw _privateConstructorUsedError;
  String? get catatan => throw _privateConstructorUsedError;

  /// Serializes this Sesi to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Sesi
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SesiCopyWith<Sesi> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SesiCopyWith<$Res> {
  factory $SesiCopyWith(Sesi value, $Res Function(Sesi) then) =
      _$SesiCopyWithImpl<$Res, Sesi>;
  @useResult
  $Res call(
      {String id,
      String programId,
      DateTime waktuMulai,
      DateTime waktuSelesai,
      String pengajarId,
      String? materi,
      String? catatan});
}

/// @nodoc
class _$SesiCopyWithImpl<$Res, $Val extends Sesi>
    implements $SesiCopyWith<$Res> {
  _$SesiCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Sesi
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? programId = null,
    Object? waktuMulai = null,
    Object? waktuSelesai = null,
    Object? pengajarId = null,
    Object? materi = freezed,
    Object? catatan = freezed,
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
      waktuMulai: null == waktuMulai
          ? _value.waktuMulai
          : waktuMulai // ignore: cast_nullable_to_non_nullable
              as DateTime,
      waktuSelesai: null == waktuSelesai
          ? _value.waktuSelesai
          : waktuSelesai // ignore: cast_nullable_to_non_nullable
              as DateTime,
      pengajarId: null == pengajarId
          ? _value.pengajarId
          : pengajarId // ignore: cast_nullable_to_non_nullable
              as String,
      materi: freezed == materi
          ? _value.materi
          : materi // ignore: cast_nullable_to_non_nullable
              as String?,
      catatan: freezed == catatan
          ? _value.catatan
          : catatan // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SesiImplCopyWith<$Res> implements $SesiCopyWith<$Res> {
  factory _$$SesiImplCopyWith(
          _$SesiImpl value, $Res Function(_$SesiImpl) then) =
      __$$SesiImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String programId,
      DateTime waktuMulai,
      DateTime waktuSelesai,
      String pengajarId,
      String? materi,
      String? catatan});
}

/// @nodoc
class __$$SesiImplCopyWithImpl<$Res>
    extends _$SesiCopyWithImpl<$Res, _$SesiImpl>
    implements _$$SesiImplCopyWith<$Res> {
  __$$SesiImplCopyWithImpl(_$SesiImpl _value, $Res Function(_$SesiImpl) _then)
      : super(_value, _then);

  /// Create a copy of Sesi
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? programId = null,
    Object? waktuMulai = null,
    Object? waktuSelesai = null,
    Object? pengajarId = null,
    Object? materi = freezed,
    Object? catatan = freezed,
  }) {
    return _then(_$SesiImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      programId: null == programId
          ? _value.programId
          : programId // ignore: cast_nullable_to_non_nullable
              as String,
      waktuMulai: null == waktuMulai
          ? _value.waktuMulai
          : waktuMulai // ignore: cast_nullable_to_non_nullable
              as DateTime,
      waktuSelesai: null == waktuSelesai
          ? _value.waktuSelesai
          : waktuSelesai // ignore: cast_nullable_to_non_nullable
              as DateTime,
      pengajarId: null == pengajarId
          ? _value.pengajarId
          : pengajarId // ignore: cast_nullable_to_non_nullable
              as String,
      materi: freezed == materi
          ? _value.materi
          : materi // ignore: cast_nullable_to_non_nullable
              as String?,
      catatan: freezed == catatan
          ? _value.catatan
          : catatan // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SesiImpl implements _Sesi {
  _$SesiImpl(
      {required this.id,
      required this.programId,
      required this.waktuMulai,
      required this.waktuSelesai,
      required this.pengajarId,
      this.materi,
      this.catatan});

  factory _$SesiImpl.fromJson(Map<String, dynamic> json) =>
      _$$SesiImplFromJson(json);

  @override
  final String id;
  @override
  final String programId;
  @override
  final DateTime waktuMulai;
  @override
  final DateTime waktuSelesai;
  @override
  final String pengajarId;
  @override
  final String? materi;
  @override
  final String? catatan;

  @override
  String toString() {
    return 'Sesi(id: $id, programId: $programId, waktuMulai: $waktuMulai, waktuSelesai: $waktuSelesai, pengajarId: $pengajarId, materi: $materi, catatan: $catatan)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SesiImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.programId, programId) ||
                other.programId == programId) &&
            (identical(other.waktuMulai, waktuMulai) ||
                other.waktuMulai == waktuMulai) &&
            (identical(other.waktuSelesai, waktuSelesai) ||
                other.waktuSelesai == waktuSelesai) &&
            (identical(other.pengajarId, pengajarId) ||
                other.pengajarId == pengajarId) &&
            (identical(other.materi, materi) || other.materi == materi) &&
            (identical(other.catatan, catatan) || other.catatan == catatan));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, programId, waktuMulai,
      waktuSelesai, pengajarId, materi, catatan);

  /// Create a copy of Sesi
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SesiImplCopyWith<_$SesiImpl> get copyWith =>
      __$$SesiImplCopyWithImpl<_$SesiImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SesiImplToJson(
      this,
    );
  }
}

abstract class _Sesi implements Sesi {
  factory _Sesi(
      {required final String id,
      required final String programId,
      required final DateTime waktuMulai,
      required final DateTime waktuSelesai,
      required final String pengajarId,
      final String? materi,
      final String? catatan}) = _$SesiImpl;

  factory _Sesi.fromJson(Map<String, dynamic> json) = _$SesiImpl.fromJson;

  @override
  String get id;
  @override
  String get programId;
  @override
  DateTime get waktuMulai;
  @override
  DateTime get waktuSelesai;
  @override
  String get pengajarId;
  @override
  String? get materi;
  @override
  String? get catatan;

  /// Create a copy of Sesi
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SesiImplCopyWith<_$SesiImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
