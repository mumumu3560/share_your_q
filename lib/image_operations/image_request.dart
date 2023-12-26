//
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';

Future<Uint8List> fetchImage(String imageId) async {
  try {
    final response = await http.get(
      Uri.parse(dotenv.get('CLOUDFLARE_CACHE_URL')),
      headers: {
        'Content-Type': 'application/json',
        'image-id': imageId, // 画像IDを指定
      },
    );

    if (response.statusCode == 200) {
      // 成功時の処理
      print('Success!');
      // response.bodyには取得したデータが入っています。
      // ここではUint8Listに変換して返しています。
      return Uint8List.fromList(response.bodyBytes);
    } else {
      // エラー時の処理
      print('Failed with status: ${response.statusCode}');
      return Uint8List(0);
    }
  } catch (error) {
    // エラーが発生した場合の処理
    print('Error: $error');
    return Uint8List(0);
  }
}
