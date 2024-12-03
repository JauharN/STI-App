// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'program_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$programHash() => r'19f8c3bd86453678ae7f55af7329339076dd5608';

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

/// See also [program].
@ProviderFor(program)
const programProvider = ProgramFamily();

/// See also [program].
class ProgramFamily extends Family<AsyncValue<Program>> {
  /// See also [program].
  const ProgramFamily();

  /// See also [program].
  ProgramProvider call(
    String programId,
  ) {
    return ProgramProvider(
      programId,
    );
  }

  @override
  ProgramProvider getProviderOverride(
    covariant ProgramProvider provider,
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
  String? get name => r'programProvider';
}

/// See also [program].
class ProgramProvider extends AutoDisposeFutureProvider<Program> {
  /// See also [program].
  ProgramProvider(
    String programId,
  ) : this._internal(
          (ref) => program(
            ref as ProgramRef,
            programId,
          ),
          from: programProvider,
          name: r'programProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$programHash,
          dependencies: ProgramFamily._dependencies,
          allTransitiveDependencies: ProgramFamily._allTransitiveDependencies,
          programId: programId,
        );

  ProgramProvider._internal(
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
    FutureOr<Program> Function(ProgramRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ProgramProvider._internal(
        (ref) => create(ref as ProgramRef),
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
  AutoDisposeFutureProviderElement<Program> createElement() {
    return _ProgramProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ProgramProvider && other.programId == programId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, programId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ProgramRef on AutoDisposeFutureProviderRef<Program> {
  /// The parameter `programId` of this provider.
  String get programId;
}

class _ProgramProviderElement extends AutoDisposeFutureProviderElement<Program>
    with ProgramRef {
  _ProgramProviderElement(super.provider);

  @override
  String get programId => (origin as ProgramProvider).programId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
