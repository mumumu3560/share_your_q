import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:http_parser/http_parser.dart'; // 追加
import "dart:async";

Future<int> uploadImage(String uploadUrl, PlatformFile file) async {
  try {
    //final Uint8List imageBytes = await file.bytes!; // PlatformFileをUint8Listに変換
    final Uint8List imageBytes = file.bytes!; // PlatformFileをUint8Listに変換
    print(uploadUrl);
    // Uriクラスを使用してURLを解析
    Uri uri = Uri.parse(uploadUrl);
    
    // パスの一部（ファイル名）を取得
    String filename = uri.pathSegments.last;

    print(filename);

    final request = http.MultipartRequest('POST', Uri.parse(uploadUrl))
      ..files.add(
        http.MultipartFile.fromBytes(
          'file',
          imageBytes,
          filename: filename,
          contentType: MediaType('image', file.extension!.substring(1)),
        ),
      );

    /*
    
     */
    print("responseの前");
    print(uploadUrl);
    http.Response response;

    try{
      //ここで止まってしまう
      response = await http.Response.fromStream(await request.send().timeout(const Duration(seconds: 10)));
      print("aaaaa");
    }  catch (e){
      print("レスポンスの取得中にエラーが発生しました: $e");
      return 5;
    }


    /*
    // http.Response.fromStream の結果を Future オブジェクトとして受け取る
    http.Response response = await http.Response.fromStream(
        await request.send().timeout(Duration(seconds: 3)))
        .catchError((error) {
      // エラーが発生した場合の処理
      print("レスポンスの取得中にエラーが発生しました: $error");
      return http.Response('Error occurred', 500); // エラーの疑似的なレスポンスを返す
    });
     */
    


    print(response);
    if (response.statusCode == 200) {
      // アップロードが成功した場合
      print("画像アップロード成功");
      return 0;
    } else {
      // アップロードエラーの場合の処理
      print("画像アップロードエラー: ${response.statusCode}");
      print("エラーレスポンス: ${response.body}");
      return 1;
    }
  } catch (e) {
    // ネットワークエラーの場合の処理
    print("ネットワークエラー: $e");
    return 2;
  }
}
