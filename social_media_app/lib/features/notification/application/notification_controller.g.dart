// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$notificationsStreamHash() =>
    r'd79c684b4956034e2ea8b2f18ad5d90484e52d7b';

/// See also [notificationsStream].
@ProviderFor(notificationsStream)
final notificationsStreamProvider =
    AutoDisposeStreamProvider<List<NotificationModel>>.internal(
      notificationsStream,
      name: r'notificationsStreamProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$notificationsStreamHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef NotificationsStreamRef =
    AutoDisposeStreamProviderRef<List<NotificationModel>>;
String _$notificationFilterHash() =>
    r'e9988bad13c62a4a4cfd2627735ac7efd7570e9a';

/// See also [NotificationFilter].
@ProviderFor(NotificationFilter)
final notificationFilterProvider =
    AutoDisposeNotifierProvider<NotificationFilter, String>.internal(
      NotificationFilter.new,
      name: r'notificationFilterProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$notificationFilterHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$NotificationFilter = AutoDisposeNotifier<String>;
String _$notificationControllerHash() =>
    r'828ef8608db21ddb2dfe5d29981700c2a60db970';

/// See also [NotificationController].
@ProviderFor(NotificationController)
final notificationControllerProvider =
    AutoDisposeAsyncNotifierProvider<NotificationController, void>.internal(
      NotificationController.new,
      name: r'notificationControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$notificationControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$NotificationController = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
