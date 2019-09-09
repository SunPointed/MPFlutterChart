import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mp_flutter_chart/chart/mp/chart/line_chart.dart';
import 'package:mp_flutter_chart/chart/mp/core/data/line_data.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_set/line_data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/description.dart';
import 'package:mp_flutter_chart/chart/mp/core/entry/entry.dart';
import 'package:mp_flutter_chart/chart/mp/core/enums/legend_form.dart';
import 'package:mp_flutter_chart/chart/mp/core/highlight/highlight.dart';
import 'package:mp_flutter_chart/chart/mp/core/utils/color_utils.dart';
import 'package:mp_flutter_chart/chart/mp/core/utils/utils.dart';
import 'package:mp_flutter_chart/chart/mp/listener.dart';

class LineChartInvertAxis extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LineChartInvertAxisState();
  }
}

class LineChartInvertAxisState extends State<LineChartInvertAxis>
    implements OnChartValueSelectedListener {
  LineChart _lineChart;
  LineData _lineData;
  var random = Random(1);

  int _count = 25;
  double _range = 50.0;

  @override
  void initState() {
    _initLineData(_count, _range);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _initLineChart();
    return Scaffold(
        appBar: AppBar(
            // Here we take the value from the MyHomePage object that was created by
            // the App.build method, and use it to set our appbar title.
            title: Text("Line Chart Invert Axis")),
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
                                value: _count.toDouble(),
                                min: 0,
                                max: 500,
                                onChanged: (value) {
                                  _count = value.toInt();
                                  _initLineData(_count, _range);
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
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: Center(
                            child: Slider(
                                value: _range,
                                min: 0,
                                max: 150,
                                onChanged: (value) {
                                  _range = value;
                                  _initLineData(_count, _range);
                                  setState(() {});
                                })),
                      ),
                      Container(
                          padding: EdgeInsets.only(right: 15.0),
                          child: Text(
                            "${_range.toInt()}",
                            textDirection: TextDirection.ltr,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: ColorUtils.BLACK,
                                fontSize: 12,
                                fontWeight: FontWeight.bold),
                          )),
                    ],
                  )
                ],
              ),
            )
          ],
        ));
  }

  @override
  void onNothingSelected() {}

  @override
  void onValueSelected(Entry e, Highlight h) {}

  void _initLineData(int count, double range) {
    List<Entry> entries = List();

    for (int i = 0; i < count; i++) {
      double xVal = (random.nextDouble() * range);
      double yVal = (random.nextDouble() * range);
      entries.add(Entry(x: xVal.toDouble(), y: yVal));
    }

    // sort by x-value
    entries.sort((entry1, entry2) {
      double diff = entry1.x - entry2.x;

      if (diff == 0)
        return 0;
      else {
        if (diff > 0)
          return 1;
        else
          return -1;
      }
    });

    // create a dataset and give it a type
    LineDataSet set1 = new LineDataSet(entries, "DataSet 1");
    set1.setLineWidth(1.5);
    set1.setCircleRadius(4);

    // create a data object with the data sets
    _lineData = LineData.fromList(List()..add(set1));
  }

  void _initLineChart() {
    var desc = Description();
    desc.setEnabled(false);
    _lineChart = LineChart(_lineData, (painter) {
      painter..setOnChartValueSelectedListener(this);

      painter.mXAxis
        ..setAvoidFirstLastClipping(true)
        ..setAxisMinimum(0);

      painter.mAxisLeft
        ..setAxisMinimum(0)
        ..setInverted(true);

      painter.mAxisRight.setEnabled(false);

      painter.mLegend.setForm(LegendForm.LINE);
    },
        touchEnabled: true,
        drawGridBackground: true,
        dragXEnabled: true,
        dragYEnabled: true,
        scaleXEnabled: true,
        scaleYEnabled: true,
        pinchZoomEnabled: true,
        desc: desc);
  }
}
