// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$postsStreamHash() => r'29a4edd0647e65dc001b9c0c4d12ae91df39b582';

/// See also [postsStream].
@ProviderFor(postsStream)
final postsStreamProvider = AutoDisposeStreamProvider<List<PostModel>>.internal(
  postsStream,
  name: r'postsStreamProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$postsStreamHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PostsStreamRef = AutoDisposeStreamProviderRef<List<PostModel>>;
String _$postHash() => r'4c0e3eba7d1d2dd00af96449f55d1c14c1106d9b';

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

/// See also [post].
@ProviderFor(post)
const postProvider = PostFamily();

/// See also [post].
class PostFamily extends Family<AsyncValue<PostModel>> {
  /// See also [post].
  const PostFamily();

  /// See also [post].
  PostProvider call(String postId) {
    return PostProvider(postId);
  }

  @override
  PostProvider getProviderOverride(covariant PostProvider provider) {
    return call(provider.postId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'postProvider';
}

/// See also [post].
class PostProvider extends AutoDisposeStreamProvider<PostModel> {
  /// See also [post].
  PostProvider(String postId)
    : this._internal(
        (ref) => post(ref as PostRef, postId),
        from: postProvider,
        name: r'postProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$postHash,
        dependencies: PostFamily._dependencies,
        allTransitiveDependencies: PostFamily._allTransitiveDependencies,
        postId: postId,
      );

  PostProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.postId,
  }) : super.internal();

  final String postId;

  @override
  Override overrideWith(Stream<PostModel> Function(PostRef provider) create) {
    return ProviderOverride(
      origin: this,
      override: PostProvider._internal(
        (ref) => create(ref as PostRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        postId: postId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<PostModel> createElement() {
    return _PostProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PostProvider && other.postId == postId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, postId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PostRef on AutoDisposeStreamProviderRef<PostModel> {
  /// The parameter `postId` of this provider.
  String get postId;
}

class _PostProviderElement extends AutoDisposeStreamProviderElement<PostModel>
    with PostRef {
  _PostProviderElement(super.provider);

  @override
  String get postId => (origin as PostProvider).postId;
}

String _$postCommentsCountHash() => r'8d4659740e0a5503f8765cfa5bd7d60321c30a90';

/// See also [postCommentsCount].
@ProviderFor(postCommentsCount)
const postCommentsCountProvider = PostCommentsCountFamily();

/// See also [postCommentsCount].
class PostCommentsCountFamily extends Family<AsyncValue<int>> {
  /// See also [postCommentsCount].
  const PostCommentsCountFamily();

  /// See also [postCommentsCount].
  PostCommentsCountProvider call(String postId) {
    return PostCommentsCountProvider(postId);
  }

  @override
  PostCommentsCountProvider getProviderOverride(
    covariant PostCommentsCountProvider provider,
  ) {
    return call(provider.postId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'postCommentsCountProvider';
}

/// See also [postCommentsCount].
class PostCommentsCountProvider extends AutoDisposeStreamProvider<int> {
  /// See also [postCommentsCount].
  PostCommentsCountProvider(String postId)
    : this._internal(
        (ref) => postCommentsCount(ref as PostCommentsCountRef, postId),
        from: postCommentsCountProvider,
        name: r'postCommentsCountProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$postCommentsCountHash,
        dependencies: PostCommentsCountFamily._dependencies,
        allTransitiveDependencies:
            PostCommentsCountFamily._allTransitiveDependencies,
        postId: postId,
      );

  PostCommentsCountProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.postId,
  }) : super.internal();

  final String postId;

  @override
  Override overrideWith(
    Stream<int> Function(PostCommentsCountRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PostCommentsCountProvider._internal(
        (ref) => create(ref as PostCommentsCountRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        postId: postId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<int> createElement() {
    return _PostCommentsCountProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PostCommentsCountProvider && other.postId == postId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, postId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PostCommentsCountRef on AutoDisposeStreamProviderRef<int> {
  /// The parameter `postId` of this provider.
  String get postId;
}

class _PostCommentsCountProviderElement
    extends AutoDisposeStreamProviderElement<int>
    with PostCommentsCountRef {
  _PostCommentsCountProviderElement(super.provider);

  @override
  String get postId => (origin as PostCommentsCountProvider).postId;
}

String _$postCommentsHash() => r'84311015e26322237db5e65038c414574724578d';

/// See also [postComments].
@ProviderFor(postComments)
const postCommentsProvider = PostCommentsFamily();

/// See also [postComments].
class PostCommentsFamily extends Family<AsyncValue<List<CommentModel>>> {
  /// See also [postComments].
  const PostCommentsFamily();

  /// See also [postComments].
  PostCommentsProvider call(String postId) {
    return PostCommentsProvider(postId);
  }

  @override
  PostCommentsProvider getProviderOverride(
    covariant PostCommentsProvider provider,
  ) {
    return call(provider.postId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'postCommentsProvider';
}

/// See also [postComments].
class PostCommentsProvider
    extends AutoDisposeStreamProvider<List<CommentModel>> {
  /// See also [postComments].
  PostCommentsProvider(String postId)
    : this._internal(
        (ref) => postComments(ref as PostCommentsRef, postId),
        from: postCommentsProvider,
        name: r'postCommentsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$postCommentsHash,
        dependencies: PostCommentsFamily._dependencies,
        allTransitiveDependencies:
            PostCommentsFamily._allTransitiveDependencies,
        postId: postId,
      );

  PostCommentsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.postId,
  }) : super.internal();

  final String postId;

  @override
  Override overrideWith(
    Stream<List<CommentModel>> Function(PostCommentsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PostCommentsProvider._internal(
        (ref) => create(ref as PostCommentsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        postId: postId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<CommentModel>> createElement() {
    return _PostCommentsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PostCommentsProvider && other.postId == postId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, postId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PostCommentsRef on AutoDisposeStreamProviderRef<List<CommentModel>> {
  /// The parameter `postId` of this provider.
  String get postId;
}

class _PostCommentsProviderElement
    extends AutoDisposeStreamProviderElement<List<CommentModel>>
    with PostCommentsRef {
  _PostCommentsProviderElement(super.provider);

  @override
  String get postId => (origin as PostCommentsProvider).postId;
}

String _$isPostSavedHash() => r'05ea4c84eeb1fb93892ef8c4e91cf0cc9be02706';

/// See also [isPostSaved].
@ProviderFor(isPostSaved)
const isPostSavedProvider = IsPostSavedFamily();

/// See also [isPostSaved].
class IsPostSavedFamily extends Family<AsyncValue<bool>> {
  /// See also [isPostSaved].
  const IsPostSavedFamily();

  /// See also [isPostSaved].
  IsPostSavedProvider call(String postId) {
    return IsPostSavedProvider(postId);
  }

  @override
  IsPostSavedProvider getProviderOverride(
    covariant IsPostSavedProvider provider,
  ) {
    return call(provider.postId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'isPostSavedProvider';
}

/// See also [isPostSaved].
class IsPostSavedProvider extends AutoDisposeStreamProvider<bool> {
  /// See also [isPostSaved].
  IsPostSavedProvider(String postId)
    : this._internal(
        (ref) => isPostSaved(ref as IsPostSavedRef, postId),
        from: isPostSavedProvider,
        name: r'isPostSavedProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$isPostSavedHash,
        dependencies: IsPostSavedFamily._dependencies,
        allTransitiveDependencies: IsPostSavedFamily._allTransitiveDependencies,
        postId: postId,
      );

  IsPostSavedProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.postId,
  }) : super.internal();

  final String postId;

  @override
  Override overrideWith(Stream<bool> Function(IsPostSavedRef provider) create) {
    return ProviderOverride(
      origin: this,
      override: IsPostSavedProvider._internal(
        (ref) => create(ref as IsPostSavedRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        postId: postId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<bool> createElement() {
    return _IsPostSavedProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is IsPostSavedProvider && other.postId == postId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, postId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin IsPostSavedRef on AutoDisposeStreamProviderRef<bool> {
  /// The parameter `postId` of this provider.
  String get postId;
}

class _IsPostSavedProviderElement extends AutoDisposeStreamProviderElement<bool>
    with IsPostSavedRef {
  _IsPostSavedProviderElement(super.provider);

  @override
  String get postId => (origin as IsPostSavedProvider).postId;
}

String _$isFollowingUserHash() => r'8f7defea93b30260a43d0cd70cccb762d1d9ef04';

/// See also [isFollowingUser].
@ProviderFor(isFollowingUser)
const isFollowingUserProvider = IsFollowingUserFamily();

/// See also [isFollowingUser].
class IsFollowingUserFamily extends Family<AsyncValue<bool>> {
  /// See also [isFollowingUser].
  const IsFollowingUserFamily();

  /// See also [isFollowingUser].
  IsFollowingUserProvider call(String targetUid) {
    return IsFollowingUserProvider(targetUid);
  }

  @override
  IsFollowingUserProvider getProviderOverride(
    covariant IsFollowingUserProvider provider,
  ) {
    return call(provider.targetUid);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'isFollowingUserProvider';
}

/// See also [isFollowingUser].
class IsFollowingUserProvider extends AutoDisposeStreamProvider<bool> {
  /// See also [isFollowingUser].
  IsFollowingUserProvider(String targetUid)
    : this._internal(
        (ref) => isFollowingUser(ref as IsFollowingUserRef, targetUid),
        from: isFollowingUserProvider,
        name: r'isFollowingUserProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$isFollowingUserHash,
        dependencies: IsFollowingUserFamily._dependencies,
        allTransitiveDependencies:
            IsFollowingUserFamily._allTransitiveDependencies,
        targetUid: targetUid,
      );

  IsFollowingUserProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.targetUid,
  }) : super.internal();

  final String targetUid;

  @override
  Override overrideWith(
    Stream<bool> Function(IsFollowingUserRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: IsFollowingUserProvider._internal(
        (ref) => create(ref as IsFollowingUserRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        targetUid: targetUid,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<bool> createElement() {
    return _IsFollowingUserProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is IsFollowingUserProvider && other.targetUid == targetUid;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, targetUid.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin IsFollowingUserRef on AutoDisposeStreamProviderRef<bool> {
  /// The parameter `targetUid` of this provider.
  String get targetUid;
}

class _IsFollowingUserProviderElement
    extends AutoDisposeStreamProviderElement<bool>
    with IsFollowingUserRef {
  _IsFollowingUserProviderElement(super.provider);

  @override
  String get targetUid => (origin as IsFollowingUserProvider).targetUid;
}

String _$unreadNotificationsCountHash() =>
    r'd0dd8c69667c7083b4ff056278c9ac48aa986274';

/// See also [unreadNotificationsCount].
@ProviderFor(unreadNotificationsCount)
final unreadNotificationsCountProvider =
    AutoDisposeStreamProvider<int>.internal(
      unreadNotificationsCount,
      name: r'unreadNotificationsCountProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$unreadNotificationsCountHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UnreadNotificationsCountRef = AutoDisposeStreamProviderRef<int>;
String _$unreadChatsCountHash() => r'b38b0d9cdea2556b95304d1d673d17060aa04ab6';

/// See also [unreadChatsCount].
@ProviderFor(unreadChatsCount)
final unreadChatsCountProvider = AutoDisposeStreamProvider<int>.internal(
  unreadChatsCount,
  name: r'unreadChatsCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$unreadChatsCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UnreadChatsCountRef = AutoDisposeStreamProviderRef<int>;
String _$postControllerHash() => r'078240c60408d6125cb0f852d35ac3d82eddcd22';

/// See also [PostController].
@ProviderFor(PostController)
final postControllerProvider =
    AutoDisposeAsyncNotifierProvider<PostController, void>.internal(
      PostController.new,
      name: r'postControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$postControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$PostController = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
