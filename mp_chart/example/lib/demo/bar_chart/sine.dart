import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mp_chart/mp/chart/bar_chart.dart';
import 'package:mp_chart/mp/controller/bar_chart_controller.dart';
import 'package:mp_chart/mp/core/data/bar_data.dart';
import 'package:mp_chart/mp/core/data_set/bar_data_set.dart';
import 'package:mp_chart/mp/core/description.dart';
import 'package:mp_chart/mp/core/entry/bar_entry.dart';
import 'package:mp_chart/mp/core/enums/legend_form.dart';
import 'package:mp_chart/mp/core/enums/legend_horizontal_alignment.dart';
import 'package:mp_chart/mp/core/enums/legend_orientation.dart';
import 'package:mp_chart/mp/core/enums/legend_vertical_alignment.dart';
import 'package:mp_chart/mp/core/utils/color_utils.dart';
import 'package:example/demo/action_state.dart';
import 'package:example/demo/util.dart';

class BarChartSine extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return BarChartSineState();
  }
}

class BarChartSineState extends BarActionState<BarChartSine> {
  List<BarEntry> _data;
  var random = Random(1);
  int _count = 150;

  @override
  void initState() {
    _initController();
    Util.loadAsset("othersine.txt").then((value) {
      _data = List();
      List<String> lines = value.split("\n");
      for (int i = 0; i < lines.length; i++) {
        var datas = lines[i].split("#");
        var x = double.parse(datas[1]);
        var y = double.parse(datas[0]);
        _data.add(BarEntry(x: x, y: y));
      }
      _initBarData(_count);
    });

    super.initState();
  }

  @override
  String getTitle() => "Bar Chart Sine";

  @override
  Widget getBody() {
    return Stack(
      children: <Widget>[
        Positioned(
          right: 0,
          left: 0,
          top: 0,
          bottom: 100,
          child: _initBarChart(),
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
                              _initBarData(_count);
                            })),
                  ),
                  Container(
                      constraints: BoxConstraints.expand(height: 50, width: 60),
                      padding: EdgeInsets.only(right: 15.0),
                      child: Center(
                          child: Text(
                        "$_count",
                        textDirection: TextDirection.ltr,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: ColorUtils.BLACK,
                            fontSize: 12,
                            fontWeight: FontWeight.bold),
                      ))),
                ],
              ),
            ],
          ),
        )
      ],
    );
  }

  void _initController() {
    var desc = Description()..enabled = false;
    controller = BarChartController(
        axisLeftSettingFunction: (axisLeft, controller) {
          axisLeft
            ..setLabelCount2(6, false)
            ..typeface = Util.LIGHT
            ..setAxisMaximum(2.5)
            ..setAxisMinimum(-2.5)
            ..granularityEnabled = (true)
            ..setGranularity(0.1);
        },
        axisRightSettingFunction: (axisRight, controller) {
          axisRight
            ..drawGridLines = (false)
            ..typeface = Util.LIGHT
            ..setLabelCount2(6, false)
            ..setAxisMinimum(-2.5)
            ..setAxisMaximum(2.5)
            ..setGranularity(0.1);
        },
        legendSettingFunction: (legend, controller) {
          legend
            ..verticalAlignment = (LegendVerticalAlignment.BOTTOM)
            ..horizontalAlignment = (LegendHorizontalAlignment.LEFT)
            ..orientation = (LegendOrientation.HORIZONTAL)
            ..drawInside = (false)
            ..shape = (LegendForm.SQUARE)
            ..formSize = (9)
            ..textSize = (11)
            ..xEntrySpace = (4);
        },
        xAxisSettingFunction: (xAxis, controller) {
          xAxis.enabled = (false);
        },
        drawGridBackground: false,
        dragXEnabled: true,
        dragYEnabled: true,
        scaleXEnabled: true,
        scaleYEnabled: true,
        pinchZoomEnabled: false,
        maxVisibleCount: 60,
        drawBarShadow: false,
        drawValueAboveBar: true,
        description: desc);
  }

  void _initBarData(int count) {
    if (_data == null) return;

    List<BarEntry> entries = List();
    for (int i = 0; i < count; i++) {
      entries.add(_data[i]);
    }

    BarDataSet set = BarDataSet(entries, "Sinus Function");
    set.setColor1(Color.fromARGB(255, 240, 120, 124));

    controller.data = BarData(List()..add(set));
    controller.data
      ..setValueTextSize(10)
      ..setValueTypeface(Util.LIGHT)
      ..setDrawValues(false)
      ..barWidth = (0.8);

    setState(() {});
  }

  Widget _initBarChart() {
    var barChart = BarChart(controller);
    controller.animator
      ..reset()
      ..animateXY1(1500, 1500);
    return barChart;
  }
}
