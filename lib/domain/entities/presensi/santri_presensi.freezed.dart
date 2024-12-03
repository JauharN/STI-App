// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'santri_presensi.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SantriPresensi _$SantriPresensiFromJson(Map<String, dynamic> json) {
  return _SantriPresensi.fromJson(json);
}

/// @nodoc
mixin _$SantriPresensi {
  String get santriId => throw _privateConstructorUsedError;
  String get santriName => throw _privateConstructorUsedError; // Tambahkan ini
  PresensiStatus get status =>
      throw _privateConstructorUsedError; // Ubah ke enum
  String? get keterangan => throw _privateConstructorUsedError;

  /// Serializes this SantriPresensi to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SantriPresensi
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SantriPresensiCopyWith<SantriPresensi> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SantriPresensiCopyWith<$Res> {
  factory $SantriPresensiCopyWith(
          SantriPresensi value, $Res Function(SantriPresensi) then) =
      _$SantriPresensiCopyWithImpl<$Res, SantriPresensi>;
  @useResult
  $Res call(
      {String santriId,
      String santriName,
      PresensiStatus status,
      String? keterangan});
}

/// @nodoc
class _$SantriPresensiCopyWithImpl<$Res, $Val extends SantriPresensi>
    implements $SantriPresensiCopyWith<$Res> {
  _$SantriPresensiCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SantriPresensi
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? santriId = null,
    Object? santriName = null,
    Object? status = null,
    Object? keterangan = freezed,
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
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as PresensiStatus,
      keterangan: freezed == keterangan
          ? _value.keterangan
          : keterangan // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SantriPresensiImplCopyWith<$Res>
    implements $SantriPresensiCopyWith<$Res> {
  factory _$$SantriPresensiImplCopyWith(_$SantriPresensiImpl value,
          $Res Function(_$SantriPresensiImpl) then) =
      __$$SantriPresensiImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String santriId,
      String santriName,
      PresensiStatus status,
      String? keterangan});
}

/// @nodoc
class __$$SantriPresensiImplCopyWithImpl<$Res>
    extends _$SantriPresensiCopyWithImpl<$Res, _$SantriPresensiImpl>
    implements _$$SantriPresensiImplCopyWith<$Res> {
  __$$SantriPresensiImplCopyWithImpl(
      _$SantriPresensiImpl _value, $Res Function(_$SantriPresensiImpl) _then)
      : super(_value, _then);

  /// Create a copy of SantriPresensi
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? santriId = null,
    Object? santriName = null,
    Object? status = null,
    Object? keterangan = freezed,
  }) {
    return _then(_$SantriPresensiImpl(
      santriId: null == santriId
          ? _value.santriId
          : santriId // ignore: cast_nullable_to_non_nullable
              as String,
      santriName: null == santriName
          ? _value.santriName
          : santriName // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as PresensiStatus,
      keterangan: freezed == keterangan
          ? _value.keterangan
          : keterangan // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SantriPresensiImpl implements _SantriPresensi {
  _$SantriPresensiImpl(
      {required this.santriId,
      required this.santriName,
      required this.status,
      this.keterangan});

  factory _$SantriPresensiImpl.fromJson(Map<String, dynamic> json) =>
      _$$SantriPresensiImplFromJson(json);

  @override
  final String santriId;
  @override
  final String santriName;
// Tambahkan ini
  @override
  final PresensiStatus status;
// Ubah ke enum
  @override
  final String? keterangan;

  @override
  String toString() {
    return 'SantriPresensi(santriId: $santriId, santriName: $santriName, status: $status, keterangan: $keterangan)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SantriPresensiImpl &&
            (identical(other.santriId, santriId) ||
                other.santriId == santriId) &&
            (identical(other.santriName, santriName) ||
                other.santriName == santriName) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.keterangan, keterangan) ||
                other.keterangan == keterangan));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, santriId, santriName, status, keterangan);

  /// Create a copy of SantriPresensi
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SantriPresensiImplCopyWith<_$SantriPresensiImpl> get copyWith =>
      __$$SantriPresensiImplCopyWithImpl<_$SantriPresensiImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SantriPresensiImplToJson(
      this,
    );
  }
}

abstract class _SantriPresensi implements SantriPresensi {
  factory _SantriPresensi(
      {required final String santriId,
      required final String santriName,
      required final PresensiStatus status,
      final String? keterangan}) = _$SantriPresensiImpl;

  factory _SantriPresensi.fromJson(Map<String, dynamic> json) =
      _$SantriPresensiImpl.fromJson;

  @override
  String get santriId;
  @override
  String get santriName; // Tambahkan ini
  @override
  PresensiStatus get status; // Ubah ke enum
  @override
  String? get keterangan;

  /// Create a copy of SantriPresensi
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SantriPresensiImplCopyWith<_$SantriPresensiImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
