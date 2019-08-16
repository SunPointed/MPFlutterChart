import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mp_flutter_chart/chart/mp/chart/horizontal_bar_chart.dart';
import 'package:mp_flutter_chart/chart/mp/core/axis.dart';
import 'package:mp_flutter_chart/chart/mp/core/data.dart';
import 'package:mp_flutter_chart/chart/mp/core/description.dart';
import 'package:mp_flutter_chart/chart/mp/core/highlight.dart';
import 'package:mp_flutter_chart/chart/mp/core/interfaces.dart';
import 'package:mp_flutter_chart/chart/mp/core/legend.dart';
import 'package:mp_flutter_chart/chart/mp/listener.dart';
import 'package:mp_flutter_chart/chart/mp/util.dart';

class BarChartHorizontal extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return BarChartHorizontalState();
  }
}

class BarChartHorizontalState extends State<BarChartHorizontal>
    implements OnChartValueSelectedListener {
  HorizontalBarChart _barChart;
  BarData _barData;

  var random = Random(1);

  int _count = 12;
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

  void _initLineData(int count, double range) {
    double barWidth = 9;
    double spaceForBar = 10;
    List<BarEntry> values = List();

    for (int i = 0; i < count; i++) {
      double val = random.nextDouble() * range;
      values.add(BarEntry(x: i * spaceForBar, y: val));
    }

    BarDataSet set1;

    set1 = BarDataSet(values, "DataSet 1");

    set1.setDrawIcons(false);

    List<IBarDataSet> dataSets = List();
    dataSets.add(set1);

    _barData = BarData(dataSets);
    _barData.setValueTextSize(10);
//      data.setValueTypeface(tfLight);
    _barData.setBarWidth(barWidth);
  }

  void _initLineChart() {
    var desc = Description();
    desc.setEnabled(false);
    _barChart = HorizontalBarChart(_barData, (painter) {
      painter
        ..setOnChartValueSelectedListener(this)
        ..setDrawBarShadow(false)
        ..setDrawValueAboveBar(false)
        ..mMaxVisibleCount = 60
        ..setFitBars(true);

      painter.mXAxis
        ..setPosition(XAxisPosition.BOTTOM)
//      ..setTypeface(tf)
        ..setDrawAxisLine(true)
        ..setDrawGridLines(false)
        ..setGranularity(10);

      painter.mAxisLeft
//      ..setTypeface(tf)
        ..setDrawAxisLine(true)
        ..setDrawGridLines(true)
        ..setAxisMinimum(0);

      painter.mAxisRight
        //      ..setTypeface(tf)
        ..setDrawAxisLine(true)
        ..setDrawGridLines(false)
        ..setAxisMinimum(0);

      painter.mLegend
        ..setVerticalAlignment(LegendVerticalAlignment.BOTTOM)
        ..setHorizontalAlignment(LegendHorizontalAlignment.LEFT)
        ..setOrientation(LegendOrientation.HORIZONTAL)
        ..setDrawInside(false)
        ..setFormSize(8)
        ..setXEntrySpace(4);

      painter.mAnimator.animateY1(2500);
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
  void onValueSelected(Entry e, Highlight h) {
//    if (e == null)
//      return;
//
//    RectF bounds = onValueSelectedRectF;
//    chart.getBarBounds((BarEntry) e, bounds);
//    MPPointF position = chart.getPosition(e, AxisDependency.LEFT);
//
//    Log.i("bounds", bounds.toString());
//    Log.i("position", position.toString());
//
//    Log.i("x-index",
//        "low: " + chart.getLowestVisibleX() + ", high: "
//            + chart.getHighestVisibleX());
//
//    MPPointF.recycleInstance(position);
  }
}
