import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:share_your_q/cloudflare_relations/server_request.dart';
import 'package:share_your_q/image_operations/image_upload.dart';
import 'package:share_your_q/image_operations/problem_view/problem_view.dart';
import 'package:share_your_q/pages/create_page/components/reference.dart';
import 'package:share_your_q/utils/various.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ConfirmPage extends StatefulWidget {

  final String problemTitle;
  final PlatformFile? selectedImage1;
  final PlatformFile? selectedImage2;

  final String subject;

  final String level;

  final String lang;

  final String explainText;

  final String refText;

  final List<String> urls;

  final List<String> tags;

  final String userName;

  final String? profileImageId;



  const ConfirmPage(
    {
      Key? key,
      required this.problemTitle,
      required this.selectedImage1,
      required this.selectedImage2,
      required this.subject,
      required this.level,
      required this.lang,
      required this.explainText,
      required this.refText,
      required this.urls,
      required this.tags,
      required this.userName,
      required this.profileImageId
    }
  ) : super(key: key);

  @override
  State<ConfirmPage> createState() => _ConfirmPageState();
}

class _ConfirmPageState extends State<ConfirmPage> {


  void _showReferenceSheet(BuildContext context) {
    showModalBottomSheet(
      constraints: BoxConstraints(
        minWidth: SizeConfig.blockSizeHorizontal! * 100,
      ),
      context: context,
      //これがないと高さが変わらない
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SizedBox(
          height: SizeConfig.blockSizeVertical! * 60,
          child: ReferenceDisplay(linkText: widget.urls, refExplain: widget.refText)
        );
      },
    );
  }

  //現在作っている問題が何問目か(制限を考える)
  int problemNum = 1;

  //cloudflare imagesのURLにつかうcustomId
  String? customId1;
  String? customId2;

  //cloudflare imagesのURLにつかうdirectUploadUrl
  String? directUploadUrl1;
  String? directUploadUrl2;



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
    fetchImageSubject();
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
        "title": widget.problemTitle,
        "subject": widget.subject,
        //"PorC": 1,
        "level": widget.level,
        //"tags": tags,
        "tag1": widget.tags.isNotEmpty ? widget.tags[0] : "",
        "tag2": widget.tags.length > 1 ? widget.tags[1] : "",
        "tag3": widget.tags.length > 2 ? widget.tags[2] : "",
        "tag4": widget.tags.length > 3 ? widget.tags[3] : "",
        "tag5": widget.tags.length > 4 ? widget.tags[4] : "",
        "user_id": myUserId,
        "p_num": 1,
        "c_num": 1,
        //"user_name" : userName,
        "explain": widget.explainText,
        "problem_id": null,
        "comment_id": null,
        //"likes": 100,
        "links": widget.urls,
        "ref_explain": widget.refText,
        "lang": widget.lang,
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
        knownUserInfo: myUserId,
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
      final checkUpload1 = await uploadSelectedImage(widget.selectedImage1, customId1!, directUploadUrl1);
    
      if(checkUpload1 != 0){
        return 1;
      }
    }
    else{
      final checkUpload2 = await uploadSelectedImage(widget.selectedImage2, customId2!, directUploadUrl2);
    
      if(checkUpload2 != 0){
        return 1;
      }
    }

    return 0;
  }



















  @override
  Widget build(BuildContext context) {


    return Scaffold(

      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('確認ページ'),

        
      ),

      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                
                    //ここで問題の評価を見る
                    
                
                
                    ProblemViewWidget(
                      title: widget.problemTitle,

                      tag1: widget.tags.isNotEmpty ? widget.tags[0] : null,
                      tag2: widget.tags.length > 1 ? widget.tags[1] : null,
                      tag3: widget.tags.length > 2 ? widget.tags[2] : null,
                      tag4: widget.tags.length > 3 ? widget.tags[3] : null,
                      tag5: widget.tags.length > 4 ? widget.tags[4] : null,

                
                      /*
                      
                       */
                
                      //tags: tags,
                      level: widget.level,
                      subject: widget.subject,
                      image1: widget.selectedImage1,
                      image2: widget.selectedImage2,
                      imageUrlPX: null,
                      imageUrlCX: null,
                
                      explanation: widget.explainText,
                
                      isCreate: true,
                      image_id: null,
                
                      problem_id: "",
                      comment_id: "",
                
                      watched: 0,
                      likes:  0,
                
                      userName: widget.userName,
                      image_own_user_id: myUserId,
                      difficulty: 0,
                      profileImage: widget.profileImageId,
                
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

                        //2秒待つ
                        await Future.delayed(const Duration(seconds: 2));

                        //ここまで来たらSupabaseはおｋ
                        if(context.mounted){
                          Navigator.of(context).pop();
                          showLoadingDialog(context, "画像のアップロード中...");
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

                          widget.subject == "数学" ? math-- : widget.subject == "物理" ? phys-- : widget.subject == "化学" ? chem-- : other--;              
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

                
                
        
                
                        
                
                        
                      },
                      child: const Text("確認して投稿"),
                    ),
                
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text("編集"),
                    ),
                
                    
                
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
}
