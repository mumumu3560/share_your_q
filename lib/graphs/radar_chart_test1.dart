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
      /*
      appBar: AppBar(
        title: Text('作問の評価'),
      ),
       */
      body: Container(

        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: RadarChart(
              RadarChartData(
                dataSets: createDataSets(),
                radarBackgroundColor: Colors.transparent,
                getTitle: (index, angle) {
                  switch (index) {
                    case 0:
                      return RadarChartTitle(text: '教育的', angle: angle);
                    case 1:
                      return RadarChartTitle(text: '計算力', angle: angle);
                    case 2:
                      return RadarChartTitle(text: '芸術的', angle: angle);
                    case 3:
                      return RadarChartTitle(text: '面白い', angle: angle);
                    case 4:
                      return RadarChartTitle(text: '難しい', angle: angle);
                    case 5: 
                      return RadarChartTitle(text: '基礎的', angle: angle);
                    default:
                      return RadarChartTitle(text: '');
                  }
                },
                titlePositionPercentageOffset: 0.2,
                tickCount: 6,
                /*
                
                 */
              ),
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
          RadarEntry(value: 240),
          RadarEntry(value: 220),
          RadarEntry(value: 180),
          RadarEntry(value: 190),
          RadarEntry(value: 210),
        ],
        fillColor: Colors.purple.withOpacity(0.4),
        borderColor: Colors.purple,
      ),
    ];
  }
}
