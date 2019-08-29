import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mp_flutter_chart/chart/mp/chart/bar_chart.dart';
import 'package:mp_flutter_chart/chart/mp/core/data/bar_data.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_set/bar_data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/description.dart';
import 'package:mp_flutter_chart/chart/mp/core/entry/bar_entry.dart';
import 'package:mp_flutter_chart/chart/mp/core/enums/x_axis_position.dart';
import 'package:mp_flutter_chart/chart/mp/core/util.dart';
import 'package:mp_flutter_chart/chart/mp/core/value_formatter/value_formatter.dart';

class BarChartNegative extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return BarChartNegativeState();
  }
}

class BarChartNegativeState extends State<BarChartNegative> {
  BarChart _barChart;
  BarData _barData;
  List<Data> _data = List();
  @override
  void initState() {
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
  Widget build(BuildContext context) {
    _initBarChart();
    return Scaffold(
        appBar: AppBar(
            // Here we take the value from the MyHomePage object that was created by
            // the App.build method, and use it to set our appbar title.
            title: Text("Bar Chart Negative")),
        body: Stack(
          children: <Widget>[
            Positioned(
              right: 0,
              left: 0,
              top: 0,
              bottom: 0,
              child: _barChart,
            ),
          ],
        ));
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

    _barData = BarData(List()..add(set));
    _barData.setValueTextSize(13);
//    _barData.setValueTypeface(tfRegular);
    _barData.setValueFormatter(Formatter());
    _barData.setBarWidth(0.8);
  }

  void _initBarChart() {
    var desc = Description();
    desc.setEnabled(false);
    _barChart = BarChart(_barData, (painter) {
      painter
        ..mExtraTopOffset = -30
        ..mExtraBottomOffset = 10
        ..mExtraLeftOffset = 70
        ..mExtraRightOffset = 70
        ..setDrawBarShadow(false)
        ..setDrawValueAboveBar(true);

      painter.mXAxis
        ..setPosition(XAxisPosition.BOTTOM)
//        ..setTypeface(tf)
        ..setDrawGridLines(false)
        ..setDrawAxisLine(false)
        ..setTextColor(ColorUtils.LTGRAY)
        ..setTextSize(13)
        ..setLabelCount1(5)
        ..setCenterAxisLabels(true)
        ..setValueFormatter(A(_data))
        ..setGranularity(1);

      painter.mAxisLeft
        ..setDrawLabels(false)
        ..setSpaceTop(25)
        ..setSpaceBottom(25)
        ..setDrawAxisLine(false)
        ..setDrawGridLines(false)
        ..setDrawZeroLine(false)
        ..mZeroLineColor = ColorUtils.GRAY
        ..mZeroLineWidth = 0.7;

      painter.mAxisRight.setEnabled(false);
      painter.mLegend.setEnabled(false);
    },
        touchEnabled: true,
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
  final List<Data> _data;

  A(this._data) : super();

  @override
  String getFormattedValue1(double value) {
    return _data[min(max(value.toInt(), 0), _data.length - 1)].xAxisValue;
    ;
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
