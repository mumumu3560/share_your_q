import 'package:riverpod_annotation/riverpod_annotation.dart';

part "tab_notifier.g.dart";

@riverpod

class TabNotifier extends _$TabNotifier {
  @override 
  int build(){
    return 0;
  }

  void updateState(int page){
    final oldState = state;
    final newState = page;
    state = newState;
  }
}