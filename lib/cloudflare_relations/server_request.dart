import 'package:http/http.dart' as http;
import "dart:convert";
import 'package:share_your_q/env/env.dart';

class ImageSelectionAndRequest {
  final String knownUserInfo;
  final bool isProblem;
  final String type;
  final Function(String, String) onServerResponseReceived;
  

  ImageSelectionAndRequest({
    required this.knownUserInfo,
    required this.onServerResponseReceived,
    required this.isProblem,
    required this.type,
  });


  Future<int> sendRequest() async {
    final serverUrl = Env.c4;

    try {
      
      //bodyにはuserIdとtypeを送る
      //typeにはcreate、update等を送る。
      //createは自分の問題の投稿の際に使用
      //updateは自分の問題の編集の際に使用


      final response = await http.post(
        Uri.parse(serverUrl),
        body: {
          "userId": knownUserInfo,
          "type": type,
          "proOrCom": isProblem.toString(),
        },
      );


      if (response.statusCode == 200) {
        final serverResponse = json.decode(response.body); // JSON形式のレスポンスをパース
        // サーバーから成功レスポンスを受け取った場合
        //レスポンスの形は{"customID": "xxxx", "directUploadUrl": "xxxx"}となる。これらの情報が正しい場合に画像をアップロードする。
        if (serverResponse.containsKey('customId') && serverResponse.containsKey('uploadURL')) {
          final customId = serverResponse['customId'];
          final directUploadUrl = serverResponse['uploadURL'];
        
          onServerResponseReceived(customId, directUploadUrl);
        }

        return 0;

      } else {
        return 1;
        
      }
    } catch (e) {
      return 2;
      
    }

  }
}

