// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'enrolled_santri_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$enrolledSantriHash() => r'f20c169f830a71f6b8451b6f42115259e9bd515a';

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

/// See also [enrolledSantri].
@ProviderFor(enrolledSantri)
const enrolledSantriProvider = EnrolledSantriFamily();

/// See also [enrolledSantri].
class EnrolledSantriFamily extends Family<AsyncValue<List<User>>> {
  /// See also [enrolledSantri].
  const EnrolledSantriFamily();

  /// See also [enrolledSantri].
  EnrolledSantriProvider call(
    String programId,
  ) {
    return EnrolledSantriProvider(
      programId,
    );
  }

  @override
  EnrolledSantriProvider getProviderOverride(
    covariant EnrolledSantriProvider provider,
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
  String? get name => r'enrolledSantriProvider';
}

/// See also [enrolledSantri].
class EnrolledSantriProvider extends AutoDisposeFutureProvider<List<User>> {
  /// See also [enrolledSantri].
  EnrolledSantriProvider(
    String programId,
  ) : this._internal(
          (ref) => enrolledSantri(
            ref as EnrolledSantriRef,
            programId,
          ),
          from: enrolledSantriProvider,
          name: r'enrolledSantriProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$enrolledSantriHash,
          dependencies: EnrolledSantriFamily._dependencies,
          allTransitiveDependencies:
              EnrolledSantriFamily._allTransitiveDependencies,
          programId: programId,
        );

  EnrolledSantriProvider._internal(
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
    FutureOr<List<User>> Function(EnrolledSantriRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: EnrolledSantriProvider._internal(
        (ref) => create(ref as EnrolledSantriRef),
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
    return _EnrolledSantriProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is EnrolledSantriProvider && other.programId == programId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, programId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin EnrolledSantriRef on AutoDisposeFutureProviderRef<List<User>> {
  /// The parameter `programId` of this provider.
  String get programId;
}

class _EnrolledSantriProviderElement
    extends AutoDisposeFutureProviderElement<List<User>>
    with EnrolledSantriRef {
  _EnrolledSantriProviderElement(super.provider);

  @override
  String get programId => (origin as EnrolledSantriProvider).programId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
