import 'package:flutter/material.dart';

import 'package:share_your_q/utils/various.dart';


import 'package:share_your_q/graphs/radar_chart_test1.dart';

//TODO ここに通知管理
//グラフなどで自分の問題の傾向を見れるようにする

class AllRightPage extends StatefulWidget {
  const AllRightPage({super.key});

  @override
  _AllRightPageState createState() => _AllRightPageState();
}
class _AllRightPageState extends State<AllRightPage> {



  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return DefaultTabController(
      length: 3,
      initialIndex: 0,

      child: Scaffold(
    
        appBar: AppBar(
          title: const Text('プロフィール'),

          bottom: (
    
            const TabBar(
              tabs: <Widget>[
                Tab(text: "作問傾向", icon: Icon(Icons.create)),
                Tab(text: "解答傾向", icon: Icon(Icons.star)),
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
                    
                    SizedBox(
                      width: SizeConfig.blockSizeHorizontal! * 90,
                      height: SizeConfig.blockSizeVertical! * 90,
                      child: const RadarChartSample(),
                    ),
                    
                    const SizedBox(height: 50,),
                    
                    SizedBox(
                      width: SizeConfig.blockSizeHorizontal! * 80,
                      height: SizeConfig.blockSizeVertical! * 80,
                      child: const RadarChartSample(),
                    ),
                    
                  ]
                ),
              ),
            ),
              
            const Center(
              child: Text("It's rainy here"),
            ),
              
            const Center(
              child: Text("It's sunny here"),
            ),
              
          ],
              
        ),
    
      ),
    );


  }
}



