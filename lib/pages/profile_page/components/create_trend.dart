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
      _heatmapData![truncatedDateTime] = _imageData[i]["watched"]! as int;
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
    return Container(
      child: Column(
        children: [
          SingleChildScrollView(
            
            //scrollDirection: Axis.horizontal,
            child: HeatMap(
              //defaultColor: Colors.white,
              colorMode: ColorMode.opacity,
              datasets: _heatmapData!,
              scrollable: true,
              defaultColor: Colors.white.withOpacity(0.4),
              /*
              datasets: {
                DateTime(2024, 1, 6, 9): 3,
                DateTime(2024, 1, 7): 7,
                DateTime(2024, 1, 5): 10,
                DateTime(2024, 1, 3): 13,
                DateTime(2023, 12, 13): 6,
              },
              
               */
              
              colorsets: const {
                
                10: Color.fromARGB(255, 0, 255, 8),
              },
              
              onClick: (value) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value.toString())));
              },
            ),
          )
        ],
      ),
    );


  }

}

