import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:share_your_q/image_operations/image_request.dart';
import 'package:share_your_q/cloudflare_relations/server_request.dart';
import 'package:share_your_q/image_operations/image_select.dart';
import 'package:share_your_q/image_operations/image_upload.dart';
import 'package:share_your_q/utils/various.dart';

import 'dart:typed_data';


//問題を作るページ

//TODO textformfieldの長さの制限を考える。


class IconSettings extends StatefulWidget {

  final Uint8List? profileImage;

  const IconSettings({
    Key? key,
    required this.profileImage,
  }): super(key: key);


  @override
  _IconSettingsState createState() => _IconSettingsState();
}

class _IconSettingsState extends State<IconSettings> {

  String newProfileImageId = "";
  PlatformFile? selectedImage1;
  String? directUploadUrl1;

  Uint8List? profileImageBytes = Uint8List(0);

  @override
  void initState() {

    // TODO: implement initState
    super.initState();


  }


  Future<int> getImageUploadUrls(bool isOne) async {

  int response1;
  try{
      
    //ここではknownUserInfoとonServerResponseReceived(関数)が必要なのでそれを渡す。
    response1 = await ImageSelectionAndRequest(
      knownUserInfo: myUserId,
      isProblem: isOne,
      type: "setting",
      onServerResponseReceived: (customId, directUploadUrl) {
        setState(() {
          newProfileImageId = customId;
          directUploadUrl1 = directUploadUrl;
        });
      },

    
    ).sendRequest().timeout(const Duration(seconds: 10));

  } catch(e){
    response1 = 1;
  }

  if(response1 == 0){
    //context.showErrorSnackBar(message: "サーバーエラーが発生しました。");
  }
  else if(response1 == 1){

    if(mounted){
      context.showErrorSnackBar(message: "サーバーエラー1");
    }
    
    return 1;
  }
  else{
    if(mounted){
      context.showErrorSnackBar(message: "ネットワークエラー1。");
    }
    
    return 2;
  }

  return 0;

  }


  // Supabaseに情報を送信する関数
  Future<void> sendInfoToSupabase() async {
    // TODO: Supabaseに情報を送信するロジックを実装

    try{

      await supabase
        .from("profiles")
        .update({
          //"username": userName,
          "profile_image_id": newProfileImageId,
        })
        .eq("id", myUserId);

      return ;


    } on PostgrestException catch (error){
      if(mounted){
        context.showErrorSnackBar(message: error.message);
      }
      return ;
    } catch(_){
      if(mounted){
      context.showErrorSnackBar(message: unexpectedErrorMessage);
      }
      return ;
    }



  }

  // 選択した画像をアップロードする関数
  Future<int> uploadSelectedImage(PlatformFile? selectedImage, String customId, String? directUploadUrl) async{
    if (selectedImage != null && directUploadUrl != null) {
      final uploadUrl = directUploadUrl;
      int responseNum;
      try{
        responseNum = await uploadImage(uploadUrl, selectedImage).timeout(const Duration(seconds: 10));
      }catch(e){
        responseNum = 1;
      }

      if(responseNum != 0){
        return 1;
      }
      else{
        return 0;
      }

    }
    else{
      return 1;
    }

  }

  Future<void> doUploadSeries() async{

    showLoadingDialog(context,"処理中...");


    int response1 = await getImageUploadUrls(true);

    if(response1 != 0){
      if(mounted){
        Navigator.of(context).pop();
      }

      if(mounted){
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(

              title: const Text("エラー"),
              content: const Text("サーバーエラーにより、画像の更新ができませんでした。"),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // ダイアログを閉じる
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );

      }

      
      
      return;
    }

    if(mounted){
      Navigator.of(context).pop();
      showLoadingDialog(context, "情報を送信中...");
    }

    await sendInfoToSupabase();

    int response2 = await uploadSelectedImage(selectedImage1, newProfileImageId, directUploadUrl1);

    if(response2 != 0){
      if(mounted){
        Navigator.of(context).pop();
      }

      if(mounted){
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(

              title: const Text("エラー"),
              content: const Text("サーバーエラーにより、画像の更新ができませんでした。"),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // ダイアログを閉じる
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );

      }

      return;
    }

    if(mounted){
      // ダイアログを閉じる
      Navigator.of(context).pop();
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Great!"),
            content: const Text("アイコンの更新が完了しました！"),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // ダイアログを閉じる
                },
                child: const Text('閉じる'),
              ),
            ],
          );
        },
      );
    }
  }
  
  
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.green),
          ),
          child: Column(
            children: [
        
              Center(
                child: Column(
                  children: [
        
                    const SizedBox(height: 20),
        
                    const Text("現在のアイコン", style: TextStyle(fontSize: 20),),
        
                    const SizedBox(height: 20),
        
                    CircleAvatar(
                      backgroundImage: profileImageBytes != null && profileImageBytes != Uint8List(0)
                        ? MemoryImage(widget.profileImage!)
                        : null,//NetworkImage(dotenv.get("CLOUDFLARE_IMAGE_URL")) as ImageProvider<Object>?,
                      radius: 30,
                    ),
        
                    const SizedBox(height: 30),
        
                    const Text("新しいアイコン", style: TextStyle(fontSize: 20),),
        
                    const SizedBox(height: 20),
        
        
                    if (selectedImage1 == null)
                      Column(
                        children: [
                          const Text(
                            "アイコン画像を選択してください",
                            style: TextStyle(color: Colors.red),
                          ),
                          ImageSelectionWidget(
                            onImageSelected: (image) {
                              setState(() {
                                selectedImage1 = image;
                              });
                            },
                          ),
                        ],
                      )
                    else
                      Column(
                        children: [
                          Image.memory(
                            selectedImage1!.bytes!,
                            height: 150,
                          ),
                          const SizedBox(height: 10),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                selectedImage1 = null;
                              });
                            },
                            child: const Text(
                              "画像を削除",
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
        
                    const SizedBox(height: 20),
        
                    ElevatedButton(
                      onPressed: () async {
                        if(selectedImage1 != null){
                          await doUploadSeries();
                          //Navigator.pop(context);
                        }
                        else{
                          context.showErrorSnackBar(message: "画像を選択してください。");
                        }
                      },
                      child: const Text("アイコンを更新"),
                    ),
                  ],
                ),
              ),
        
              const SizedBox(height: 20),
        
        
            ],
          ),
        ),
      ),
    );
  }

}







































