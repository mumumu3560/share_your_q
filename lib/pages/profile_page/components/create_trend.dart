import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:share_your_q/utils/various.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';

import 'package:share_your_q/pages/profile_page/components/create_trend/trend_heatmap.dart';

class CreateTrend extends StatefulWidget{
  
  final String? image_own_user_id;

  final int maxSize;
  final Map<DateTime, int>? heatmapData;
  final Map<DateTime, int>? heatmapDataMath;
  final Map<DateTime, int>? heatmapDataPhys;
  final Map<DateTime, int>? heatmapDataChemi;
  final Map<DateTime, int>? heatmapDataOther;

  const CreateTrend({
    Key? key,
    required this.image_own_user_id,
    required this.maxSize,
    required this.heatmapData,
    required this.heatmapDataMath,
    required this.heatmapDataPhys,
    required this.heatmapDataChemi,
    required this.heatmapDataOther,

  }) : super(key: key);

  @override
  _CreateTrendState createState() => _CreateTrendState();
}

class _CreateTrendState extends State<CreateTrend> with AutomaticKeepAliveClientMixin{

  @override
  bool get wantKeepAlive => true;

  /*
  late List<Map<String, dynamic>> _imageData = [];
  late List<Map<String, dynamic>> _likesData = [];
  Map<DateTime, int>? _heatmapData = {};
  //Map<DateTime, int>? _heatmapData2 = {};

  Map<DateTime, int>? _heatmapDataMath = {};
  Map<DateTime, int>? _heatmapDataPhys = {};
  Map<DateTime, int>? _heatmapDataChemi = {};
  Map<DateTime, int>? _heatmapDataOther = {};

  
   */
  bool isLoading = true;


  /*
  int maxSize = 0;

  bool nowDisplay = false;
  Positioned? widgets;

  Timer? timer;
   */



  //List<Map<String, dynamic>>
  /*
  Future<void> fetchData() async {
    try{
      _imageData = await supabase
        .from('image_data')
        .select<List<Map<String, dynamic>>>()
        .eq('user_id', widget.image_own_user_id);

      /*
      
       */

      _likesData = await supabase
        .from("likes")
        .select<List<Map<String, dynamic>>>()
        .eq("user_id", widget.image_own_user_id)
        .eq("add", true);


      convertData("watched", _imageData);

      setState(() {
        _heatmapData = _heatmapData;
      });

      //convertDataSubject("subject", _imageData);


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

      //utcを日本時間に変換
      DateTime date = DateTime.parse(target[i]["created_at"]).add(const Duration(hours: 9));
      DateTime truncatedDateTime = DateTime(date.year, date.month, date.day);

      int watchedCount = target[i][type]! as int;
      int watchedCount2 = 0;

      if(_heatmapData![truncatedDateTime] != null){
        watchedCount2 = _heatmapData![truncatedDateTime]!;
      }
      
      int watchedCount3 = watchedCount + watchedCount2;

      _heatmapData![truncatedDateTime] = watchedCount3;//_imageData[i]["watched"]! as int;
      maxSize = max(maxSize, target[i][type]);




      String createdSubject = target[i]["subject"]! as String;

      if(createdSubject == "数学"){
        _heatmapDataMath![truncatedDateTime] = 1;//watchedCount3;//_imageData[i]["watched"]! as int;
      }
      else if(createdSubject == "物理"){
        _heatmapDataPhys![truncatedDateTime] = 1;//watchedCount3;//_imageData[i]["watched"]! as int;
      }
      else if(createdSubject == "化学"){
        _heatmapDataChemi![truncatedDateTime] = 1;//watchedCount3;//_imageData[i]["watched"]! as int;
      }
      else{
        _heatmapDataOther![truncatedDateTime] = 1;//watchedCount3;//_imageData[i]["watched"]! as int;
      }

    }

    
  }
   */


  /*
  void convertDataSubject(String type, List<Map<String, dynamic>> target)
  {
    for(int i = 0; i < target.length; i++){
      
      DateTime date = DateTime.parse(target[i]["created_at"]);
      DateTime truncatedDateTime = DateTime(date.year, date.month, date.day);

      //subjectは
      //数物化その他の4種類

      String createdSubject = target[i]["subject"]! as String;

      if(createdSubject == "数学"){
        _heatmapDataMath![truncatedDateTime] = 1;//watchedCount3;//_imageData[i]["watched"]! as int;
      }
      else if(createdSubject == "物理"){
        _heatmapDataPhys![truncatedDateTime] = 1;//watchedCount3;//_imageData[i]["watched"]! as int;
      }
      else if(createdSubject == "化学"){
        _heatmapDataChemi![truncatedDateTime] = 1;//watchedCount3;//_imageData[i]["watched"]! as int;
      }
      else{
        _heatmapDataOther![truncatedDateTime] = 1;//watchedCount3;//_imageData[i]["watched"]! as int;
      }

      //_heatmapData2![truncatedDateTime] = 1;//watchedCount3;//_imageData[i]["watched"]! as int;
      //maxSize = max(maxSize, target[i][type]);

    }

    setState(() {
      _heatmapDataMath = _heatmapDataMath;
      _heatmapDataPhys = _heatmapDataPhys;
      _heatmapDataChemi = _heatmapDataChemi;
      _heatmapDataOther = _heatmapDataOther;
    });
  }
   */



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

  String selectedSubject = "数学";

  void setSubject(String subject){
    setState(() {
      selectedSubject = subject;
    });
  }




  @override
  void initState(){
    super.initState();

    isLoading = false;
    //fetchData();


    //isLoading = false;
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
        child: isLoading 
        ? const Center(child: CircularProgressIndicator())
        :Column(
          children: [
    
            const SizedBox(height: 10,),
    
            const Text(
              "閲覧数",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
    
            SizedBox(height: SizeConfig.blockSizeVertical!*1,),

            formattedDate == "" ? Column(
              children: [
                const Text(""),
                const Text(""),
                //const Text(""),
              ],
            )
            
            :
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



            SizedBox(height: SizeConfig.blockSizeVertical!*1,),


            Scrollbar(
              thumbVisibility: true,
              
              child: SingleChildScrollView(
                
                //scrollDirection: Axis.horizontal,
                child: Container(
            
                  child: Column(
            
                    children: [
            
                      
                      HeatMap(
                        //defaultColor: Colors.white,
                        colorMode: ColorMode.opacity,
                        datasets: widget.heatmapData,
                        scrollable: true,
                        defaultColor: Colors.white.withOpacity(0.2),
                        
                        colorsets: {
                          widget.maxSize: const Color.fromARGB(255, 0, 255, 8),
                        },
                        
                        onClick: (value) {
                          //ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value.toString())));
                          /*
                          
                           */
            
                          if(widget.heatmapData!.containsKey(value)){
                            setHeatMap(value, widget.heatmapData?[value] as int);
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
            
                      SizedBox(height: SizeConfig.blockSizeVertical!*3,),
            
                      /*
                      Divider(
                        color: Colors.green,
                        thickness: 5,
                      ),
                       */
                      //SizedBox(height: SizeConfig.blockSizeVertical!*15,),

                      TrendHeatmap(
                        subject: "数学", 
                        heatmapDataMath: widget.heatmapDataMath, 
                        heatmapDataPhys: widget.heatmapDataPhys, 
                        heatmapDataChemi: widget.heatmapDataChemi, 
                        heatmapDataOther: widget.heatmapDataOther
                      )
            






                      /*
                      const Text(
                        "ジャンル別投稿日",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: SizeConfig.blockSizeVertical!*2,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(onPressed: () => setSubject("数学"), child: Text("数学")),
                          SizedBox(width: SizeConfig.blockSizeHorizontal!*2,),

                          ElevatedButton(onPressed: () => setSubject("物理"), child: Text("物理")),
                          SizedBox(width: SizeConfig.blockSizeHorizontal!*2,),

                          ElevatedButton(onPressed: () => setSubject("化学"), child: Text("化学")),
                          SizedBox(width: SizeConfig.blockSizeHorizontal!*2,),
                          
                          ElevatedButton(onPressed: () => setSubject("その他"), child: Text("その他")),
                        ],
                      ),
            
                      SizedBox(height: SizeConfig.blockSizeVertical!*10,),
                      const Text(
                        "数学",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
            
                      SizedBox(height: SizeConfig.blockSizeVertical!*5,),
            
                      HeatMap(
                        colorMode: ColorMode.opacity,
                        datasets: _heatmapDataMath!,
                        scrollable: true,
                        defaultColor: Colors.white.withOpacity(0.2),
                        
                        colorsets: {
                          maxSize: Colors.blue,
                        },
                        
                        onClick: (value) {
            
                        },
                      ),
            
            
                      SizedBox(height: SizeConfig.blockSizeVertical!*10,),
            
                      const Text(
                        "物理",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
            
                      SizedBox(height: SizeConfig.blockSizeVertical!*5,),
            
            
                      HeatMap(
                        colorMode: ColorMode.opacity,
                        datasets: _heatmapDataPhys!,
                        scrollable: true,
                        defaultColor: Colors.white.withOpacity(0.2),
                        
                        colorsets: {
                          maxSize: Colors.red,
                        },
                        
                        onClick: (value) {
            
                        },
                      ),
            
                      SizedBox(height: SizeConfig.blockSizeVertical!*10,),
            
                      const Text(
                        "化学",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
            
                      SizedBox(height: SizeConfig.blockSizeVertical!*5,),
            
                      HeatMap(
                        colorMode: ColorMode.opacity,
                        datasets: _heatmapDataChemi!,
                        scrollable: true,
                        defaultColor: Colors.white.withOpacity(0.2),
                        
                        colorsets: {
                          maxSize: Colors.green,
                        },
                        
                        onClick: (value) {
            
                        },
                      ),
            
                      SizedBox(height: SizeConfig.blockSizeVertical!*10,),
            
                      const Text(
                        "その他",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
            
                      SizedBox(height: SizeConfig.blockSizeVertical!*5,),
            
                      HeatMap(
                        colorMode: ColorMode.opacity,
                        datasets: _heatmapDataOther!,
                        scrollable: true,
                        defaultColor: Colors.white.withOpacity(0.2),
                        
                        colorsets: {
                          maxSize: Colors.white,
                        },
                        
                        onClick: (value) {
            
                        },
                      ),
                      
                      
                       */
            
            
            
            
                    ],
                  ),
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
