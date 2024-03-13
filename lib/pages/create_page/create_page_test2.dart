import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_your_q/pages/create_page/components/confirmation_page.dart';
import 'package:share_your_q/pages/create_page/components/reference.dart';

import 'package:supabase_flutter/supabase_flutter.dart';


import 'package:share_your_q/cloudflare_relations/server_request.dart';
import 'package:share_your_q/image_operations/image_select.dart';
import 'package:share_your_q/image_operations/image_upload.dart';
import 'package:share_your_q/utils/various.dart';

import 'package:share_your_q/image_operations/problem_view/problem_view.dart';



// TODO ここはリリース時のみ Admob
/*
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:share_your_q/admob/anchored_adaptive_banner.dart';
 */



import 'dart:async';
import 'dart:io';

//dotenv
import 'package:flutter_dotenv/flutter_dotenv.dart';



//問題を作るページ



//TODO textformfieldの長さの制限を考える。
//Supabaseではtext型だがこれはvarchar(10)になおす。
//textは最大で2GBまで入るので問題がある(flutterのtextformfieldの制限変えられる)

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

  //cloudflare imagesのURLにつかうdirectUploadUrl
  //String? directUploadUrl1;
  //String? directUploadUrl2;

  // 確認画面を表示するかどうか
  //bool isConfirmationMode = false;

  String? userName = "";

  List<Map<String,dynamic>> profileImageId = [];

  // TODO admob本番
  //InterstitialAd? _interstitialAd;

  //TODO ここは今test用のものなので後で変更する。
  /*
  final String _adUnitId = Platform.isAndroid
      ? "ca-app-pub-3940256099942544/1033173712"//dotenv.get("INTERSTITIAL_ID_CREATE")
      : "ca-app-pub-3940256099942544/1033173712";//dotenv.get("INTERSTITIAL_ID_CREATE");
   */

  /// Loads an interstitial ad.
  /// TODO admob本番
  /*
  void _loadAd() {
    InterstitialAd.load(
        adUnitId: _adUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            ad.fullScreenContentCallback = FullScreenContentCallback(
                onAdShowedFullScreenContent: (ad) {
                  //print('$ad onAdShowedFullScreenContent.');
                  context.showSuccessSnackBar(message: "onAdShowedFullScreenContent");
                },
                // Called when an impression occurs on the ad.
                onAdImpression: (ad) {},
                // Called when the ad failed to show full screen content.
                onAdFailedToShowFullScreenContent: (ad, err) {
                  ad.dispose();
                },
                // Called when the ad dismissed full screen content.
                onAdDismissedFullScreenContent: (ad) {
                  ad.dispose();
                },
                // Called when a click is recorded for an ad.
                onAdClicked: (ad) {});

            // Keep a reference to the ad so you can show it later.
            _interstitialAd = ad;
          },
          // Called when an ad request failed.
          onAdFailedToLoad: (LoadAdError error) {
            // ignore: avoid_print
            print('InterstitialAd failed to load: $error');
            context.showErrorSnackBar(message: "InterstitialAd failed to load: $error");
            
            
          },
        ));
  }

   */


  @override
  void dispose() {
    // TODO admob本番
    //_interstitialAd?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO admob本番
    //_loadAd();
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
      if(context.mounted){
        context.showErrorSnackBar(message: error.message);
      }
    } catch(_){
      if(context.mounted){
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
      if(context.mounted){
        context.showErrorSnackBar(message: error.message);
      }
    } catch(_){
      if(context.mounted){
      context.showErrorSnackBar(message: unexpectedErrorMessage);
      }
    }
  }

 /*
  // サーバーレスポンスからcustomIdとdirectUploadUrlを受け取る関数
  void onServerResponseReceived(String customId, String directUploadUrl, bool isProblem) {
    setState(() {
      if (isProblem) {
        customId1 = customId;
        directUploadUrl1 = directUploadUrl;
      } else {
        customId2 = customId;
        directUploadUrl2 = directUploadUrl;
      }
    });
  }

  // 選択した画像をアップロードする関数
  Future<int> uploadSelectedImage(PlatformFile? selectedImage, String customId, String? directUploadUrl) async{
    if (selectedImage != null && directUploadUrl != null) {
      print("ここはどうですか？");
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

  // Supabaseに情報を送信する関数
  Future<int> sendInfoToSupabase() async {
    // TODO: Supabaseに情報を送信するロジックを実装

    //numとusernameはsupabase側で行えばよい
    try{

      await supabase.from("image_data").insert({
        //"num": problemNum,
        "title": problemTitle,
        "subject": subject,
        //"PorC": 1,
        "level": level,
        //"tags": tags,
        "tag1": tags.isNotEmpty ? tags[0] : "",
        "tag2": tags.length > 1 ? tags[1] : "",
        "tag3": tags.length > 2 ? tags[2] : "",
        "tag4": tags.length > 3 ? tags[3] : "",
        "tag5": tags.length > 4 ? tags[4] : "",
        "user_id": myUserId,
        "p_num": 1,
        "c_num": 1,
        //"user_name" : userName,
        "explain": explainText,
        "problem_id": null,
        "comment_id": null,
        //"likes": 100,
        "links": urls,
        "ref_explain": refText,
        "lang": lang,
      });

      //ここでは、ユーザーの問題の投稿数を増やす。

      //TODO ここを消す。supabaseで処理
      
      /*
      await supabase.from("profiles").update({
        "problem_num": problemNum,
      }).eq("id", userId);

       */

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

  /*
  //ここで受け取ったURLを保存
  Future<int> updateInfoToSupabase() async {
    // TODO: Supabaseに情報を送信するロジックを実装

    //numとusernameはsupabase側で行えばよい
    try{

      final response = await supabase
      .from('image_data')
      .select('image_data_id')
      .eq('user_id', userId)
      .order('created_at', ascending: false)
      .limit(1);

      if (response.isEmpty) {
        print('Error fetching latest image_data record: ${response.error!.message}');
        return 1;
      }

      int newImageId = response[0]['image_data_id'];

      await supabase
        .from("image_data")
        .update({
          "problem_id": customId1,
          "comment_id": customId2,
        })
        .eq("image_data_id", newImageId);

      //ここでは、ユーザーの問題の投稿数を増やす。

      //TODO ここを消す。supabaseで処理
      
      /*
      await supabase.from("profiles").update({
        "problem_num": problemNum,
      }).eq("id", userId);

       */

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
   */

  //もしSupabaseに問題を送信する際にエラーが発生した場合、
  // Supabaseに情報を送信する関数
  Future<int> deleteInfoFromSupabase() async {
    // TODO: Supabaseに情報を送信するロジックを実装

    //numとusernameはsupabase側で行えばよい
    try{

      final response = await supabase
        .from('image_data')
        .select<List<Map<String,dynamic>>>()
        .eq('user_id', myUserId)
        .is_('problem_id', null)
        .is_('comment_id', null)
        .order('created_at', ascending: false) // 降順で並べ替え
        .limit(1); // 最新の1件のみ取得

      if (response.isNotEmpty) {
        // 特定されたレコードのIDを取得
        final recordId = response[0]['image_data_id'];

        // 取得したIDを使用してレコードを削除
        await supabase
          .from('image_data')
          .delete()
          .eq('image_data_id', recordId);
      }
      else{
        return 1;
      }

      //ここで自分Supabaseにある最新のデータを削除する。



      //TODO ここを消す。supabaseで処理
      
      /*
      await supabase.from("profiles").update({
        "problem_num": problemNum,
      }).eq("id", userId);

       */

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

  // クラウドフレアのImageサービスからアップロード用のURLを取得する関数
  Future<int> getImageUploadUrls(bool isOne) async {

    //TODO今は1つの問題につき2つの画像をアップロードするようにしているが、
    //これからは問題、解答複数枚に対応するようにする。

    print("ここは？");

    int response1;
    try{
      
      //ここではknownUserInfoとonServerResponseReceived(関数)が必要なのでそれを渡す。
      response1 = await ImageSelectionAndRequest(
        //knownUserInfo: '${userId}XproblemXnum${problemNum.toString()}XPnum${problemIcount.toString()}XCnum${commentIcount.toString()}',
        knownUserInfo: userId,
        isProblem: isOne,
        type: "create",
        //1回目ならisOne=true、2回目ならisOne=false
        onServerResponseReceived: (customId, directUploadUrl) {
          onServerResponseReceived(customId, directUploadUrl, isOne);
        },

      
      ).sendRequest().timeout(const Duration(seconds: 10));

    } catch(e){
      response1 = 1;
    }

    print(response1);
    print("ここではdirectUploadUrlが取得できたかどうか");

    if(response1 == 0){
      //context.showErrorSnackBar(message: "サーバーエラーが発生しました。");
    }
    else if(response1 == 1){

      if(context.mounted){
        context.showErrorSnackBar(message: "サーバーエラー1");
      }
      
      return 1;
    }
    else{
      if(context.mounted){
        context.showErrorSnackBar(message: "ネットワークエラー1。");
      }
      
      return 2;
    }

    /*
    // customId1, customId2, directUploadUrl1, directUploadUrl2 を使用して画像をアップロード
    final checkUpload2 = await uploadSelectedImage(selectedImage2, customId2!, directUploadUrl2);

    if(checkUpload2 as int != 0){
      return 1;
    }
     */

    print("レスポンス確認");

    //TODO: responseがエラーを起こした場合の処理を書く

    

    print("ここが問題2");
    /*
    int response2;
    try{
      // 2つ目の画像用のリクエスト
      response2 = await ImageSelectionAndRequest(
        //knownUserInfo: '${userId}XCommentXnum${problemNum.toString()}XPnum${problemIcount.toString()}XCnum${commentIcount.toString()}',
        knownUserInfo: userId,
        onServerResponseReceived: (customId, directUploadUrl) {
          onServerResponseReceived(customId, directUploadUrl, false);
        },

      ).sendRequest().timeout(Duration(seconds: 5));
    }catch(e){
      response2 = 1;
    }

    if(response2 == 0){
      //context.showErrorSnackBar(message: "サーバーエラーが発生しました。");
    }
    else if(response1 == 1){
      if(context.mounted){
        context.showErrorSnackBar(message: "サーバーエラー2。");
      }
      return 3;
    }
    else{
      if(context.mounted){
        context.showErrorSnackBar(message: "ネットワークエラー2");
      }
      return 4;
    }
     */

    print("境目");
    /*
    // customId1, customId2, directUploadUrl1, directUploadUrl2 を使用して画像をアップロード
    final checkUpload2 = await uploadSelectedImage(selectedImage2, customId2!, directUploadUrl2);

    if(checkUpload2 as int != 0){
      return 1;
    }
     */
    print("できたかどうかの確認");

    return 0;

  }


  Future<int> imageUploadWithUrls(bool isOne) async{
    // customId1, customId2, directUploadUrl1, directUploadUrl2 を使用して画像をアップロード
    print("ここが問題1");

    if(isOne){
      final checkUpload1 = await uploadSelectedImage(selectedImage1, customId1!, directUploadUrl1);
    
      if(checkUpload1 != 0){
        return 1;
      }
    }
    else{
      final checkUpload2 = await uploadSelectedImage(selectedImage2, customId2!, directUploadUrl2);
    
      if(checkUpload2 != 0){
        return 1;
      }
    }

    return 0;
  }


  */
  //getImageUpload→sendInfotoSupabase右imageUploadWithUrls
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
      if(!jad){
        context.showErrorSnackBar(message: 'タグは5つまでしか追加できません');
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

    print(jad);
    print(urls);
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

    //SizeConfig().init(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('作成ページ'),

        actions: [
          /*
          TextButton(
            onPressed: showRestriction, 
            child: const Text("投稿可能回数")
          ),
          SizedBox(width: SizeConfig.blockSizeHorizontal!*1,),
           */

          //ヘルプマーク
          IconButton(
            onPressed: showRestriction,
            icon: const Icon(Icons.help),
          ),

        ],

        
      ),


      /*
      endDrawer: Drawer(
        child: ListView(
          children: [
            SizedBox(
              height: SizeConfig.blockSizeVertical! * 15,
              child: const DrawerHeader(
                child: Text("投稿残り回数"),
              ),
            ),

            ListTile(
              title: Text("数学: ${math}回"),
              onTap: () {

              },
            ),

            ListTile(
              title: Text('物理: ${phys}回'),
              onTap: () {
                // 画像探しページに遷移するコードを追加
              },
            ),

            ListTile(
              title: Text('化学: ${chem}回'),
              onTap: () {

              },
            ),

            ListTile(
              title: Text('その他: ${other}回'),
              onTap: () {

              },
            ),

          ],
        ),

      ),
       */
      
      


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
                              print("now");
                              //await fetchProblemNum();
                              print("isOK");
          
                              if (selectedImage1 == null ||
                                  selectedImage2 == null ||
                                  problemTitle == null ||
                                  subject == null ||
                                  level == null ||
                                  lang == null ||
                                  tags.isEmpty) {
                                // エラーがある場合の処理
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('全ての情報を入力してください。'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              } else {
                                print("ここは？");
                                //print(selectedImage1!.bytes!);
                                //fetchProblemNum();
                                /*
                                
                                 */
                                setState(() {
                                  
                                  //isConfirmationMode = true;
                                });

                                /**
                                 * problemTitle: problemTitle!, 
                                        selectedImage1: selectedImage1, 
                                        selectedImage2: selectedImage2, 
                                        subject: subject!, 
                                        level: level!, 
                                        lang: lang!, 
                                        explainText: explainText!, 
                                        refText: refText!, 
                                        urls: urls, 
                                        tags: tags, 
                                        userName: userName!
                                 * 
                                 */

                                //上のやつ全部プリント
                                print(problemTitle);
                                //print(selectedImage1);
                                //print(selectedImage2);
                                print(subject);

                                print(level);

                                print(lang);

                                print(explainText);

                                print(refText);

                                print(urls);
                                print(tags);
                                print(userName);


                                /*
                                
                                 */

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

                                //Navigator.of(context).push(MaterialPageRoute(builder: (context) => ConfirmDisplay(confirmWidget: bi)));
                              }
                            },
                            child: const Text("問題のプレビュー"),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    //if (isConfirmationMode)
                      //buildConfirmationView(),
          
                  ],
                ),
              ),
            ),
          ),

          SizedBox(height: SizeConfig.blockSizeVertical! * 3),
          

          //TODO Admob
          Container(
            height: SizeConfig.blockSizeVertical! * 17,
            //color: Colors.white,
            //child: AdaptiveAdBanner(requestId: "CREATE",)
          ),
          //BannerContainer(height: SizeConfig.blockSizeHorizontal! * 10),
          //InlineAdaptiveExample(),
        ],
      ),
    );
  }

  // stateless widgetを作る。名前はConfirmDisplay

  




  /*
  // 問題投稿の確認画面を表示する関数
  Widget buildConfirmationView() {
    //TODO ここはAdmobのテスト広告を表示するためのもの。

    void _showReferenceSheet(BuildContext context) {
    showModalBottomSheet(
      constraints: BoxConstraints(
        maxWidth: SizeConfig.blockSizeHorizontal! * 100,
      ),
      context: context,
      //これがないと高さが変わらない
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SizedBox(
          height: SizeConfig.blockSizeVertical! * 60,
          child: ReferenceDisplay(linkText: urls, refExplain: refText)
        );
      },
    );
  }
    

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[

        //ここで問題の評価を見る
        


        ProblemViewWidget(
          title: problemTitle!,

          tag1: tags.isNotEmpty ? tags[0] : null,
          tag2: tags.length > 1 ? tags[1] : null,
          tag3: tags.length > 2 ? tags[2] : null,
          tag4: tags.length > 3 ? tags[3] : null,
          tag5: tags.length > 4 ? tags[4] : null,

          //tags: tags,
          level: level!,
          subject: subject!,
          image1: selectedImage1,
          image2: selectedImage2,
          imageUrlPX: null,
          imageUrlCX: null,

          explanation: explainText!,

          isCreate: true,
          image_id: null,

          problem_id: "",
          comment_id: "",

          watched: 0,
          likes:  0,

          userName: userName,
          image_own_user_id: myUserId,
          difficulty: 0,
          profileImage: profileImageId[0]["profile_image_id"],

          problemAdd: 0,
          commentAdd: 0,
        ),

        /*
        SizedBox(
          height: SizeConfig.blockSizeVertical! * 5,
          child: InterstitialExample()
        ),
         */

        
        /*
        ElevatedButton(
          onPressed: () async{

            //showLoadingDialog(context,"処理中...");

            //TODO Admob
            
            if (_interstitialAd == null) {
              return;
            }
            _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
              onAdShowedFullScreenContent: (InterstitialAd ad) =>
                print('$ad onAdShowedFullScreenContent.'),
                //context.showSuccessSnackBar(message: "aaa"),

              onAdDismissedFullScreenContent: (InterstitialAd ad) {
                print('$ad onAdDismissedFullScreenContent.');
                //context.showSuccessSnackBar(message: "bbb");
                ad.dispose();
                _loadAd();
              },

              onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
                print('$ad onAdFailedToShowFullScreenContent: $error');
                //context.showErrorSnackBar(message: "ccc");
                ad.dispose();
                _loadAd();
                return;
              },

              onAdImpression: (InterstitialAd ad) => print('$ad impression occurred.'),
              onAdClicked: (InterstitialAd ad) => print('$ad clicked.'));

              // TODO admob本番
              _interstitialAd!.show();
              _interstitialAd = null;

          },
          child: const Text("広告を見る1"),
        ),
         */

        Row(
          children: [
            Text("参考文献はこんな感じに表示されます→"),


            IconButton(
              icon: const Icon(Icons.bar_chart, color: Colors.blue,),
              tooltip: "参考文献の確認",
              onPressed: (){
                _showReferenceSheet(context);
              },
            ),
          ],
        ),
         

        /*
        ElevatedButton(
          onPressed: () async{
            

            interstitialAdManager.showInterstitialAd();
          },
          child: const Text("広告を見る2"),
        ),
         */
        
        ElevatedButton(
          onPressed: () async {

            showLoadingDialog(context,"処理中...");


            //TODO Admob

            /*
            if (_interstitialAd == null) {
              return;
            }
            _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
              onAdShowedFullScreenContent: (InterstitialAd ad) =>
                print('$ad onAdShowedFullScreenContent.'),
                //context.showSuccessSnackBar(message: "aaa"),

              onAdDismissedFullScreenContent: (InterstitialAd ad) {
                print('$ad onAdDismissedFullScreenContent.');
                //context.showSuccessSnackBar(message: "bbb");
                ad.dispose();
                _loadAd();
                return;
              },

              onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
                print('$ad onAdFailedToShowFullScreenContent: $error');
                //context.showErrorSnackBar(message: "ccc");
                ad.dispose();
                _loadAd();
                return;
              },

              onAdImpression: (InterstitialAd ad) => print('$ad impression occurred.'),
              onAdClicked: (InterstitialAd ad) => print('$ad clicked.')
            );

            // TODO admob本番
            _interstitialAd!.show();
            _interstitialAd = null;
             */

            //TODO Admob
            

            
            




            //ここからSupabase
            int checkSupabase = await sendInfoToSupabase();

            if(checkSupabase != 0){
              if(context.mounted){
                //deleteInfoFromSupabase();
                //context.showErrorSnackBar(message: "サーバーエラーにより、問題の投稿ができませんでした。");
                Navigator.of(context).pop();
              }

              if(context.mounted){
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(

                      title: const Text("エラー"),
                      content: const Text("サーバーエラーにより、問題の投稿ができませんでした。"),
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

            //3秒待つ
            await Future.delayed(const Duration(seconds: 5));

            //ここから画像のアップロードURL取得。
            int checkGetUploadUrl1 = await getImageUploadUrls(true);
            int checkGetUploadUrl2 = await getImageUploadUrls(false);
            

            if(checkGetUploadUrl1 != 0 || checkGetUploadUrl2 != 0){
              if(context.mounted){
                deleteInfoFromSupabase();
                //context.showErrorSnackBar(message: "サーバーエラーにより、画像のアップロードができませんでした。");
                Navigator.of(context).pop();
              }

              if(context.mounted){
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                          title: const Text("エラー"),
                          content: const Text("サーバーエラーにより、URLの取得ができませんでした。"),
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




            //supabaseにURLを送信
            /*
            int checkUpdateInfo = await updateInfoToSupabase();

            if(checkUpdateInfo != 0){
              if(context.mounted){
                deleteInfoFromSupabase();
                //context.showErrorSnackBar(message: "サーバーエラーにより、URLの送信ができませんでした。");
                Navigator.of(context).pop();
              }

              if(context.mounted){
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                          title: const Text("エラー"),
                          content: const Text("サーバーエラーにより、URLの送信ができませんでした。"),
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
             */

            print("Supabaseはおｋ");

            int checkUpload1 = await imageUploadWithUrls(true);
            int checkUpload2 = await imageUploadWithUrls(false);


            if(checkGetUploadUrl1 != 0 || checkGetUploadUrl2 != 0){
              if(context.mounted){
                //context.showErrorSnackBar(message: "サーバーエラーにより、画像のアップロードができませんでした。");
                Navigator.of(context).pop();
              }

              if(context.mounted){
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text("エラー"),
                      content: const Text("サーバーエラーにより、画像のアップロードができませんでした。"),
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



            

            if(context.mounted){
              // ダイアログを閉じる
              Navigator.of(context).pop();
            }

            if(context.mounted){
              subject == "数学" ? math-- : subject == "物理" ? phys-- : subject == "化学" ? chem-- : other--;              
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text("Great!"),
                      content: const Text("問題の投稿が完了しました！"),
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

            

            setState(() {
              isConfirmationMode = false;
            });
          },
          child: const Text("確認して投稿"),
        ),

        ElevatedButton(
          onPressed: () {
            setState(() {
              isConfirmationMode = false;
            });
          },
          child: const Text("編集"),
        ),

      ],
    );
  }
   */
}









