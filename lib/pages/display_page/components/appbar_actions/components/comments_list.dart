import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:share_your_q/env/env.dart';

import 'package:share_your_q/pages/profile_page/profile_page.dart';
import 'package:share_your_q/utils/various.dart';

//import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

//import "package:share_your_q/admob/ad_test.dart";

import 'dart:typed_data';

//google_admob
//TODO ビルドリリースの時のみ
import 'package:share_your_q/admob/inline_adaptive_banner.dart';

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
  }) : super(key: key);

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
          .select<List<Map<String, dynamic>>>()
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
  Future<void> reloadList() async {
    setState(() {
      isLoading = true;
    });
    await fetchData(); // リロード時にデータを再取得
  }

  TextEditingController _textController = TextEditingController();

  void _showCommentSheet() {
    showModalBottomSheet(
      constraints: BoxConstraints(
        maxWidth: SizeConfig.blockSizeHorizontal! * 100,
      ),
      context: context,
      isScrollControlled: true, // スクロール可能かどうか
      //isDismissible: false,
      builder: (context) {
        return Container(
          height: SizeConfig.blockSizeVertical! * 35 +
              MediaQuery.of(context).viewInsets.bottom,
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context)
                .viewInsets
                .bottom, // キーボードが表示された際にウィジェットが上にスクロールするようにする
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

      await reloadList();
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
        //resizeToAvoidBottomInset: true,
        /*
      
       */

        appBar: AppBar(
          automaticallyImplyLeading: widget.canToPage,

          leading: widget.responseId == -1
              ? null
              //ひとつ前に戻る
              : IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.arrow_back)),
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
            /*
          IconButton(
            onPressed: reloadList,
            icon: commentShow ? Icon(Icons.refresh) : Container(), // リロードアイコン
          ),
           */

            IconButton(
                // 閉じるときはネストしているModal内のRouteではなく、root側のNavigatorを指定する必要がある
                onPressed: () =>
                    Navigator.of(context, rootNavigator: true).pop(),
                icon: Icon(Icons.close))

            /*
          例外が発生しました
          _AssertionError (
            'package:flutter/src/widgets/navigator.dart': 
            Failed assertion: line 5277 pos 12: '!_debugLocked': is not true.
          )
           */
          ],
        ),
        body: commentShow
            ? Center(
                child: SizedBox(
                  //height: SizeConfig.blockSizeVertical! * 70,
                  child: Column(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            if (commentList.isEmpty && !isLoading)
                              Container(
                                  child: Column(
                                children: [
                                  widget.responseId == -1
                                      ? Container()
                                      : CommentItem(
                                          item: widget.item!, 
                                          isRes: true, 
                                          commentsId: widget.item!["id"] as int,
                                        ),
                                  Text(
                                    widget.responseId == -1
                                        ? "コメントはありません"
                                        : "返信はありません",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ))
                            else
                              isLoading
                                  ? const Expanded(
                                      child: Center(
                                          child: CircularProgressIndicator()))
                                  : Expanded(
                                      //RefreshIndicatorによってリロードできるようになる。
                                      child: RefreshIndicator(
                                        color: Colors.green,
                                        onRefresh: () async {
                                          await reloadList();
                                        },

                                        //リストビューを作成する
                                        //TODOスクロールバーの追加
                                        child: ListView.builder(
                                          addAutomaticKeepAlives: true,
                                          //https://stackoverflow.com/questions/68623174/why-cant-i-slide-the-listview-builder-on-flutter-web
                                          physics:
                                              const AlwaysScrollableScrollPhysics(),

                                          //TODO ここでリストの保持を行う。
                                          itemCount: widget.responseId != -1
                                              ? commentList.length
                                              : commentList.length,

                                          //itemCount: 10,
                                          itemBuilder: (context, index) {
                                            //

                                            if (index == 0 &&
                                                widget.responseId != -1) {
                                              return Column(
                                                children: [
                                                  CommentItem(
                                                    item: widget.item!,
                                                    isRes: true,
                                                    commentsId: widget.item!["id"] as int,
                                                  ),
                                                  CommentItem(
                                                    item: commentList[index],
                                                    isRes: false,
                                                    commentsId: commentList[index]["id"] as int,
                                                  ),
                                                ],
                                              );
                                            }


                                            //6の倍数の時には広告を表示する。
                                            if (index % 6 == 1) {
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

                                                  /*
                                          
                                           */

                                          SizedBox(
                                            height: SizeConfig.blockSizeVertical! * 40,
                                            //InlineAdaptiveAdBanner(requestId: "LIST",),
                                            //TODO Admob
                                            /*
                                            //InlineAdaptiveExample(),
                                             */
                                            child: InlineAdaptiveAdBanner(
                                              requestId: "LIST", 
                                              adHeight: SizeConfig.blockSizeVertical!.toInt() * 40,
                                            )
                                          ),
                                                  //const ,

                                                  CommentItem(
                                                    item: item,
                                                    isRes: false,
                                                    commentsId: item["id"] as int,
                                                  ),
                                                ],
                                              );
                                            } else {
                                              final item = commentList[index];
                                              return CommentItem(
                                                item: item,
                                                isRes: false,
                                                commentsId: item["id"] as int,
                                              );
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
                                  }),
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
                      )),
                    ],
                  ),
                ),
              )
            : null);
  }
}

//ここはsupabaseから取得したデータの内容を表示するためのウィジェット
class CommentItem extends StatefulWidget {
  final Map<String, dynamic> item;
  final bool isRes;
  final int commentsId;

  const CommentItem({
    Key? key,
    required this.item,
    required this.isRes,
    required this.commentsId,
  }) : super(key: key);

  @override
  State<CommentItem> createState() => _CommentItemState();
}

class _CommentItemState extends State<CommentItem>
    with AutomaticKeepAliveClientMixin {
  //TODO mylistitemが保持されているかどうか。
  @override
  bool get wantKeepAlive => true;

  String profileImageId = Env.c3;
  String userName = "";

  String targetUserId = "";

  /*
  例外が発生しました
FlutterError (This widget has been unmounted, so the State no longer has a context (and should be considered defunct).
Consider canceling any active work during "dispose" or using the "mounted" getter to determine if the State is still active.)
   */

  Future<void> fetchUserProfile(String target) async {
    try {
      final response = await supabase
          .from("profiles")
          .select<List<Map<String, dynamic>>>()
          .eq("id", target);

      setState(() {
        userName = response[0]["username"];
      });
    } on PostgrestException catch (error) {
      context.showErrorSnackBar(message: error.message);
    } catch (_) {
      context.showErrorSnackBar(message: unexpectedErrorMessage);
    }
  }

  late Future<Uint8List?> imageData;

  Future<Uint8List?> fetchProfileImage(String target) async {
    try {
      final response = await supabase
          .from("profiles")
          .select<List<Map<String, dynamic>>>()
          .eq("id", target);

      if (response[0]["profile_image_id"] == null) {
        profileImageId = Env.c3;
        //return dotenv.get("CLOUDFLARE_NO_IMAGE_URL");
      } else {
        profileImageId = response[0]["profile_image_id"];
        //return response[0]["profile_image_id"];
      }

      final response2 = await fetchImageWithCache(profileImageId);
      isLoadingImage = false;

      return response2;

      //print(profileImageId);

      //return response[0]["profile_image_id"];
    } on PostgrestException catch (error) {
      if (context.mounted) {
        context.showErrorSnackBar(message: error.message);
      }
      final response2 = await fetchImageWithCache(profileImageId);
      isLoadingImage = false;

      return response2;
    } catch (_) {
      if (context.mounted) {
        context.showErrorSnackBar(message: unexpectedErrorMessage);
      }
      final response2 = await fetchImageWithCache(profileImageId);
      isLoadingImage = false;

      return response2;
    }
  }

  /*
  PostgrestException 
  (
    PostgrestException(message: Column 'good' of relation 'comments_like' does not exist, 
    code: PGRST204, details: Bad Request, hint: null)
  )
   */

  bool isLike = false;
  bool isDisLike = false;

  Future<void> fetchCommentsLike()async{
    final response = await supabase
      .from("comments_like")
      .select<List<Map<String,dynamic>>>()
      .eq("comments_id", widget.commentsId)
      .eq("user_id", myUserId);

    if(response.isEmpty){

      final response2 = await supabase
        .from("comments_like")
        .insert({
          "comments_id": widget.commentsId,
          "good": false,
          "bad": false,
          "user_id": myUserId,
        });

      isLike = false;
      isDisLike = false;
    }
    else{
      isLike = response[0]["good"];
      isDisLike = response[0]["bad"];
    }

    setState(() {
      isLike = isLike;
      isDisLike = isDisLike;
    });
  }

  //isGoodはグッドボタンを押したかバッドボタンを押したか
  //isLike isDislike
  //それぞれのボタンが押されたかどうか
  Future<void> onPressedThumbsButton(bool isGood) async {
    
    try{
      final response3 = await supabase
        .from("comments_like")
        .update({
          "good": isGood ? !isLike : false,
          "bad": isGood ? false : !isDisLike,
        })
        .eq("comments_id", widget.commentsId)
        .eq("user_id", myUserId);

      if(isGood){
        //ここはグッドボタンを押したときの動作。
        //false→true
        //good++
        //true→false
        //good--
        isLike = !isLike;

        isLike ? good++ : good--;

        isDisLike = false;

      }
      else{

        //ここはバッドボタンを押したときの動作。
        //false→true
        //bad++
        //true→false
        //bad--
        //元々isLikeならgood--そうでなければなにもしない
        isDisLike = !isDisLike;

        isLike ? good-- : good = good;

        isLike = false;

        
      }

      setState(() {
        isLike = isLike;
        isDisLike = isDisLike;
      });

    }
    on PostgrestException catch (error) {
      context.showErrorSnackBar(message: error.message);
    } catch (_) {
      context.showErrorSnackBar(message: unexpectedErrorMessage);
    }
  }

  Future<void> showCommentForm() async {
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
  bool isLoading = true;

  int good = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    good = widget.item["good"] as int;
    fetchCommentsLike();

    targetUserId = widget.item["user_id"];

    //fetchProfileImage(targetUserId);

    fetchUserProfile(targetUserId);

    imageData = fetchProfileImage(targetUserId) as Future<Uint8List?>;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    //color: widget.isRes ? Colors.black12 : null,
    return ListTile(
      tileColor: widget.isRes ? Color.fromARGB(255, 73, 72, 72) : null,
      dense: true,
      //selectedColor: widget.isRes ? Colors.white : Colors.black12,

      title: Row(
        //rowは上にそろえる
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            child: CircleAvatar(
              radius: 14,
              child: ClipOval(
                child: FutureBuilder(
                  future: imageData,
                  builder: (context, imageSnapshot) {
                    if (imageSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      // データの読み込み中はローディングインジケータなどを表示する
                      return const CircularProgressIndicator();
                    } else if (imageSnapshot.hasError ||
                        imageSnapshot.data == null) {
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
          ),
      
      
          SizedBox(
            width: SizeConfig.blockSizeHorizontal! * 2,
          ),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              //mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(formatCreatedAt(widget.item["created_at"])),
                  ],
                ),
                SizedBox(
                  height: SizeConfig.blockSizeVertical! * 1,
                ),
                SizedBox(
                  //width: SizeConfig.blockSizeHorizontal! * 75,
                  child: Text(
                    widget.item["comments"] as String,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  height: SizeConfig.blockSizeVertical! * 1,
                ),
                Row(
                  //mainAxisAlignment: MainAxisAlignment.start,
                  //crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //ここはグッドボタン
                    IconButton(
                      onPressed: () => onPressedThumbsButton(true),
                      icon: Icon(
                        isLike ? Icons.thumb_up_alt : Icons.thumb_up_alt_outlined,
                        color: isLike ? Colors.green : Colors.white,
                        size: 16,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                    ),
                    
                    //SizedBox(width: 10,),
                    
                    Text( good.toString()),
                    
                    SizedBox(
                      width: SizeConfig.blockSizeHorizontal! * 1,
                    ),
                    
                    //ここはバッドボタン
                    IconButton(
                      onPressed: () => onPressedThumbsButton(false),
                      icon: Icon(
                        isDisLike ? Icons.thumb_down_alt : Icons.thumb_down_alt_outlined,
                        color: isDisLike ? Colors.red : Colors.white,
                        size: 16,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                    ),
                    
                    
                    /*
                    Text(
                      widget.item["bad"].toString(),
                    ),
                     */
                    
                    SizedBox(
                      width: SizeConfig.blockSizeHorizontal! * 1,
                    ),
                    
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
                    
 
              ],
            ),
          ),
        ],
      ),

      onTap: () async {
        widget.isRes
            ? null
            : Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => CommentList(
                    imageId: widget.item["image_id"] as int,
                    responseId: widget.item["id"] as int,
                    canToPage: true,
                    resText: widget.item["comments"] as String,
                    item: widget.item,
                    title: "返信"),
              ));
      },
    );
  }
}
