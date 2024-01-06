import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


import 'package:share_your_q/cloudflare_relations/server_request.dart';
import 'package:share_your_q/image_operations/image_select.dart';
import 'package:share_your_q/image_operations/image_upload.dart';
import 'package:share_your_q/utils/various.dart';

import "package:share_your_q/image_operations/problem_view.dart";

//問題を作るページ

//TODO textformfieldの長さの制限を考える。


class ProfileSettings extends StatefulWidget {
  @override
  _ProfileSettingsState createState() => _ProfileSettingsState();
}

class _ProfileSettingsState extends State<ProfileSettings> {

  TextEditingController _explainController = TextEditingController();

  String? userName = "";

  List<int> years = List.generate(130, (index) => DateTime.now().year - index); // 130年前~現在までの年度ギネスだと122らしい

  //リンクの入力コントローラー
  TextEditingController _linkController = TextEditingController();

  //説明文の入力コントローラー
    
  String explainText = "";

  String linkText = "";

  int selectedYear = 2000; // 選択された年度

  List<Map<String, dynamic>> profileData = [];


  Future<void> getInfoFromSupabase() async{
    try{

      profileData = await supabase.from("profiles").select<List<Map<String, dynamic>>>().eq("id", myUserId);

      setState(() {
        userName = profileData[0]["username"];
        selectedYear = profileData[0]["age"];
        explainText = profileData[0]["explain"];
        linkText = profileData[0]["Links"];

        _explainController.text = explainText;
        _linkController.text = linkText;

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
  Future<void> sendInfoToSupabase() async {
    // TODO: Supabaseに情報を送信するロジックを実装

    try{

      await supabase.from("profiles").update({
        //"username": userName,
        "age": selectedYear,
        "explain": explainText,
        "Links": linkText,
      }).eq("id", myUserId);

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

  @override
  void initState() {
    super.initState();
    getInfoFromSupabase();
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('プロフィール編集'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Column(

                children: [



                  SizedBox(
                    width: SizeConfig.blockSizeHorizontal! * 90,
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
                  
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      Row(
                        children: [

                          Container(
                            alignment: Alignment.centerRight,
                            width: 200,
                            child: const Text("誕生年")
                          ),
                          const SizedBox(width: 10),
                          Container(
                            width: 100,
                            height: 50,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.green), // 枠線を追加
                              borderRadius: BorderRadius.circular(8), // 枠線の角を丸める
                            ),

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

                      
                      
                      Row(
                        children: [
                          Container(
                            alignment: Alignment.centerRight,
                            width: 200,
                            height: 100,
                            child: const Text("twitter(X)のリンク")
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            width: 300,
                            height: 50,

                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.green), // 枠線を追加
                              borderRadius: BorderRadius.circular(8), // 枠線の角を丸める
                            ),
                            
                            child: TextFormField(
                              keyboardType: TextInputType.multiline,
                              maxLines: 1,
                              controller: _linkController,
                              onChanged: (value) {
                                setState(() {
                                  linkText = value;
                                });
                              },

                              decoration: InputDecoration(
                                border: InputBorder.none
                              ),
                          
                            ),
                          ),
                        ],
                      ),

                    ],
                  ),



                  SizedBox(height: SizeConfig.blockSizeVertical! * 5),

                  ElevatedButton(
                    onPressed: () async{
                      await sendInfoToSupabase();
                      Navigator.pop(context);
                    },
                    child: Text("更新"),
                  ),
                  SizedBox(height: 20),
                ],
              ),

            ],
          ),
        ),
      ),
    );
  }

}







































