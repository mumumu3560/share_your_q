import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';


class RadarChartSample extends StatefulWidget {
  @override
  _RadarChartSampleState createState() => _RadarChartSampleState();
}

class _RadarChartSampleState extends State<RadarChartSample> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Radar Chart Sample'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: RadarChart(
            RadarChartData(
              dataSets: createDataSets(),
              radarBackgroundColor: Colors.transparent,
              getTitle: (index, angle) {
                switch (index) {
                  case 0:
                    return RadarChartTitle(text: '英語', angle: angle);
                  case 1:
                    return RadarChartTitle(text: '数学', angle: angle);
                  case 2:
                    return RadarChartTitle(text: '理科', angle: angle);
                  case 3:
                    return RadarChartTitle(text: '社会', angle: angle);
                  case 4:
                    return RadarChartTitle(text: '国語', angle: angle);
                  default:
                    return RadarChartTitle(text: '');
                }
              },
              titlePositionPercentageOffset: 0.2,
              tickCount: 5,
              /*
              radarTouchData: RadarTouchData(
                touchCallback: (FlTouchEvent event, RadarTouchResponse response) {
                  // Handle touch events here
                },
              ),
               */
            ),
          ),
        ),
      ),
    );
  }

  List<RadarDataSet> createDataSets() {
    return [
      RadarDataSet(
        dataEntries: [
          RadarEntry(value: 200),
          RadarEntry(value: 150),
          RadarEntry(value: 180),
          RadarEntry(value: 220),
          RadarEntry(value: 250),
        ],
        fillColor: Colors.blue.withOpacity(0.4),
        borderColor: Colors.blue,
      ),
      RadarDataSet(
        dataEntries: [
          RadarEntry(value: 180),
          RadarEntry(value: 220),
          RadarEntry(value: 250),
          RadarEntry(value: 200),
          RadarEntry(value: 160),
        ],
        fillColor: Colors.green.withOpacity(0.4),
        borderColor: Colors.green,
      ),



    ];
  }
}
