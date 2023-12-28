import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';
import "package:share_your_q/utils/various.dart";
import "package:share_your_q/image_operations/image_request.dart";
import 'dart:typed_data';
import "package:share_your_q/pages/profile_page/profile_page.dart";

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
  

  @override
  void initState() {

    super.initState();

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

        //mainAxisAlignment: MainAxisAlignment.center,
        //crossAxisAlignment: CrossAxisAlignment.center,

        children: <Widget>[

          Container(
            padding: EdgeInsets.all(8.0),
            margin: EdgeInsets.all(8.0),
            alignment: Alignment.centerLeft,
            //decoration: BoxDecoration(border: Border.all(), ),
            child: Text(
              "${widget.title}",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
            ),
          ),

          Container(
            //alignment: Alignment.center,
            padding: EdgeInsets.all(8.0),
            margin: EdgeInsets.all(8.0),
            alignment: Alignment.centerLeft, 
            //decoration: BoxDecoration(border: Border.all(), color: Colors.black),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                

                InkWell(
                  child: Text("制作者: ${widget.userName}"),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProfilePage(userId: widget.image_own_user_id, userName: widget.userName!,)),
                    );
                  },
                ),
                

                SizedBox(height: 5,),

                Text("レベル: ${widget.level}"),
                // tagは最大5つまでそれぞれをカンマで区切って表示する

                SizedBox(height: 5,),
                //タグを横並びにする
                
                Row(

                  children: [
                    if (widget.tag1 != null) Text("タグ: #${widget.tag1}"),
                    if (widget.tag2 != null) Text("#${widget.tag2}"),
                    if (widget.tag3 != null) Text("#${widget.tag3}"),
                    if (widget.tag4 != null) Text("#${widget.tag4}"),
                    if (widget.tag5 != null) Text("#${widget.tag5}"),
                  ],
                ),

                SizedBox(height: 5,),

                Text("ジャンル: ${widget.subject}"),

                SizedBox(height: 5,),

                Text("閲覧数: ${widget.watched}"),

                SizedBox(height: 5,),

                Text("高評価: ${widget.likes}"),
                

                SizedBox(height: 15,),

                SelectableText(
                "説明:\n${widget.explanation}",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
                ),
              ],

            ),
          ),

          SizedBox(height: 10,),

          ElevatedButton(
            onPressed: () {
              setState(() {
                showProblemImage = !showProblemImage;
              });
            },
            child: Text("問題を表示する"),
          ),

          SizedBox(height: 10,),

          

          if (showProblemImage && (widget.image1 != null || image1Bytes != null))
            if (image1Bytes == Uint8List(0) || isLoadingImage1)
              preloader
            else
              GestureDetector(

                child: Container(
                  width: SizeConfig.blockSizeHorizontal! * 90,
                  height: SizeConfig.blockSizeVertical! * 90,
                  
                  padding: EdgeInsets.all(8.0),
                  margin: EdgeInsets.all(8.0),
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

                onTap: () {
                  //画像をタップしたら拡大表示する
                  showDialog(
                    context: context,
                    builder: (_) {
                      return Dialog(
                        child: Container(
                          //width: SizeConfig.blockSizeHorizontal! * 90,
                          //height: SizeConfig.blockSizeVertical! * 90,
                          padding: EdgeInsets.all(8.0),
                          margin: EdgeInsets.all(8.0),
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
                                  
                                : widget.imageUrlPX != null
                                    ? Image.memory(
                                        image1Bytes!,
                                        fit: BoxFit.contain,
                                      )
                                    //TODO No imageの画像を表示する  
                                    : null,
                          ),
                        ),
                      );
                    },
                  );
                },


              ),

          SizedBox(height: SizeConfig.blockSizeVertical! * 10,),
          ElevatedButton(
            onPressed: () {
              setState(() {
                showExplanationImage = !showExplanationImage;
              });
            },
            child: Text("解説を表示する"),
          ),
          


          if (showExplanationImage && (widget.image2 != null || image2Bytes != null))
            if (image2Bytes == Uint8List(0) || isLoadingImage2)
              preloader
            else
              GestureDetector(
                child: Container(
                  width: SizeConfig.blockSizeHorizontal! * 90,
                  height: SizeConfig.blockSizeVertical! * 90,
              
                  padding: EdgeInsets.all(8.0),
                  margin: EdgeInsets.all(8.0),
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
                    context: context,
                    builder: (_) {
                      return Dialog(
                        child: Container(
                          padding: EdgeInsets.all(8.0),
                          margin: EdgeInsets.all(8.0),
                          
                          child: SizedBox(
                            child: widget.image2 != null
                                ? Image.memory(
                                    widget.image2!.bytes!,
                                    fit: BoxFit.contain,
                                  )
                                  //ここでもし画像が存在しない場合の処理を考える
                                  
                                : widget.imageUrlCX != null
                                    ? Image.memory(
                                        image2Bytes!,
                                        fit: BoxFit.contain,
                                      )
                                    //TODO No imageの画像を表示する  
                                    : null,
                          ),
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


