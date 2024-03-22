//
//import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'package:share_your_q/env/env.dart';

Future<Uint8List?> fetchImage(String? imageId) async {

  String imageIdNext = imageId!;


  
  try {
    final response = await http.get(
      Uri.parse(Env.c2),
      headers: {
        'Content-Type': 'application/json',
        'image-id': imageIdNext, // 画像IDを指定
      },
    );

    if (response.statusCode == 200) {
      // 成功時の処理
      // response.bodyには取得したデータが入っています。
      // ここではUint8Listに変換して返しています。
      return Uint8List.fromList(response.bodyBytes);
    } else {

      try{
        final response = await http.get(
          Uri.parse(Env.c1),
          headers: {
            'Content-Type': 'application/json',
            'image-id': imageIdNext, // 画像IDを指定
          },
        );

        return Uint8List.fromList(response.bodyBytes);
      }
      catch(e){
        
      }
    }
  } catch (error) {
    // エラーが発生した場合の処理
    return null;
  }
  return null;
}
