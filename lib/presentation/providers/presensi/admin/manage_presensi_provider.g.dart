// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manage_presensi_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$managePresensiStateHash() =>
    r'4a03b58138977ba026d6794c52570e2ba0b2d3d8';

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

abstract class _$ManagePresensiState
    extends BuildlessAutoDisposeAsyncNotifier<List<PresensiPertemuan>> {
  late final String programId;

  FutureOr<List<PresensiPertemuan>> build(
    String programId,
  );
}

/// See also [ManagePresensiState].
@ProviderFor(ManagePresensiState)
const managePresensiStateProvider = ManagePresensiStateFamily();

/// See also [ManagePresensiState].
class ManagePresensiStateFamily
    extends Family<AsyncValue<List<PresensiPertemuan>>> {
  /// See also [ManagePresensiState].
  const ManagePresensiStateFamily();

  /// See also [ManagePresensiState].
  ManagePresensiStateProvider call(
    String programId,
  ) {
    return ManagePresensiStateProvider(
      programId,
    );
  }

  @override
  ManagePresensiStateProvider getProviderOverride(
    covariant ManagePresensiStateProvider provider,
  ) {
    return call(
      provider.programId,
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
  String? get name => r'managePresensiStateProvider';
}

/// See also [ManagePresensiState].
class ManagePresensiStateProvider extends AutoDisposeAsyncNotifierProviderImpl<
    ManagePresensiState, List<PresensiPertemuan>> {
  /// See also [ManagePresensiState].
  ManagePresensiStateProvider(
    String programId,
  ) : this._internal(
          () => ManagePresensiState()..programId = programId,
          from: managePresensiStateProvider,
          name: r'managePresensiStateProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$managePresensiStateHash,
          dependencies: ManagePresensiStateFamily._dependencies,
          allTransitiveDependencies:
              ManagePresensiStateFamily._allTransitiveDependencies,
          programId: programId,
        );

  ManagePresensiStateProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.programId,
  }) : super.internal();

  final String programId;

  @override
  FutureOr<List<PresensiPertemuan>> runNotifierBuild(
    covariant ManagePresensiState notifier,
  ) {
    return notifier.build(
      programId,
    );
  }

  @override
  Override overrideWith(ManagePresensiState Function() create) {
    return ProviderOverride(
      origin: this,
      override: ManagePresensiStateProvider._internal(
        () => create()..programId = programId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        programId: programId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<ManagePresensiState,
      List<PresensiPertemuan>> createElement() {
    return _ManagePresensiStateProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ManagePresensiStateProvider && other.programId == programId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, programId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ManagePresensiStateRef
    on AutoDisposeAsyncNotifierProviderRef<List<PresensiPertemuan>> {
  /// The parameter `programId` of this provider.
  String get programId;
}

class _ManagePresensiStateProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<ManagePresensiState,
        List<PresensiPertemuan>> with ManagePresensiStateRef {
  _ManagePresensiStateProviderElement(super.provider);

  @override
  String get programId => (origin as ManagePresensiStateProvider).programId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
