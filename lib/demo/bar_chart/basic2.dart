import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mp_flutter_chart/chart/mp/chart/bar_chart.dart';
import 'package:mp_flutter_chart/chart/mp/core/data/bar_data.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_interfaces/i_bar_data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_set/bar_data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/description.dart';
import 'package:mp_flutter_chart/chart/mp/core/entry/bar_entry.dart';
import 'package:mp_flutter_chart/chart/mp/core/enums/x_axis_position.dart';
import 'package:mp_flutter_chart/chart/mp/core/utils/color_utils.dart';
import 'package:mp_flutter_chart/demo/action_state.dart';

class BarChartBasic2 extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return BarChartBasic2State();
  }
}

class BarChartBasic2State extends BarActionState<BarChartBasic2> {
  var random = Random(1);
  int _count = 10;
  double _range = 100.0;

  @override
  void initState() {
    _initBarData(_count, _range);
    super.initState();
  }

  @override
  String getTitle() => "Bar Chart Basic2";

  @override
  void chartInit() {
    _initBarChart();
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
          child: barChart == null ? Center(child: Text("no data")) : barChart,
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
                              _initBarData(_count, _range);
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
                            max: 200,
                            onChanged: (value) {
                              _range = value;
                              _initBarData(_count, _range);
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
    );
  }

  void _initBarData(int count, double range) {
    List<BarEntry> values = List();

    for (int i = 0; i < count; i++) {
      double multi = (range + 1);
      double val = (random.nextDouble() * multi) + multi / 3;
      values.add(new BarEntry(x: i.toDouble(), y: val));
    }

    BarDataSet set1;

    set1 = new BarDataSet(values, "Data Set");
    set1.setColors1(ColorUtils.VORDIPLOM_COLORS);
    set1.setDrawValues(false);

    List<IBarDataSet> dataSets = List();
    dataSets.add(set1);

    barData = BarData(dataSets);
    barData.setValueTextSize(10);
    barData.setBarWidth(0.9);
  }

  void _initBarChart() {
    if(barData == null){
      return;
    }

    var desc = Description();
    desc.setEnabled(false);
    barChart = BarChart(barData, (painter) {
      painter
        ..mMaxVisibleCount = 60
        ..setFitBars(true);

      painter.mXAxis
        ..setPosition(XAxisPosition.BOTTOM)
        ..setDrawGridLines(false);

      painter.mAxisLeft.setDrawGridLines(false);

      painter.mLegend.setEnabled(false);

      painter.mAnimator.animateY1(1500);
    },
        touchEnabled: true,
        drawGridBackground: false,
        dragXEnabled: true,
        dragYEnabled: true,
        scaleXEnabled: true,
        scaleYEnabled: true,
        pinchZoomEnabled: false,
        maxVisibleCount: 60,
        desc: desc);
  }
}
