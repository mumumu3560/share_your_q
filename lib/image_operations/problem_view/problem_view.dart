import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_your_q/env/env.dart';
import "package:share_your_q/utils/various.dart";
import "package:share_your_q/image_operations/image_request.dart";
import "package:share_your_q/pages/profile_page/profile_page.dart";

import 'package:share_your_q/image_operations/problem_view/pro_com_add.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


//ユーザーの問題を表示するヴィジェット
class ProblemViewWidget extends StatefulWidget {
  final String title;
  //final List<String> tags;
  //tagは最大5つまでそれぞれをカンマで区切って表示する
  final String? tag1;
  final String? tag2;
  final String? tag3;
  final String? tag4;
  final String? tag5;

  final String level;
  final String subject;

  final PlatformFile? image1;
  final PlatformFile? image2;
  final String? imageUrlPX;
  final String? imageUrlCX;

  final String? explanation;

  final bool isCreate;

  final int? image_id;

  final String problem_id;
  final String comment_id;

  final int watched;

  final int likes;

  final String? userName;
  final String image_own_user_id;

  final double? difficulty;

  final String? profileImage;

  final int? problemAdd;
  final int? commentAdd;

  const ProblemViewWidget({
    Key? key,
    required this.title,

    //required this.tags,
    required this.tag1,
    required this.tag2,
    required this.tag3,
    required this.tag4,
    required this.tag5,

    required this.level,
    required this.subject,
    required this.image1,
    required this.image2,
    required this.imageUrlPX,
    required this.imageUrlCX,

    required this.explanation,

    required this.isCreate,
    required this.image_id,

    required this.problem_id,
    required this.comment_id,
    required this.watched,
    required this.likes,

    required this.userName,
    required this.image_own_user_id,
    required this.difficulty,

    required this.profileImage,

    required this.problemAdd,
    required this.commentAdd,
    
  }) : super(key: key);

  @override
  _ProblemViewWidgetState createState() => _ProblemViewWidgetState();
}

class _ProblemViewWidgetState extends State<ProblemViewWidget> {

  //これは画面全体の話
  bool isLoading = true;

  bool showProblemImage = false;
  bool showExplanationImage = false;

  bool isLoadingImage1 = true; // 1つ目の画像の読み込み状態を管理
  bool isLoadingImage2 = true; // 2つ目の画像の読み込み状態を管理

  Uint8List? image1Bytes = Uint8List(0);
  Uint8List? image2Bytes = Uint8List(0);

  Uint8List? profileImageBytes = Uint8List(0);

  bool isLiked = false;

  //最初にページを開いたときとそうでないときでの処理の変更
  bool isFirst = true;

  int likes = 0;

  bool _statusBarVisible = true;

  //ここで画像を拡大表示など
  //https://qiita.com/ling350181/items/adfebd6f7c648084d1b5

void showPreviewImage100(
  BuildContext context, {
  required Uint8List image,
}) {
  showDialog(
    //useSafeArea: false,
    barrierDismissible: true,
    //barrierLabel: '閉じる',
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return GestureDetector(
            onTap: () {
              _toggleSystemBars100(setState); // タップ時にシステムバーを切り替える
            },
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                Container(
                  color: Colors.black,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: InteractiveViewer(
                        minScale: 0.1,
                        maxScale: 5,
                        child: Image.memory(
                          image,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: _statusBarVisible ? IconButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(
                          Icons.arrow_back,
                          size: 30,
                        ),
                      )
                      : SizedBox(width: 0,),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

void _toggleSystemBars100(Function(void Function()) setState) {
  setState(() {
    _statusBarVisible = !_statusBarVisible;
    /*
    if (!_statusBarVisible) {
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual, overlays: [SystemUiOverlay.top, /*SystemUiOverlay.bottom
         */],
      );
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [/*SystemUiOverlay.bottom */]);
    }
    */
  });
}








  Future<void> loadLikes() async{
    try {
      // `user_id`と`image_id`の組み合わせで既存のレコードを検索する
      final existingRecord = await supabase
          .from('likes')
          .select()
          .eq('user_id', myUserId)
          .eq('image_id', widget.image_id!);


      // レコードが存在する場合はアップデート、存在しない場合は挿入する
      if (existingRecord.isNotEmpty) {
        // レコードが存在する場合はアップデート
        setState(() {
          isLiked = existingRecord[0]["add"];
        });

        final response;

        if(isFirst){
          response = await supabase
            .from('likes')
            .update({ 'add': isLiked })
            .eq('user_id', myUserId)
            .eq('image_id', widget.image_id!);
          isFirst = false;
        }
        else{
          response = await supabase
            .from('likes')
            .update({ 'add': !isLiked })
            .eq('user_id', myUserId)
            .eq('image_id', widget.image_id!);
        }

        //isLiked = !isLiked;
        if (response != null) {
          // エラーハンドリング
        } else {
          // 成功時の処理
        }
      } else {
        // レコードが存在しない場合は挿入
        final response2 = await supabase
            .from('likes')
            .insert({ 
              'add': false,
              'user_id': myUserId,
              'problem_num' : 0,
              "image_id" : widget.image_id,
              "image_own_user_id" : widget.image_own_user_id,
              });

        isFirst = false;


        if (response2 == null) {
          // エラーハンドリング
          print('Error inserting data: $response2');
        } else {
          // 成功時の処理
          print('Data inserted successfully!');
        }
      }
    } on PostgrestException catch(error){
      if(mounted){
        context.showErrorSnackBar(message: error.message);
      }
    } catch(_){
      if(mounted){
        context.showErrorSnackBar(message: unexpectedErrorMessage);
      }
    }
  }


  bool? isFollowed;
  String myUsername = "";

  Future<void> isFollow() async{
    try{

      final response = await supabase
        .from('follow')
        .select()
        .eq('follower_id', myUserId)
        .eq('followed_id', widget.image_own_user_id);

      final res = await supabase 
        .from("profiles")
        .select()
        .eq("id", myUserId);

      myUsername = res[0]["username"];
      
      if(response.isEmpty){

        await supabase
          .from("follow")
          .insert([
            {
              "follower_id" : myUserId,
              "followed_id" : widget.image_own_user_id,
              "add": false,
              "follower_name" : myUsername,
            }
          ]);

        setState(() {
          isFollowed = false;
        });

      }
      else{
        if(response[0]["add"] == true){
          setState(() {
            isFollowed = true;
          });
        }
        else{
          setState(() {
            isFollowed = false;
          });
        }
      }

    } on PostgrestException catch (error){
      if(mounted){
        context.showErrorSnackBar(message: error.message);
      }
      return null;
    } catch(_){
      if(mounted){
      context.showErrorSnackBar(message: unexpectedErrorMessage);
      }
      return null;
    }
  } 


  Future<void> followProcess() async{
    try{

      if(isFollowed == true){

        await supabase
          .from('follow')
          .update({ "add": false })
          .eq('follower_id', myUserId)
          .eq('followed_id', widget.image_own_user_id);

          /*
          "follower_id" : myUserId,
              "followed_id" : widget.image_own_user_id,
              "add": false,
              "follower_name" : myUsername,
           */
        
        setState(() {
          isFollowed = false;
        });
      }
      else if(isFollowed == false){


        await supabase
          .from('follow')
          .update({ "add": true })
          .eq('follower_id', myUserId)
          .eq('followed_id', widget.image_own_user_id);

          /*
          "follower_id" : myUserId,
              "followed_id" : widget.image_own_user_id,
              "add": false,
              "follower_name" : myUsername,
           */
        
        setState(() {
          isFollowed = true;
        });

      }


      
      



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

  Future<void> waitProcess() async{
    setState(() {
      likes = widget.likes;
    });

    if(!widget.isCreate){
      await loadLikes();
    }

    /*
    await fetchImage(widget.profileImage).then((bytes){
      setState(() {
        profileImageBytes = bytes;
      });
    });

    if(widget.image1 != null || widget.image2 != null){
      isLoadingImage1 = false;
      isLoadingImage2 = false;
    }
    else{

      // 1つ目の画像のバイナリデータを取得
      await fetchImage(widget.problem_id).then((bytes) {
        setState(() {
          image1Bytes = bytes;
          isLoadingImage1 = false;
        });
      });

      // 2つ目の画像のバイナリデータを取得
      await fetchImage(widget.comment_id).then((bytes) {
        setState(() {
          image2Bytes = bytes;
          isLoadingImage2 = false;
        });
      });


    }
     */

    //followProcess();

    if(myUserId != widget.image_own_user_id){
      await isFollow();
    }

    isLoading = false;

  }


  

  @override
  void initState() {
    super.initState();


    //ここでいいねとフォローの処理を行う
    waitProcess();

    //この先で画像を取得する。waitProcessから外したのはローディングの関係
    fetchImage(widget.profileImage).then((bytes){
      setState(() {
        profileImageBytes = bytes;
      });
    });

    if(widget.image1 != null || widget.image2 != null){
      isLoadingImage1 = false;
      isLoadingImage2 = false;
    }
    else{

      // 1つ目の画像のバイナリデータを取得
      fetchImage(widget.problem_id).then((bytes) {
        setState(() {
          image1Bytes = bytes;
          isLoadingImage1 = false;
        });
      });

      // 2つ目の画像のバイナリデータを取得
      fetchImage(widget.comment_id).then((bytes) {
        setState(() {
          image2Bytes = bytes;
          isLoadingImage2 = false;
        });
      });


    }
    
 
    


  }

  

  
  

  @override
  Widget build(BuildContext context) {
    
    
    SizeConfig().init(context);

    return (isLoading && widget.isCreate == false) 
    ? Center(
        child: CircularProgressIndicator()
      ) 
    :SingleChildScrollView(
    
      child: Column(
    
        children: <Widget>[
    
          Container(
            padding: const EdgeInsets.all(8.0),
            margin: const EdgeInsets.all(8.0),
            alignment: Alignment.centerLeft,
            //decoration: BoxDecoration(border: Border.all(), ),
            child: Text(
              widget.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
            ),
          ),
    
          Container(
            //alignment: Alignment.center,
            padding: const EdgeInsets.all(8.0),
            margin: const EdgeInsets.all(8.0),
            alignment: Alignment.centerLeft, 
            //decoration: BoxDecoration(border: Border.all(), color: Colors.black),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
    
                Row(
                  children: [
                    Material(
                      child: InkWell(
                        onTap: () {
                          if (widget.userName != null && widget.userName != ""){
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ProfilePage(
                                userName: widget.userName!,
                                userId: widget.image_own_user_id,
                                //profileImage: widget.profileImage,
                              )),
                            );
                          }
                          
                        },
                        child: CircleAvatar(
                          backgroundImage: profileImageBytes != null && profileImageBytes != Uint8List(0)
                            ? MemoryImage(profileImageBytes!)
                            : NetworkImage(Env.c3) as ImageProvider<Object>?,
                            
                          radius: 20,
                        ),
                      ),
                    ),
    
                    const SizedBox(width: 10,),
    
                    Text(
                      "${widget.userName}",
                      style: const TextStyle(
                        fontSize: 16, 
                        fontWeight: FontWeight.bold, 
                        fontStyle: FontStyle.italic
                      ),
                    ),
    
                    const SizedBox(width: 10,),
    
                    
                  ],
                ),
    
                const SizedBox(height: 10,),
                widget.image_own_user_id == myUserId || isFollowed == null
                      ? const SizedBox(width: 10,)
                      : ElevatedButton(
    
                        style: ElevatedButton.styleFrom(
                          //フォローしていないときは透明にしたい
                          backgroundColor: isFollowed == false ? Colors.blue : Colors.red,
                          //もうすこしまるみを持たせたい
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          
                        ),
                        onPressed: () async {
                          //フォローする
                          await followProcess();
                        },
                        child: isFollowed == false
                          ? const Text("フォローする", style:TextStyle(fontSize: 12, fontWeight: FontWeight.bold))
                          : const Text("フォロー解除", style:TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
    
                const SizedBox(height: 5,),
    
                Row(
                  children: [
    
                    Text(widget.level),
    
                    const SizedBox(width: 10,),
    
                    Text(widget.subject),
                    
                  ],
                ),
                
    
                const SizedBox(height: 5,),
                //タグを横並びにする
                
                Row(
    
                  children: [
                    if (widget.tag1 != null && widget.tag1 != "") Text("タグ: #${widget.tag1}"),
                    if (widget.tag2 != null && widget.tag2 != "") Text("#${widget.tag2}"),
                    if (widget.tag3 != null && widget.tag3 != "") Text("#${widget.tag3}"),
                    if (widget.tag4 != null && widget.tag4 != "") Text("#${widget.tag4}"),
                    if (widget.tag5 != null && widget.tag5 != "") Text("#${widget.tag5}"),
                  ],
                ),
    
                const SizedBox(height: 5,),
    
                Row(
                  children: [
                    Icon(Icons.remove_red_eye, color: Colors.green, size: 24,),
                    //Text("閲覧数: ${widget.watched}"),
                    Text("${widget.watched}"),
    
                    const SizedBox(width: 10,),
    
    
    
                    //ここをappbaractionsのものにする。
                    IconButton(
                      onPressed: widget.isCreate ? null : () async {
                        //いいねをする
                        await loadLikes();
    
                        setState(() {
                          isLiked = !isLiked;
                          likes = isLiked ? likes + 1 : likes - 1;
                        });
                      },
    
                      icon: Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border_outlined,
                        color: isLiked ? Colors.red : Colors.white,
                      ),
                    ),
    
                    
    
    
                    //Text("いいね: ${widget.likes}"),
                    Text("${likes}"),
                  ],
                ),
                
    
                const SizedBox(height: 15,),
    
                SelectableText(
                "説明:\n${widget.explanation}",
                style: const TextStyle(fontSize: 16,  fontStyle: FontStyle.italic),
                ),
    
                
              ],
              
    
            ),
          ),
    
          const SizedBox(height: 10,),
    
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    showProblemImage = !showProblemImage;
                  });
                },
                child: const Text("問題を表示する"),
              ),
    
              const SizedBox(width: 10,),
    
              ProblemOrCommentAdding(
                userId: myUserId,
                imageId: widget.image_id,
                isProblem: true,
                addNum: widget.problemAdd,
              ),
    
            ],
          ),
    
          const SizedBox(height: 10,),
    
          
    
          if (showProblemImage && (widget.image1 != null || image1Bytes != null))
            if (image1Bytes == Uint8List(0) || isLoadingImage1)
              preloader
            else
              GestureDetector(
    
                child: Container(
                  /*
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.green),
                    borderRadius: BorderRadius.circular(10),
                  ),
                   */
                  //width: SizeConfig.blockSizeHorizontal! * 100,
                  //height: SizeConfig.blockSizeVertical! * 100,
                  
                  padding: const EdgeInsets.all(8.0),
                  margin: const EdgeInsets.all(8.0),
                  //decoration: BoxDecoration(border: Border.all(), color: Colors.black),
                  child: SizedBox(
                    //width: SizeConfig.safeBlockHorizontal! * 80,
                    //height: SizeConfig.safeBlockVertical! * 30,
              
                    child: widget.image1 != null
                        ? Image.memory(
                            widget.image1!.bytes!,
                            fit: BoxFit.contain,
                          )
                          //ここでもし画像が存在しない場合の処理を考える
                          
                        : image1Bytes != null
                            ? Image.memory(
                                image1Bytes!,
                                fit: BoxFit.contain,
                              )
                            //TODO No imageの画像を表示する  
                            : null,
                  ),
              
                ),
    
                onTap:(){
           
    
                  showPreviewImage100(
                    context,
                    image: widget.isCreate
                      ? widget.image1!.bytes!
                      : image1Bytes!,
                  );
                 
                }
    
    
              ),
    
          SizedBox(height: SizeConfig.blockSizeVertical! * 10,),
    
    
          Row(
            mainAxisAlignment: MainAxisAlignment.center, 
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    showExplanationImage = !showExplanationImage;
                  });
                },
                child: const Text("解説を表示する"),
              ),
    
              const SizedBox(width: 10,),
    
              ProblemOrCommentAdding(
                userId: myUserId,
                imageId: widget.image_id,
                isProblem: false,
                addNum: widget.commentAdd,
              ),
            ],
          ),
          
    
    
          if (showExplanationImage && (widget.image2 != null || image2Bytes != null))
            if (image2Bytes == Uint8List(0) || isLoadingImage2)
              preloader
            else
              GestureDetector(
                child: Container(
                  //width: SizeConfig.blockSizeHorizontal! * 100,
                  //height: SizeConfig.blockSizeVertical! * 100,
              
                  padding: const EdgeInsets.all(8.0),
                  margin: const EdgeInsets.all(8.0),
                  //decoration: BoxDecoration(border: Border.all(), color: Colors.black),
                  child: SizedBox(
                    //width: SizeConfig.safeBlockHorizontal! * 80,
                    //height: SizeConfig.safeBlockVertical! * 80,
                    child: widget.image2 != null
                        ? Image.memory(
                            widget.image2!.bytes!,
                            fit: BoxFit.contain,
                          )
                          //ここでもし画像が存在しない場合を考える。
                        : widget.imageUrlCX != null
                            ? Image.memory(
                                image2Bytes!,
                                fit: BoxFit.contain,
                              )
                              //TODO No imageの画像を表示する
                            : null,
                  ),
                ),
    
                onTap:(){
    
                  showPreviewImage100(
                    context,
                    image: widget.isCreate
                      ? widget.image2!.bytes!
                      : image2Bytes!,
                  );
                 
                }
              ),
  
          SizedBox(height: SizeConfig.blockSizeVertical! * 10,),
    
          
          
    
        ],
      ),
    );
  }
}


