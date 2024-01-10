import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';

import 'package:timeago/timeago.dart';

import 'dart:collection';
import 'dart:typed_data';

import "package:share_your_q/image_operations/image_request.dart";

//https://www.kamo-it.org/blog/flutter-extension/
//https://zenn.dev/dshukertjr/books/flutter-supabase-chat/viewer/page1

final supabase = Supabase.instance.client;
final myUserId = supabase.auth.currentUser!.id.toString();
//プリローダー
const preloader = Center(child: CircularProgressIndicator(color: Colors.orange));

// ローディングスピナーを含むダイアログを表示する関数
void showLoadingDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    barrierDismissible: false, // ユーザーがダイアログ外をタップして閉じられないようにする
    builder: (BuildContext context) {
      return AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(color: Colors.orange),
            SizedBox(width: 20),
            Text(message), // ローディング中のメッセージ
          ],
        ),
      );
    },
  );
}

void showFinisheDialog(BuildContext context, String title, String message) {
  // 完了メッセージを表示
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // ダイアログを閉じる
            },
            child: Text('OK'),
          ),
        ],
      );
    },
  );
}

const formSpacer = SizedBox(width: 16, height: 16);

//フォームのパディング
const formPadding = EdgeInsets.symmetric(vertical: 20, horizontal: 16);

//予期せぬエラーが起きた際のエラーメッセージ
const unexpectedErrorMessage = '予期せぬエラーが起きました';



extension ShowSnackBar on BuildContext {
  /// 標準的なSnackbarを表示
  void showSnackBar({
    required String message,
    Color backgroundColor = Colors.black,
  }) {
    ScaffoldMessenger.of(this).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: backgroundColor,
    ));
  }

  /// エラーが起きた際のSnackbarを表示
  void showErrorSnackBar({required String message}) {
    showSnackBar(
      message: message,
      backgroundColor: Theme.of(this).colorScheme.error,
    );
  }

  /// 成功した際のSnackbarを表示
  void showSuccessSnackBar({required String message}) {
    showSnackBar(
      message: message,
      backgroundColor: Theme.of(this).colorScheme.secondary,
    );
  }
}


/*

/// チャットのメッセージを表示するためのウィジェット
class ChatBubble extends StatelessWidget {

  final Map<String, dynamic> commentData;
  
  const ChatBubble({
    Key? key,
    required this.commentData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child: Row(
        children: [
            const SizedBox(width: 12),
            GestureDetector(

              child: CircleAvatar(
                radius: 20,
                child: Image.network("https://storage.divcurious.com/rufy.png"),
                /*
                child: Icon(
                  Icons.error_outline,
                  color: Colors.blue,
                  size: 40,
                ),
                 */

              ),

              onTap: () async{
                //profilepageに飛ぶ

              },


            ),


            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  commentData["user_name"],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 4),

                Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 14,
                  ),
                  decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(8),
                  ),
                  child: SelectionArea(
                    child: Text(
                      commentData["comments"],
                      style: TextStyle(
                        fontSize: 14,
                      ),
                  
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Text(format(DateTime.parse(commentData["created_at"]), locale: 'ja')),
             // 時間を表示
            const SizedBox(width: 60),
        ],
      ),
    );
  }
}
 */



class ShowDialogWithFunction {
  final String title;
  final String shownMessage;
  final Future<void> Function() functionOnPressed;
  final BuildContext context;
  

  ShowDialogWithFunction({
    required this.title,
    required this.shownMessage,
    required this.functionOnPressed,
    required this.context,
  });

  Future<void> show() async{
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(shownMessage),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // ダイアログを閉じる
              },
              child: Text('キャンセル'),
            ),
            TextButton(
              onPressed: () async{
                Navigator.of(context).pop(); // ダイアログを閉じる
                await functionOnPressed();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }


}



//https://qiita.com/kokogento/items/87aaf0a0fbc192e51504

//ここは機種に依らないサイズを決めるclass
class SizeConfig {
  static MediaQueryData? _mediaQueryData;
  static double? screenWidth;
  static double? screenHeight;
  static double? blockSizeHorizontal;
  static double? blockSizeVertical;

  static double? _safeAreaHorizontal;
  static double? _safeAreaVertical;
  static double? safeBlockHorizontal;
  static double? safeBlockVertical;

  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData!.size.width;
    screenHeight = _mediaQueryData!.size.height;
    blockSizeHorizontal = screenWidth! / 100;
    blockSizeVertical = screenHeight! / 100;

    _safeAreaHorizontal =
        _mediaQueryData!.padding.left + _mediaQueryData!.padding.right;

    _safeAreaVertical =
        _mediaQueryData!.padding.top + _mediaQueryData!.padding.bottom;
        
    safeBlockHorizontal = (screenWidth! - _safeAreaHorizontal!) / 100;
    safeBlockVertical = (screenHeight! - _safeAreaVertical!) / 100;
  }
}





class LRUCache {
  late int _capacity;
  late LinkedHashMap<String, Uint8List> _cache;

  LRUCache(this._capacity) : _cache = LinkedHashMap<String, Uint8List>();

  factory LRUCache.create(int capacity) {
    return LRUCache(capacity);
  }

  void put(String key, Uint8List value) {
    // キャパシティを超えた場合、最も古いエントリーを削除
    if (_cache.length >= _capacity) {
      final oldestKey = _cache.keys.first;
      _cache.remove(oldestKey);
    }

    // 新しいエントリーを追加
    _cache[key] = value;
  }

  Uint8List? get(String key) {
    // キーが存在する場合、そのエントリーを返す（最近使用されたものとしてマーク）
    if (_cache.containsKey(key)) {
      final value = _cache[key]!;
      _cache.remove(key);
      _cache[key] = value; // もう一度追加することで最近使用されたものとしてマーク
      return value;
    } else {
      return null;
    }
  }
}

//キャッシュのインスタンス
var cache = LRUCache.create(20);


Future<Uint8List?> fetchImageWithCache(String? imageId) async {
  // キャッシュから画像を取得

  print("ここはfetchImageWithCacheの中です");
  print(imageId);

  if(imageId == null){
    return Uint8List(0);
  }
  Uint8List? cachedImage = cache.get(imageId);
  if (cachedImage != null) {
    // キャッシュにある場合はキャッシュから返す
    return cachedImage;
  }

  // キャッシュにない場合は既存の fetchImage 関数を呼ぶ
  Uint8List? imageBytes = await fetchImage(imageId);

  if(imageBytes == null){
    print("ここに入ってくるかな？");
    print("ここじゃなかったらどうなるんだ？？");
    return null;
  }


  // 取得した画像をキャッシュに保存
  cache.put(imageId, imageBytes);
  return imageBytes;
}


Widget BannerContainer(){
  return Container(
    height: SizeConfig.blockSizeVertical! * 10,
    //height: 100 ,
    width: double.infinity,
    color: Colors.white,
    //TODO ビルドリリースの時のみ
    //child: _adMob.getAdBanner(),
  );
}