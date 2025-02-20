// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'program_detail_with_stats_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$programDetailWithStatsStateHash() =>
    r'34618debc21288d4fc408c29b122793df8f55818';

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

abstract class _$ProgramDetailWithStatsState
    extends BuildlessAutoDisposeAsyncNotifier<
        (ProgramDetail, PresensiSummary)> {
  late final String programId;

  FutureOr<(ProgramDetail, PresensiSummary)> build(
    String programId,
  );
}

/// See also [ProgramDetailWithStatsState].
@ProviderFor(ProgramDetailWithStatsState)
const programDetailWithStatsStateProvider = ProgramDetailWithStatsStateFamily();

/// See also [ProgramDetailWithStatsState].
class ProgramDetailWithStatsStateFamily
    extends Family<AsyncValue<(ProgramDetail, PresensiSummary)>> {
  /// See also [ProgramDetailWithStatsState].
  const ProgramDetailWithStatsStateFamily();

  /// See also [ProgramDetailWithStatsState].
  ProgramDetailWithStatsStateProvider call(
    String programId,
  ) {
    return ProgramDetailWithStatsStateProvider(
      programId,
    );
  }

  @override
  ProgramDetailWithStatsStateProvider getProviderOverride(
    covariant ProgramDetailWithStatsStateProvider provider,
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
  String? get name => r'programDetailWithStatsStateProvider';
}

/// See also [ProgramDetailWithStatsState].
class ProgramDetailWithStatsStateProvider
    extends AutoDisposeAsyncNotifierProviderImpl<ProgramDetailWithStatsState,
        (ProgramDetail, PresensiSummary)> {
  /// See also [ProgramDetailWithStatsState].
  ProgramDetailWithStatsStateProvider(
    String programId,
  ) : this._internal(
          () => ProgramDetailWithStatsState()..programId = programId,
          from: programDetailWithStatsStateProvider,
          name: r'programDetailWithStatsStateProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$programDetailWithStatsStateHash,
          dependencies: ProgramDetailWithStatsStateFamily._dependencies,
          allTransitiveDependencies:
              ProgramDetailWithStatsStateFamily._allTransitiveDependencies,
          programId: programId,
        );

  ProgramDetailWithStatsStateProvider._internal(
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
  FutureOr<(ProgramDetail, PresensiSummary)> runNotifierBuild(
    covariant ProgramDetailWithStatsState notifier,
  ) {
    return notifier.build(
      programId,
    );
  }

  @override
  Override overrideWith(ProgramDetailWithStatsState Function() create) {
    return ProviderOverride(
      origin: this,
      override: ProgramDetailWithStatsStateProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<ProgramDetailWithStatsState,
      (ProgramDetail, PresensiSummary)> createElement() {
    return _ProgramDetailWithStatsStateProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ProgramDetailWithStatsStateProvider &&
        other.programId == programId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, programId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ProgramDetailWithStatsStateRef
    on AutoDisposeAsyncNotifierProviderRef<(ProgramDetail, PresensiSummary)> {
  /// The parameter `programId` of this provider.
  String get programId;
}

class _ProgramDetailWithStatsStateProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<ProgramDetailWithStatsState,
        (ProgramDetail, PresensiSummary)> with ProgramDetailWithStatsStateRef {
  _ProgramDetailWithStatsStateProviderElement(super.provider);

  @override
  String get programId =>
      (origin as ProgramDetailWithStatsStateProvider).programId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
