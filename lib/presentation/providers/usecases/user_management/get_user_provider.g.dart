// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_user_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$getUserHash() => r'b58dad31ab59004189d22d922f494fb133a05025';

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

/// See also [getUser].
@ProviderFor(getUser)
const getUserProvider = GetUserFamily();

/// See also [getUser].
class GetUserFamily extends Family<AsyncValue<User>> {
  /// See also [getUser].
  const GetUserFamily();

  /// See also [getUser].
  GetUserProvider call(
    String uid,
  ) {
    return GetUserProvider(
      uid,
    );
  }

  @override
  GetUserProvider getProviderOverride(
    covariant GetUserProvider provider,
  ) {
    return call(
      provider.uid,
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
  String? get name => r'getUserProvider';
}

/// See also [getUser].
class GetUserProvider extends AutoDisposeFutureProvider<User> {
  /// See also [getUser].
  GetUserProvider(
    String uid,
  ) : this._internal(
          (ref) => getUser(
            ref as GetUserRef,
            uid,
          ),
          from: getUserProvider,
          name: r'getUserProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$getUserHash,
          dependencies: GetUserFamily._dependencies,
          allTransitiveDependencies: GetUserFamily._allTransitiveDependencies,
          uid: uid,
        );

  GetUserProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.uid,
  }) : super.internal();

  final String uid;

  @override
  Override overrideWith(
    FutureOr<User> Function(GetUserRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: GetUserProvider._internal(
        (ref) => create(ref as GetUserRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        uid: uid,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<User> createElement() {
    return _GetUserProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GetUserProvider && other.uid == uid;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, uid.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin GetUserRef on AutoDisposeFutureProviderRef<User> {
  /// The parameter `uid` of this provider.
  String get uid;
}

class _GetUserProviderElement extends AutoDisposeFutureProviderElement<User>
    with GetUserRef {
  _GetUserProviderElement(super.provider);

  @override
  String get uid => (origin as GetUserProvider).uid;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
