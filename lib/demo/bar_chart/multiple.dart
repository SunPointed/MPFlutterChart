import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mp_flutter_chart/chart/mp/chart/bar_chart.dart';
import 'package:mp_flutter_chart/chart/mp/core/data.dart';
import 'package:mp_flutter_chart/chart/mp/core/description.dart';
import 'package:mp_flutter_chart/chart/mp/core/format.dart';
import 'package:mp_flutter_chart/chart/mp/core/highlight.dart';
import 'package:mp_flutter_chart/chart/mp/core/legend.dart';
import 'package:mp_flutter_chart/chart/mp/listener.dart';
import 'package:mp_flutter_chart/chart/mp/util.dart';

class BarChartMultiple extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return BarChartMultipleState();
  }
}

class BarChartMultipleState extends State<BarChartMultiple>
    implements OnChartValueSelectedListener {
  BarChart _barChart;
  BarData _barData;

  var random = Random(1);

  int _count = 10;
  double _range = 100.0;

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
            title: Text("Bar Chart Basic")),
        body: Stack(
          children: <Widget>[
            Positioned(
              right: 0,
              left: 0,
              top: 0,
              bottom: 100,
              child: _barChart,
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
                                max: 200,
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

  int groupCount;
  int startYear;
  int endYear;

  void _initLineData(int count, double range) {
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
          x: i.toDouble(), y: (random.nextDouble() * randomMultiplier)));
      values2.add(BarEntry(
          x: i.toDouble(), y: (random.nextDouble() * randomMultiplier)));
      values3.add(BarEntry(
          x: i.toDouble(), y: (random.nextDouble() * randomMultiplier)));
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

    _barData = BarData(List()..add(set1)..add(set2)..add(set3)..add(set4));
    _barData.setValueFormatter(LargeValueFormatter());
//    _barData.setValueTypeface(tfLight);

    // specify the width each bar should have
    _barData.setBarWidth(0.2);
  }

  void _initLineChart() {
    var desc = Description();
    desc.setEnabled(false);
    _barChart = BarChart(_barData, (painter) {
      double groupSpace = 0.08;
      double barSpace = 0.03; // x4 DataSet/ x4 DataSet
      // (0.2 + 0.03) * 4 + 0.08 = 1.00 -> interval per "group"

      painter
        ..groupBars(startYear.toDouble(), groupSpace, barSpace)
        ..setOnChartValueSelectedListener(this)
        ..setDrawBarShadow(false);

      painter.mXAxis
//      ..setTypeface(tf)
        ..setGranularity(1.0)
        ..setCenterAxisLabels
        ..setAxisMinimum(startYear.toDouble())
        ..setAxisMaximum(startYear +
            painter.getData().getGroupWidth(groupSpace, barSpace) * groupCount)
        ..setValueFormatter(A());

      ValueFormatter formatter = LargeValueFormatter();
      painter.mAxisLeft
//      ..setTypeface(tf)
        ..setValueFormatter(formatter)
        ..setDrawGridLines(false)
        ..setSpaceTop(35)
        ..setAxisMinimum(0);

      painter.mAxisRight.setEnabled(false);

      painter.mLegend
        ..setVerticalAlignment(LegendVerticalAlignment.TOP)
        ..setHorizontalAlignment(LegendHorizontalAlignment.RIGHT)
        ..setOrientation(LegendOrientation.VERTICAL)
        ..setDrawInside(false)
//        ..setTypeface(tfLight)
        ..setYOffset(0.0)
        ..setXOffset(10)
        ..setYEntrySpace(0)
        ..setTextSize(8);
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
