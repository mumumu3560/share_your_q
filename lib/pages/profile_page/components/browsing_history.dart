/*
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:share_your_q/utils/various.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';

import 'package:share_your_q/pages/profile_page/components/create_trend/trend_heatmap.dart';

class BrowsingHistory extends StatefulWidget{
  
  final String? image_own_user_id;

  final int maxSize;
  final Map<DateTime, int>? heatmapData;
  final Map<DateTime, int>? heatmapDataMath;
  final Map<DateTime, int>? heatmapDataPhys;
  final Map<DateTime, int>? heatmapDataChemi;
  final Map<DateTime, int>? heatmapDataOther;

  const BrowsingHistory({
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
  _BrowsingHistoryState createState() => _BrowsingHistoryState();
}

class _BrowsingHistoryState extends State<BrowsingHistory> with AutomaticKeepAliveClientMixin{

  @override
  bool get wantKeepAlive => true;

  List<Map<String,dynamic>> _likesData = [];

  List<Map<String,dynamic>> _imageData = [];


  Future<void> fetchImageList() async{
    try{
      _likesData = await supabase
        .from('likes')
        .select<List<Map<String, dynamic>>>()
        .eq('user_id', widget.image_own_user_id)
        .order('updated_at', ascending: false)
        .limit(20);

      for(int i = 0; i < _likesData.length; i++){

        final singleImage = await supabase
          .from('image_data')
          .select<List<Map<String,dynamic>>>()
          .eq('image_id', _likesData[i]['image_id']);

        _imageData.add(singleImage[0]);
      }

    } on PostgrestException catch (error) {
      context.showErrorSnackBar(message: error.message);
      return ;
    }
    catch (_) {
      context.showErrorSnackBar(message: unexpectedErrorMessage);
    }
  }


  @override
  void initState(){
    super.initState();

  }

  @override
  void dispose() {
    super.dispose();
  }
  


  @override
  Widget build(BuildContext context){

    super.build(context);
    return SingleChildScrollView(
    );


  }

}

 */