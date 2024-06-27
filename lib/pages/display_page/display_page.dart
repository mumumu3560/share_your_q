import 'package:flutter/material.dart';
//import 'package:share_your_q/admob/ad_test.dart';
import 'package:share_your_q/admob/anchored_adaptive_banner.dart';
import 'package:share_your_q/utils/various.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_your_q/image_operations/problem_view/problem_view.dart';
import 'package:share_your_q/pages/display_page/components/appbar_actions/appbar_actions.dart';
//google_admob
//TODO ビルドリリースの時のみ
//import "package:share_your_q/admob/ad_mob.dart";


class DisplayPage extends StatefulWidget {

  final String title;
  
  final int? image_id;
  final String? image_own_user_id;
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

  final int? num;

  final int watched;

  final int likes;

  //TODO ここは後でまとめる。itemを受け取る形にする
  //具体的にはMap<String, dynamic>を受け取る形にする

  final String? problem_id;
  final String? comment_id;

  final String userName;

  final double difficulty;

  final String profileImage;

  final int? problemAdd;
  final int? commentAdd;
  


  const DisplayPage({
    Key? key,
    required this.title,
    required this.image_id,

    required this.image_own_user_id,

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
    required this.num,

    required this.problem_id,
    required this.comment_id,

    required this.watched,

    required this.likes,

    required this.userName,

    required this.difficulty,

    required this.profileImage,

    required this.problemAdd,
    required this.commentAdd,

  }) : super(key: key);

  @override
  _DisplayPageState createState() => _DisplayPageState();
}

class _DisplayPageState extends State<DisplayPage>{

  bool isLiked = false;
  bool isLoading = true; // ローディング中かどうかを示すフラグ
  //TODO ビルドリリースの時のみ
  

  List<Map<String,dynamic>> likesData = [];



  @override
  void initState(){
    

    super.initState();
    _initializeData();

    //TODO ビルドリリースの時のみ
  }

  @override
  void dispose() {
    super.dispose();
    //TODO ビルドリリースの時のみ
  }


  Future<void> _initializeData() async {
    try {
      // 非同期処理（データの取得やAPIコールなど）を行う
    } finally {
      // ローディングが終了したことを示すフラグをセットし、ウィジェットを再構築する
      setState(() {
        isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context){

     return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        //title: const Text('画像一覧'),

        
        actions: [
          AppBarActions(
            //isLiked: isLiked,
            imageId: widget.image_id,
            problem_id: widget.problem_id,
            comment_id: widget.comment_id,
            image_own_user_id: widget.image_own_user_id,
            num: widget.num,
          ),

        ],


      ),

      //endDrawer: const Drawer(child: Center(child: Text("EndDrawer"))),

      body: Column(
        children: [
          Expanded(
            child: Column(
              children: [
                Container(
                  
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue),
                    borderRadius: BorderRadius.circular(10),
                  ),
          
                  alignment: Alignment.center,
                  height: SizeConfig.blockSizeVertical! * 75,
            
                  child: ProblemViewWidget(
                    title: widget.title,
                              
                    tag1: widget.tag1,
                    tag2: widget.tag2,
                    tag3: widget.tag3,
                    tag4: widget.tag4,
                    tag5: widget.tag5,
                              
                    //tags: tags,
                    level: widget.level,
                    subject: widget.subject,
                    image1: null,
                    image2: null,
                    imageUrlPX: widget.imageUrlPX,
                    imageUrlCX: widget.imageUrlCX,
                              
                    explanation: widget.explanation,
                            
                    isCreate: false,
                    image_id: widget.image_id!,
                            
                    problem_id: widget.problem_id!,
                    comment_id: widget.comment_id!,
                            
                    watched: widget.watched,
                            
                    likes: widget.likes,
                            
                    userName: widget.userName,
                            
                    image_own_user_id: widget.image_own_user_id!,
                            
                    difficulty: widget.difficulty,
                            
                    profileImage: widget.profileImage,
                  
                    problemAdd: widget.problemAdd,
                    commentAdd: widget.commentAdd,
                              
                  )
            
                ),
          
                SizedBox(height: SizeConfig.blockSizeVertical! * 2,),
          
                /*
                Container(
                  height: SizeConfig.blockSizeVertical! * 10,
                  width: double.infinity,
                  color: Colors.white,
                  //TODO ビルドリリースの時のみ
                  //child: _adMob.getAdBanner(),
                ),
                */
          
                //
          
          
              ],
            ),
          ),

          
          /*
          
           */
          Container(
            height: SizeConfig.blockSizeVertical!* 10,
            color: Colors.white,
            child: AdaptiveAdBanner(requestId: "DISPLAY",)
          ),
          //BannerContainer(height: SizeConfig.blockSizeHorizontal! * 10),
          //InlineAdaptiveExample(),
        ],
      ),

      



     );


  }
}



