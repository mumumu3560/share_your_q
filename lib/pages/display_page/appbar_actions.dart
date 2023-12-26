import 'package:flutter/material.dart';
import 'package:share_your_q/utils/various.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:share_your_q/pages/display_page/comment_list_display.dart';
import 'package:share_your_q/pages/display_page/evaluate_display.dart';


class AppBarActions extends StatefulWidget {
  
  final bool? isLiked;
  final int? imageId;
  final String? problem_id;
  final String? comment_id;
  final String? image_own_user_id;
  final int? num;


  const AppBarActions({
    Key? key,
    required this.isLiked,
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

  @override
  void initState(){
    super.initState();
    isLiked = widget.isLiked!;
  }


  Future<void> _insertTestSupabase() async{
    try {
      // `user_id`と`image_id`の組み合わせで既存のレコードを検索する
      final existingRecord = await supabase
          .from('likes')
          .select<List<Map<String, dynamic>>>()
          .eq('user_id', myUserId)
          .eq('image_id', widget.imageId);

      // レコードが存在する場合はアップデート、存在しない場合は挿入する
      if (existingRecord.isNotEmpty) {
        // レコードが存在する場合はアップデート
        print("ここが問題手の");
        isLiked = existingRecord[0]["add"];
        print(existingRecord[0]["add"]);

        
        print("どこだよ");

        //islikedが!isliked
        final response = await supabase
            .from('likes')
            .update({ 'add': !isLiked })
            .eq("image_id", widget.imageId)
            .eq("user_id", myUserId);

        //isLiked = !isLiked;
        if (response != null) {
          // エラーハンドリング
          print('Error updating data: ${response}');
        } else {
          // 成功時の処理
          print('Data updated successfully!');
        }
      } else {
        print("ここが二つ目");
        print("errorが発生しています");
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

  void _showCommentSheet(BuildContext context, int imageId) {
    showModalBottomSheet(
      context: context,
      //これがないと高さが変わらない
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          height: SizeConfig.blockSizeVertical! * 90,
          child: CommentListDisplay(image_id: imageId),
        );
      },
    );
  }

  Future<void> deleteRequestSupabase() async{
      
    showLoadingDialog(context, "削除申請中...");
    print(widget.imageId!);

    //await Future.delayed(Duration(seconds: 5));

    try{
      
      //ここはSupabaseのカスケード設定で対応するimage_dataテーブルが消えるとここも消える
      await supabase.from("delete_request").insert({
        "image_data_id": widget.imageId,
        "user_id": myUserId,
        "problem_id": widget.problem_id,
        "comment_id": widget.comment_id,
    });
    

      print("これは削除申請");

    } on PostgrestException catch (error){

      if(context.mounted){
        context.showErrorSnackBar(message: error.message);
      }

    } catch(_){

      if(context.mounted){
      context.showErrorSnackBar(message: unexpectedErrorMessage);
      }
    }

    print("ここで削除依頼をCloudflareに送る。");

    //TODO ここから変わる

    if(context.mounted){
      Navigator.of(context).pop(); // ダイアログを閉じる
    }



    showLoadingDialog(context, "削除中...");
    print(widget.imageId!);

    try{
      //ここでは、問題の情報をsupabaseに送る。
      //P_I_CountとC_I_Countは、問題文の画像と解説の画像の数を表す。今は1にしておく。
      await supabase.from("image_data")
        .delete()
        .eq("image_data_id", widget.imageId);

      print("これは削除申請");

    } on PostgrestException catch (error){

      if(context.mounted){
        context.showErrorSnackBar(message: error.message);
      }

    } catch(_){

      if(context.mounted){
      context.showErrorSnackBar(message: unexpectedErrorMessage);
      }
    }

    print("削除ができたはず");

    if(context.mounted){
      Navigator.of(context).pop(); // ダイアログを閉じる
    }

    if(context.mounted){
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Done"),
            content: Text("問題の削除が終わりました"),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  //Navigator.pop(context);
                  Navigator.of(context).pop(); // ダイアログを閉じる
                },
                child: Text('閉じる'),
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
                  leading: Icon(Icons.delete),
                  title: Text("この投稿を削除する"),
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
                  leading: Icon(Icons.report),
                  title: Text("この投稿を通報する"),
                  onTap: () async{
                    await ShowDialogWithFunction(
                      context: context, 
                      title: "確認", 
                      shownMessage: "この投稿を通報しますか？", 
                      functionOnPressed: () async{
                        await supabase.from("report").insert({
                          "image_data_id": widget.imageId,
                          "user_id": myUserId,
                          "content": "",
                        });
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
      //これがないと高さが変わらない
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          height: SizeConfig.blockSizeVertical! * 60,
          child: EvaluateDisplay(image_id: imageId),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [


        IconButton(
          icon: const Icon(Icons.chat, color: Colors.green,),
          tooltip: "コメント",
          onPressed: (){
            _showCommentSheet(context, widget.imageId!);
          },
        ),

        SizedBox(width: SizeConfig.blockSizeHorizontal! * 2,),


        IconButton(
          icon: Icon(
            isLiked ? Icons.favorite : Icons.favorite_border_outlined,
            color: isLiked ? Colors.red : Colors.white,
          ),
          
          tooltip: "いいね",
          onPressed: () async{
            
            
            await _insertTestSupabase();

            setState(() {            
              isLiked = !isLiked;
            });
             

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