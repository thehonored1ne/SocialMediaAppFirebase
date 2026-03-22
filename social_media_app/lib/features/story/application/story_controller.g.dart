// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'story_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$activeStoriesHash() => r'228474a19bdd33420fe56de360f43df37f16c673';

/// See also [activeStories].
@ProviderFor(activeStories)
final activeStoriesProvider =
    AutoDisposeStreamProvider<List<StoryModel>>.internal(
      activeStories,
      name: r'activeStoriesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$activeStoriesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ActiveStoriesRef = AutoDisposeStreamProviderRef<List<StoryModel>>;
String _$groupedStoriesHash() => r'a25897364d178eff30282668fae93274584394c9';

/// See also [groupedStories].
@ProviderFor(groupedStories)
final groupedStoriesProvider =
    AutoDisposeStreamProvider<Map<String, List<StoryModel>>>.internal(
      groupedStories,
      name: r'groupedStoriesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$groupedStoriesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GroupedStoriesRef =
    AutoDisposeStreamProviderRef<Map<String, List<StoryModel>>>;
String _$storyControllerHash() => r'2ef93643c42f31c1845db3f4dd529f990773297c';

/// See also [StoryController].
@ProviderFor(StoryController)
final storyControllerProvider =
    AutoDisposeAsyncNotifierProvider<StoryController, void>.internal(
      StoryController.new,
      name: r'storyControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$storyControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$StoryController = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
