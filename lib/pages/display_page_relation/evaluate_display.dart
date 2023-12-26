import 'package:flutter/material.dart';
import 'package:share_your_q/utils/various.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

int eval_point = 0;
int diff_point = 0;
int evalValue = 1;

class EvaluateDisplay extends StatefulWidget{
  
  final int? image_id;

  const EvaluateDisplay({
    Key? key,
    required this.image_id,
  }) : super(key: key);

  @override
  _EvaluateDisplayState createState() => _EvaluateDisplayState();
}

class _EvaluateDisplayState extends State<EvaluateDisplay>{

  late List<Map<String, dynamic>> _imageData = [];

  late final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    print("${this} dispose() _StateLifecycle.defunct");
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
      eval_point = eval;
    });
  }

  void setDiff(int diff){
    setState(() {
      diff_point = diff;
    });
  }

  void judPoints(){
    print("eval、diffの順番");
    print(eval_point);
    print(diff_point);
  }


  /// 評価の更新
  void _submitEvaluation() async {

    if (eval_point == 0 || diff_point == 0) {
      context.showErrorSnackBar(message: "評価が入力されていません。");
      return;
    }

    try {
      await supabase.from('likes')
        .update({
          "difficulty": diff_point,
          "eval": eval_point,
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
            //_ratingBar(setEvalKind, eval_point),
    
            Text("評価: $evalValue"),
    
            //_ratingBar(setDiff, diff_point),
    
            Text("難易度: $diff_point"),
    
            EvaluateWithRadio(),
    
            SizedBox(height: SizeConfig.blockSizeVertical!,),
    
            ElevatedButton(
              onPressed: () async{
                _submitEvaluation();
                judPoints();
              },
              child: Text("ここが評価"),
            )
    
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
    itemCount: 5,
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

  @override
  Widget build(BuildContext context){
    //List<String> _evalList = ["educational", "artistic", "calculation", "interesting", "basic"];
    return Container(
      
      child: Column(
        children: [
          
          const Text(
            "1: この問題はどんな問題？",
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
                  setState((){
                    evalValue = value!;
                  });
                  print(evalValue);
                },
              ),
              Text("教育的"),


              Radio(
                value: 2,
                groupValue: evalValue,
                onChanged: (value) {
                  print(evalValue);
                  setState((){
                    evalValue = value!;
                  });
                  print(evalValue);
                },
              ),
              Text("芸術的"),


              Radio(
                value: 3,
                groupValue: evalValue,
                onChanged: (value) {
                  print(evalValue);
                  setState((){
                    evalValue = value!;
                  });
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
                  setState((){
                    evalValue = value!;
                  });
                  print(evalValue);
                },
              ),
              Text("興味深い"),


              Radio(
                value: 5,
                groupValue: evalValue,
                onChanged: (value) {
                  print(evalValue);
                  setState((){
                    evalValue = value!;
                  });
                  print(evalValue);
                },
              ),
              Text("基礎的"),


            ],
          ),

          SizedBox(height: SizeConfig.blockSizeVertical! * 3,),

          const Text(
            "2: この問題の難易度は？",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          )

        ],
      ),
    
    );
  }
}


