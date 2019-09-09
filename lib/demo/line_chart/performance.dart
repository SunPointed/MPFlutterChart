import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mp_flutter_chart/chart/mp/chart/line_chart.dart';
import 'package:mp_flutter_chart/chart/mp/core/data/line_data.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_set/line_data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/description.dart';
import 'package:mp_flutter_chart/chart/mp/core/entry/entry.dart';
import 'package:mp_flutter_chart/chart/mp/core/enums/mode.dart';
import 'package:mp_flutter_chart/chart/mp/core/utils/color_utils.dart';
import 'package:mp_flutter_chart/chart/mp/core/utils/utils.dart';

class LineChartPerformance extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LineChartPerformanceState();
  }
}

class LineChartPerformanceState extends State<LineChartPerformance> {
  LineChart _lineChart;
  LineData _lineData;
  var random = Random(1);

  double _range = 100.0;
  int _count = 0;

  @override
  void initState() {
    _initLineData(_range);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _initLineChart();
    return Scaffold(
        appBar: AppBar(
            // Here we take the value from the MyHomePage object that was created by
            // the App.build method, and use it to set our appbar title.
            title: Text("Line Chart Performance ")),
        body: Stack(
          children: <Widget>[
            Positioned(
              right: 0,
              left: 0,
              top: 0,
              bottom: 100,
              child: _lineChart,
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: Center(
                            child: Slider(
                                value: _range,
                                min: 0,
                                max: 9000,
                                onChanged: (value) {
                                  _range = value;
                                  _initLineData(_range);
                                  setState(() {});
                                })),
                      ),
                      Container(
                          padding: EdgeInsets.only(right: 15.0),
                          child: Text(
                            "$_count",
                            textDirection: TextDirection.ltr,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: ColorUtils.BLACK,
                                fontSize: 12,
                                fontWeight: FontWeight.bold),
                          )),
                    ],
                  ),
                ],
              ),
            )
          ],
        ));
  }

  void _initLineData(double range) {
    List<Entry> values = List();

    _count = (range + 1000).toInt();

    for (int i = 0; i < _count; i++) {
      double val = (random.nextDouble() * (range + 1)) + 3;
      values.add(new Entry(x: i * 0.001, y:val));
    }

    // create a dataset and give it a type
    LineDataSet set1 = new LineDataSet(values, "DataSet 1");

    set1.setColor1(ColorUtils.BLACK);
    set1.setLineWidth(0.5);
    set1.setDrawValues(false);
    set1.setDrawCircles(false);
    set1.setMode(Mode.LINEAR);
    set1.setDrawFilled(false);

    // create a data object with the data sets
    _lineData = LineData.fromList(List()..add(set1));
  }

  void _initLineChart() {
    var desc = Description();
    desc.setEnabled(false);
    _lineChart = LineChart(_lineData, (painter) {
      painter.mAxisLeft.setDrawGridLines(false);
      painter.mAxisRight.setEnabled(false);
      painter.mXAxis
        ..setDrawGridLines(true)
        ..setDrawAxisLine(false);
      painter.mDescription.setEnabled(false);
      painter.mLegend.setEnabled(false);
    },
        touchEnabled: true,
        drawGridBackground: true,
        dragXEnabled: true,
        dragYEnabled: true,
        scaleXEnabled: true,
        scaleYEnabled: true,
        pinchZoomEnabled: false,
        desc: desc);
  }
}
