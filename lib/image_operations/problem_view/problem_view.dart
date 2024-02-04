import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:file_picker/file_picker.dart';
import "package:share_your_q/utils/various.dart";
import "package:share_your_q/image_operations/image_request.dart";
import 'dart:typed_data';
import "package:share_your_q/pages/profile_page/profile_page.dart";

import 'package:share_your_q/image_operations/problem_view/pro_com_add.dart';


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

  bool showProblemImage = false;
  bool showExplanationImage = false;

  bool isLoadingImage1 = true; // 1つ目の画像の読み込み状態を管理
  bool isLoadingImage2 = true; // 2つ目の画像の読み込み状態を管理

  Uint8List? image1Bytes = Uint8List(0);
  Uint8List? image2Bytes = Uint8List(0);

  Uint8List? profileImageBytes = Uint8List(0);


  

  @override
  void initState() {

    super.initState();

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

    return SingleChildScrollView(

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
                    InkWell(
                      onTap: () {
                        if (widget.userName != null && widget.userName != ""){
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ProfilePage(
                              userName: widget.userName!,
                              userId: widget.image_own_user_id,
                              profileImage: widget.profileImage,
                            )),
                          );
                        }
                        
                      },
                      child: CircleAvatar(
                        backgroundImage: profileImageBytes != null && profileImageBytes != Uint8List(0)
                          ? MemoryImage(profileImageBytes!)
                          : NetworkImage(dotenv.get("CLOUDFLARE_NO_IMAGE_URL")) as ImageProvider<Object>?,
                        radius: 20,
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
                  ],
                ),

                const SizedBox(height: 5,),

                Row(
                  children: [
                    Text("難易度: ${widget.difficulty}"),

                    const SizedBox(width: 10,),

                    /*
                    GestureDetector(
                      child: CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: Text(
                          "易",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        radius: 15,
                      )
                    ),

                    SizedBox(width: 10,),

                    GestureDetector(
                      child: CircleAvatar(
                        backgroundColor: Colors.red,
                        child: Text(
                          "難",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        radius: 15,
                      )
                    ),
                     */
                  ],
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
                        await likeImage(widget.image_id, myUserId);
                        setState(() {
                          widget.likes += 1;
                        });
                      },
                      icon: Icon(Icons.favorite, color: Colors.red, size: 24,)
                    ),
                    //Text("いいね: ${widget.likes}"),
                    Text("${widget.likes}"),
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
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.green),
                    borderRadius: BorderRadius.circular(10),
                  ),
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
                  //画像を拡大表示する
                  showDialog(
                    context: context,
                    builder: (_) {
                      return Dialog(
                        child: Stack(
                          children: [
                            Container(
                              width: double.infinity,
                              height: double.infinity,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: Image.memory(
                                    image1Bytes!,
                                    fit: BoxFit.cover,
                                  ).image,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 16.0,
                              left: 16.0,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pop(); // ダイアログを閉じる
                                },
                                child: const Icon(
                                  Icons.arrow_back,
                                  color: Colors.white,
                                  size: 24.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
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
                  width: SizeConfig.blockSizeHorizontal! * 100,
                  height: SizeConfig.blockSizeVertical! * 100,
              
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
                  //画像を拡大表示する
                  showDialog(
                    useSafeArea: false,
                    context: context,
                    builder: (_) {
                      return Dialog(
                        child: Stack(
                          children: [
                            Container(
                              width: double.infinity,
                              height: double.infinity,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: Image.memory(
                                    image2Bytes!,
                                    fit: BoxFit.cover,
                                  ).image,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 16.0,
                              left: 16.0,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pop(); // ダイアログを閉じる
                                },
                                child: const Icon(
                                  Icons.arrow_back,
                                  color: Colors.white,
                                  size: 24.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                 
                }
              ),


          SizedBox(height: SizeConfig.blockSizeVertical! * 10,),

        ],
      ),
    );
  }
}


