import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mp_chart/mp/chart/bar_chart.dart';
import 'package:mp_chart/mp/controller/bar_chart_controller.dart';
import 'package:mp_chart/mp/core/data/bar_data.dart';
import 'package:mp_chart/mp/core/data_set/bar_data_set.dart';
import 'package:mp_chart/mp/core/description.dart';
import 'package:mp_chart/mp/core/entry/bar_entry.dart';
import 'package:mp_chart/mp/core/enums/x_axis_position.dart';
import 'package:mp_chart/mp/core/utils/color_utils.dart';
import 'package:mp_chart/mp/core/value_formatter/value_formatter.dart';
import 'package:example/demo/action_state.dart';
import 'package:example/demo/util.dart';

class BarChartNegative extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return BarChartNegativeState();
  }
}

class BarChartNegativeState extends SimpleActionState<BarChartNegative> {
  BarChartController _controller;
  List<Data> _data = List();

  @override
  void initState() {
    _initController();
    _data.clear();
    _data
      ..add(Data(0, -224.1, "12-29"))
      ..add(Data(1, 238.5, "12-30"))
      ..add(Data(2, 1280.1, "12-31"))
      ..add(Data(3, -442.3, "01-01"))
      ..add(Data(4, -2280.1, "01-02"));
    _initBarData();
    super.initState();
  }

  @override
  String getTitle() => "Bar Chart Negative";

  @override
  Widget getBody() {
    return Stack(
      children: <Widget>[
        Positioned(
          right: 0,
          left: 0,
          top: 0,
          bottom: 0,
          child: BarChart(_controller),
        ),
      ],
    );
  }

  void _initBarData() {
    List<BarEntry> values = List();
    List<Color> colors = List();

    Color green = Color.fromARGB(255, 110, 190, 102);
    Color red = Color.fromARGB(255, 211, 74, 88);

    for (int i = 0; i < _data.length; i++) {
      Data d = _data[i];
      BarEntry entry = BarEntry(x: d.xValue, y: d.yValue);
      values.add(entry);

      // specific colors
      if (d.yValue >= 0)
        colors.add(red);
      else
        colors.add(green);
    }

    BarDataSet set;

    set = BarDataSet(values, "Values");
    set.setColors1(colors);
    set.setValueTextColors(colors);

    _controller.data = BarData(List()..add(set));
    _controller.data
      ..setValueTextSize(13)
      ..setValueTypeface(Util.REGULAR)
      ..setValueFormatter(Formatter())
      ..barWidth = (0.8);
  }

  void _initController() {
    var desc = Description()..enabled = false;
    _controller = BarChartController(
        axisLeftSettingFunction: (axisLeft, controller) {
          axisLeft
            ..drawLabels = (false)
            ..spacePercentTop = (25)
            ..spacePercentBottom = (25)
            ..drawAxisLine = (false)
            ..drawGridLines = (false)
            ..setDrawZeroLine(false)
            ..zeroLineColor = ColorUtils.GRAY
            ..zeroLineWidth = 0.7;
        },
        axisRightSettingFunction: (axisRight, controller) {
          axisRight.enabled = (false);
        },
        legendSettingFunction: (legend, controller) {
          legend.enabled = (false);
        },
        xAxisSettingFunction: (xAxis, controller) {
          xAxis
            ..position = (XAxisPosition.BOTTOM)
            ..typeface = Util.LIGHT
            ..drawGridLines = (false)
            ..drawAxisLine = (false)
            ..textColor = (ColorUtils.LTGRAY)
            ..textSize = (13)
            ..setLabelCount1(5)
            ..centerAxisLabels = (true)
            ..setValueFormatter(A(_data))
            ..setGranularity(1);
        },
        drawGridBackground: false,
        dragXEnabled: true,
        dragYEnabled: true,
        scaleXEnabled: true,
        scaleYEnabled: true,
        pinchZoomEnabled: false,
        description: desc,
        extraTopOffset: -30,
        extraBottomOffset: 10,
        extraLeftOffset: 70,
        extraRightOffset: 70,
        drawBarShadow: false,
        drawValueAboveBar: true);
  }
}

class A extends ValueFormatter {
  final List<Data> _data;

  A(this._data) : super();

  @override
  String getFormattedValue1(double value) {
    return _data[min(max(value.toInt(), 0), _data.length - 1)].xAxisValue;
  }
}

class Data {
  final String xAxisValue;
  final double yValue;
  final double xValue;

  const Data(this.xValue, this.yValue, this.xAxisValue);
}

class Formatter extends ValueFormatter {
  NumberFormat _format;

  Formatter() : super() {
    _format = NumberFormat("######.0");
  }

  @override
  String getFormattedValue1(double value) {
    return _format.format(value);
  }
}
