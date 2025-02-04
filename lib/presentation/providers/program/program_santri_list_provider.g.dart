// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'program_santri_list_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$programSantriListHash() => r'26c6cdc7d0a1a7f96eea7c0fd8e1d91468830d7d';

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

/// See also [programSantriList].
@ProviderFor(programSantriList)
const programSantriListProvider = ProgramSantriListFamily();

/// See also [programSantriList].
class ProgramSantriListFamily extends Family<AsyncValue<List<User>>> {
  /// See also [programSantriList].
  const ProgramSantriListFamily();

  /// See also [programSantriList].
  ProgramSantriListProvider call(
    String programId,
  ) {
    return ProgramSantriListProvider(
      programId,
    );
  }

  @override
  ProgramSantriListProvider getProviderOverride(
    covariant ProgramSantriListProvider provider,
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
  String? get name => r'programSantriListProvider';
}

/// See also [programSantriList].
class ProgramSantriListProvider extends AutoDisposeFutureProvider<List<User>> {
  /// See also [programSantriList].
  ProgramSantriListProvider(
    String programId,
  ) : this._internal(
          (ref) => programSantriList(
            ref as ProgramSantriListRef,
            programId,
          ),
          from: programSantriListProvider,
          name: r'programSantriListProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$programSantriListHash,
          dependencies: ProgramSantriListFamily._dependencies,
          allTransitiveDependencies:
              ProgramSantriListFamily._allTransitiveDependencies,
          programId: programId,
        );

  ProgramSantriListProvider._internal(
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
    FutureOr<List<User>> Function(ProgramSantriListRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ProgramSantriListProvider._internal(
        (ref) => create(ref as ProgramSantriListRef),
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
  AutoDisposeFutureProviderElement<List<User>> createElement() {
    return _ProgramSantriListProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ProgramSantriListProvider && other.programId == programId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, programId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ProgramSantriListRef on AutoDisposeFutureProviderRef<List<User>> {
  /// The parameter `programId` of this provider.
  String get programId;
}

class _ProgramSantriListProviderElement
    extends AutoDisposeFutureProviderElement<List<User>>
    with ProgramSantriListRef {
  _ProgramSantriListProviderElement(super.provider);

  @override
  String get programId => (origin as ProgramSantriListProvider).programId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
