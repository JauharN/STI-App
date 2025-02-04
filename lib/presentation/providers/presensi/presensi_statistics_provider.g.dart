// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'presensi_statistics_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$presensiStatisticsHash() =>
    r'10e244acf3044ee9680d3788b24b1a6130a9d003';

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

abstract class _$PresensiStatistics
    extends BuildlessAutoDisposeAsyncNotifier<PresensiStatisticsData> {
  late final String programId;

  FutureOr<PresensiStatisticsData> build(
    String programId,
  );
}

/// See also [PresensiStatistics].
@ProviderFor(PresensiStatistics)
const presensiStatisticsProvider = PresensiStatisticsFamily();

/// See also [PresensiStatistics].
class PresensiStatisticsFamily
    extends Family<AsyncValue<PresensiStatisticsData>> {
  /// See also [PresensiStatistics].
  const PresensiStatisticsFamily();

  /// See also [PresensiStatistics].
  PresensiStatisticsProvider call(
    String programId,
  ) {
    return PresensiStatisticsProvider(
      programId,
    );
  }

  @override
  PresensiStatisticsProvider getProviderOverride(
    covariant PresensiStatisticsProvider provider,
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
  String? get name => r'presensiStatisticsProvider';
}

/// See also [PresensiStatistics].
class PresensiStatisticsProvider extends AutoDisposeAsyncNotifierProviderImpl<
    PresensiStatistics, PresensiStatisticsData> {
  /// See also [PresensiStatistics].
  PresensiStatisticsProvider(
    String programId,
  ) : this._internal(
          () => PresensiStatistics()..programId = programId,
          from: presensiStatisticsProvider,
          name: r'presensiStatisticsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$presensiStatisticsHash,
          dependencies: PresensiStatisticsFamily._dependencies,
          allTransitiveDependencies:
              PresensiStatisticsFamily._allTransitiveDependencies,
          programId: programId,
        );

  PresensiStatisticsProvider._internal(
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
  FutureOr<PresensiStatisticsData> runNotifierBuild(
    covariant PresensiStatistics notifier,
  ) {
    return notifier.build(
      programId,
    );
  }

  @override
  Override overrideWith(PresensiStatistics Function() create) {
    return ProviderOverride(
      origin: this,
      override: PresensiStatisticsProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<PresensiStatistics,
      PresensiStatisticsData> createElement() {
    return _PresensiStatisticsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PresensiStatisticsProvider && other.programId == programId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, programId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin PresensiStatisticsRef
    on AutoDisposeAsyncNotifierProviderRef<PresensiStatisticsData> {
  /// The parameter `programId` of this provider.
  String get programId;
}

class _PresensiStatisticsProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<PresensiStatistics,
        PresensiStatisticsData> with PresensiStatisticsRef {
  _PresensiStatisticsProviderElement(super.provider);

  @override
  String get programId => (origin as PresensiStatisticsProvider).programId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
