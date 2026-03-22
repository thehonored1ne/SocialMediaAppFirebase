// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'community_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$communityRepositoryHash() =>
    r'30690bf3bc9a883e25b89f606e129419ef7c7766';

/// See also [communityRepository].
@ProviderFor(communityRepository)
final communityRepositoryProvider =
    AutoDisposeProvider<CommunityRepository>.internal(
      communityRepository,
      name: r'communityRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$communityRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CommunityRepositoryRef = AutoDisposeProviderRef<CommunityRepository>;
String _$communitiesHash() => r'1ee2b2e78e7df3b34efe3a3453c1983623068573';

/// See also [communities].
@ProviderFor(communities)
final communitiesProvider =
    AutoDisposeStreamProvider<List<CommunityModel>>.internal(
      communities,
      name: r'communitiesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$communitiesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CommunitiesRef = AutoDisposeStreamProviderRef<List<CommunityModel>>;
String _$communityHash() => r'ab7e66e028cd9072e7f4957e7196c286318cb6f7';

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

/// See also [community].
@ProviderFor(community)
const communityProvider = CommunityFamily();

/// See also [community].
class CommunityFamily extends Family<AsyncValue<CommunityModel>> {
  /// See also [community].
  const CommunityFamily();

  /// See also [community].
  CommunityProvider call(String id) {
    return CommunityProvider(id);
  }

  @override
  CommunityProvider getProviderOverride(covariant CommunityProvider provider) {
    return call(provider.id);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'communityProvider';
}

/// See also [community].
class CommunityProvider extends AutoDisposeStreamProvider<CommunityModel> {
  /// See also [community].
  CommunityProvider(String id)
    : this._internal(
        (ref) => community(ref as CommunityRef, id),
        from: communityProvider,
        name: r'communityProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$communityHash,
        dependencies: CommunityFamily._dependencies,
        allTransitiveDependencies: CommunityFamily._allTransitiveDependencies,
        id: id,
      );

  CommunityProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final String id;

  @override
  Override overrideWith(
    Stream<CommunityModel> Function(CommunityRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CommunityProvider._internal(
        (ref) => create(ref as CommunityRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<CommunityModel> createElement() {
    return _CommunityProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CommunityProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CommunityRef on AutoDisposeStreamProviderRef<CommunityModel> {
  /// The parameter `id` of this provider.
  String get id;
}

class _CommunityProviderElement
    extends AutoDisposeStreamProviderElement<CommunityModel>
    with CommunityRef {
  _CommunityProviderElement(super.provider);

  @override
  String get id => (origin as CommunityProvider).id;
}

String _$communityPostsHash() => r'2e799acb4f215e4e887547e14f4899e650c2f76b';

/// See also [communityPosts].
@ProviderFor(communityPosts)
const communityPostsProvider = CommunityPostsFamily();

/// See also [communityPosts].
class CommunityPostsFamily extends Family<AsyncValue<List<PostModel>>> {
  /// See also [communityPosts].
  const CommunityPostsFamily();

  /// See also [communityPosts].
  CommunityPostsProvider call(String communityId) {
    return CommunityPostsProvider(communityId);
  }

  @override
  CommunityPostsProvider getProviderOverride(
    covariant CommunityPostsProvider provider,
  ) {
    return call(provider.communityId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'communityPostsProvider';
}

/// See also [communityPosts].
class CommunityPostsProvider
    extends AutoDisposeStreamProvider<List<PostModel>> {
  /// See also [communityPosts].
  CommunityPostsProvider(String communityId)
    : this._internal(
        (ref) => communityPosts(ref as CommunityPostsRef, communityId),
        from: communityPostsProvider,
        name: r'communityPostsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$communityPostsHash,
        dependencies: CommunityPostsFamily._dependencies,
        allTransitiveDependencies:
            CommunityPostsFamily._allTransitiveDependencies,
        communityId: communityId,
      );

  CommunityPostsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.communityId,
  }) : super.internal();

  final String communityId;

  @override
  Override overrideWith(
    Stream<List<PostModel>> Function(CommunityPostsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CommunityPostsProvider._internal(
        (ref) => create(ref as CommunityPostsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        communityId: communityId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<PostModel>> createElement() {
    return _CommunityPostsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CommunityPostsProvider && other.communityId == communityId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, communityId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CommunityPostsRef on AutoDisposeStreamProviderRef<List<PostModel>> {
  /// The parameter `communityId` of this provider.
  String get communityId;
}

class _CommunityPostsProviderElement
    extends AutoDisposeStreamProviderElement<List<PostModel>>
    with CommunityPostsRef {
  _CommunityPostsProviderElement(super.provider);

  @override
  String get communityId => (origin as CommunityPostsProvider).communityId;
}

String _$communityMembersHash() => r'92c21d235de3a64be2270c710bb550c2af13a199';

/// See also [communityMembers].
@ProviderFor(communityMembers)
const communityMembersProvider = CommunityMembersFamily();

/// See also [communityMembers].
class CommunityMembersFamily extends Family<AsyncValue<List<UserModel>>> {
  /// See also [communityMembers].
  const CommunityMembersFamily();

  /// See also [communityMembers].
  CommunityMembersProvider call({
    required String communityId,
    required bool isPending,
  }) {
    return CommunityMembersProvider(
      communityId: communityId,
      isPending: isPending,
    );
  }

  @override
  CommunityMembersProvider getProviderOverride(
    covariant CommunityMembersProvider provider,
  ) {
    return call(
      communityId: provider.communityId,
      isPending: provider.isPending,
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
  String? get name => r'communityMembersProvider';
}

/// See also [communityMembers].
class CommunityMembersProvider
    extends AutoDisposeFutureProvider<List<UserModel>> {
  /// See also [communityMembers].
  CommunityMembersProvider({
    required String communityId,
    required bool isPending,
  }) : this._internal(
         (ref) => communityMembers(
           ref as CommunityMembersRef,
           communityId: communityId,
           isPending: isPending,
         ),
         from: communityMembersProvider,
         name: r'communityMembersProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$communityMembersHash,
         dependencies: CommunityMembersFamily._dependencies,
         allTransitiveDependencies:
             CommunityMembersFamily._allTransitiveDependencies,
         communityId: communityId,
         isPending: isPending,
       );

  CommunityMembersProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.communityId,
    required this.isPending,
  }) : super.internal();

  final String communityId;
  final bool isPending;

  @override
  Override overrideWith(
    FutureOr<List<UserModel>> Function(CommunityMembersRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CommunityMembersProvider._internal(
        (ref) => create(ref as CommunityMembersRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        communityId: communityId,
        isPending: isPending,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<UserModel>> createElement() {
    return _CommunityMembersProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CommunityMembersProvider &&
        other.communityId == communityId &&
        other.isPending == isPending;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, communityId.hashCode);
    hash = _SystemHash.combine(hash, isPending.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CommunityMembersRef on AutoDisposeFutureProviderRef<List<UserModel>> {
  /// The parameter `communityId` of this provider.
  String get communityId;

  /// The parameter `isPending` of this provider.
  bool get isPending;
}

class _CommunityMembersProviderElement
    extends AutoDisposeFutureProviderElement<List<UserModel>>
    with CommunityMembersRef {
  _CommunityMembersProviderElement(super.provider);

  @override
  String get communityId => (origin as CommunityMembersProvider).communityId;
  @override
  bool get isPending => (origin as CommunityMembersProvider).isPending;
}

String _$communityControllerHash() =>
    r'13dc999fd436842a2ffebb2651377f871ab2d450';

/// See also [CommunityController].
@ProviderFor(CommunityController)
final communityControllerProvider =
    AutoDisposeAsyncNotifierProvider<CommunityController, void>.internal(
      CommunityController.new,
      name: r'communityControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$communityControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CommunityController = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
