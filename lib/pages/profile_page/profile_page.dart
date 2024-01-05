import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:share_your_q/utils/various.dart';
import 'package:share_your_q/image_operations/image_display.dart';

import 'package:share_your_q/pages/display_page/display_page.dart';

import 'package:share_your_q/graphs/radar_chart_test1.dart';
import 'package:share_your_q/pages/profile_page/components/profile.dart';

//TODO ここにプロフィールページを作成する
//グラフなどで自分の問題の傾向を見れるようにする

class ProfilePage extends StatefulWidget {

  final String userId;
  final String userName;

  const ProfilePage({
    Key? key,
    required this.userId,
    required this.userName,
  }): super(key: key);
  
  @override
  _ProfilePageState createState() => _ProfilePageState();
}
class _ProfilePageState extends State<ProfilePage> {
  List<Map<String, dynamic>> imageData = [];


  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return DefaultTabController(
      length: 3,
      initialIndex: 0,

      child: Scaffold(
    
        appBar: AppBar(
          title: Text('${widget.userName}のプロフィール'),

          actions: [
            widget.userId == myUserId
            ? TextButton(
              child: Text("プロフィール編集"),
              onPressed: () async {
                //TODO ここに編集ページへの遷移を書く
              },
            )
            : TextButton(
              child: Text("フォローする"),
              onPressed: () async {
                //TODO ここにフォロー機能を書く
              },  
            )
          ],

          bottom: (
    
            const TabBar(
              tabs: <Widget>[
                Tab(text: "プロフィール", icon: Icon(Icons.star)),
                Tab(text: "作問・解答傾向", icon: Icon(Icons.create)),
                Tab(text: "貢献度", icon: Icon(Icons.workspace_premium)),
                
              ]
            )
          )
          
          //title: const Text("プロフィール"),
        ),
    
        body: TabBarView(
          children: <Widget>[
              
            Center(
              
              child: SingleChildScrollView(

                child: Column(
                  children: [
                    
                    Container(
                      width: SizeConfig.blockSizeHorizontal! * 90,
                      height: SizeConfig.blockSizeVertical! * 90,
                      child: Profile(
                        userId: widget.userId,
                        userName: widget.userName,
                      )
                    ),
                    
                    SizedBox(height: 50,),
                    
                    Container(
                      width: SizeConfig.blockSizeHorizontal! * 80,
                      height: SizeConfig.blockSizeVertical! * 80,
                      child: RadarChartSample(),
                    ),
                    
                  ]
                ),
              ),
            ),
              
            Center(
              child: Text("It's rainy here"),
            ),
              
            Center(
              child: Text("It's sunny here"),
            ),
              
          ],
              
        ),
    
      ),
    );


  }
}



