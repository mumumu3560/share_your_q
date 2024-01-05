import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:share_your_q/utils/various.dart';
import 'package:share_your_q/image_operations/image_display.dart';

import 'package:share_your_q/pages/display_page/display_page.dart';

import 'package:share_your_q/graphs/radar_chart_test1.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Profile extends StatefulWidget {

  final String userId;
  final String userName;

  const Profile({
    Key? key,
    required this.userId,
    required this.userName,
  }): super(key: key);
  
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<Profile> {
  List<Map<String, dynamic>> imageData = [];


  Future<void> fetchData() async{

    try{
      imageData = await supabase
        .from('image_data')
        .select<List<Map<String, dynamic>>>()
        .eq('user_id', widget.userId);

      print("imageData is here");
      print(imageData);

    } on PostgrestException catch (error) {
      context.showErrorSnackBar(message: error.message);

    }
    catch (_) {
      context.showErrorSnackBar(message: unexpectedErrorMessage);

    }

  }

  @override
  initState(){
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Container(
      child: Row(
        children: [
          Text("aaaaa"),
          SizedBox(width: 10,),
          Text("bbbbb"),
          
        ],
      ),
    );

  }
}



