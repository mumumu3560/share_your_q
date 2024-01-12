import 'package:http/http.dart' as http;
import "dart:convert";

import 'package:flutter_dotenv/flutter_dotenv.dart';

class ImageSelectionAndRequest {
  final String knownUserInfo;
  final Function(String, String) onServerResponseReceived;
  

  ImageSelectionAndRequest({
    required this.knownUserInfo,
    required this.onServerResponseReceived,
  });


  Future<int> sendRequest() async {
    await dotenv.load(fileName: '.env');
    final serverUrl = dotenv.get('CLOUDFLARE_DIRECT_URL');

    try {
      
      //bodyにはuserIdとtypeを送る
      //typeにはcreate、update等を送る。
      //createは自分の問題の投稿の際に使用
      //updateは自分の問題の編集の際に使用
      print("here");
      print("serverRequest");
      print(serverUrl);
      final response = await http.post(
        Uri.parse(serverUrl),
        body: {
          "userId": knownUserInfo,
        },
      );


      if (response.statusCode == 200) {
        print("サーバーから成功レスポンスを受け取りました");
        final serverResponse = json.decode(response.body); // JSON形式のレスポンスをパース
        print(serverResponse);
        // サーバーから成功レスポンスを受け取った場合
        //レスポンスの形は{"customID": "xxxx", "directUploadUrl": "xxxx"}となる。これらの情報が正しい場合に画像をアップロードする。
        if (serverResponse.containsKey('customId') && serverResponse.containsKey('uploadURL')) {
          final customId = serverResponse['customId'];
          final directUploadUrl = serverResponse['uploadURL'];
        
          print(customId);
          print(directUploadUrl);

          onServerResponseReceived(customId, directUploadUrl);
        }

        return 0;

      } else {
        print("サーバーエラー: ${response.statusCode}");
        return 1;
        
      }
    } catch (e) {
      print("ネットワークエラー: $e");
      return 2;
      
    }

  }
}

