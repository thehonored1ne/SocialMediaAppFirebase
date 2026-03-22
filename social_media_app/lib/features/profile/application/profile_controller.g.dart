// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$profileRepositoryHash() => r'f6c2d51a12427db7213cb2e784a3dd9008ed94ef';

/// See also [profileRepository].
@ProviderFor(profileRepository)
final profileRepositoryProvider =
    AutoDisposeProvider<ProfileRepository>.internal(
      profileRepository,
      name: r'profileRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$profileRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ProfileRepositoryRef = AutoDisposeProviderRef<ProfileRepository>;
String _$profileHash() => r'31abf7e793954e72168120204789635668f1f52b';

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

/// See also [profile].
@ProviderFor(profile)
const profileProvider = ProfileFamily();

/// See also [profile].
class ProfileFamily extends Family<AsyncValue<UserModel>> {
  /// See also [profile].
  const ProfileFamily();

  /// See also [profile].
  ProfileProvider call(String uid) {
    return ProfileProvider(uid);
  }

  @override
  ProfileProvider getProviderOverride(covariant ProfileProvider provider) {
    return call(provider.uid);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'profileProvider';
}

/// See also [profile].
class ProfileProvider extends AutoDisposeStreamProvider<UserModel> {
  /// See also [profile].
  ProfileProvider(String uid)
    : this._internal(
        (ref) => profile(ref as ProfileRef, uid),
        from: profileProvider,
        name: r'profileProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$profileHash,
        dependencies: ProfileFamily._dependencies,
        allTransitiveDependencies: ProfileFamily._allTransitiveDependencies,
        uid: uid,
      );

  ProfileProvider._internal(
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
    Stream<UserModel> Function(ProfileRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ProfileProvider._internal(
        (ref) => create(ref as ProfileRef),
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
  AutoDisposeStreamProviderElement<UserModel> createElement() {
    return _ProfileProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ProfileProvider && other.uid == uid;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, uid.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ProfileRef on AutoDisposeStreamProviderRef<UserModel> {
  /// The parameter `uid` of this provider.
  String get uid;
}

class _ProfileProviderElement
    extends AutoDisposeStreamProviderElement<UserModel>
    with ProfileRef {
  _ProfileProviderElement(super.provider);

  @override
  String get uid => (origin as ProfileProvider).uid;
}

String _$suggestedUsersHash() => r'81362105bdec25fa80ed5b52647db884b99fc1a4';

/// See also [suggestedUsers].
@ProviderFor(suggestedUsers)
final suggestedUsersProvider =
    AutoDisposeStreamProvider<List<UserModel>>.internal(
      suggestedUsers,
      name: r'suggestedUsersProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$suggestedUsersHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SuggestedUsersRef = AutoDisposeStreamProviderRef<List<UserModel>>;
String _$userPostsHash() => r'b04f83f07109dca8b29ce7159415e88b7c290b4d';

/// See also [userPosts].
@ProviderFor(userPosts)
const userPostsProvider = UserPostsFamily();

/// See also [userPosts].
class UserPostsFamily extends Family<AsyncValue<List<PostModel>>> {
  /// See also [userPosts].
  const UserPostsFamily();

  /// See also [userPosts].
  UserPostsProvider call(String uid) {
    return UserPostsProvider(uid);
  }

  @override
  UserPostsProvider getProviderOverride(covariant UserPostsProvider provider) {
    return call(provider.uid);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'userPostsProvider';
}

/// See also [userPosts].
class UserPostsProvider extends AutoDisposeStreamProvider<List<PostModel>> {
  /// See also [userPosts].
  UserPostsProvider(String uid)
    : this._internal(
        (ref) => userPosts(ref as UserPostsRef, uid),
        from: userPostsProvider,
        name: r'userPostsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$userPostsHash,
        dependencies: UserPostsFamily._dependencies,
        allTransitiveDependencies: UserPostsFamily._allTransitiveDependencies,
        uid: uid,
      );

  UserPostsProvider._internal(
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
    Stream<List<PostModel>> Function(UserPostsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: UserPostsProvider._internal(
        (ref) => create(ref as UserPostsRef),
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
  AutoDisposeStreamProviderElement<List<PostModel>> createElement() {
    return _UserPostsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UserPostsProvider && other.uid == uid;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, uid.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin UserPostsRef on AutoDisposeStreamProviderRef<List<PostModel>> {
  /// The parameter `uid` of this provider.
  String get uid;
}

class _UserPostsProviderElement
    extends AutoDisposeStreamProviderElement<List<PostModel>>
    with UserPostsRef {
  _UserPostsProviderElement(super.provider);

  @override
  String get uid => (origin as UserPostsProvider).uid;
}

String _$userReelsHash() => r'966770db2bde4a4de2935401154e424470b135ae';

/// See also [userReels].
@ProviderFor(userReels)
const userReelsProvider = UserReelsFamily();

/// See also [userReels].
class UserReelsFamily extends Family<AsyncValue<List<PostModel>>> {
  /// See also [userReels].
  const UserReelsFamily();

  /// See also [userReels].
  UserReelsProvider call(String uid) {
    return UserReelsProvider(uid);
  }

  @override
  UserReelsProvider getProviderOverride(covariant UserReelsProvider provider) {
    return call(provider.uid);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'userReelsProvider';
}

/// See also [userReels].
class UserReelsProvider extends AutoDisposeStreamProvider<List<PostModel>> {
  /// See also [userReels].
  UserReelsProvider(String uid)
    : this._internal(
        (ref) => userReels(ref as UserReelsRef, uid),
        from: userReelsProvider,
        name: r'userReelsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$userReelsHash,
        dependencies: UserReelsFamily._dependencies,
        allTransitiveDependencies: UserReelsFamily._allTransitiveDependencies,
        uid: uid,
      );

  UserReelsProvider._internal(
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
    Stream<List<PostModel>> Function(UserReelsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: UserReelsProvider._internal(
        (ref) => create(ref as UserReelsRef),
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
  AutoDisposeStreamProviderElement<List<PostModel>> createElement() {
    return _UserReelsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UserReelsProvider && other.uid == uid;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, uid.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin UserReelsRef on AutoDisposeStreamProviderRef<List<PostModel>> {
  /// The parameter `uid` of this provider.
  String get uid;
}

class _UserReelsProviderElement
    extends AutoDisposeStreamProviderElement<List<PostModel>>
    with UserReelsRef {
  _UserReelsProviderElement(super.provider);

  @override
  String get uid => (origin as UserReelsProvider).uid;
}

String _$userBookmarksHash() => r'4a45a8d266839aab009a73ec485f7f6e868dc6cd';

/// See also [userBookmarks].
@ProviderFor(userBookmarks)
const userBookmarksProvider = UserBookmarksFamily();

/// See also [userBookmarks].
class UserBookmarksFamily extends Family<AsyncValue<List<PostModel>>> {
  /// See also [userBookmarks].
  const UserBookmarksFamily();

  /// See also [userBookmarks].
  UserBookmarksProvider call(List<String> postIds) {
    return UserBookmarksProvider(postIds);
  }

  @override
  UserBookmarksProvider getProviderOverride(
    covariant UserBookmarksProvider provider,
  ) {
    return call(provider.postIds);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'userBookmarksProvider';
}

/// See also [userBookmarks].
class UserBookmarksProvider extends AutoDisposeFutureProvider<List<PostModel>> {
  /// See also [userBookmarks].
  UserBookmarksProvider(List<String> postIds)
    : this._internal(
        (ref) => userBookmarks(ref as UserBookmarksRef, postIds),
        from: userBookmarksProvider,
        name: r'userBookmarksProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$userBookmarksHash,
        dependencies: UserBookmarksFamily._dependencies,
        allTransitiveDependencies:
            UserBookmarksFamily._allTransitiveDependencies,
        postIds: postIds,
      );

  UserBookmarksProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.postIds,
  }) : super.internal();

  final List<String> postIds;

  @override
  Override overrideWith(
    FutureOr<List<PostModel>> Function(UserBookmarksRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: UserBookmarksProvider._internal(
        (ref) => create(ref as UserBookmarksRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        postIds: postIds,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<PostModel>> createElement() {
    return _UserBookmarksProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UserBookmarksProvider && other.postIds == postIds;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, postIds.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin UserBookmarksRef on AutoDisposeFutureProviderRef<List<PostModel>> {
  /// The parameter `postIds` of this provider.
  List<String> get postIds;
}

class _UserBookmarksProviderElement
    extends AutoDisposeFutureProviderElement<List<PostModel>>
    with UserBookmarksRef {
  _UserBookmarksProviderElement(super.provider);

  @override
  List<String> get postIds => (origin as UserBookmarksProvider).postIds;
}

String _$githubTopReposHash() => r'0ddbc50a9d32544fba42a2ef38870329581bc7c3';

/// See also [githubTopRepos].
@ProviderFor(githubTopRepos)
const githubTopReposProvider = GithubTopReposFamily();

/// See also [githubTopRepos].
class GithubTopReposFamily extends Family<AsyncValue<List<dynamic>>> {
  /// See also [githubTopRepos].
  const GithubTopReposFamily();

  /// See also [githubTopRepos].
  GithubTopReposProvider call(String username) {
    return GithubTopReposProvider(username);
  }

  @override
  GithubTopReposProvider getProviderOverride(
    covariant GithubTopReposProvider provider,
  ) {
    return call(provider.username);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'githubTopReposProvider';
}

/// See also [githubTopRepos].
class GithubTopReposProvider extends AutoDisposeFutureProvider<List<dynamic>> {
  /// See also [githubTopRepos].
  GithubTopReposProvider(String username)
    : this._internal(
        (ref) => githubTopRepos(ref as GithubTopReposRef, username),
        from: githubTopReposProvider,
        name: r'githubTopReposProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$githubTopReposHash,
        dependencies: GithubTopReposFamily._dependencies,
        allTransitiveDependencies:
            GithubTopReposFamily._allTransitiveDependencies,
        username: username,
      );

  GithubTopReposProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.username,
  }) : super.internal();

  final String username;

  @override
  Override overrideWith(
    FutureOr<List<dynamic>> Function(GithubTopReposRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: GithubTopReposProvider._internal(
        (ref) => create(ref as GithubTopReposRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        username: username,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<dynamic>> createElement() {
    return _GithubTopReposProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GithubTopReposProvider && other.username == username;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, username.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin GithubTopReposRef on AutoDisposeFutureProviderRef<List<dynamic>> {
  /// The parameter `username` of this provider.
  String get username;
}

class _GithubTopReposProviderElement
    extends AutoDisposeFutureProviderElement<List<dynamic>>
    with GithubTopReposRef {
  _GithubTopReposProviderElement(super.provider);

  @override
  String get username => (origin as GithubTopReposProvider).username;
}

String _$profileStatsHash() => r'fd67401effee124eb7e49d4e5a32baf273cd4a9f';

/// See also [profileStats].
@ProviderFor(profileStats)
const profileStatsProvider = ProfileStatsFamily();

/// See also [profileStats].
class ProfileStatsFamily extends Family<({int posts, int likes})> {
  /// See also [profileStats].
  const ProfileStatsFamily();

  /// See also [profileStats].
  ProfileStatsProvider call(String uid) {
    return ProfileStatsProvider(uid);
  }

  @override
  ProfileStatsProvider getProviderOverride(
    covariant ProfileStatsProvider provider,
  ) {
    return call(provider.uid);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'profileStatsProvider';
}

/// See also [profileStats].
class ProfileStatsProvider
    extends AutoDisposeProvider<({int posts, int likes})> {
  /// See also [profileStats].
  ProfileStatsProvider(String uid)
    : this._internal(
        (ref) => profileStats(ref as ProfileStatsRef, uid),
        from: profileStatsProvider,
        name: r'profileStatsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$profileStatsHash,
        dependencies: ProfileStatsFamily._dependencies,
        allTransitiveDependencies:
            ProfileStatsFamily._allTransitiveDependencies,
        uid: uid,
      );

  ProfileStatsProvider._internal(
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
    ({int posts, int likes}) Function(ProfileStatsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ProfileStatsProvider._internal(
        (ref) => create(ref as ProfileStatsRef),
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
  AutoDisposeProviderElement<({int posts, int likes})> createElement() {
    return _ProfileStatsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ProfileStatsProvider && other.uid == uid;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, uid.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ProfileStatsRef on AutoDisposeProviderRef<({int posts, int likes})> {
  /// The parameter `uid` of this provider.
  String get uid;
}

class _ProfileStatsProviderElement
    extends AutoDisposeProviderElement<({int posts, int likes})>
    with ProfileStatsRef {
  _ProfileStatsProviderElement(super.provider);

  @override
  String get uid => (origin as ProfileStatsProvider).uid;
}

String _$profileControllerHash() => r'0bc05653ba2a807084080c7a3a4c4c5077e899a3';

/// See also [ProfileController].
@ProviderFor(ProfileController)
final profileControllerProvider =
    AutoDisposeAsyncNotifierProvider<ProfileController, void>.internal(
      ProfileController.new,
      name: r'profileControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$profileControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ProfileController = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
