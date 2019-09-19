import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:mp_flutter_chart/chart/mp/chart/line_chart.dart';
import 'package:mp_flutter_chart/chart/mp/core/data/line_data.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_set/line_data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/description.dart';
import 'package:mp_flutter_chart/chart/mp/core/entry/entry.dart';
import 'package:mp_flutter_chart/chart/mp/core/enums/axis_dependency.dart';
import 'package:mp_flutter_chart/chart/mp/core/enums/x_axis_position.dart';
import 'package:mp_flutter_chart/chart/mp/core/enums/y_axis_label_position.dart';
import 'package:mp_flutter_chart/chart/mp/core/image_loader.dart';
import 'package:mp_flutter_chart/chart/mp/core/utils/color_utils.dart';
import 'package:mp_flutter_chart/chart/mp/core/value_formatter/value_formatter.dart';
import 'package:mp_flutter_chart/demo/action_state.dart';
import 'package:mp_flutter_chart/demo/util.dart';

class EvenMoreHourly extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return EvenMoreHourlyState();
  }
}

class EvenMoreHourlyState extends LineActionState<EvenMoreHourly> {
  var random = Random(1);
  int _count = 100;

  @override
  void initState() {
    _initLineData(_count.toDouble());
    super.initState();
  }

  @override
  String getTitle() => "Even More Hourly";

  @override
  void chartInit() {
    _initLineChart();
  }

  @override
  Widget getBody() {
    return Stack(
      children: <Widget>[
        Positioned(
          right: 0,
          left: 0,
          top: 0,
          bottom: 100,
          child: lineChart == null ? Center(child: Text("no data")) : lineChart,
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
                            max: 1500,
                            onChanged: (value) {
                              _count = value.toInt();
                              _initLineData(_count.toDouble());
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
    );
  }

  void _initLineData(double count) async {
    var img = await ImageLoader.loadImage('assets/img/star.png');
    double range = 50;
    // now in hours
    int now = Util.currentTimeMillis();

    List<Entry> values = List();

    // count = hours
    double to = now + count;

    // increment by 1 hour
    for (double x = now.toDouble(); x < to; x++) {
      double y = _getRandom(range, 50);
      values.add(Entry(x: x, y: y, icon: img)); // add one entry per hour
    }

    // create a dataset and give it a type
    LineDataSet set1 = LineDataSet(values, "DataSet 1");
    set1.setAxisDependency(AxisDependency.LEFT);
    set1.setColor1(ColorUtils.getHoloBlue());
    set1.setValueTextColor(ColorUtils.getHoloBlue());
    set1.setLineWidth(1.5);
    set1.setDrawCircles(false);
    set1.setDrawValues(false);
    set1.setFillAlpha(65);
    set1.setFillColor(ColorUtils.getHoloBlue());
    set1.setHighLightColor(Color.fromARGB(255, 244, 117, 117));
    set1.setDrawCircleHole(false);

    // create a data object with the data sets
    lineData = LineData.fromList(List()..add(set1));
    lineData.setValueTextColor(ColorUtils.getHoloBlue());
    lineData.setValueTextSize(9);

    setState(() {});
  }

  double _getRandom(double range, double start) {
    return (random.nextDouble() * range) + start;
  }

  void _initLineChart() {
    if (lineData == null) return;

    if (lineChart != null) {
      lineChart?.data = lineData;
      lineChart?.getState()?.setStateIfNotDispose();
      return;
    }

    var desc = Description();
    desc.setEnabled(false);
    lineChart = LineChart(lineData, (painter) {
      painter.setViewPortOffsets(0, 0, 0, 0);
      painter.mDescription.setEnabled(false);
      painter.mLegend.setEnabled(false);
      painter.mXAxis
        ..setPosition(XAxisPosition.TOP_INSIDE)
//        ..setTypeface(tfLight)
        ..setTextSize(10)
        ..setTextColor(ColorUtils.WHITE)
        ..setDrawAxisLine(false)
        ..setDrawGridLines(true)
        ..setTextColor(Color.fromARGB(255, 255, 192, 56))
        ..setCenterAxisLabels(true)
        ..setGranularity(1)
        ..setValueFormatter(A());

      painter.mAxisLeft
        ..setPosition(YAxisLabelPosition.INSIDE_CHART)
//      ..setTypeface(tfLight)
        ..setTextColor(Color.fromARGB(255, 51, 181, 229))
        ..setDrawGridLines(true)
        ..setGranularityEnabled(true)
        ..setAxisMinimum(0)
        ..setAxisMaximum(170)
        ..setYOffset(-9)
        ..setTextColor(Color.fromARGB(255, 255, 192, 56));

      painter.mAxisRight.setEnabled(false);
    },
        touchEnabled: false,
        dragDecelerationFrictionCoef: 0.9,
        highLightPerTapEnabled: true,
        backgroundColor: ColorUtils.WHITE,
        drawGridBackground: false,
        dragXEnabled: true,
        dragYEnabled: true,
        scaleXEnabled: true,
        scaleYEnabled: true,
        pinchZoomEnabled: false,
        desc: desc);
  }
}

class A extends ValueFormatter {
  final intl.DateFormat mFormat = intl.DateFormat("dd MMM HH:mm");

  @override
  String getFormattedValue1(double value) {
    return mFormat.format(DateTime.now());
  }
}
