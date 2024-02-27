import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:share_your_q/utils/various.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';


class TrendHeatmap extends StatefulWidget{
  final String subject;
  final Map<DateTime, int>? heatmapDataMath;
  final Map<DateTime, int>? heatmapDataPhys;
  final Map<DateTime, int>? heatmapDataChemi;
  final Map<DateTime, int>? heatmapDataOther;

  const TrendHeatmap({
    Key? key,
    required this.subject,
    required this.heatmapDataMath,
    required this.heatmapDataPhys,
    required this.heatmapDataChemi,
    required this.heatmapDataOther,
  }) : super(key: key);

  @override
  TrendHeatmapState createState() => TrendHeatmapState();

}

class TrendHeatmapState extends State<TrendHeatmap>{

  Map<DateTime, int>? _selectedHeatMap;

  String selectedSubject = "数学";
  MaterialColor selectedColor = Colors.blue;
  int maxSize = 1;
  MaterialColor selectedColorMaterial = Colors.blue;

  void setSubject(String subject){
    switch(subject){
      case "数学":
        setState(() {
          _selectedHeatMap = widget.heatmapDataMath;
          selectedColor = Colors.blue;
          selectedSubject = "数学";
        });
        break;
      case "物理":
        setState(() {
          _selectedHeatMap = widget.heatmapDataPhys;
          selectedColor = Colors.red;
          selectedSubject = "物理";
        });
        break;
      case "化学":
        setState(() {
          _selectedHeatMap = widget.heatmapDataChemi;
          selectedColor = Colors.green;
          selectedSubject = "化学";
        });
        break;
      case "その他":
        setState(() {
          _selectedHeatMap = widget.heatmapDataOther;
          selectedColor = Colors.purple;
          selectedSubject = "その他";
        });
        break;
    }

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
  void initState() {
    super.initState();
    _selectedHeatMap = widget.heatmapDataMath;
  }


  @override
  Widget build(BuildContext context) {

    return Column(
      children: [
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
            
            ElevatedButton(
              onPressed: () => setSubject("数学"), 
              child: Text("数学"),
              style: ElevatedButton.styleFrom(
                //フォローしていないときは透明にしたい
                backgroundColor: selectedSubject == "数学" ? Colors.blue : Colors.transparent,
                elevation: 0,

                //枠線をつけたい
                side: const BorderSide(
                  color: Colors.grey,
                  width: 1,
                ),
                //もうすこしまるみを持たせたい
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            SizedBox(width: SizeConfig.blockSizeHorizontal!*2,),

            ElevatedButton(
              onPressed: () => setSubject("物理"), 
              child: Text("物理"),
              style: ElevatedButton.styleFrom(
                //フォローしていないときは透明にしたい
                backgroundColor: selectedSubject == "物理" ? Colors.red : Colors.transparent,
                //もうすこしまるみを持たせたい
                elevation: 0,

                //枠線をつけたい
                side: const BorderSide(
                  color: Colors.grey,
                  width: 1,
                ),

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            SizedBox(width: SizeConfig.blockSizeHorizontal!*2,),

            ElevatedButton(
              onPressed: () => setSubject("化学"), 
              child: Text("化学"),
              style: ElevatedButton.styleFrom(
                //フォローしていないときは透明にしたい
                backgroundColor: selectedSubject == "化学" ? Colors.green : Colors.transparent,
                //もうすこしまるみを持たせたい

                elevation: 0,

                //枠線をつけたい
                side: const BorderSide(
                  color: Colors.grey,
                  width: 1,
                ),

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            SizedBox(width: SizeConfig.blockSizeHorizontal!*2,),
            
            ElevatedButton(
              onPressed: () => setSubject("その他"), 
              child: Text("その他"),
              style: ElevatedButton.styleFrom(
                //フォローしていないときは透明にしたい
                backgroundColor: selectedSubject == "その他" ? Colors.purple : Colors.transparent,
                //もうすこしまるみを持たせたい

                elevation: 0,

                //枠線をつけたい
                side: const BorderSide(
                  color: Colors.grey,
                  width: 1,
                ),

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

          ],
        ),

        SizedBox(height: SizeConfig.blockSizeVertical!*2,),

        Text(
          selectedSubject,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        SizedBox(height: SizeConfig.blockSizeVertical!*2,),
        
        formattedDate == "" ? const Text(""):
          Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "$formattedDate",
                ),
                /*
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.remove_red_eye),

                    Text(
                      "$nowDate",
                    ),
                  ],
                ),
                 */
              ],
            ),
          ),

        SizedBox(height: SizeConfig.blockSizeVertical!*2,),

        HeatMap(
          colorMode: ColorMode.opacity,
          datasets: _selectedHeatMap!,
          scrollable: true,
          defaultColor: Colors.white.withOpacity(0.2),
          
          colorsets: {
            maxSize: selectedColor,
          },
          
          onClick: (value) {
            setHeatMap(value, 0);
          },
        ),

      ],
    );
    
  }


}