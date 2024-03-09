import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:share_your_q/pages/login_relatives/redirect.dart';
import 'package:share_your_q/pages/profile_page/components/iroiro_test/image_test.dart';
//import 'package:share_your_q/admob/ad_test.dart';
import 'dart:math';

import 'package:share_your_q/utils/various.dart';


import 'package:share_your_q/pages/profile_page/components/settings/profile_setting.dart';
import 'dart:typed_data';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import "package:share_your_q/image_operations/image_list_display.dart";
import 'package:share_your_q/pages/profile_page/components/create_trend.dart';


import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:share_your_q/pages/profile_page/components/follow_list/follow_list.dart';

import 'package:share_your_q/pages/profile_page/components/likes/likes_list.dart';

import 'package:share_your_q/pages/display_page/components/appbar_actions/components/comments_list.dart';



//お問い合わせフォームのページ
class InquiryPage extends StatefulWidget{
  
  @override
  State<StatefulWidget> createState() {
    return InquiryPageState();
  }
  
   

}

class InquiryPageState extends State<InquiryPage> {

  //ここでOneSignalの通知の切り替えを行う

  bool isChecked = false;

  List<Map<String,dynamic>> inquiries = [];

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
              'お問い合わせやバグ報告などはこちらにお願いします。\n'
              'チャット形式で返答します。(フランクな形での返答があります)\n' 
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
            icon: const Icon(Icons.chat),
            onPressed: () async{
              _showCommentSheet();
            },
          ),
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
        itemCount: inquiries.length,
        itemBuilder: (context, index){
          return ListTile(
            dense: true,
            title: Text(inquiries[index]['contents']),
            subtitle: Text(inquiries[index]['created_at'].toString()),
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
