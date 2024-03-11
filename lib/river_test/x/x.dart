import "package:riverpod_annotation/riverpod_annotation.dart";
part "x.g.dart";

@riverpod
class S1Notifier extends _$S1Notifier {
  @override 
  int build(){
    return 0;
  }

  void updateState(){
    final oldState = state;
    final newState = oldState + 1;
    state = newState;
    
  }

}

//flutter pub run build_runner build --delete-conflicting-outputs