// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recent_presensi_activities_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$recentPresensiActivitiesControllerHash() =>
    r'75105ee991c02837fabfaad2afb144aba78b5d53';

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

abstract class _$RecentPresensiActivitiesController
    extends BuildlessAutoDisposeAsyncNotifier<List<PresensiPertemuan>> {
  late final String programId;

  FutureOr<List<PresensiPertemuan>> build(
    String programId,
  );
}

/// See also [RecentPresensiActivitiesController].
@ProviderFor(RecentPresensiActivitiesController)
const recentPresensiActivitiesControllerProvider =
    RecentPresensiActivitiesControllerFamily();

/// See also [RecentPresensiActivitiesController].
class RecentPresensiActivitiesControllerFamily
    extends Family<AsyncValue<List<PresensiPertemuan>>> {
  /// See also [RecentPresensiActivitiesController].
  const RecentPresensiActivitiesControllerFamily();

  /// See also [RecentPresensiActivitiesController].
  RecentPresensiActivitiesControllerProvider call(
    String programId,
  ) {
    return RecentPresensiActivitiesControllerProvider(
      programId,
    );
  }

  @override
  RecentPresensiActivitiesControllerProvider getProviderOverride(
    covariant RecentPresensiActivitiesControllerProvider provider,
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
  String? get name => r'recentPresensiActivitiesControllerProvider';
}

/// See also [RecentPresensiActivitiesController].
class RecentPresensiActivitiesControllerProvider
    extends AutoDisposeAsyncNotifierProviderImpl<
        RecentPresensiActivitiesController, List<PresensiPertemuan>> {
  /// See also [RecentPresensiActivitiesController].
  RecentPresensiActivitiesControllerProvider(
    String programId,
  ) : this._internal(
          () => RecentPresensiActivitiesController()..programId = programId,
          from: recentPresensiActivitiesControllerProvider,
          name: r'recentPresensiActivitiesControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$recentPresensiActivitiesControllerHash,
          dependencies: RecentPresensiActivitiesControllerFamily._dependencies,
          allTransitiveDependencies: RecentPresensiActivitiesControllerFamily
              ._allTransitiveDependencies,
          programId: programId,
        );

  RecentPresensiActivitiesControllerProvider._internal(
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
    covariant RecentPresensiActivitiesController notifier,
  ) {
    return notifier.build(
      programId,
    );
  }

  @override
  Override overrideWith(RecentPresensiActivitiesController Function() create) {
    return ProviderOverride(
      origin: this,
      override: RecentPresensiActivitiesControllerProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<RecentPresensiActivitiesController,
      List<PresensiPertemuan>> createElement() {
    return _RecentPresensiActivitiesControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RecentPresensiActivitiesControllerProvider &&
        other.programId == programId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, programId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin RecentPresensiActivitiesControllerRef
    on AutoDisposeAsyncNotifierProviderRef<List<PresensiPertemuan>> {
  /// The parameter `programId` of this provider.
  String get programId;
}

class _RecentPresensiActivitiesControllerProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<
        RecentPresensiActivitiesController,
        List<PresensiPertemuan>> with RecentPresensiActivitiesControllerRef {
  _RecentPresensiActivitiesControllerProviderElement(super.provider);

  @override
  String get programId =>
      (origin as RecentPresensiActivitiesControllerProvider).programId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
