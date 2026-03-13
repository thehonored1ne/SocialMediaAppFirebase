import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'scroll_notifier.g.dart';

@riverpod
class HomeScrollNotifier extends _$HomeScrollNotifier {
  @override
  int build() => 0;

  void trigger() {
    state++;
  }
}
