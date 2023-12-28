import 'package:flutter/material.dart';
import 'package:share_your_q/image_operations/image_display.dart'; // ImageDisplayScreenをインポート
import "package:share_your_q/utils/various.dart";

import 'package:share_your_q/pages/display_page/display_page.dart';

import "package:share_your_q/image_operations/test_override.dart";
import "package:share_your_q/image_operations/image_list_display.dart";

//TODO ビルドリリースの時のみ
//import "package:share_your_q/admob/ad_mob.dart";

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}


class _SearchPageState extends State<SearchPage> {


  //教科、数学など
  String? subject = "全て";
  //小学校、中学校などいつ習ったものか
  String? level = "全て";
  //検索方法
  String? method = "新着";
  //タグ
  List<String> tags = [];

  //tagの入力コントローラー
  TextEditingController _tagController = TextEditingController();

  // タグの入力値
  String tagInput = '';

  //TODO ビルドリリースの時のみ
  //final AdMob _adMob = AdMob();

  // タグを追加する関数
  void addTag() {

    bool jad = false;

    if (tagInput.isNotEmpty && tags.length < 5) {

      print(tags);
      print(tagInput);

      if (!tags.contains(tagInput)) {
        print("this is a test");
        setState(() {
          tags.add(tagInput);
          tagInput = '';
          _tagController.clear(); // 入力フォームを空にする
        });

      } else {
        jad = true;
        context.showErrorSnackBar(message: '同じタグは追加できません');
      }

    } else {

      if(tagInput.isEmpty){
        context.showErrorSnackBar(message: 'タグを入力してください');
        return;
      }
      if(!jad){
        context.showErrorSnackBar(message: 'タグは5つまでしか追加できません');
        return;
      }
      
      
    }

    print(jad);
    print(tags);
  }

  // タグを削除する関数
  void removeTag(String tag) {
    setState(() {
      tags.remove(tag);
    });
  }

  @override
  void initState() {
    super.initState();
    //TODO ビルドリリースの時のみ
    //_adMob.load();
  }

  @override
  void dispose() {
    super.dispose();
    _tagController.dispose();
    //TODO ビルドリリースの時のみ
    //_adMob.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('検索'),
      ),
      body: Column(
        
        children: [
          Expanded(
            child: Column(

              
            
              children: [

                SizedBox(height: SizeConfig.blockSizeVertical! * 10,),
                
                // レベルとジャンルの横並び
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    DropdownButton<String>(
                      value: level,
                      onChanged: (value) {
                        setState(() {
                          level = value;
                        });
                      },
                      items: <String>["全て", '小学校', '中学校', '高校', '大学', 'その他']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      //hint: const Text('レベル選択'),
                    ),


                    SizedBox(width: SizeConfig.blockSizeHorizontal! * 1,),
            
                    
                    DropdownButton<String>(
                      value: subject,
                      onChanged: (value) {
                        setState(() {
                          subject = value;
                        });
                      },
                      items: <String>["全て", '数学', '物理', '化学', 'その他']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      //hint: const Text('ジャンル選択'),
                    ),

                    SizedBox(width: SizeConfig.blockSizeHorizontal! * 1,),
            
            
                    // 検索方法の選択
                    DropdownButton<String>(
                      value: method,
                      onChanged: (value) {
                        setState(() {
                          method = value;
                        });
                      },
                      items: <String>['新着', '未発掘', "ランダム"]
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      //hint: const Text('並び替え方法の選択'),
                    ),
                  ],

                ),
            
                
            
            
                
                // タグの入力フォーム
                TextFormField(
                  maxLength: 10,
                  controller: _tagController,
                  onChanged: (value) {
                    
                    setState(() {
                      tagInput = value;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: '検索したいタグを入力',
                  ),
                ),
                
                ElevatedButton(
                  onPressed: addTag,
                  child: Text("タグを追加"),
                ),

                SizedBox(height: SizeConfig.blockSizeVertical! * 2,),
            
                Wrap(
                  children: tags
                  .map(
                    (tag) => Chip(
                      label: Text(tag),
                      onDeleted: () {
                        removeTag(tag);
                      },
                    ),
                  )
                .toList(),
                ),

                SizedBox(height: SizeConfig.blockSizeVertical! * 2,),
            
                ElevatedButton(
                  onPressed:(){
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ImageListDisplay(title: method, subject: subject, level: level, method: method,tags: tags, searchUserId: "",), // ImageDisplayに遷移
                      ),
                    );
                  },
                  child: Text("検索"),
                ),
            
          
              ],
          
              
            ),


          ),





          Container(
            height: SizeConfig.blockSizeVertical! * 15,
            //height: 100 ,
            width: double.infinity,
            color: Colors.white,
            //TODO ビルドリリースの時のみ
            //child: _adMob.getAdBanner(),
          ),



        ],

        
      ),
    );
  }
}
