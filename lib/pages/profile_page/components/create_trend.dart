import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:share_your_q/utils/various.dart';

import 'package:share_your_q/pages/profile_page/components/create_trend/trend_heatmap.dart';

class CreateTrend extends StatefulWidget{
  
  final String? image_own_user_id;

  final int maxSize;
  final Map<DateTime, int>? heatmapData;
  final Map<DateTime, int>? heatmapDataMath;
  final Map<DateTime, int>? heatmapDataPhys;
  final Map<DateTime, int>? heatmapDataChemi;
  final Map<DateTime, int>? heatmapDataOther;

  final Map<String, int> streakSums;
  final Map<String, int> streakNows;
  final Map<String, int> streakMaxs;
  

  const CreateTrend({
    Key? key,
    required this.image_own_user_id,
    required this.maxSize,
    required this.heatmapData,
    required this.heatmapDataMath,
    required this.heatmapDataPhys,
    required this.heatmapDataChemi,
    required this.heatmapDataOther,

    required this.streakSums,
    required this.streakNows,
    required this.streakMaxs,

  }) : super(key: key);

  @override
  _CreateTrendState createState() => _CreateTrendState();
}

class _CreateTrendState extends State<CreateTrend> with AutomaticKeepAliveClientMixin{

  @override
  bool get wantKeepAlive => true;

  bool isLoading = true;


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
    
            /*
            const Text(
              "閲覧数",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
             */
    
            SizedBox(height: SizeConfig.blockSizeVertical!*1,),

            formattedDate == "" ? const Column(
              children: [
                Text(""),
                Text(""),
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
            
                      
                      /*
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
                          
\
                        },
                      ),
            
                      SizedBox(height: SizeConfig.blockSizeVertical!*3,),
                       */
       
                      TrendHeatmap(
                        subject: "数学", 
                        heatmapDataMath: widget.heatmapDataMath, 
                        heatmapDataPhys: widget.heatmapDataPhys, 
                        heatmapDataChemi: widget.heatmapDataChemi, 
                        heatmapDataOther: widget.heatmapDataOther,

                        streakSums: widget.streakSums,
                        streakNows: widget.streakNows,
                        streakMaxs: widget.streakMaxs,
                      )
            





            
            
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
