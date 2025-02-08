// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'presensi_detail_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$programNameHash() => r'628ee6568b9a251b37423b990f685b864d6995a7';

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

/// See also [programName].
@ProviderFor(programName)
const programNameProvider = ProgramNameFamily();

/// See also [programName].
class ProgramNameFamily extends Family<AsyncValue<String>> {
  /// See also [programName].
  const ProgramNameFamily();

  /// See also [programName].
  ProgramNameProvider call(
    String programId,
  ) {
    return ProgramNameProvider(
      programId,
    );
  }

  @override
  ProgramNameProvider getProviderOverride(
    covariant ProgramNameProvider provider,
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
  String? get name => r'programNameProvider';
}

/// See also [programName].
class ProgramNameProvider extends AutoDisposeFutureProvider<String> {
  /// See also [programName].
  ProgramNameProvider(
    String programId,
  ) : this._internal(
          (ref) => programName(
            ref as ProgramNameRef,
            programId,
          ),
          from: programNameProvider,
          name: r'programNameProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$programNameHash,
          dependencies: ProgramNameFamily._dependencies,
          allTransitiveDependencies:
              ProgramNameFamily._allTransitiveDependencies,
          programId: programId,
        );

  ProgramNameProvider._internal(
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
  Override overrideWith(
    FutureOr<String> Function(ProgramNameRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ProgramNameProvider._internal(
        (ref) => create(ref as ProgramNameRef),
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
  AutoDisposeFutureProviderElement<String> createElement() {
    return _ProgramNameProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ProgramNameProvider && other.programId == programId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, programId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ProgramNameRef on AutoDisposeFutureProviderRef<String> {
  /// The parameter `programId` of this provider.
  String get programId;
}

class _ProgramNameProviderElement
    extends AutoDisposeFutureProviderElement<String> with ProgramNameRef {
  _ProgramNameProviderElement(super.provider);

  @override
  String get programId => (origin as ProgramNameProvider).programId;
}

String _$presensiDetailStateHash() =>
    r'ffba57511da20468f035fb4f78af53ffb033541a';

abstract class _$PresensiDetailState
    extends BuildlessAutoDisposeAsyncNotifier<DetailPresensi> {
  late final String programId;

  FutureOr<DetailPresensi> build(
    String programId,
  );
}

/// See also [PresensiDetailState].
@ProviderFor(PresensiDetailState)
const presensiDetailStateProvider = PresensiDetailStateFamily();

/// See also [PresensiDetailState].
class PresensiDetailStateFamily extends Family<AsyncValue<DetailPresensi>> {
  /// See also [PresensiDetailState].
  const PresensiDetailStateFamily();

  /// See also [PresensiDetailState].
  PresensiDetailStateProvider call(
    String programId,
  ) {
    return PresensiDetailStateProvider(
      programId,
    );
  }

  @override
  PresensiDetailStateProvider getProviderOverride(
    covariant PresensiDetailStateProvider provider,
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
  String? get name => r'presensiDetailStateProvider';
}

/// See also [PresensiDetailState].
class PresensiDetailStateProvider extends AutoDisposeAsyncNotifierProviderImpl<
    PresensiDetailState, DetailPresensi> {
  /// See also [PresensiDetailState].
  PresensiDetailStateProvider(
    String programId,
  ) : this._internal(
          () => PresensiDetailState()..programId = programId,
          from: presensiDetailStateProvider,
          name: r'presensiDetailStateProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$presensiDetailStateHash,
          dependencies: PresensiDetailStateFamily._dependencies,
          allTransitiveDependencies:
              PresensiDetailStateFamily._allTransitiveDependencies,
          programId: programId,
        );

  PresensiDetailStateProvider._internal(
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
  FutureOr<DetailPresensi> runNotifierBuild(
    covariant PresensiDetailState notifier,
  ) {
    return notifier.build(
      programId,
    );
  }

  @override
  Override overrideWith(PresensiDetailState Function() create) {
    return ProviderOverride(
      origin: this,
      override: PresensiDetailStateProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<PresensiDetailState, DetailPresensi>
      createElement() {
    return _PresensiDetailStateProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PresensiDetailStateProvider && other.programId == programId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, programId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin PresensiDetailStateRef
    on AutoDisposeAsyncNotifierProviderRef<DetailPresensi> {
  /// The parameter `programId` of this provider.
  String get programId;
}

class _PresensiDetailStateProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<PresensiDetailState,
        DetailPresensi> with PresensiDetailStateRef {
  _PresensiDetailStateProviderElement(super.provider);

  @override
  String get programId => (origin as PresensiDetailStateProvider).programId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
