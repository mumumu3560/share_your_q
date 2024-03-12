import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
//import 'package:share_your_q/admob/ad_test.dart';

import 'package:share_your_q/utils/various.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';


import 'package:flutter/gestures.dart';
import 'package:share_your_q/pages/display_page/components/appbar_actions/components/comments_list.dart';



//お問い合わせフォームのページ
class InquiryPage extends StatefulWidget{
  const InquiryPage({super.key});

  
  @override
  State<StatefulWidget> createState() {
    return InquiryPageState();
  }
  
   

}

class InquiryPageState extends State<InquiryPage> {

  //ここでOneSignalの通知の切り替えを行う

  bool isChecked = false;

  List<Map<dynamic,dynamic>> inquiries = [];

  /*
  
  Future<void> _switchNotification() async{


    try{
      final response = await supabase
        .from('inquiries')
        .select<List<Map<String,dynamic>>>()
        .eq('id', myUserId);

      setState(() {
        inquiries = response;
      });

    }
    on PostgrestException catch (e){
      context.showErrorSnackBar(message: e.message);
      return;
    }
    catch(_){
      context.showErrorSnackBar(message: unexpectedErrorMessage);
      return;
    }

    

  }
   */

  String title = "";
  bool isLoading = true;


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
          height: SizeConfig.blockSizeVertical! * 35+MediaQuery.of(context).viewInsets.bottom,
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
                      hintText: 'お問い合わせ内容を入力',
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

  Future<void> reloadList() async{
    setState(() {
      isLoading = true;
    });
    await fetchContents(); // リロード時にデータを再取得
  }

  /// メッセージを送信する
  void _submitMessage() async {
    final comment = _textController.text;
    textKeeper = "";
    if (comment.isEmpty) {
      context.showErrorSnackBar(message: "入力がありません。");
      return;
    }
    _textController.clear();
    try {
      await supabase.from('inquiries').insert({
        "user_id": myUserId,
        'contents': comment,
      });

      await reloadList();


    } on PostgrestException catch (error) {
      // エラーが発生した場合はエラーメッセージを表示
      context.showErrorSnackBar(message: error.message);
    } catch (_) {
      // 予期せぬエラーが起きた際は予期せぬエラー用のメッセージを表示
      context.showErrorSnackBar(message: unexpectedErrorMessage);
    }


    
  }

  void showHelpDialog(){
    showDialog(
      context: context,
      builder: (context){
        return AlertDialog(
          title: const Text('ヘルプ'),
          content: InkWell(
            child: const Text(
              'お問い合わせやバグ報告がありましたら\n'
              'こちらからお願いします。'
            ).urlToLink(context)
 
          ),
          actions: [
            TextButton(
              onPressed: (){
                Navigator.pop(context);
              },
              child: const Text('閉じる'),
            ),
          ],
        );
      }
    );

  }

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

  Future<void> fetchContents()async{
    try{
      final response = await supabase
        .from('inquiries')
        .select<List<Map<String,dynamic>>>("contents, created_at")
        .eq('user_id', myUserId);

      final response2 = await supabase
        .from('inquiries_reply')
        .select<List<Map<String,dynamic>>>("contents , created_at")
        .eq('user_id', myUserId);

      //inquiriesのものとinquiries_replyのものを結合するが、その際に新しい変数bool isYouを加えて、
      //inquiriesのものはtrue、inquiries_replyのものはfalseとする
      //その後、created_atでソートするという処理を書く

      // inquiriesの各アイテムにisYouフィールドを追加してtrueをセット
      final inquiriesList = (response as List).map((item) {
        return {
          ...item,
          'isYou': true,
        };
      }).toList();

      // inquiries_replyの各アイテムにisYouフィールドを追加してfalseをセット
      final inquiriesReplyList = (response2 as List).map((item) {
        return {
          ...item,
          'isYou': false,
        };
      }).toList();

      // 両方のリストを結合
      final combinedList = [...inquiriesList, ...inquiriesReplyList];

      // created_atでリストをソート
      combinedList.sort((a, b) => b['created_at'].compareTo(a['created_at']));

      debugPrint(combinedList.toString());

      debugPrint("combinedList");
      //combinedlistの型は？
      debugPrint(combinedList.runtimeType.toString());






      
      


      setState(() {
        inquiries = combinedList /*as List<Map<String, dynamic>> */;
      });



    }
    on PostgrestException catch (e){
      context.showErrorSnackBar(message: e.message);
      return;
    }
    catch(_){
      context.showErrorSnackBar(message: unexpectedErrorMessage);
      return;
    }
  }



  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    fetchContents();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('お問い合わせ'),
        actions: [

          //チャットマーク
          IconButton(
            icon: const Icon(Icons.chat, color: Colors.green,),
            onPressed: () async{
              _showCommentSheet();
            },
          ),

          SizedBox(width: SizeConfig.blockSizeHorizontal! * 2,),
          //ヘルプマーク
          IconButton(
            icon: const Icon(Icons.help),
            onPressed: () async{
              showHelpDialog();
            },
          ),
        ],
      ),
      //ListViewの形式で表示
      body: ListView.builder(

        reverse: true,
        itemCount: inquiries.length,
        itemBuilder: (context, index){
          return Align(
            alignment: inquiries[index]['isYou'] ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.all(8),
              width: SizeConfig.blockSizeHorizontal! * 80,
              child: Card(
          

                child: ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  tileColor: inquiries[index]['isYou'] ? Colors.green : null,
                  //Color.fromARGB(255, 73, 72, 72)
                  //Color.fromARGB(255, 0, 0, 0)
                  //tileColor: inquiries[index]['isYou'] ? null : Color.fromARGB(255, 73, 72, 72),
                  dense: true,
                  title: Text(inquiries[index]['contents']),
                  subtitle: Text(
                    formatCreatedAt(inquiries[index]['created_at']),
                    style: const TextStyle(
                      fontSize: 10,
                    ),
                  ),
                            
                  
                  onLongPress: (){
                    //自分の投稿の場合のみ削除できるようにする
                    if(inquiries[index]['isYou']){
                      showDialog(
                        context: context,
                        builder: (context){
                          return AlertDialog(
                            title: const Text('削除'),
                            content: const Text('この投稿を削除しますか？'),
                            actions: [
                              TextButton(
                                onPressed: (){
                                  Navigator.pop(context);
                                },
                                child: const Text('キャンセル'),
                              ),
                              TextButton(
                                onPressed: () async{
                                  
                                  try{
                                    await supabase
                                      .from('inquiries')
                                      .delete()
                                      .eq('contents', inquiries[index]['contents'])
                                      .eq("user_id", myUserId);
                                    
                                    await reloadList();

                                  }
                                  on PostgrestException catch (e){
                                    context.showErrorSnackBar(message: e.message);
                                    return;
                                  }
                                  catch(_){
                                    context.showErrorSnackBar(message: unexpectedErrorMessage);
                                    return;
                                  }
                                  if(context.mounted){
                                    Navigator.pop(context);
                                  }
                                },
                                child: const Text('削除'),
                              ),
                            ],
                          );
                        }
                      );
                    }
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}





//https://qiita.com/Hiiisan/items/f0bbc5715fab7e6787ad
RegExp _urlReg = RegExp(
  r'https?://([\w-]+\.)+[\w-]+(/[\w-./?%&=#]*)?',
);

extension TextEx on Text {

  RichText urlToLink(
    BuildContext context,
  ) {
    final textSpans = <InlineSpan>[];

    data!.splitMapJoin(
      _urlReg,
      onMatch: (Match matchPre) {
        final match = matchPre[0] ?? '';
        textSpans.add(
          TextSpan(
            text: match,
            style: const TextStyle(
              color: Colors.blue,
              decoration: TextDecoration.underline,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () async => await launchUrl(
                    Uri.parse(match),
                  ),
          ),
        );
        return '';
      },
      onNonMatch: (String text) {
        textSpans.add(
          TextSpan(
            text: text,
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
        );
        return '';
      },
    );

    return RichText(text: TextSpan(children: textSpans));
  }
}
