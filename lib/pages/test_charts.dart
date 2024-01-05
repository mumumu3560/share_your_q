import 'package:flutter/material.dart';

import 'package:share_your_q/graphs/bar_chart.dart';
import 'package:share_your_q/graphs/example_bar_chart.dart';
import 'package:share_your_q/graphs/example_radar_chart.dart';

import 'package:share_your_q/graphs/radar_chart_test1.dart';

import 'package:share_your_q/utils/various.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
       home: const Home(title: 'Flutter Demo Home Page'),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key, required this.title});
  final String title;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("棒グラフデモ"),
      ),
      body: content(),
    );
  }

  Widget content() {
  return Center(
    child: Padding(
      padding: const EdgeInsets.only(top: 25),
      child: Container(
        width: SizeConfig.blockSizeHorizontal! * 80,
        height: SizeConfig.blockSizeVertical! * 80,

        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: SizeConfig.blockSizeHorizontal! * 80,
                height: SizeConfig.blockSizeVertical! * 80,
                child: RadarChartSample(),
              ),
        
              Container(
                width: SizeConfig.blockSizeHorizontal! * 80,
                height: SizeConfig.blockSizeVertical! * 80,
                child: RadarChartSample(),
              ),
        
            ],
          ),
        )
        

      ),
    ),
  );
}

}