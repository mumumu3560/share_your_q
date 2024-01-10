import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:share_your_q/utils/various.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:timeago/timeago.dart';

class CreateTrend extends StatefulWidget{
  
  final String? image_own_user_id;

  const CreateTrend({
    Key? key,
    required this.image_own_user_id,
  }) : super(key: key);

  @override
  _CreateTrendState createState() => _CreateTrendState();
}

class _CreateTrendState extends State<CreateTrend>{

  late List<Map<String, dynamic>> _imageData = [];
  Map<DateTime, int>? _heatmapData = {};

  int maxSize = 0;

  @override
  void dispose() {
    super.dispose();
  }

  //List<Map<String, dynamic>>
  Future<void> fetchData() async {
    try{
      _imageData = await supabase
        .from('image_data')
        .select<List<Map<String, dynamic>>>()
        .eq('user_id', widget.image_own_user_id);

      print(_imageData[0]['created_at']);
      print("hhhhhhhhhhhhhhhhh");

      print(DateTime.parse(_imageData[0]["created_at"])); 

      print(DateTime(2021, 1, 6));
      
      convertData();


    } on PostgrestException catch (error) {
      context.showErrorSnackBar(message: error.message);
      return ;
    }
    catch (_) {
      context.showErrorSnackBar(message: unexpectedErrorMessage);
      return ;
    }
  }


  void convertData(){
    for(int i = 0; i < _imageData.length; i++){
      DateTime date = DateTime.parse(_imageData[i]["created_at"]);
      DateTime truncatedDateTime = DateTime(date.year, date.month, date.day);

      int watchedCount = _imageData[i]["watched"]! as int;
      int watchedCount2 = 0;

      if(_heatmapData![truncatedDateTime] != null){
        watchedCount2 = _heatmapData![truncatedDateTime]!;
      }
      
      int watchedCount3 = watchedCount + watchedCount2;

      _heatmapData![truncatedDateTime] = watchedCount3;//_imageData[i]["watched"]! as int;
      maxSize = max(maxSize, _imageData[i]["watched"]);

      print("truncate");
      print(truncatedDateTime);
      print(_imageData[i]["watched"]);
    }

    setState(() {
      _heatmapData = _heatmapData;
    });
  }


  @override
  void initState(){
    super.initState();
    fetchData();
  }


  @override
  Widget build(BuildContext context){
    return SingleChildScrollView(
      child: Container(
        child: Column(
          children: [
    
            SizedBox(height: 10,),
    
            Text(
              "閲覧数の推移",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
    
            SizedBox(height: SizeConfig.blockSizeVertical!*5,),


            SingleChildScrollView(
              
              //scrollDirection: Axis.horizontal,
              child: Container(
                child: HeatMap(
                  //defaultColor: Colors.white,
                  colorMode: ColorMode.opacity,
                  datasets: _heatmapData!,
                  scrollable: true,
                  defaultColor: Colors.white.withOpacity(0.2),
                  
                  colorsets: {
                    maxSize: const Color.fromARGB(255, 0, 255, 8),
                  },
                  
                  onClick: (value) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value.toString())));
                  },
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

