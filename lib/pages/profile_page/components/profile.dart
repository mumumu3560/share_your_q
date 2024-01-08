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
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  List<Map<String, dynamic>> imageData = [];
  List<Map<String, dynamic>> profileData = [];


  Future<void> fetchData() async{

    try{
      imageData = await supabase
        .from('image_data')
        .select<List<Map<String, dynamic>>>()
        .eq('user_id', widget.userId);

      profileData = await supabase
        .from('profiles')
        .select<List<Map<String, dynamic>>>()
        .eq('id', widget.userId);

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

      child: Column(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: SizeConfig.safeBlockHorizontal! * 85,
                  height: SizeConfig.safeBlockVertical! * 30,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.green),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

    );

  }
}



