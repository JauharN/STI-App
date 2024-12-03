// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'santri_list_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$santriListHash() => r'2c2f33f3a6eff5c8956fdc4dc79d06d45119f2de';

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

/// See also [santriList].
@ProviderFor(santriList)
const santriListProvider = SantriListFamily();

/// See also [santriList].
class SantriListFamily extends Family<AsyncValue<List<User>>> {
  /// See also [santriList].
  const SantriListFamily();

  /// See also [santriList].
  SantriListProvider call(
    String programId,
  ) {
    return SantriListProvider(
      programId,
    );
  }

  @override
  SantriListProvider getProviderOverride(
    covariant SantriListProvider provider,
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
  String? get name => r'santriListProvider';
}

/// See also [santriList].
class SantriListProvider extends AutoDisposeFutureProvider<List<User>> {
  /// See also [santriList].
  SantriListProvider(
    String programId,
  ) : this._internal(
          (ref) => santriList(
            ref as SantriListRef,
            programId,
          ),
          from: santriListProvider,
          name: r'santriListProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$santriListHash,
          dependencies: SantriListFamily._dependencies,
          allTransitiveDependencies:
              SantriListFamily._allTransitiveDependencies,
          programId: programId,
        );

  SantriListProvider._internal(
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
    FutureOr<List<User>> Function(SantriListRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SantriListProvider._internal(
        (ref) => create(ref as SantriListRef),
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
    return _SantriListProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SantriListProvider && other.programId == programId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, programId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin SantriListRef on AutoDisposeFutureProviderRef<List<User>> {
  /// The parameter `programId` of this provider.
  String get programId;
}

class _SantriListProviderElement
    extends AutoDisposeFutureProviderElement<List<User>> with SantriListRef {
  _SantriListProviderElement(super.provider);

  @override
  String get programId => (origin as SantriListProvider).programId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
