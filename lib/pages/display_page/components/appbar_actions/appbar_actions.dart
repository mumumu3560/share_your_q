import 'package:flutter/material.dart';
import 'package:share_your_q/admob/anchored_adaptive_banner.dart';
import 'package:share_your_q/pages/display_page/components/appbar_actions/components/comments_list.dart';
import 'package:share_your_q/utils/various.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:share_your_q/pages/display_page/components/appbar_actions/components/evaluate_display.dart';


class AppBarActions extends StatefulWidget {
  
  final int? imageId;
  final String? problem_id;
  final String? comment_id;
  final String? image_own_user_id;
  final int? num;


  const AppBarActions({
    Key? key,
    required this.imageId,
    required this.problem_id,
    required this.comment_id,
    required this.image_own_user_id,
    required this.num,

  }):super(key: key);

  @override
  _AppBarActionsState createState() => _AppBarActionsState();
}

class _AppBarActionsState extends State<AppBarActions> {
  bool isLiked = false;
  bool isFirst = true;

  bool showingComment = false;

  @override
  void initState(){

    super.initState();

    //loadData();
    
  }

  void loadData()async {

    await _insertTestSupabase();
  }

  /*
   */


  Future<void> _insertTestSupabase() async{
    try {
      // `user_id`と`image_id`の組み合わせで既存のレコードを検索する
      final existingRecord = await supabase
          .from('likes')
          .select()
          .eq('user_id', myUserId)
          .eq('image_id', widget.imageId!);

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
            .eq('image_id', widget.imageId!);
          isFirst = false;
        }
        else{
          response = await supabase
            .from('likes')
            .update({ 'add': !isLiked })
            .eq('user_id', myUserId)
            .eq('image_id', widget.imageId!);
        }

        /*
        //isLiked = !isLiked;
        if (response != null) {
          // エラーハンドリング
          print('Error updating data: $response');
        } else {
          // 成功時の処理
          print('Data updated successfully!');
        }
         */
      } else {
        // レコードが存在しない場合は挿入
        final response = await supabase
            .from('likes')
            .insert({ 
              'add': false,
              'user_id': myUserId,
              'problem_num' : widget.num,
              "image_id" : widget.imageId,
              "image_own_user_id" : widget.image_own_user_id,
              });

        /*
        if (response == null) {
          // エラーハンドリング
          print('Error inserting data: $response');
        } else {
          // 成功時の処理
          print('Data inserted successfully!');
        }
         */
      }
    } on PostgrestException catch (error) {
      // エラーハンドリング
      if(mounted){
        context.showErrorSnackBar(message: error.message);
      }
    }
    catch (error) {
      if(mounted){
        context.showErrorSnackBar(message: unexpectedErrorMessage);
      }
    }
  }

  void _showCommentSheet(BuildContext context, int imageId) {
    setState(() {
      showingComment = true;
    });

    
  showModalBottomSheet(
    context: context,
    constraints: BoxConstraints(
        maxWidth: SizeConfig.blockSizeHorizontal! * 100,
      ),
    isScrollControlled: true,

    
    //isDismissible: false,
    //https://zenn.dev/yu1ro/articles/6d7db85990bb82
    builder: (context) => Container(
      height: SizeConfig.blockSizeVertical! * 70,

      

      child: CommentList(
            imageId: imageId,
            responseId: -1,
            canToPage: false,
            resText: "コメント",
            item: null,
            title: "コメント",
          ),
      
    ),
  );
}


  Future<void> reportRequestSupabase() async{
      
    showLoadingDialog(context, "報告中...");


    try{

      await supabase.from("report").insert({
        "image_id": widget.imageId,
        "user_id": myUserId,
        "Content": "",
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


    //TODO ここから変わる

    //2秒待つ
    await Future.delayed(const Duration(seconds: 2));

    if(mounted){
      Navigator.of(context).pop(); // ダイアログを閉じる
    }


    if(mounted){
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Done"),
            content: const Text("報告が終わりました"),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  //Navigator.pop(context);
                  Navigator.of(context).pop(); // ダイアログを閉じる
                },
                child: const Text('閉じる'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> deleteRequestSupabase() async{
      
    

    try{
      showLoadingDialog(context, "削除申請中...");
      
      //ここはSupabaseのカスケード設定で対応するimage_dataテーブルが消えるとここも消える
      await supabase.from("delete_request").insert({
        "image_data_id": widget.imageId,
        "user_id": myUserId,
        "problem_id": widget.problem_id,
        "comment_id": widget.comment_id,
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


    //TODO ここから変わる

    //TODO ここで終わりでよくない？

    if(mounted){
      Navigator.of(context).pop(); // ダイアログを閉じる
    }

    if(mounted){
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Done"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("削除申請が終わりました"),

                  
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    //Navigator.pop(context);
                    Navigator.of(context).pop(); // ダイアログを閉じる
                  },
                  child: const Text('閉じる'),
                ),
              ],
            );
          },
        );
      }


  }

  Future<void> _showSettingSheet(BuildContext context) async{
    
    showModalBottomSheet(
      context: context,
      constraints: BoxConstraints(
        maxWidth: SizeConfig.blockSizeHorizontal! * 100,
      ),
      //これがないと高さが変わらない
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          height: SizeConfig.blockSizeVertical! * 20,
          alignment: Alignment.center,
          child: ListView(

            children: [


              widget.image_own_user_id == myUserId
              ? ListTile(
                  leading: const Icon(Icons.delete),
                  title: const Text("この投稿を削除する"),
                  onTap: () async{
                    await ShowDialogWithFunction(
                      context: context, 
                      title: "確認", 
                      shownMessage: "この投稿を削除しますか？", 
                      functionOnPressed: deleteRequestSupabase,
                    ).show();
                      //削除する
                  },
                )

              : ListTile(
                  leading: const Icon(Icons.report),
                  title: const Text("この投稿を報告する"),
                  onTap: () async{
                    await ShowDialogWithFunction(
                      context: context, 
                      title: "確認", 
                      shownMessage: "この投稿を報告しますか？", 
                      functionOnPressed: () async{
                        await reportRequestSupabase();
                      },
                    ).show();
                  },
                ),

              


              
            ],
          )
        );
      },
    );
  }

  void _showEvaluateSheet(BuildContext context, int imageId) {
    showModalBottomSheet(
      
      context: context,

      constraints: BoxConstraints(
        maxWidth: SizeConfig.blockSizeHorizontal! * 100,
      ),
      //これがないと高さが変わらない
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SizedBox(
          height: SizeConfig.blockSizeVertical! * 60,
          width: SizeConfig.blockSizeHorizontal! * 100,
          child: EvaluateDisplay(image_id: imageId, image_own_user_id: widget.image_own_user_id,),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [

        //コメントを見る
        IconButton(
          icon: const Icon(Icons.chat, color: Colors.green,),
          tooltip: "コメント",
          onPressed: (){
            _showCommentSheet(context, widget.imageId!);
          },
        ),

        SizedBox(width: SizeConfig.blockSizeHorizontal! * 2,),

        //ここで問題の評価を見る
        IconButton(
          icon: const Icon(Icons.bar_chart, color: Colors.blue,),
          tooltip: "評価",
          onPressed: (){
            _showEvaluateSheet(context, widget.imageId!);
          },
        ),

        SizedBox(width: SizeConfig.blockSizeHorizontal! * 2,),

        

        
        //setting
        IconButton(
          icon: const Icon(
            Icons.more_vert, color: Colors.white,
          ),
          
          tooltip: "処理",
          onPressed: () async{
            _showSettingSheet(context);

          },
        ),

        SizedBox(width: SizeConfig.blockSizeHorizontal! * 2,),
      ],
    );
  }
}