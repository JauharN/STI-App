// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_users_by_role_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$getUsersByRoleUsecaseHash() =>
    r'c1f18d68588c2a304b8508038a35cca14fff1c35';

/// See also [getUsersByRoleUsecase].
@ProviderFor(getUsersByRoleUsecase)
final getUsersByRoleUsecaseProvider =
    AutoDisposeProvider<GetUsersByRole>.internal(
  getUsersByRoleUsecase,
  name: r'getUsersByRoleUsecaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$getUsersByRoleUsecaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef GetUsersByRoleUsecaseRef = AutoDisposeProviderRef<GetUsersByRole>;
String _$getUsersByRoleHash() => r'b77393d1dce3ff64dd796b977e2097a891d9cc10';

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

/// See also [getUsersByRole].
@ProviderFor(getUsersByRole)
const getUsersByRoleProvider = GetUsersByRoleFamily();

/// See also [getUsersByRole].
class GetUsersByRoleFamily extends Family<AsyncValue<List<User>>> {
  /// See also [getUsersByRole].
  const GetUsersByRoleFamily();

  /// See also [getUsersByRole].
  GetUsersByRoleProvider call({
    required String roleToGet,
    required String currentUserRole,
    required bool includeInactive,
  }) {
    return GetUsersByRoleProvider(
      roleToGet: roleToGet,
      currentUserRole: currentUserRole,
      includeInactive: includeInactive,
    );
  }

  @override
  GetUsersByRoleProvider getProviderOverride(
    covariant GetUsersByRoleProvider provider,
  ) {
    return call(
      roleToGet: provider.roleToGet,
      currentUserRole: provider.currentUserRole,
      includeInactive: provider.includeInactive,
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
  String? get name => r'getUsersByRoleProvider';
}

/// See also [getUsersByRole].
class GetUsersByRoleProvider extends AutoDisposeFutureProvider<List<User>> {
  /// See also [getUsersByRole].
  GetUsersByRoleProvider({
    required String roleToGet,
    required String currentUserRole,
    required bool includeInactive,
  }) : this._internal(
          (ref) => getUsersByRole(
            ref as GetUsersByRoleRef,
            roleToGet: roleToGet,
            currentUserRole: currentUserRole,
            includeInactive: includeInactive,
          ),
          from: getUsersByRoleProvider,
          name: r'getUsersByRoleProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$getUsersByRoleHash,
          dependencies: GetUsersByRoleFamily._dependencies,
          allTransitiveDependencies:
              GetUsersByRoleFamily._allTransitiveDependencies,
          roleToGet: roleToGet,
          currentUserRole: currentUserRole,
          includeInactive: includeInactive,
        );

  GetUsersByRoleProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.roleToGet,
    required this.currentUserRole,
    required this.includeInactive,
  }) : super.internal();

  final String roleToGet;
  final String currentUserRole;
  final bool includeInactive;

  @override
  Override overrideWith(
    FutureOr<List<User>> Function(GetUsersByRoleRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: GetUsersByRoleProvider._internal(
        (ref) => create(ref as GetUsersByRoleRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        roleToGet: roleToGet,
        currentUserRole: currentUserRole,
        includeInactive: includeInactive,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<User>> createElement() {
    return _GetUsersByRoleProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GetUsersByRoleProvider &&
        other.roleToGet == roleToGet &&
        other.currentUserRole == currentUserRole &&
        other.includeInactive == includeInactive;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, roleToGet.hashCode);
    hash = _SystemHash.combine(hash, currentUserRole.hashCode);
    hash = _SystemHash.combine(hash, includeInactive.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin GetUsersByRoleRef on AutoDisposeFutureProviderRef<List<User>> {
  /// The parameter `roleToGet` of this provider.
  String get roleToGet;

  /// The parameter `currentUserRole` of this provider.
  String get currentUserRole;

  /// The parameter `includeInactive` of this provider.
  bool get includeInactive;
}

class _GetUsersByRoleProviderElement
    extends AutoDisposeFutureProviderElement<List<User>>
    with GetUsersByRoleRef {
  _GetUsersByRoleProviderElement(super.provider);

  @override
  String get roleToGet => (origin as GetUsersByRoleProvider).roleToGet;
  @override
  String get currentUserRole =>
      (origin as GetUsersByRoleProvider).currentUserRole;
  @override
  bool get includeInactive =>
      (origin as GetUsersByRoleProvider).includeInactive;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
