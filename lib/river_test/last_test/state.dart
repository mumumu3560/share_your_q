import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'shikoku.dart';
part 'state.g.dart';

@riverpod
class ShikokuNotifier extends _$ShikokuNotifier {
  @override
  Shikoku build() {
    // 人口
    return const Shikoku(
      kagawa: 93,
      tokushima: 70,
      kouchi: 69,
      ehime: 130,
    );
  }

  void updateKagawa() {
    final oldState = state;
    final newState = oldState.copyWith(
      kagawa: oldState.kagawa + 1,
    );
    state = newState;
  }

  void updateTokushima() {
    final oldState = state;
    final newState = oldState.copyWith(
      tokushima: oldState.tokushima + 1,
    );
    state = newState;
  }

  void updateKochi() {
    final oldState = state;
    final newState = oldState.copyWith(
      kouchi: oldState.kouchi + 1,
    );
    state = newState;
  }

  void updateEhime() {
    final oldState = state;
    final newState = oldState.copyWith(
      ehime: oldState.ehime + 1,
    );
    state = newState;
  }
}