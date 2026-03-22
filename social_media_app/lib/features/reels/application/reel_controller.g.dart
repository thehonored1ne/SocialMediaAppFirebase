// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reel_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$reelRepositoryHash() => r'570bb7579f7a793c7aafe00687249a45a9a0df00';

/// See also [reelRepository].
@ProviderFor(reelRepository)
final reelRepositoryProvider = AutoDisposeProvider<ReelRepository>.internal(
  reelRepository,
  name: r'reelRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$reelRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ReelRepositoryRef = AutoDisposeProviderRef<ReelRepository>;
String _$reelsStreamHash() => r'c669210bf17975c05d1d61c0409ba4da52bef5a5';

/// See also [reelsStream].
@ProviderFor(reelsStream)
final reelsStreamProvider = AutoDisposeStreamProvider<List<PostModel>>.internal(
  reelsStream,
  name: r'reelsStreamProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$reelsStreamHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ReelsStreamRef = AutoDisposeStreamProviderRef<List<PostModel>>;
String _$reelCommentsHash() => r'96349b26f2d1c4d541a0f6aea4191d56d845fb7b';

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

/// See also [reelComments].
@ProviderFor(reelComments)
const reelCommentsProvider = ReelCommentsFamily();

/// See also [reelComments].
class ReelCommentsFamily extends Family<AsyncValue<List<CommentModel>>> {
  /// See also [reelComments].
  const ReelCommentsFamily();

  /// See also [reelComments].
  ReelCommentsProvider call(String reelId) {
    return ReelCommentsProvider(reelId);
  }

  @override
  ReelCommentsProvider getProviderOverride(
    covariant ReelCommentsProvider provider,
  ) {
    return call(provider.reelId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'reelCommentsProvider';
}

/// See also [reelComments].
class ReelCommentsProvider
    extends AutoDisposeStreamProvider<List<CommentModel>> {
  /// See also [reelComments].
  ReelCommentsProvider(String reelId)
    : this._internal(
        (ref) => reelComments(ref as ReelCommentsRef, reelId),
        from: reelCommentsProvider,
        name: r'reelCommentsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$reelCommentsHash,
        dependencies: ReelCommentsFamily._dependencies,
        allTransitiveDependencies:
            ReelCommentsFamily._allTransitiveDependencies,
        reelId: reelId,
      );

  ReelCommentsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.reelId,
  }) : super.internal();

  final String reelId;

  @override
  Override overrideWith(
    Stream<List<CommentModel>> Function(ReelCommentsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ReelCommentsProvider._internal(
        (ref) => create(ref as ReelCommentsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        reelId: reelId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<CommentModel>> createElement() {
    return _ReelCommentsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ReelCommentsProvider && other.reelId == reelId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, reelId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ReelCommentsRef on AutoDisposeStreamProviderRef<List<CommentModel>> {
  /// The parameter `reelId` of this provider.
  String get reelId;
}

class _ReelCommentsProviderElement
    extends AutoDisposeStreamProviderElement<List<CommentModel>>
    with ReelCommentsRef {
  _ReelCommentsProviderElement(super.provider);

  @override
  String get reelId => (origin as ReelCommentsProvider).reelId;
}

String _$reelControllerHash() => r'47a3b0b1a568102510bb266df2a641b155cff2ea';

/// See also [ReelController].
@ProviderFor(ReelController)
final reelControllerProvider =
    AutoDisposeAsyncNotifierProvider<ReelController, void>.internal(
      ReelController.new,
      name: r'reelControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$reelControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ReelController = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
