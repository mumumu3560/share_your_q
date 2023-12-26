import 'package:flutter/material.dart';
import 'package:share_your_q/utils/various.dart';
import 'package:file_picker/file_picker.dart';
import "package:share_your_q/image_operations/problem_view.dart";
import 'package:share_your_q/pages/display_page/appbar_actions.dart';
import "package:share_your_q/image_operations/image_request.dart";

//google_admob
//TODO ビルドリリースの時のみ
//import "package:share_your_q/admob/ad_mob.dart";

//リストをタップした際に遷移するページ問題が見れる
//UIはわからない

//テキストを保持する。
//コメントを送信した場合には空
//入力がありそれを送信していない場合には、そのテキストを保持する


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
  final String? imageUrlP;
  final String? imageUrlC;

  final String? explanation;

  final int? num;

  //TODO ここは後でまとめる。itemを受け取る形にする
  //具体的にはMap<String, dynamic>を受け取る形にする

  final String? problem_id;
  final String? comment_id;
  


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
    required this.imageUrlP,
    required this.imageUrlC,

    required this.explanation,
    required this.num,

    required this.problem_id,
    required this.comment_id,

  }) : super(key: key);

  @override
  _DisplayPageState createState() => _DisplayPageState();
}

class _DisplayPageState extends State<DisplayPage>{


  final userId = supabase.auth.currentUser!.id;
  bool isLiked = false;
  bool isLoading = true; // ローディング中かどうかを示すフラグ
  //TODO ビルドリリースの時のみ
  //final AdMob _adMob = AdMob();

  /*
  late Future<List<int>> problemImageFuture;
  late Future<List<int>> commentimageFuture;

   */

  @override
  void initState(){
    

    /*
    problemImageFuture = fetchImage(widget.problem_id!);
    commentimageFuture = fetchImage(widget.comment_id!);
     */

    super.initState();
    //_insertOrUpdateDataToSupabaseTable();
    _initializeData();

    //TODO ビルドリリースの時のみ
    //_adMob.load();
  }

  @override
  void dispose() {
    super.dispose();
    //TODO ビルドリリースの時のみ
    //_adMob.dispose();
  }


  Future<void> _initializeData() async {
    try {
      // 非同期処理（データの取得やAPIコールなど）を行う
      await _insertOrUpdateDataToSupabaseTable();
    } finally {
      // ローディングが終了したことを示すフラグをセットし、ウィジェットを再構築する
      setState(() {
        isLoading = false;
      });
    }
  }


  Future<void> _insertOrUpdateDataToSupabaseTable() async {
    try {
      // `user_id`と`image_id`の組み合わせで既存のレコードを検索する
      final existingRecord = await supabase
          .from('likes')
          .select<List<Map<String, dynamic>>>()
          .eq('user_id', userId)
          .eq('image_id', widget.image_id);

      // レコードが存在する場合はアップデート、存在しない場合は挿入する
      if (existingRecord.isNotEmpty) {
        // レコードが存在する場合はアップデート
        print("ここが問題手の");
        isLiked = existingRecord[0]["add"];
        print(existingRecord[0]["add"]);

        print("ここが一つ目");
        final response = await supabase
            .from('likes')
            .update({ 'add': isLiked })
            .eq('user_id', userId)
            .eq('image_id', widget.image_id);

        if (response != null) {
          // エラーハンドリング
          print('Error updating data: ${response}');
        } else {
          // 成功時の処理
          print('Data updated successfully!');
        }
      } else {
        print("ここが二つ目");
        // レコードが存在しない場合は挿入
        final response = await supabase
            .from('likes')
            .insert({
              'user_id': userId,
              "image_own_user_id": widget.image_own_user_id,
              "add": false,
              "problem_num": widget.num,
              "image_id": widget.image_id,
              // 他のカラムの挿入もここで行う
            });

        
        print("here");
        print(response);

        if (response == null) {
          // エラーハンドリング
          print('Error inserting data: ${response}');
        } else {
          // 成功時の処理
          print('Data inserted successfully!');
        }
      }
    } catch (error) {
      // 例外が発生した場合のエラーハンドリング
      print('Error: $error');
    }
  }





  @override
  Widget build(BuildContext context){

     return Scaffold(
      //resizeToAvoidBottomInset: true,
      appBar: AppBar(
        //title: const Text('画像一覧'),

        
        actions: [
          AppBarActions(
            isLiked: isLiked,
            imageId: widget.image_id,
            problem_id: widget.problem_id,
            comment_id: widget.comment_id,
            image_own_user_id: widget.image_own_user_id,
            num: widget.num,
          ),

        ],


      ),

      endDrawer: const Drawer(child: Center(child: Text("EndDrawer"))),

      body: SingleChildScrollView(
        
        child: Column(
          children: [
            Container(
              
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue),
                borderRadius: BorderRadius.circular(10),
              ),

              alignment: Alignment.center,
              height: SizeConfig.blockSizeVertical! * 75,
      
              child: ListView(
                children: [
                  ProblemViewWidget(
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
                    imageUrlP: widget.imageUrlP,
                    imageUrlC: widget.imageUrlC,
      
                    explanation: widget.explanation,

                    isCreate: false,
                    image_id: widget.image_id,

                    problem_id: widget.problem_id!,
                    comment_id: widget.comment_id!,
      
                  ),

                ],
              )
      
            ),

            SizedBox(height: SizeConfig.blockSizeVertical! * 2,),

            Container(
              height: SizeConfig.blockSizeVertical! * 10,
              width: double.infinity,
              color: Colors.white,
              //TODO ビルドリリースの時のみ
              //child: _adMob.getAdBanner(),
            ),

            SizedBox(height: SizeConfig.blockSizeVertical! * 2,),

          ],
        ),

        


      ),

      



     );


  }
}



