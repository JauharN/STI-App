// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'program_santri_list_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$programSantriListHash() => r'1264112b4dd491774d916cef6d8c163c0382ebe2';

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

abstract class _$ProgramSantriList
    extends BuildlessAutoDisposeAsyncNotifier<List<User>> {
  late final String programId;

  FutureOr<List<User>> build(
    String programId,
  );
}

/// See also [ProgramSantriList].
@ProviderFor(ProgramSantriList)
const programSantriListProvider = ProgramSantriListFamily();

/// See also [ProgramSantriList].
class ProgramSantriListFamily extends Family<AsyncValue<List<User>>> {
  /// See also [ProgramSantriList].
  const ProgramSantriListFamily();

  /// See also [ProgramSantriList].
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

/// See also [ProgramSantriList].
class ProgramSantriListProvider extends AutoDisposeAsyncNotifierProviderImpl<
    ProgramSantriList, List<User>> {
  /// See also [ProgramSantriList].
  ProgramSantriListProvider(
    String programId,
  ) : this._internal(
          () => ProgramSantriList()..programId = programId,
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
  FutureOr<List<User>> runNotifierBuild(
    covariant ProgramSantriList notifier,
  ) {
    return notifier.build(
      programId,
    );
  }

  @override
  Override overrideWith(ProgramSantriList Function() create) {
    return ProviderOverride(
      origin: this,
      override: ProgramSantriListProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<ProgramSantriList, List<User>>
      createElement() {
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

mixin ProgramSantriListRef on AutoDisposeAsyncNotifierProviderRef<List<User>> {
  /// The parameter `programId` of this provider.
  String get programId;
}

class _ProgramSantriListProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<ProgramSantriList,
        List<User>> with ProgramSantriListRef {
  _ProgramSantriListProviderElement(super.provider);

  @override
  String get programId => (origin as ProgramSantriListProvider).programId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
