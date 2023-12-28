import 'package:flutter/material.dart';
import 'package:share_your_q/utils/various.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

int eval_point = 0;
int diff_point = 0;
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

  void setEvalKind(int eval){
    setState(() {
      evalValue = eval;
    });
  }

  void setDiff(int diff){
    setState(() {
      diff_point = diff;
    });
  }

  void judPoints(){
    print("eval、diffの順番");
    print(evalValue);
    print(diff_point);
  }


  /// 評価の更新
  void _submitEvaluation() async {

    if (evalValue == 0 || diff_point == 0) {
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

    await Future.delayed(Duration(seconds: 1));



    if(context.mounted){
        Navigator.of(context).pop(); // ダイアログを閉じる
    }

    if(context.mounted){
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Done"),
            content: Text("送信が完了しました！"),
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

    fetchData().then((data) {
      setState(() {
        _imageData = data;
      });
    });
    
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
          
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            myUserId == widget.image_own_user_id 
              ? Container()
              : EvaluateWithRadio(),
            
            
    
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
    
    
      ),
    );


  }

}



Widget _ratingBar(Function function, int point){
  return RatingBar.builder(

    initialRating: point as double,
    minRating: 1,
    direction: Axis.horizontal,
    allowHalfRating: false,
    itemCount: 10,
    itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
    itemBuilder: (context, _) => Icon(
      Icons.star,
      color: Colors.amber,
    ),
    onRatingUpdate: (rating) {
      function(rating);
    },
  );

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
        children: [

          const Text(
            "問題の評価",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: SizeConfig.blockSizeVertical!,),
          
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

          const Text(
            "Q2: この問題の難易度は？",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: SizeConfig.blockSizeVertical!,),

          
          _ratingBar(setDiff, diff_point),
          SizedBox(height: SizeConfig.blockSizeVertical!,),
          Text("難易度: $diff_point"),

        ],
      ),
    
    );
  }
}


