import 'package:flutter/material.dart';

import 'package:share_your_q/pages/profile_page/profile_page.dart';
import 'package:share_your_q/utils/various.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';



//import "package:share_your_q/admob/ad_test.dart";

import 'dart:typed_data';


//google_admob
//TODO ビルドリリースの時のみ
//import 'package:share_your_q/admob/inline_adaptive_banner.dart';

String textKeeper = "";

class CommentList extends StatefulWidget {

  final int imageId;

  final int responseId;

  final bool canToPage;

  final String resText;

  final Map<String, dynamic>? item;

  final String title;



  const CommentList({
    Key? key,
    required this.imageId,
    required this.responseId,
    required this.canToPage,
    required this.resText,

    required this.item,

    required this.title,

  }) :super(key: key);

  @override
  CommentListState createState() => CommentListState();

}


class CommentListState extends State<CommentList> {
  bool isLoading = true;

  List<Map<String, dynamic>> commentList = [];

  Future<void> fetchData() async {
    try {
      final List<Map<String, dynamic>> response;

      response = await supabase
        .from("comments")
        .select<List<Map<String,dynamic>>>()
        .eq("image_id", widget.imageId)
        .eq("response_id", widget.responseId)
        .order('created_at', ascending: false);

      setState(() {
        isLoading = false;
        commentList = response;
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }


  
  @override
  void initState() {
    super.initState();
    _textController.text = textKeeper;

    fetchData();

    isLoading = false;


    //TODO ビルドリリースの時のみ
  }

  @override
  void dispose() {
    super.dispose();

    textKeeper = _textController.text;
    _textController.dispose();

    //TODO ビルドリリースの時のみ
  }

  


  // リストをリロードするメソッド
  Future<void> reloadList() async{
    setState(() {
      isLoading = true;
    });
    await fetchData(); // リロード時にデータを再取得
  }

   TextEditingController _textController = TextEditingController();

  void _showCommentSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // スクロール可能かどうか
      //isDismissible: false,
      builder: (context) {
        return Container(
          height: SizeConfig.blockSizeVertical! * 35,
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom, // キーボードが表示された際にウィジェットが上にスクロールするようにする
          ),
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              //mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: TextField(
                    maxLength: 500,
                    controller: _textController,
                    keyboardType: TextInputType.multiline,
                    maxLines: 5, // 複数行入力可能
                    decoration: InputDecoration(
                      hintText: 'コメントを入力',
                      border: OutlineInputBorder(),
                            
                    ),
                  ),
                ),
                //SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    _submitMessage();
                    Navigator.of(context).pop(); // モーダルを閉じる
                  },
                  child: Text('送信'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  //https://qiita.com/hirothings/items/9601165efee48713cee8
  void showCommentListTest2(){
    showModalBottomSheet(
      //大きさは画面の90%に設定

      context: context,
      isScrollControlled: true,
      builder: (context) => Navigator(
        onGenerateRoute: (context) => MaterialPageRoute<CommentList>(
          builder: (context) => Container(
            height: SizeConfig.blockSizeVertical! * 70,
            child: CommentList(
              imageId: widget.imageId,
              responseId: widget.responseId,
              canToPage: true,
              resText: "テストtext",
              item: null,
              title: "返信",
            ),
          ),
        ),
      ),
    );
  }


  void showCommentListTest(BuildContext context) {
  showModalBottomSheet(
    isDismissible: false,

    context: context,
    isScrollControlled: true,
    builder: (context) => Container(
      height: SizeConfig.blockSizeVertical! * 70,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),

      /*
      child: Navigator(
        onGenerateRoute: (context) => MaterialPageRoute<CommentList>(
          builder: (context) => CommentList(
            imageId: widget.imageId,
            responseId: widget.responseId,
            canToPage: true,
            resText: "テストtext",
            item: null,
            title: "返信",
          ),
        ),
      ),
       */
    ),
  );
}





  /// メッセージを送信する
  void _submitMessage() async {
    final comment = _textController.text;
    textKeeper = "";
    if (comment.isEmpty) {
      context.showErrorSnackBar(message: "コメントが入力されていません。");
      return;
    }
    _textController.clear();
    try {
      await supabase.from('comments').insert({
        "user_id": myUserId,
        'comments': comment,
        "image_id": widget.imageId,
        "response_id": widget.responseId,
      });


    } on PostgrestException catch (error) {
      // エラーが発生した場合はエラーメッセージを表示
      context.showErrorSnackBar(message: error.message);
    } catch (_) {
      // 予期せぬエラーが起きた際は予期せぬエラー用のメッセージを表示
      context.showErrorSnackBar(message: unexpectedErrorMessage);
    }

    /*
    fetchData().then((data) {
      setState(() {
        _commentList = data;
      });
    });
     */
    
  }


  bool commentShow = true;

  

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Scaffold(
      /*
      
       */

      appBar: AppBar(
        automaticallyImplyLeading: widget.canToPage,

        leading: widget.responseId == -1 
          ? IconButton(
            // 閉じるときはネストしているModal内のRouteではなく、root側のNavigatorを指定する必要がある
            onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
            icon: Icon(Icons.close)
          )
            //ひとつ前に戻る
          : IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: Icon(Icons.arrow_back)
            ),
        title: Text(widget.title), // アプリバーに表示するタイトル

        
        actions: [
          /*
          if(widget.responseId == -1 ) ElevatedButton(
            onPressed: () {
              setState(() {
                showCommentListTest(context);
                //commentShow = !commentShow;
              });
            },
            child: const Text("コメント表示")
          ),
           */
          IconButton(
            onPressed: reloadList,
            icon: commentShow ? Icon(Icons.refresh) : Container(), // リロードアイコン
          ),
        ],
         

      ),

      body: commentShow ? Center(
        child: SizedBox(
          height: SizeConfig.blockSizeVertical! * 70,
          child: Column(
            children: [
              widget.responseId != -1 ? Container(
                child: CommentItem(item: widget.item!, isRes: true,),
              )
              : Container(),
              
              
              Expanded(
                /*
                height: SizeConfig.blockSizeVertical! * 65,
                //中央寄り
                alignment: Alignment.center,
                 */
                
                child: Column(
                  children: [
              
                    if(commentList.isEmpty && !isLoading)
                      Container(
                        //padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal! * 10),
                        child: const Text(
                          "コメントはありません",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      )
              
                    else 
                      isLoading
                          ? const Expanded(
                              child: Center(
                                child: CircularProgressIndicator()
                              )
                            )
                          : Expanded(
                            
                            //RefreshIndicatorによってリロードできるようになる。
                              child: RefreshIndicator(
                                color: Colors.green,
                                onRefresh: () async{ 
                                  await reloadList();
                                },
              
                                //リストビューを作成する
                                //TODOスクロールバーの追加
                                child: ListView.builder(
                                  addAutomaticKeepAlives: true,
                                  //https://stackoverflow.com/questions/68623174/why-cant-i-slide-the-listview-builder-on-flutter-web
                                  physics: const AlwaysScrollableScrollPhysics(),
                                  
                                  
                                  //TODO ここでリストの保持を行う。
                                  itemCount: commentList.length,
                                  //itemCount: 10,
                                  itemBuilder: (context, index) {
                                                      
                                    //6の倍数の時には広告を表示する。
                                    if(index%6 == 1){
                                      final item = commentList[index];
                                      return Column(
                                        children: [
                                          /*
                                          Container(
                                            height: 64,
                                            width: double.infinity,
                                            color: Colors.white,
                                            //TODO ビルドリリースの時のみ
                                            //child: _adMob.getAdBanner(),
                                          ),
                                           */
                                                      
                                          SizedBox(
                                            height: SizeConfig.blockSizeVertical! * 40,
                                            //InlineAdaptiveAdBanner(requestId: "LIST",),
                                            //TODO Admob
                                            /*
                                            child: InlineAdaptiveAdBanner(
                                              requestId: "LIST", 
                                              adHeight: SizeConfig.blockSizeVertical!.toInt() * 40,
                                            )//InlineAdaptiveExample(),
                                             */
                                          ),
                                          //const ,
                                                      
                                          
                                          CommentItem(item: item, isRes: false,) ,
                                        ],
                                      );
                                    }
                                    else{
                                      final item = commentList[index];
                                      return CommentItem(item: item, isRes: false,); 
                                    }
                                    
                                    
                                  },
                                ),
                              ),
                            ),
              
                    
                    
                  ],
                ),
              ),
            
              Material(
                //color: Colors.black12,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          /*
                          keyboardType: TextInputType.multiline,
                          maxLines: 3, // 複数行入力可能。3行まで表示。
                          controller: _textController,
                          decoration: const InputDecoration(
                            hintText: 'メッセージを入力',
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: EdgeInsets.all(8),
                          ),
                            */
                
                          child: Text("コメントを入力"),
                
                          onPressed: () {
                            _showCommentSheet();
                          }
                        
                        
                        ),
                      ),
                        
                      /*
                      TextButton(
                        onPressed: () {
                          //_submitMessage();
                          _showCommentSheet();
                        },
                        child: const Text('送信'),
                      ),
                        */
                    ],
                  ),
                )
              ),
            
            ],
          ),
        ),
      )
      : null
    );
  }
}












//ここはsupabaseから取得したデータの内容を表示するためのウィジェット
class CommentItem extends StatefulWidget {
  final Map<String, dynamic> item;
  final bool isRes;
  const CommentItem({

    Key? key,
    required this.item,

    required this.isRes,
    
  }): super(key: key);

  @override
  State<CommentItem> createState() => _CommentItemState();
}

class _CommentItemState extends State<CommentItem> with AutomaticKeepAliveClientMixin {

  //TODO mylistitemが保持されているかどうか。
  @override
  bool get wantKeepAlive => true;


  String profileImageId = dotenv.get("CLOUDFLARE_NO_IMAGE_URL");
  String userName = "";

  String targetUserId = "";

  Future<void> fetchUserProfile(String target) async{
    try{
      final response = await supabase
        .from("profiles")
        .select<List<Map<String,dynamic>>>()
        .eq("id", target);
      
      setState(() {
        userName = response[0]["username"];
      });
    } on PostgrestException catch (error){
      context.showErrorSnackBar(message: error.message);
    } catch(_){
      context.showErrorSnackBar(message: unexpectedErrorMessage);
    }
  }

  Future<String> fetchProfileImage(String target) async{

    try{

      final response = await supabase
        .from("profiles")
        .select<List<Map<String, dynamic>>>()
        .eq("id", target);

      if(response[0]["profile_image_id"] == null){

        return dotenv.get("CLOUDFLARE_NO_IMAGE_URL");
      }
      else{
        profileImageId = response[0]["profile_image_id"];
        return response[0]["profile_image_id"];
      }

      //print(profileImageId);

      //return response[0]["profile_image_id"];

    } on PostgrestException catch (error){
      if(context.mounted){
        context.showErrorSnackBar(message: error.message);
        
      }
      return dotenv.get("CLOUDFLARE_NO_IMAGE_URL");
    } catch(_){
      if(context.mounted){
        context.showErrorSnackBar(message: unexpectedErrorMessage);
        
      }
      return dotenv.get("CLOUDFLARE_NO_IMAGE_URL");
    }


  }

  Future<void> onPressedThumbsButton(bool isGood)async{
    final response = await supabase
      .from("comments_like")
      .upsert({
        isGood ? "good" : "bad": widget.item[isGood ? "good" : "bad"] + 1,
      })
      .eq("comment_id", widget.item["id"]);
  }

  Future<void> showCommentForm() async{
    print("コメントフォームが表示されました");
  }


  //ここで投稿日時の管理
  String formatCreatedAt(String createdAtString) {
    DateTime createdAt = DateTime.parse(createdAtString);
    DateTime now = DateTime.now();
    Duration difference = now.difference(createdAt);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分前';

    } else if (difference.inHours < 24) {
      return '${difference.inHours}時間前';

    } else if (difference.inDays < 365) {
      return '${createdAt.month}月${createdAt.day}日';

    } else {
      return '${createdAt.year}年${createdAt.month}月${createdAt.day}日';
    }
  }

  bool isLoadingImage = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    targetUserId = widget.item["user_id"];


    //fetchProfileImage(targetUserId);

    fetchUserProfile(targetUserId);

  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Card(
      color: widget.isRes ? Colors.black12 : null,
      child: ListTile(
        dense: true,


        

        leading: FutureBuilder(
          future: fetchProfileImage(targetUserId),
          builder: (context, profileImageSnapshot) {
            if (profileImageSnapshot.connectionState == ConnectionState.waiting) {
              // データの読み込み中はローディングインジケータなどを表示する
              return const CircularProgressIndicator();
            } else if (profileImageSnapshot.hasError || profileImageSnapshot.data == "") {
              // エラーが発生した場合は代替のアイコンを表示する
              return GestureDetector(
                child: const CircleAvatar(
                  radius: 20,
                  child: Icon(
                    Icons.error_outline,
                    color: Colors.blue,
                    size: 40,
                  ),
                ),
                onTap: () {
                  print('エラーが発生しました。onTap アクションをここで処理してください。');
                  context.showErrorSnackBar(message: "プロフィールに遷移できません");
                },
              );
            } else {
              print(targetUserId);
              isLoadingImage = false;
              // データが正常に読み込まれた場合に画像を表示する
              return GestureDetector(
                child: CircleAvatar(
                  radius: 20,
                  child: ClipOval(
                    child: FutureBuilder(
                      future: fetchImageWithCache(profileImageSnapshot.data as String),
                      builder: (context, imageSnapshot) {
                        if (imageSnapshot.connectionState == ConnectionState.waiting) {
                          // データの読み込み中はローディングインジケータなどを表示する
                          return const CircularProgressIndicator();
                        } else if (imageSnapshot.hasError || imageSnapshot.data == null) {
                          print("ここかもしれないなぁ");
                          // エラーが発生した場合は代替のアイコンを表示する
                          return const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 40,
                          );
                        } else {
                          // データが正常に読み込まれた場合に画像を表示する
                          print("ここは最後の砦です");
                          print(profileImageSnapshot.data);
                          return Image.memory(
                            imageSnapshot.data as Uint8List,
                            fit: BoxFit.cover,
                            width: 40,
                            height: 40,
                            errorBuilder: (context, error, stackTrace) {
                              print("ここは最後のエラーとアンって");
                              // エラーが発生した場合の代替イメージを表示する
                              return const Icon(
                                Icons.error_outline,
                                color: Colors.red,
                                size: 40,
                              );
                            },
                          );
                        }
                      },
                    ),
                  ),
                ),
                onTap: () {
                  if (!isLoadingImage) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ProfilePage(
                          userId: targetUserId, 
                          userName: userName, 
                          profileImage: profileImageId,
                        ),
                      ),
                    );
                  } else {
                    context.showErrorSnackBar(message: "現在読み込み中です...");
                  }
                },
              );
            }
          },
        ),






        title: Padding(
          padding: const EdgeInsets.all(1.0),
          child: Text(
            userName,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          //mainAxisAlignment: MainAxisAlignment.start,
          children: [
        
            Text(formatCreatedAt(widget.item["created_at"])),
        
            SizedBox(height: SizeConfig.blockSizeVertical! * 1,),
        
            Text(
              widget.item["comments"] as String,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold
                
              ),
            ),

            SizedBox(height: SizeConfig.blockSizeVertical! * 1,),
        
        
            Row(
              //mainAxisAlignment: MainAxisAlignment.start,
              //crossAxisAlignment: CrossAxisAlignment.start,
              children: [
        
                //ここはグッドボタン
                IconButton(
                  onPressed: () => onPressedThumbsButton(true),
                  icon: Icon(
                    Icons.thumb_up_alt_outlined,
                    color: Colors.white,
                    size: 16,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                ),
        
                //SizedBox(width: 10,),
        
                Text(widget.item["good"].toString()),
        
                SizedBox(width: SizeConfig.blockSizeHorizontal! * 1,),
        
        
                //ここはバッドボタン
                IconButton(
                  onPressed: () => onPressedThumbsButton(false),
                  icon: Icon(
                    Icons.thumb_down_alt_outlined,
                    color: Colors.white,
                    size: 16,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                  
                ),
        
                //SizedBox(width: 10,),
        
                Text(widget.item["bad"].toString()),
        
                SizedBox(width: SizeConfig.blockSizeHorizontal! * 1,),
        
                //ここはコメントボタン
                IconButton(
                  onPressed: () => showCommentForm(),
                  icon: Icon(
                    Icons.comment,
                    color: Colors.green,
                    size: 16,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                ),
        
                //SizedBox(width: 10,),
        
                Text(widget.item["response_num"].toString()),
        
                
        
              ],
            ),
        
            /*
            Row(
              children: [
                Text("返信"),
                Text(widget.item["response_num"].toString()),
              ],
            ),
             */
        
          ],
        ),
        onTap: () async{

          widget.isRes ? null

          :Navigator.of(context).push(
            MaterialPageRoute(

              builder: (context) => CommentList(
                imageId: widget.item["image_id"] as int,
                responseId: widget.item["id"] as int,
                canToPage: true,
                resText: widget.item["comments"] as String,
                item: widget.item,
                title: "返信"
              ),
            )

          );
           
        },
      ),
    );
  }
}
