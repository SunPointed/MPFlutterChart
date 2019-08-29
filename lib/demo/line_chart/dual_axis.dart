import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mp_flutter_chart/chart/mp/chart/line_chart.dart';
import 'package:mp_flutter_chart/chart/mp/core/data/line_data.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_set/line_data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/description.dart';
import 'package:mp_flutter_chart/chart/mp/core/entry/entry.dart';
import 'package:mp_flutter_chart/chart/mp/core/enums/axis_dependency.dart';
import 'package:mp_flutter_chart/chart/mp/core/enums/legend_form.dart';
import 'package:mp_flutter_chart/chart/mp/core/enums/legend_horizontal_alignment.dart';
import 'package:mp_flutter_chart/chart/mp/core/enums/legend_orientation.dart';
import 'package:mp_flutter_chart/chart/mp/core/enums/legend_vertical_alignment.dart';
import 'package:mp_flutter_chart/chart/mp/core/highlight/highlight.dart';
import 'package:mp_flutter_chart/chart/mp/core/util.dart';
import 'package:mp_flutter_chart/chart/mp/listener.dart';

class LineChartDualAxis extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LineChartDualAxisState();
  }
}

class LineChartDualAxisState extends State<LineChartDualAxis>
    implements OnChartValueSelectedListener {
  LineChart _lineChart;
  LineData _lineData;
  var random = Random(1);

  int _count = 20;
  double _range = 30.0;

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
            title: Text("Line Chart Dual Axis")),
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
  void onValueSelected(Entry e, Highlight h) {
//    todo
//    Log.i("Entry selected", e.toString());
//    chart.centerViewToAnimated(e.getX(), e.getY(), chart.getData().getDataSetByIndex(h.getDataSetIndex())
//        .getAxisDependency(), 500);
  }

  void _initLineData(int count, double range) {
    List<Entry> values1 = List();

    for (int i = 0; i < count; i++) {
      double val = (random.nextDouble() * (range / 2.0)) + 50;
      values1.add(Entry(x: i.toDouble(), y: val));
    }

    List<Entry> values2 = List();

    for (int i = 0; i < count; i++) {
      double val = (random.nextDouble() * range) + 450;
      values2.add(new Entry(x: i.toDouble(), y: val));
    }

    List<Entry> values3 = List();

    for (int i = 0; i < count; i++) {
      double val = (random.nextDouble() * range) + 500;
      values3.add(new Entry(x: i.toDouble(), y: val));
    }

    LineDataSet set1, set2, set3;

    // create a dataset and give it a type
    set1 = LineDataSet(values1, "DataSet 1");

    set1.setAxisDependency(AxisDependency.LEFT);
    set1.setColor1(ColorUtils.HOLO_BLUE);
    set1.setCircleColor(ColorUtils.WHITE);
    set1.setLineWidth(2);
    set1.setCircleRadius(3);
    set1.setFillAlpha(65);
    set1.setFillColor(ColorUtils.HOLO_BLUE);
    set1.setHighLightColor(Color.fromARGB(255, 244, 117, 117));
    set1.setDrawCircleHole(false);
    //set1.setFillFormatter(new MyFillFormatter(0f));
    //set1.setDrawHorizontalHighlightIndicator(false);
    //set1.setVisible(false);
    //set1.setCircleHoleColor(Color.WHITE);

    // create a dataset and give it a type
    set2 = LineDataSet(values2, "DataSet 2");
    set2.setAxisDependency(AxisDependency.RIGHT);
    set2.setColor1(ColorUtils.RED);
    set2.setCircleColor(ColorUtils.WHITE);
    set2.setLineWidth(2);
    set2.setCircleRadius(3);
    set2.setFillAlpha(65);
    set2.setFillColor(ColorUtils.RED);
    set2.setDrawCircleHole(false);
    set2.setHighLightColor(Color.fromARGB(255, 244, 117, 117));
    //set2.setFillFormatter(new MyFillFormatter(900f));

    set3 = new LineDataSet(values3, "DataSet 3");
    set3.setAxisDependency(AxisDependency.RIGHT);
    set3.setColor1(ColorUtils.YELLOW);
    set3.setCircleColor(ColorUtils.WHITE);
    set3.setLineWidth(2);
    set3.setCircleRadius(3);
    set3.setFillAlpha(65);
    set3.setFillColor(Color.fromARGB(200, ColorUtils.YELLOW.red,
        ColorUtils.YELLOW.green, ColorUtils.YELLOW.blue));
    set3.setDrawCircleHole(false);
    set3.setHighLightColor(Color.fromARGB(255, 244, 117, 117));

    // create a data object with the data sets
    _lineData = LineData.fromList(List()..add(set1)..add(set2)..add(set3));
    _lineData.setValueTextColor(ColorUtils.WHITE);
    _lineData.setValueTextSize(9);
  }

  void _initLineChart() {
    var desc = Description();
    desc.setEnabled(false);
    _lineChart = LineChart(_lineData, (painter) {
      painter
        ..setOnChartValueSelectedListener(this)
        ..mDragDecelerationFrictionCoef = 0.9
        ..mHighlightPerDragEnabled = true
        ..setGridBackgroundColor(ColorUtils.LTGRAY);

//      chart.animateX(1500); todo

      painter.mLegend
        ..setForm(LegendForm.LINE)
        ..setTextSize(11)
        ..setTextColor(ColorUtils.WHITE)
        ..setVerticalAlignment(LegendVerticalAlignment.BOTTOM)
        ..setHorizontalAlignment(LegendHorizontalAlignment.LEFT)
        ..setOrientation(LegendOrientation.HORIZONTAL)
        ..setDrawInside(false);
//      ..setTypeface(tf)

      painter.mXAxis
        ..setTextColor(ColorUtils.WHITE)
        ..setTextSize(11)
        ..setDrawGridLines(false)
        ..setDrawAxisLine(false);
//    ..setTypeface(tf)

      painter.mAxisLeft
        ..setTextColor(ColorUtils.HOLO_BLUE)
        ..setAxisMaximum(200.0)
        ..setAxisMinimum(0.0)
        ..setDrawGridLines(true)
        ..setDrawAxisLine(true)
        ..setGranularityEnabled(true);
//    ..setTypeface(tf)

      painter.mAxisRight
        ..setTextColor(ColorUtils.RED)
        ..setAxisMaximum(900.0)
        ..setAxisMinimum(-200)
        ..setDrawGridLines(false)
        ..setDrawZeroLine(false)
        ..setGranularityEnabled(false);
//    ..setTypeface(tf)

      painter.mAnimator.animateX1(1500);
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
