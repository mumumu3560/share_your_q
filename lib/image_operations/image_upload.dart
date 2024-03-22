import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:http_parser/http_parser.dart'; // 追加
import "dart:async";

Future<int> uploadImage(String uploadUrl, PlatformFile file) async {
  try {
    //final Uint8List imageBytes = await file.bytes!; // PlatformFileをUint8Listに変換
    final Uint8List imageBytes = file.bytes!; // PlatformFileをUint8Listに変換

    // Uriクラスを使用してURLを解析
    Uri uri = Uri.parse(uploadUrl);
    
    // パスの一部（ファイル名）を取得
    String filename = uri.pathSegments.last;


    final request = http.MultipartRequest('POST', Uri.parse(uploadUrl))
      ..files.add(
        http.MultipartFile.fromBytes(
          'file',
          imageBytes,
          filename: filename,
          contentType: MediaType('image', file.extension!.substring(1)),
        ),
      );

    
    http.Response response;

    try{
      //ここで止まってしまう
      response = await http.Response.fromStream(await request.send().timeout(const Duration(seconds: 10)));
      
    }  catch (e){
      return 5;
    }


    if (response.statusCode == 200) {
      return 0;
    } else {
      return 1;
    }
  } catch (e) {
    return 2;
  }
}
