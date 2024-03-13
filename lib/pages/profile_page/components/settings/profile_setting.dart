import 'dart:typed_data';

import 'package:flutter/material.dart';
//TODO Admob
import 'package:share_your_q/admob/anchored_adaptive_banner.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


import 'package:share_your_q/utils/various.dart';


import "package:share_your_q/pages/profile_page/components/settings/icon_setting.dart";

//問題を作るページ

//TODO textformfieldの長さの制限を考える。


class ProfileSettings extends StatefulWidget {


  final Uint8List? profileImage;

  const ProfileSettings({
    Key? key,
    required this.profileImage,
  }): super(key: key);


  @override
  _ProfileSettingsState createState() => _ProfileSettingsState();
}

class _ProfileSettingsState extends State<ProfileSettings> {

  final TextEditingController _explainController = TextEditingController();

  String? userName = "";

  List<int> years = List.generate(130, (index) => DateTime.now().year - index); // 130年前~現在までの年度ギネスだと122らしい

  //リンクの入力コントローラー
  final TextEditingController _linkController1 = TextEditingController();
  final TextEditingController _linkController2 = TextEditingController();
  final TextEditingController _linkController3 = TextEditingController();


  //説明文の入力コントローラー
    
  String explainText = "";

  List<dynamic> linkText = [];

  String linkText1 = "";
  String linkText2 = "";
  String linkText3 = "";

  int selectedYear = 2000; // 選択された年度

  List<Map<String, dynamic>> profileData = [];


  Future<void> getInfoFromSupabase() async{
    try{

      print("エラー箇所はここの可能性");
      profileData = await supabase.from("profiles").select<List<Map<String, dynamic>>>().eq("id", myUserId);

      print("ここが来ればおｋ");

      setState(() {
        userName = profileData[0]["username"];
        selectedYear = profileData[0]["age"];
        explainText = profileData[0]["explain"];
        
        if(profileData[0]["links"] != null){
          linkText = profileData[0]["links"];
          linkText1 = linkText[0];
          linkText2 = linkText[1];
          linkText3 = linkText[2];
        }else{
          linkText = [];
        }

        

        _explainController.text = explainText;
        _linkController1.text = linkText1;
        _linkController2.text = linkText2;
        _linkController3.text = linkText3;

      });
      return ;


    } on PostgrestException catch (error){
      if(context.mounted){
        context.showErrorSnackBar(message: error.message);
      }
      return ;
    } catch(_){
      if(context.mounted){
      context.showErrorSnackBar(message: unexpectedErrorMessage);
      }
      return ;
    }

  }


  // Supabaseに情報を送信する関数
  Future<int> sendInfoToSupabase() async {
    // TODO: Supabaseに情報を送信するロジックを実装

    try{
      

      linkText = [linkText1, linkText2, linkText3];

      await supabase.from("profiles").update({
        //"username": userName,
        "age": selectedYear,
        "explain": explainText,
        "links": linkText,
      }).eq("id", myUserId);

      return 0;


    } on PostgrestException catch (error){
      if(context.mounted){
        context.showErrorSnackBar(message: error.message);
      }
      return 1;
    } catch(_){
      if(context.mounted){
      context.showErrorSnackBar(message: unexpectedErrorMessage);
      }
      return 2;
    }



  }

  @override
  void initState() {
    super.initState();
    getInfoFromSupabase();
  }


  @override
  Widget build(BuildContext context) {
    

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('プロフィール編集'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                
                children: <Widget>[
                  Column(
          
                    children: [
          
                      Center(
                        child: SizedBox(
                          width: SizeConfig.blockSizeHorizontal! * 90,
                          height: SizeConfig.blockSizeVertical! * 70,
                          child: IconSettings(profileImage: widget.profileImage,),
                        ),
                      ),
          
                      
          
          
          
                      Column(
                        children: [
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: SizeConfig.blockSizeHorizontal!*5),
                            alignment: Alignment.centerLeft,
                            width: SizeConfig.blockSizeHorizontal! * 95,
                            child: TextFormField(
                              
                              keyboardType: TextInputType.multiline,
                              maxLines: 3,
                              maxLength: 100,
                              controller: _explainController,
                              onChanged: (value) {
                                setState(() {
                                  explainText = value;
                                });
                              },
                          
                              decoration: const InputDecoration(
                                labelText: 'プロフィール説明文',
                              ),
                          
                            ),
                          ),
                        ],
                      ),
                      
                      Column(
                        
                        children: [
          
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: SizeConfig.blockSizeHorizontal!*5),
                            alignment: Alignment.centerLeft,
                            child: Column(
                              
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                          
                                Container(
                                  child: const Text("誕生年")
                                ),
                                const SizedBox(width: 10),
                                Container(
                                  width: 100,
                                  height: 50,
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  /*
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.green), // 枠線を追加
                                    borderRadius: BorderRadius.circular(8), // 枠線の角を丸める
                                  ),
                                   */
                          
                                  child: DropdownButton<int>(
                                    
                                    value: selectedYear,
                                    onChanged: (int? newValue) {
                                      if (newValue != null) {
                                        setState(() {
                                          selectedYear = newValue;
                                        });
                                      }
                                    },
                                    items: years.map<DropdownMenuItem<int>>((int value) {
                                      return DropdownMenuItem<int>(
                                        value: value,
                                        child: Text(value.toString()),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],
                            ),
                          ),
          
                          SizedBox(height: SizeConfig.blockSizeVertical!*3,),
          
                          
                          
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: SizeConfig.blockSizeHorizontal!*5),
                            alignment: Alignment.centerLeft,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  child: const Text("twitter(X)などのリンク(3つまで)")
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10),
                                      width: 300,
                                
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.green), // 枠線を追加
                                        borderRadius: BorderRadius.circular(8), // 枠線の角を丸める
                                      ),
                                      child: TextFormField(
                                        keyboardType: TextInputType.multiline,
                                        maxLines: 1,
                                        controller: _linkController1,
                                        onChanged: (value) {
                                          setState(() {
                                            linkText1 = value;
                                          });
                                        },
                                                        
                                        decoration: const InputDecoration(
                                          border: InputBorder.none
                                        ),
                                                              
                                      ),
                                    ),
          
                                    const SizedBox(height: 10,),
          
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10),
                                      width: 300,
                                
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.green), // 枠線を追加
                                        borderRadius: BorderRadius.circular(8), // 枠線の角を丸める
                                      ),
                                      child: TextFormField(
                                        keyboardType: TextInputType.multiline,
                                        maxLines: 1,
                                        controller: _linkController2,
                                        onChanged: (value) {
                                          setState(() {
                                            linkText2 = value;
                                          });
                                        },
                                                        
                                        decoration: const InputDecoration(
                                          border: InputBorder.none
                                        ),
                                                              
                                      ),
                                    ),
          
                                    const SizedBox(height: 10,),
          
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10),
                                      width: 300,
                                
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.green), // 枠線を追加
                                        borderRadius: BorderRadius.circular(8), // 枠線の角を丸める
                                      ),
                                      child: TextFormField(
                                        keyboardType: TextInputType.multiline,
                                        maxLines: 1,
                                        controller: _linkController3,
                                        onChanged: (value) {
                                          setState(() {
                                            linkText3 = value;
                                          });
                                        },
                                                        
                                        decoration: const InputDecoration(
                                          border: InputBorder.none
                                        ),
                                                              
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
          
                        ],
                      ),
          
          
          
                      SizedBox(height: SizeConfig.blockSizeVertical! * 5),
          
                      ElevatedButton(
                        onPressed: () async{
                          showLoadingDialog(context, "処理中...");
                          int response = await sendInfoToSupabase();

                          //2秒待つ
                          await Future.delayed(const Duration(seconds: 2), () {});


                          if(response != 0){
                            if(context.mounted){
                              Navigator.of(context).pop();
                            }

                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(

                                  title: const Text("エラー"),
                                  content: const Text("サーバーエラーにより、情報の更新ができませんでした。"),
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
                          else{
                            if(context.mounted){
                              Navigator.of(context).pop();
                            }

                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(

                                  title: const Text("完了"),
                                  content: const Text("プロフィールを更新しました。"),
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

                        },
                        child: const Text("更新"),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
          
                ],
              ),
            ),
          ),

          Container(
            height: SizeConfig.blockSizeVertical! * 15,
            color: Colors.white,
            child: AdaptiveAdBanner(requestId: "UPDATE"),
          ),
        ],
      ),
    );
  }

}







































