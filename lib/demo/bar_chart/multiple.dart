import 'dart:math';
import 'dart:ui' as ui;

import 'package:mp_flutter_chart/chart/mp/core/common_interfaces.dart';
import 'package:flutter/material.dart';
import 'package:mp_flutter_chart/chart/mp/chart/bar_chart.dart';
import 'package:mp_flutter_chart/chart/mp/core/data/bar_data.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_set/bar_data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/description.dart';
import 'package:mp_flutter_chart/chart/mp/core/entry/bar_entry.dart';
import 'package:mp_flutter_chart/chart/mp/core/entry/entry.dart';
import 'package:mp_flutter_chart/chart/mp/core/enums/legend_horizontal_alignment.dart';
import 'package:mp_flutter_chart/chart/mp/core/enums/legend_orientation.dart';
import 'package:mp_flutter_chart/chart/mp/core/enums/legend_vertical_alignment.dart';
import 'package:mp_flutter_chart/chart/mp/core/highlight/highlight.dart';
import 'package:mp_flutter_chart/chart/mp/core/image_loader.dart';
import 'package:mp_flutter_chart/chart/mp/core/utils/color_utils.dart';
import 'package:mp_flutter_chart/chart/mp/core/value_formatter/large_value_formatter.dart';
import 'package:mp_flutter_chart/chart/mp/core/value_formatter/value_formatter.dart';
import 'package:mp_flutter_chart/demo/action_state.dart';

class BarChartMultiple extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return BarChartMultipleState();
  }
}

class BarChartMultipleState extends BarActionState<BarChartMultiple>
    implements OnChartValueSelectedListener {
  var random = Random(1);
  int _count = 10;
  double _range = 100.0;

  @override
  void initState() {
    _initBarData(_count, _range);
    super.initState();
  }

  @override
  void chartInit() {
    _initBarChart();
  }

  @override
  String getTitle() => "Bar Chart Multiple";

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

  int groupCount;
  int startYear;
  int endYear;

  void _initBarData(int count, double range) async {
    List<ui.Image> imgs = List(3);
    imgs[0] = await ImageLoader.loadImage('assets/img/star.png');
    imgs[1] = await ImageLoader.loadImage('assets/img/add.png');
    imgs[2] = await ImageLoader.loadImage('assets/img/close.png');
    groupCount = count + 1;
    startYear = 1980;
    endYear = startYear + groupCount;
//    tvX.setText(String.format(Locale.ENGLISH, "%d-%d", startYear, endYear));
//    tvY.setText(String.valueOf(seekBarY.getProgress()));

    List<BarEntry> values1 = List();
    List<BarEntry> values2 = List();
    List<BarEntry> values3 = List();
    List<BarEntry> values4 = List();

    double randomMultiplier = range * 100000;

    for (int i = startYear; i < endYear; i++) {
      values1.add(BarEntry(
          x: i.toDouble(),
          y: (random.nextDouble() * randomMultiplier),
          icon: imgs[0]));
      values2.add(BarEntry(
          x: i.toDouble(),
          y: (random.nextDouble() * randomMultiplier),
          icon: imgs[1]));
      values3.add(BarEntry(
          x: i.toDouble(),
          y: (random.nextDouble() * randomMultiplier),
          icon: imgs[2]));
      values4.add(BarEntry(
          x: i.toDouble(), y: (random.nextDouble() * randomMultiplier)));
    }

    BarDataSet set1, set2, set3, set4;

    // create 4 DataSets
    set1 = BarDataSet(values1, "Company A");
    set1.setColor1(Color.fromARGB(255, 104, 241, 175));
    set2 = BarDataSet(values2, "Company B");
    set2.setColor1(Color.fromARGB(255, 164, 228, 251));
    set3 = BarDataSet(values3, "Company C");
    set3.setColor1(Color.fromARGB(255, 242, 247, 158));
    set4 = BarDataSet(values4, "Company D");
    set4.setColor1(Color.fromARGB(255, 255, 102, 0));

    barData = BarData(List()..add(set1)..add(set2)..add(set3)..add(set4));
    barData.setValueFormatter(LargeValueFormatter());
//    barData.setValueTypeface(tfLight);

    // specify the width each bar should have
    barData.barWidth = (0.2);

    setState(() {});
  }

  void _initBarChart() {
    if (barData == null) {
      return;
    }

    if (barChart != null) {
      barChart?.data = barData;
      barChart?.getState()?.setStateIfNotDispose();
      return;
    }

    var desc = Description()..enabled = false;
    double groupSpace = 0.08;
    double barSpace = 0.03; // x4 DataSet/ x4 DataSet
    barChart = BarChart(barData, axisLeftSettingFunction: (axisLeft, chart) {
      ValueFormatter formatter = LargeValueFormatter();
      axisLeft
//      ..setTypeface(tf)
        ..setValueFormatter(formatter)
        ..drawGridLines = (false)
        ..spacePercentTop = (35)
        ..setAxisMinimum(0);
    }, axisRightSettingFunction: (axisRight, chart) {
      axisRight.enabled = (false);
    }, legendSettingFunction: (legend, chart) {
      legend
        ..verticalAlignment = (LegendVerticalAlignment.TOP)
        ..horizontalAlignment = (LegendHorizontalAlignment.RIGHT)
        ..orientation = (LegendOrientation.VERTICAL)
        ..drawInside = (false)
//        ..setTypeface(tfLight)
        ..yOffset = (0.0)
        ..xOffset = (10)
        ..yEntrySpace = (0)
        ..textSize = (8);
    }, xAxisSettingFunction: (xAxis, chart) {
      xAxis
//      ..setTypeface(tf)
        ..setGranularity(1.0)
        ..centerAxisLabels = true
        ..setAxisMinimum(startYear.toDouble())
        ..setAxisMaximum(startYear +
            barData.getGroupWidth(groupSpace, barSpace) * groupCount)
        ..setValueFormatter(A());
      // (0.2 + 0.03) * 4 + 0.08 = 1.00 -> interval per "group"
      (chart as BarChart).groupBars(startYear.toDouble(), groupSpace, barSpace);
    },
        touchEnabled: true,
        drawGridBackground: false,
        dragXEnabled: true,
        dragYEnabled: true,
        scaleXEnabled: true,
        scaleYEnabled: true,
        pinchZoomEnabled: false,
        maxVisibleCount: 60,
        selectionListener: this,
        drawBarShadow: false,
        description: desc);
  }

  @override
  void onNothingSelected() {}

  @override
  void onValueSelected(Entry e, Highlight h) {}
}

class A extends ValueFormatter {
  @override
  String getFormattedValue1(double value) {
    return value.toInt().toString();
  }
}
