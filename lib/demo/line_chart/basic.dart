import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mp_flutter_chart/chart/mp/chart/line_chart.dart';
import 'package:mp_flutter_chart/chart/mp/core/data.dart';
import 'package:mp_flutter_chart/chart/mp/core/description.dart';
import 'package:mp_flutter_chart/chart/mp/core/interfaces.dart';
import 'package:mp_flutter_chart/chart/mp/core/legend.dart';
import 'package:mp_flutter_chart/chart/mp/core/limit.dart';
import 'package:mp_flutter_chart/chart/mp/listener.dart';
import 'package:mp_flutter_chart/chart/mp/util.dart';

class LineChartBasic extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LineChartBasicState();
  }
}

class LineChartBasicState extends State<LineChartBasic> {
  LineChart _lineChart;
  LineData _lineData;

  var random = Random(1);

  int _count = 45;
  double _range = 180.0;

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
            title: Text("Line Chart Basic")),
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
                                max: 180,
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
    List<Entry> values = List();

    for (int i = 0; i < count; i++) {
      double val = (random.nextDouble() * range) - 30;
      values.add(Entry(x: i.toDouble(), y: val));
    }

    LineDataSet set1;

    // create a dataset and give it a type
    set1 = LineDataSet(values, "DataSet 1");

    set1.setDrawIcons(false);

    // draw dashed line
//      set1.enableDashedLine(10, 5, 0);

    // black lines and points
    set1.setColor1(ColorUtils.FADE_RED_END);
    set1.setCircleColor(ColorUtils.FADE_RED_END);
    set1.setHighLightColor(ColorUtils.PURPLE);

    // line thickness and point size
    set1.setLineWidth(1);
    set1.setCircleRadius(3);

    // draw points as solid circles
    set1.setDrawCircleHole(false);

    // customize legend entry
    set1.setFormLineWidth(1);
//      set1.setFormLineDashEffect(new DashPathEffect(new double[]{10f, 5f}, 0f));
    set1.setFormSize(15);

    // text size of values
    set1.setValueTextSize(9);

    // draw selection line as dashed
//      set1.enableDashedHighlightLine(10, 5, 0);

    // set the filled area
    set1.setDrawFilled(true);
//    set1.setFillFormatter(A(_lineChart.painter));

    // set color of filled area
    set1.setFillColor(ColorUtils.FADE_RED_END);

    set1.setDrawIcons(true);
    List<ILineDataSet> dataSets = List();
    dataSets.add(set1); // add the data sets

    // create a data object with the data sets
    _lineData = LineData.fromList(dataSets);
    _lineData.setValueTypeface(TextStyle(fontSize: Utils.convertDpToPixel(9)));
  }

  void _initLineChart() {
    var desc = Description();
    desc.setEnabled(false);
    _lineChart = LineChart(_lineData, (painter) {
      painter.mXAxis.enableGridDashedLine(10, 10, 0);

      painter.mAxisRight.setEnabled(false);
//    _lineChart.painter.mAxisRight.enableGridDashedLine(10, 10, 0);
//    _lineChart.painter.mAxisRight.setAxisMaximum(200);
//    _lineChart.painter.mAxisRight.setAxisMinimum(-50);

      painter.mAxisLeft.enableGridDashedLine(10, 10, 0);
      painter.mAxisLeft.setAxisMaximum(200);
      painter.mAxisLeft.setAxisMinimum(-50);

      LimitLine llXAxis = new LimitLine(9, "Index 10");
      llXAxis.setLineWidth(4);
      llXAxis.enableDashedLine(10, 10, 0);
      llXAxis.setLabelPosition(LimitLabelPosition.RIGHT_BOTTOM);
      llXAxis.setTextSize(10);

      LimitLine ll1 = new LimitLine(150, "Upper Limit");
      ll1.setLineWidth(4);
      ll1.enableDashedLine(10, 10, 0);
      ll1.setLabelPosition(LimitLabelPosition.RIGHT_TOP);
      ll1.setTextSize(10);

      LimitLine ll2 = new LimitLine(-30, "Lower Limit");
      ll2.setLineWidth(4);
      ll2.enableDashedLine(10, 10, 0);
      ll2.setLabelPosition(LimitLabelPosition.RIGHT_BOTTOM);
      ll2.setTextSize(10);

      // draw limit lines behind data instead of on top
      painter.mAxisLeft.setDrawLimitLinesBehindData(true);
      painter.mXAxis.setDrawLimitLinesBehindData(true);

      // add limit lines
      painter.mAxisLeft.addLimitLine(ll1);
      painter.mAxisLeft.addLimitLine(ll2);
      painter.mLegend.setForm(LegendForm.LINE);

      painter.mAnimator.animateX1(1500);
    },
        touchEnabled: true,
        drawGridBackground: false,
        dragXEnabled: true,
        dragYEnabled: true,
        scaleXEnabled: true,
        scaleYEnabled: true,
        pinchZoomEnabled: true,
        desc: desc);
  }
}
