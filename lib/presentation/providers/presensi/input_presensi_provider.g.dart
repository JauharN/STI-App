// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'input_presensi_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$isValidPresensiInputHash() =>
    r'f75b1e1e1e902b25837752ae66ca544d9a4d0137';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [isValidPresensiInput].
@ProviderFor(isValidPresensiInput)
const isValidPresensiInputProvider = IsValidPresensiInputFamily();

/// See also [isValidPresensiInput].
class IsValidPresensiInputFamily extends Family<bool> {
  /// See also [isValidPresensiInput].
  const IsValidPresensiInputFamily();

  /// See also [isValidPresensiInput].
  IsValidPresensiInputProvider call({
    required String programId,
    required int pertemuanKe,
    required String materi,
    required List<SantriPresensi> daftarHadir,
  }) {
    return IsValidPresensiInputProvider(
      programId: programId,
      pertemuanKe: pertemuanKe,
      materi: materi,
      daftarHadir: daftarHadir,
    );
  }

  @override
  IsValidPresensiInputProvider getProviderOverride(
    covariant IsValidPresensiInputProvider provider,
  ) {
    return call(
      programId: provider.programId,
      pertemuanKe: provider.pertemuanKe,
      materi: provider.materi,
      daftarHadir: provider.daftarHadir,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'isValidPresensiInputProvider';
}

/// See also [isValidPresensiInput].
class IsValidPresensiInputProvider extends AutoDisposeProvider<bool> {
  /// See also [isValidPresensiInput].
  IsValidPresensiInputProvider({
    required String programId,
    required int pertemuanKe,
    required String materi,
    required List<SantriPresensi> daftarHadir,
  }) : this._internal(
          (ref) => isValidPresensiInput(
            ref as IsValidPresensiInputRef,
            programId: programId,
            pertemuanKe: pertemuanKe,
            materi: materi,
            daftarHadir: daftarHadir,
          ),
          from: isValidPresensiInputProvider,
          name: r'isValidPresensiInputProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$isValidPresensiInputHash,
          dependencies: IsValidPresensiInputFamily._dependencies,
          allTransitiveDependencies:
              IsValidPresensiInputFamily._allTransitiveDependencies,
          programId: programId,
          pertemuanKe: pertemuanKe,
          materi: materi,
          daftarHadir: daftarHadir,
        );

  IsValidPresensiInputProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.programId,
    required this.pertemuanKe,
    required this.materi,
    required this.daftarHadir,
  }) : super.internal();

  final String programId;
  final int pertemuanKe;
  final String materi;
  final List<SantriPresensi> daftarHadir;

  @override
  Override overrideWith(
    bool Function(IsValidPresensiInputRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: IsValidPresensiInputProvider._internal(
        (ref) => create(ref as IsValidPresensiInputRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        programId: programId,
        pertemuanKe: pertemuanKe,
        materi: materi,
        daftarHadir: daftarHadir,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<bool> createElement() {
    return _IsValidPresensiInputProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is IsValidPresensiInputProvider &&
        other.programId == programId &&
        other.pertemuanKe == pertemuanKe &&
        other.materi == materi &&
        other.daftarHadir == daftarHadir;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, programId.hashCode);
    hash = _SystemHash.combine(hash, pertemuanKe.hashCode);
    hash = _SystemHash.combine(hash, materi.hashCode);
    hash = _SystemHash.combine(hash, daftarHadir.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin IsValidPresensiInputRef on AutoDisposeProviderRef<bool> {
  /// The parameter `programId` of this provider.
  String get programId;

  /// The parameter `pertemuanKe` of this provider.
  int get pertemuanKe;

  /// The parameter `materi` of this provider.
  String get materi;

  /// The parameter `daftarHadir` of this provider.
  List<SantriPresensi> get daftarHadir;
}

class _IsValidPresensiInputProviderElement
    extends AutoDisposeProviderElement<bool> with IsValidPresensiInputRef {
  _IsValidPresensiInputProviderElement(super.provider);

  @override
  String get programId => (origin as IsValidPresensiInputProvider).programId;
  @override
  int get pertemuanKe => (origin as IsValidPresensiInputProvider).pertemuanKe;
  @override
  String get materi => (origin as IsValidPresensiInputProvider).materi;
  @override
  List<SantriPresensi> get daftarHadir =>
      (origin as IsValidPresensiInputProvider).daftarHadir;
}

String _$inputPresensiControllerHash() =>
    r'99dc95b6d1fa25c28dd3650765acdc3f3a12bcd1';

/// See also [InputPresensiController].
@ProviderFor(InputPresensiController)
final inputPresensiControllerProvider =
    AutoDisposeAsyncNotifierProvider<InputPresensiController, void>.internal(
  InputPresensiController.new,
  name: r'inputPresensiControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$inputPresensiControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$InputPresensiController = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
