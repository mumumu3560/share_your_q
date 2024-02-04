import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:share_your_q/utils/various.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';

class CreateTrend extends StatefulWidget{
  
  final String? image_own_user_id;

  const CreateTrend({
    Key? key,
    required this.image_own_user_id,
  }) : super(key: key);

  @override
  _CreateTrendState createState() => _CreateTrendState();
}

class _CreateTrendState extends State<CreateTrend> with AutomaticKeepAliveClientMixin{

  @override
  bool get wantKeepAlive => true;

  late List<Map<String, dynamic>> _imageData = [];
  late List<Map<String, dynamic>> _likesData = [];
  Map<DateTime, int>? _heatmapData = {};

  int maxSize = 0;

  bool nowDisplay = false;
  Positioned? widgets;

  Timer? timer;



  //List<Map<String, dynamic>>
  Future<void> fetchData() async {
    try{
      _imageData = await supabase
        .from('image_data')
        .select<List<Map<String, dynamic>>>()
        .eq('user_id', widget.image_own_user_id);

      _likesData = await supabase
        .from("likes")
        .select<List<Map<String, dynamic>>>()
        .eq("user_id", widget.image_own_user_id)
        .eq("add", true);

      convertData("watched", _imageData);


    } on PostgrestException catch (error) {
      context.showErrorSnackBar(message: error.message);
      return ;
    }
    catch (_) {
      context.showErrorSnackBar(message: unexpectedErrorMessage);
      return ;
    }
  }

  //ここではheatmapで使えるデータ型に変更する。
  //typeはwatchedかlikesのどちらか
  //targetは_imageDataか_likesDataのどちらか
  void convertData(String type, List<Map<String, dynamic>> target){
    for(int i = 0; i < target.length; i++){
      DateTime date = DateTime.parse(target[i]["created_at"]);
      DateTime truncatedDateTime = DateTime(date.year, date.month, date.day);

      int watchedCount = target[i][type]! as int;
      int watchedCount2 = 0;

      if(_heatmapData![truncatedDateTime] != null){
        watchedCount2 = _heatmapData![truncatedDateTime]!;
      }
      
      int watchedCount3 = watchedCount + watchedCount2;

      _heatmapData![truncatedDateTime] = watchedCount3;//_imageData[i]["watched"]! as int;
      maxSize = max(maxSize, target[i][type]);

    }

    setState(() {
      _heatmapData = _heatmapData;
    });
  }



  Positioned? logoPositioned;
  Timer? _timer;


  void hideLogo() {
    // タイマーが終了したら FlutterLogo を非表示にする
    logoPositioned = null;
    setState(() {});
  }

  DateTime? now = DateTime.now();
  int nowDate = 0;
  String formattedDate = "";


  void setHeatMap(DateTime? dateTime, int? count) {

    setState(() {
      now = dateTime;
      
      if(count == null){
        nowDate = 0;
      }
      else{
        nowDate = count;
      }

      formattedDate = "${dateTime?.year}/${dateTime?.month}/${dateTime?.day}";

    });

  }


  @override
  void initState(){
    super.initState();
    fetchData();
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
  }


  @override
  Widget build(BuildContext context){

    super.build(context);
    return SingleChildScrollView(
      child: Container(
        child: Column(
          children: [
    
            const SizedBox(height: 10,),
    
            const Text(
              "閲覧数の推移",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
    
            SizedBox(height: SizeConfig.blockSizeVertical!*5,),

            formattedDate == "" ? const Text(""):
              Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "$formattedDate",
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.remove_red_eye),

                        Text(
                          "$nowDate",
                        ),
                      ],
                    ),
                  ],
                ),
              ),



            SizedBox(height: SizeConfig.blockSizeVertical!*5,),


            SingleChildScrollView(
              
              //scrollDirection: Axis.horizontal,
              child: Container(

                child: Column(

                  children: [

                    HeatMap(
                      //defaultColor: Colors.white,
                      colorMode: ColorMode.opacity,
                      datasets: _heatmapData!,
                      scrollable: true,
                      defaultColor: Colors.white.withOpacity(0.2),
                      
                      colorsets: {
                        maxSize: const Color.fromARGB(255, 0, 255, 8),
                      },
                      
                      onClick: (value) {
                        //ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value.toString())));
                        /*
                        
                         */

                        if(_heatmapData!.containsKey(value)){
                          setHeatMap(value, _heatmapData?[value] as int);
                        }
                        else{
                          setHeatMap(value, 0);
                        }
                        
                        /*
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "$value"
                            ),
                          ),
                        );
                         */
                      },
                    ),




                  ],
                ),
              ),
            ),
    



            SizedBox(height: SizeConfig.blockSizeVertical!*10,),
    



            
          ],
        ),
      ),
    );


  }

}
