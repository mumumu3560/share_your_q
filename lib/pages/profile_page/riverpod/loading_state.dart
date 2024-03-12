import "package:riverpod_annotation/riverpod_annotation.dart";

part"loading_state.g.dart";

// データを管理するクラス
//二つのファイルでローディングが終わったときにisLoadingをfalseにすることができるようなクラスを作りたい
@riverpod
class LoadingNotifier extends _$LoadingNotifier {

  @override 
  Future<bool> build(){
    

  }

  void updateState(){
    final oldState = state;
    final newState = oldState + 1;
    state = newState;
    
  }

  // データを変更する関数
  void updateState() async {
    // データを上書き
    state = const AsyncValue.loading();
    // 3秒まつ
    const sec3 = Duration(seconds: 3);
    await Future.delayed(sec3);
    // データを上書き
    state = const AsyncValue.data('新しいデータ');
  }

}