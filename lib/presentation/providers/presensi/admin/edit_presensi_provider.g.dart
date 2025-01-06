// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'edit_presensi_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$editPresensiDataHash() => r'b10598b62c6a85452b695a76a288b5530e0f8783';

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

/// See also [editPresensiData].
@ProviderFor(editPresensiData)
const editPresensiDataProvider = EditPresensiDataFamily();

/// See also [editPresensiData].
class EditPresensiDataFamily extends Family<AsyncValue<PresensiPertemuan>> {
  /// See also [editPresensiData].
  const EditPresensiDataFamily();

  /// See also [editPresensiData].
  EditPresensiDataProvider call(
    String programId,
    String presensiId,
  ) {
    return EditPresensiDataProvider(
      programId,
      presensiId,
    );
  }

  @override
  EditPresensiDataProvider getProviderOverride(
    covariant EditPresensiDataProvider provider,
  ) {
    return call(
      provider.programId,
      provider.presensiId,
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
  String? get name => r'editPresensiDataProvider';
}

/// See also [editPresensiData].
class EditPresensiDataProvider
    extends AutoDisposeFutureProvider<PresensiPertemuan> {
  /// See also [editPresensiData].
  EditPresensiDataProvider(
    String programId,
    String presensiId,
  ) : this._internal(
          (ref) => editPresensiData(
            ref as EditPresensiDataRef,
            programId,
            presensiId,
          ),
          from: editPresensiDataProvider,
          name: r'editPresensiDataProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$editPresensiDataHash,
          dependencies: EditPresensiDataFamily._dependencies,
          allTransitiveDependencies:
              EditPresensiDataFamily._allTransitiveDependencies,
          programId: programId,
          presensiId: presensiId,
        );

  EditPresensiDataProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.programId,
    required this.presensiId,
  }) : super.internal();

  final String programId;
  final String presensiId;

  @override
  Override overrideWith(
    FutureOr<PresensiPertemuan> Function(EditPresensiDataRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: EditPresensiDataProvider._internal(
        (ref) => create(ref as EditPresensiDataRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        programId: programId,
        presensiId: presensiId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<PresensiPertemuan> createElement() {
    return _EditPresensiDataProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is EditPresensiDataProvider &&
        other.programId == programId &&
        other.presensiId == presensiId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, programId.hashCode);
    hash = _SystemHash.combine(hash, presensiId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin EditPresensiDataRef on AutoDisposeFutureProviderRef<PresensiPertemuan> {
  /// The parameter `programId` of this provider.
  String get programId;

  /// The parameter `presensiId` of this provider.
  String get presensiId;
}

class _EditPresensiDataProviderElement
    extends AutoDisposeFutureProviderElement<PresensiPertemuan>
    with EditPresensiDataRef {
  _EditPresensiDataProviderElement(super.provider);

  @override
  String get programId => (origin as EditPresensiDataProvider).programId;
  @override
  String get presensiId => (origin as EditPresensiDataProvider).presensiId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
