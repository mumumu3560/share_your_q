import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:share_your_q/utils/various.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

int eval_point = 0;
int diff_point = -1;
int evalValue = 1;

class EvaluateDisplay extends StatefulWidget{
  
  final int? image_id;
  final String? image_own_user_id;

  const EvaluateDisplay({
    Key? key,
    required this.image_id,
    required this.image_own_user_id,
  }) : super(key: key);

  @override
  _EvaluateDisplayState createState() => _EvaluateDisplayState();
}

class _EvaluateDisplayState extends State<EvaluateDisplay>{

  late List<Map<String, dynamic>> _imageData = [];
  List<dynamic> linkText = [];

  String refExplain = "";

  late final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
  }
  

  Future<List<Map<String, dynamic>>> fetchData() async {
    try{
      List<Map<String, dynamic>> data = await supabase
        .from('image_data')
        .select<List<Map<String, dynamic>>>()
        .eq('image_data_id', widget.image_id!);

        print(data[0]["links"]);
        setState(() {
          if (data[0]["links"] == null){
          }
          else{
            linkText = data[0]["links"];
          }

          refExplain = data[0]["ref_explain"];
        });

      return data; 

    } on PostgrestException catch (error) {
      context.showErrorSnackBar(message: error.message);
      return [];
    }
    catch (_) {
      context.showErrorSnackBar(message: unexpectedErrorMessage);
      return [];
    }
  }

  void judPoints(){
    print("eval、diffの順番");
    print(evalValue);
    print(diff_point);
  }


  /// 評価の更新
  void _submitEvaluation() async {

    if (evalValue == 0 || diff_point == -1) {
      context.showErrorSnackBar(message: "評価が入力されていません。");
      return;
    }

    showLoadingDialog(context, "送信中...");

    try {
      await supabase.from('likes')
        .update({
          "difficulty": diff_point,
          "eval": evalValue,
        })
        .eq("image_id", widget.image_id)
        .eq("user_id", myUserId);

    } on PostgrestException catch (error) {
      // エラーが発生した場合はエラーメッセージを表示
      context.showErrorSnackBar(message: error.message);
    } catch (_) {
      // 予期せぬエラーが起きた際は予期せぬエラー用のメッセージを表示
      context.showErrorSnackBar(message: unexpectedErrorMessage);
    }

    await Future.delayed(const Duration(seconds: 1));



    if(context.mounted){
        Navigator.of(context).pop(); // ダイアログを閉じる
    }

    if(context.mounted){
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Done"),
            content: const Text("送信が完了しました！"),
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

    fetchData().then((data) {
      setState(() {
        _imageData = data;
      });
    });
    
  }

  Future<void> _launchURL(String target) async {
    try {
      final targetUrl = target;
      if (await canLaunchUrl(Uri.parse(targetUrl))) {
        await launchUrl(Uri.parse(targetUrl));
      } else {
        context.showErrorSnackBar(message: "リンクを開くことができませんでした。");
      }
    } catch(_){
      context.showErrorSnackBar(message: unexpectedErrorMessage);
      return ;
    }
  }

  @override
  void initState(){
    super.initState();
    //これで非同期的
    fetchData().then((data) {
      setState(() {
        _imageData = data;
      });
    });

    //print(_imageData[0]["links"]);

  }


  @override
  Widget build(BuildContext context){
    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.green),
          borderRadius: BorderRadius.circular(10),
        ),
    
        //height: SizeConfig.blockSizeVertical! * 80,
        //width: SizeConfig.blockSizeHorizontal! * 100,
    
        child: Column(
          
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                myUserId == widget.image_own_user_id 
                  ? Container()
                  : const EvaluateWithRadio(),
                
                
    
                myUserId == widget.image_own_user_id 
                  ? Container()
                  : SizedBox(height: SizeConfig.blockSizeVertical! * 3,),
    
                myUserId == widget.image_own_user_id 
                  ? Container()
                  : ElevatedButton(
                    onPressed: () {
                      judPoints();
                      _submitEvaluation();
                    },
                    child: const Text("送信"),
                  ),
              ],
            ),

            SizedBox(height: SizeConfig.blockSizeVertical! * 3,),

            Container(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "参考",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
            
                  SizedBox(height: SizeConfig.blockSizeVertical! * 3,),
                  
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: linkText.asMap().entries.map((entry) {
                      // entry.key がインデックス（0-based）ですので、1を加えて1-basedの参考番号にします。
                      int referenceNumber = entry.key + 1;
            
                      return Column(
                        children: [
                          Row(
                            children: [
            
                              Text("参考$referenceNumber"),
            
                              const SizedBox(width: 5),
                              
                              InkWell(
                                onTap: () async {
                                  //await _launchURL(entry.value);
                                },
                                child: Text(
                                  entry.value,
                                ).urlToLink(context),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                        ],
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            SizedBox(height: SizeConfig.blockSizeVertical! * 3,),

            Container(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "説明",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),
            
                  Text(
                    refExplain,
                    style: const TextStyle(
                      fontSize: 14,
                      // fontStyleは薄くしたい
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
             



    
          ],
        ),
    
    
      ),
    );


  }

}



class EvaluateWithRadio extends StatefulWidget{

  const EvaluateWithRadio({
    Key? key,
  }) : super(key: key);
  
  @override
  _EvaluateWithRadioState createState() => _EvaluateWithRadioState();
}

class _EvaluateWithRadioState extends State<EvaluateWithRadio>{

  void setDiff(int diff){
    setState(() {
      diff_point = diff;
    });
  }

  void setEval(int eval){
    setState(() {
      evalValue = eval;
    });
  }

  

  @override
  Widget build(BuildContext context){
    //List<String> _evalList = ["educational", "artistic", "calculation", "interesting", "basic"];
    return Container(
      
      child: Column(
        children: <Widget>[

          const Text(
            "アンケート",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: SizeConfig.blockSizeVertical!,),
          
          /*
          const Text(
            "Q1: この問題はどんな問題？",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ), 
            
        

          SizedBox(height: SizeConfig.blockSizeVertical!,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              
              
              Radio(
                value: 1,
                groupValue: evalValue,
                onChanged: (value) {
                  print(evalValue);
                  setEval(value!);
                  print(evalValue);
                },
              ),
              Text("教育的"),


              Radio(
                value: 2,
                groupValue: evalValue,
                onChanged: (value) {
                  print(evalValue);
                  setEval(value!);
                  print(evalValue);
                },
              ),
              Text("芸術的"),


              Radio(
                value: 3,
                groupValue: evalValue,
                onChanged: (value) {
                  print(evalValue);
                  setEval(value!);
                  print(evalValue);
                },
              ),
              Text("計算的"),


            ],
          ),

          SizedBox(height: SizeConfig.blockSizeVertical!,),
    
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              Radio(
                value: 4,
                groupValue: evalValue,
                onChanged: (value) {
                  print(evalValue);
                  setEval(value!);
                  print(evalValue);
                },
              ),
              Text("興味深い"),


              Radio(
                value: 5,
                groupValue: evalValue,
                onChanged: (value) {
                  print(evalValue);
                  setEval(value!);
                  print(evalValue);
                },
              ),
              Text("基礎的"),



            ],
          ),

          SizedBox(height: SizeConfig.blockSizeVertical! * 3,),
           */

          const Text(
            "Q1: この問題は易しい？難しい？",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Radio(
                value: 0,
                groupValue: diff_point,
                onChanged: (value) {
                  setDiff(value!);
                },
              ),

              const Text("易しい"),

              Radio(
                value: 1,
                groupValue: diff_point,
                onChanged: (value) {
                  setDiff(value!);
                },
              ),

              const Text("難しい"),

            ],
          ),

          SizedBox(height: SizeConfig.blockSizeVertical!,),

        ],
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
