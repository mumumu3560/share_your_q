import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_your_q/pages/create_page/components/confirmation_page.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:share_your_q/image_operations/image_select.dart';
import 'package:share_your_q/utils/various.dart';




// TODO ここはリリース時のみ Admob
import 'package:share_your_q/admob/anchored_adaptive_banner.dart';



import 'dart:async';




class CreatePage extends StatefulWidget {
  const CreatePage({super.key});

  @override
  _CreatePageState createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {

  

  //現在作っている問題が何問目か(制限を考える)
  int problemNum = 1;

  //問題文の画像と解説の画像の数を表す。
  int problemIcount = 1;
  int commentIcount = 1;


  final userId = supabase.auth.currentUser!.id;

  //cloudflare imagesのURLにつかうcustomId
  String? customId1;
  String? customId2;

  //PlatformFileはwebでもandroidでも使える。
  PlatformFile? selectedImage1;
  PlatformFile? selectedImage2;

  //supabaseに送るもの。
  String? problemTitle = '';
  //教科、数学など
  String? subject;
  
  //小学校、中学校などいつ習ったものか
  String? level;

  String? lang;

  //タグ
  List<String> tags = [];

  //url
  List<String> urls = [];

  //tagの入力コントローラー
  final TextEditingController _tagController = TextEditingController();

  //参考文献の入力コントローラー
  final TextEditingController _urlController = TextEditingController();

  //参考文献説明の入力コントローラー
  final TextEditingController _refController = TextEditingController();

  //説明文の入力コントローラー
  final TextEditingController _explainController = TextEditingController();

  String? explainText = '';
  String? refText = '';


  // タグの入力値
  String tagInput = '';

  // 参考文献の入力値
  String urlInput = '';


  String? userName = "";

  List<Map<String,dynamic>> profileImageId = [];



  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    fetchProfileImage();
    fetchImageSubject();
  }

  Future<void> fetchProfileImage() async{
    try{
      final response = await supabase.from("profiles").select<List<Map<String, dynamic>>>().eq("id", myUserId);
      setState(() {
        profileImageId = response;
      });
    } on PostgrestException catch (error){
      if(mounted){
        context.showErrorSnackBar(message: error.message);
      }
    } catch(_){
      if(mounted){
      context.showErrorSnackBar(message: unexpectedErrorMessage);
      }
    }
  }

  int phys = 1;
  int chem = 1;
  int math = 1;
  int other = 1;

  Future<void> fetchImageSubject() async{
    try{
      final response = await supabase
        .from("image_data")
        .select<List<Map<String, dynamic>>>()
        .eq("user_id", myUserId)
        .order("created_at", ascending: false)
        .limit(4);

      for(int i = 0; i < response.length; i++){
        //supabaseから取得したtimestamptz型のやつはutcで取得される。
        DateTime date = DateTime.parse(response[i]["created_at"]).add(const Duration(hours: 9));
        DateTime now = DateTime.now();



        //context.showErrorSnackBar(message: "i=${i}  日付${date}  現在${now}");


        if(date.year == now.year && date.month == now.month && date.day == now.day){
          if(response[i]["subject"] == "数学"){
            setState(() {
              math--;
            });
          }
          else if(response[i]["subject"] == "物理"){
            setState(() {
              phys--;
            });
          }
          else if(response[i]["subject"] == "化学"){
            setState(() {
              chem--;
            });
          }
          else{
            setState(() {
              other--;
            });
          }
        }
      }

      
      

    }
    on PostgrestException catch (error){
      if(mounted){
        context.showErrorSnackBar(message: error.message);
      }
    } catch(_){
      if(mounted){
      context.showErrorSnackBar(message: unexpectedErrorMessage);
      }
    }
  }

  // タグを追加する関数
  void addTag() {

    bool jad = false;

    if (tagInput.isNotEmpty && tags.length < 5) {

      if (!tags.contains(tagInput)) {
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
      if(!jad){
        context.showErrorSnackBar(message: 'タグは5つまでしか追加できません');
      }
      
    }

  }

  // タグを削除する関数
  void removeTag(String tag) {
    setState(() {
      tags.remove(tag);
    });
  }


  // 参考文献を追加する関数
  void addUrl() {

    bool jad = false;

    if (urlInput.isNotEmpty && urls.length < 10) {

      if (!urls.contains(urlInput)) {
        setState(() {
          urls.add(urlInput);
          urlInput = '';
          _urlController.clear(); // 入力フォームを空にする
        });

      } else {
        jad = true;
        context.showErrorSnackBar(message: '同じ参考文献は追加できません');
      }

    } else {
      if(!jad){
        context.showErrorSnackBar(message: '参考文献は10個までしか追加できません');
      }
      
    }

  }

  // 参考文献を削除する関数
  void removeUrl(String url) {
    setState(() {
      urls.remove(url);
    });
  }

  void showRestriction(){
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
              content: Container(
                //height: SizeConfig.blockSizeVertical! * 20,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    //const Text("ヘルプ", style: TextStyle(fontSize: 20),),

                    ListTile(
                      title: Text('各ジャンルの投稿は一日一回まで',style: TextStyle(fontSize: 18)),
                      onTap: () {

                      },
                    ),

                    //const Text("残り回数", style: TextStyle(fontSize: 20),),

                    ListTile(
                      //チェックマークのアイコンにする
                      //Text("数学: ${math}/1回"),
                      title: Row(
                        children: [
                          const Text("数学: ",style: TextStyle(fontSize: 18)),
                          math == 0 
                            ? const Icon(Icons.check_box, color: Colors.green,) 
                            : const Icon(Icons.check_box_outline_blank, color: Colors.red,),
                        ],
                      ),
                      onTap: () {
                        if(math == 0){
                          
                        }
                        else{

                          setState(() {
                            subject = "数学";
                          });
                          Navigator.of(context).pop();
                        }

                      },
                    ),
                    ListTile(
                      title: Row(
                        children: [
                          const Text("物理: ",style: TextStyle(fontSize: 18)),
                          phys == 0 
                            ? const Icon(Icons.check_box, color: Colors.green,) 
                            : const Icon(Icons.check_box_outline_blank, color: Colors.red,),
                        ],
                      ),
                      onTap: () {
                        
                        if(phys == 0){
                          
                        }
                        else{

                          setState(() {
                            subject = "物理";
                          });
                          Navigator.of(context).pop();
                        }

                      },
                    ),
                    ListTile(
                      title: Row(
                        children: [
                          const Text("化学: ",style: TextStyle(fontSize: 18)),
                          chem == 0 
                            ? const Icon(Icons.check_box, color: Colors.green,) 
                            : const Icon(Icons.check_box_outline_blank, color: Colors.red,),
                        ],
                      ),
                      onTap: () {

                        if(chem == 0){
                          
                        }
                        else{

                          setState(() {
                            subject = "化学";
                          });
                          Navigator.of(context).pop();
                        }

                      },
                    ),
                    ListTile(
                      title: Row(
                        children: [
                          const Text("その他: ",style: TextStyle(fontSize: 18)),
                          other == 0 
                            ? const Icon(Icons.check_box, color: Colors.green,) 
                            : const Icon(Icons.check_box_outline_blank, color: Colors.red,),
                        ],
                      ),
                      onTap: () {
                        
                        
                        if(other == 0){
                          
                        }
                        else{

                          setState(() {
                            subject = "その他";
                          });
                          Navigator.of(context).pop();
                        }


                      },
                    ),


                    (math == 0 && phys == 0 && chem == 0 && other == 0)
                      ? ListTile(
                      title: const Text(
                        "All Done!!",
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.green
                        ),

                      ),
                      onTap: () {
                      
                      },
                    )
                    : const SizedBox(),
                  ],

                ),
                
              ),
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

  void showHelp(){
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
              content: Container(
                //height: SizeConfig.blockSizeVertical! * 20,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("ヘルプ", style: TextStyle(fontSize: 20),),

                    ListTile(
                      title: Text('各ジャンルの投稿は一日一回まで'),
                      onTap: () {

                      },

                    
                    ),
                  ],

                ),
                
              ),
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





  @override
  Widget build(BuildContext context) {

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('作成ページ'),

        actions: [
          //ヘルプマーク
          IconButton(
            onPressed: showRestriction,
            icon: const Icon(Icons.help),
          ),

        ],

        
      ),

      
      


      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    //if (!isConfirmationMode)
                      Column(
          
                        children: [
                          // タイトルの入力フォーム
                          TextFormField(
                            maxLength: 30,
                            initialValue: problemTitle,
                            onChanged: (value) {
                              setState(() {
                                problemTitle = value;
                              });
                            },
                            decoration: const InputDecoration(
                              labelText: '問題のタイトル',
                            ),
                          ),
          
                          
                          // レベルとジャンルの横並び
                          DropdownButton<String>(
                            value: level,
                            onChanged: (value) {
                              setState(() {
                                level = value;
                              });
                            },
                            items: <String>['小学校', '中学校', '高校', '大学', 'その他']
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            hint: const Text('レベルを選択してください'),
                          ),
          
                          
                          DropdownButton<String>(
                            value: subject,
                            onChanged: (value) {
                              if(value == "数学" && math == 0){
                                context.showErrorSnackBar(message: "今日はもう数学の問題を投稿しました。");
                                return;
                              }
                              else if(value == "物理" && phys == 0){
                                context.showErrorSnackBar(message: "今日はもう物理の問題を投稿しました。");
                                return;
                              }
                              else if(value == "化学" && chem == 0){
                                context.showErrorSnackBar(message: "今日はもう化学の問題を投稿しました。");
                                return;
                              }
                              else if(value == "その他" && other == 0){
                                context.showErrorSnackBar(message: "今日はもうその他の問題を投稿しました。");
                                return;
                              }

                              setState(() {
                                subject = value;
                              });

                            },
                            items: <String>['数学', '物理', '化学', 'その他']
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            hint: const Text('ジャンルを選択してください'),
                          ),

                          DropdownButton<String>(
                            value: lang,
                            onChanged: (value) {
                              setState(() {
                                lang = value;
                              });
                            },
                            items: <String>["ja", "en"]
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            hint: const Text('言語を選択してください'),
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
                              labelText: 'タグを入力',
                            ),
                          ),
          
          
                          ElevatedButton(
                            onPressed: addTag,
                            child: const Text("タグを追加"),
                          ),
          
                        
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
          
                          const SizedBox(height: 10),
          
          
          
          
                          
          
                          // 参考文献リンクの入力フォーム
                          TextFormField(
                            maxLength: 200,
                            controller: _urlController,
                            onChanged: (value) {
                              
                              setState(() {
                                urlInput = value;
                              });
                            },
                            decoration: const InputDecoration(
                              labelText: '参考文献を入力(リンクなど)',
                            ),
                          ),
          
          
                          ElevatedButton(
                            onPressed: addUrl,
                            child: const Text("参考文献を追加"),
                          ),
          
                        
                          Wrap(
                            children: urls
                            .map(
                              (url) => Chip(
                                label: Text(url),
                                onDeleted: () {
                                  removeUrl(url);
                                },
                              ),
                            )
                          .toList(),
                          ),
          
                          const SizedBox(height: 10),
          
                          //ここは参考文献についての説明
                          SizedBox(
                            width: SizeConfig.blockSizeHorizontal! * 90,
                            child: TextFormField(
                              //大きさを変えたい
                              
                              keyboardType: TextInputType.multiline,
                              maxLines: 3,
                              maxLength: 200,
                              controller: _refController,
                              onChanged: (value) {
                                setState(() {
                                  refText = value;
                                });
                              },
                          
                              decoration: const InputDecoration(
                                labelText: '参考文献の簡単な説明',
                              ),
                          
                            ),
                          ),
          
          
          
          
                          //ここは説明分
                          SizedBox(
                            width: SizeConfig.blockSizeHorizontal! * 90,
                            child: TextFormField(
                              //大きさを変えたい
                              
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
                                labelText: '問題の簡単な説明',
                              ),
                          
                            ),
                          ),
          
          
          
                          
          
                          
          
          
          
                          SizedBox(height: SizeConfig.blockSizeVertical! * 20),
                          
                          // 画像1の選択ウィジェット
                          Column(
                            children: [
                              if (selectedImage1 == null)
                                Column(
                                  children: [
                                    const Text(
                                      "問題文の画像を選択してください",
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
                            ],
                          ),
                          
                          SizedBox(height: SizeConfig.blockSizeVertical! * 20), // 適宜間隔を設定
                          
                          // 画像2の選択ウィジェット
                          Column(
                            children: [
                              if (selectedImage2 == null)
                                Column(
                                  children: [
                                    const Text(
                                      "解説の画像を選択してください",
                                      style: TextStyle(color: Colors.red),
                                    ),
                                    ImageSelectionWidget(
                                      onImageSelected: (image) {
                                        setState(() {
                                          selectedImage2 = image;
                                        });
                                      },
                                    ),
                                  ],
                                )
                              else
                                Column(
                                  children: [
                                    Image.memory(
                                      selectedImage2!.bytes!,
                                      height: 150,
                                    ),
                                    const SizedBox(height: 10),
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          selectedImage2 = null;
                                        });
                                      },
                                      child: const Text(
                                        "画像を削除",
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
          
                          SizedBox(height: SizeConfig.blockSizeVertical! * 20),
          
                          ElevatedButton(
                            onPressed: () async{
          
                              if (selectedImage1 == null ||
                                  selectedImage2 == null ||
                                  problemTitle == null ||
                                  subject == null ||
                                  level == null ||
                                  lang == null ||
                                  tags.isEmpty) {

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('全ての情報を入力してください。'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              } else {
        

                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => 
                                      ConfirmPage(
                                        problemTitle: problemTitle!, 
                                        selectedImage1: selectedImage1, 
                                        selectedImage2: selectedImage2, 
                                        subject: subject!, 
                                        level: level!, 
                                        lang: lang!, 
                                        explainText: explainText!, 
                                        refText: refText!, 
                                        urls: urls, 
                                        tags: tags, 
                                        userName: userName!,
                                        profileImageId: profileImageId[0]["profile_image_id"],
                                      )
                                  )
                                );

                               }
                            },
                            child: const Text("問題のプレビュー"),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
          
                  ],
                ),
              ),
            ),
          ),

          SizedBox(height: SizeConfig.blockSizeVertical! * 5),
          

          //TODO Admob
          Container(
            height: SizeConfig.blockSizeVertical! * 10,
            color: Colors.white,
            child: AdaptiveAdBanner(requestId: "CREATE",)
          ),
        ],
      ),
    );
  }
}









