import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mp_flutter_chart/chart/mp/chart/line_chart.dart';
import 'package:mp_flutter_chart/chart/mp/core/data/line_data.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_interfaces/i_line_data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_set/line_data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/description.dart';
import 'package:mp_flutter_chart/chart/mp/core/entry/entry.dart';
import 'package:mp_flutter_chart/chart/mp/core/enums/legend_form.dart';
import 'package:mp_flutter_chart/chart/mp/core/enums/limite_label_postion.dart';
import 'package:mp_flutter_chart/chart/mp/core/image_loader.dart';
import 'package:mp_flutter_chart/chart/mp/core/limit_line.dart';
import 'package:mp_flutter_chart/chart/mp/core/utils/color_utils.dart';
import 'package:mp_flutter_chart/demo/action_state.dart';

class LineChartBasic extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LineChartBasicState();
  }
}

class LineChartBasicState extends LineActionState<LineChartBasic> {
  var random = Random(1);
  int _count = 45;
  double _range = 180.0;

  @override
  void initState() {
    _initLineData(_count, _range);
    super.initState();
  }

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
                            max: 500,
                            onChanged: (value) {
                              _count = value.toInt();
                              _initLineData(_count, _range);
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

  @override
  String getTitle() {
    return "Line Chart Basic";
  }

  void _initLineData(int count, double range) async {
    var img = await ImageLoader.loadImage('assets/img/star.png');
    List<Entry> values = List();

    for (int i = 0; i < count; i++) {
      double val = (random.nextDouble() * range) - 30;
      values.add(Entry(x: i.toDouble(), y: val, icon: img));
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
//      set1.setFormLineDashEffect( DashPathEffect( double[]{10f, 5f}, 0f));
    set1.setFormSize(15);

    // text size of values
    set1.setValueTextSize(9);

    // draw selection line as dashed
//      set1.enableDashedHighlightLine(10, 5, 0);

    // set the filled area
    set1.setDrawFilled(true);
//    set1.setFillFormatter(A(lineChart.painter));

    // set color of filled area
    set1.setFillColor(ColorUtils.FADE_RED_END);

    List<ILineDataSet> dataSets = List();
    dataSets.add(set1); // add the data sets

    // create a data object with the data sets
    lineData = LineData.fromList(dataSets);
//    lineData.setValueTypeface(TextStyle(fontSize: Utils.convertDpToPixel(9)));

    setState(() {});
  }

  void _initLineChart() {
    if (lineData == null) {
      return;
    }

    if (lineChart != null) {
      lineChart?.data = lineData;
      lineChart?.getState()?.setStateIfNotDispose();
      return;
    }

    var desc = Description()..enabled = false;
    LimitLine llXAxis = LimitLine(9, "Index 10");
    llXAxis.setLineWidth(4);
    llXAxis.enableDashedLine(10, 10, 0);
    llXAxis.labelPosition = (LimitLabelPosition.RIGHT_BOTTOM);
    llXAxis.textSize = (10);
    LimitLine ll1 = LimitLine(150, "Upper Limit");
    ll1.setLineWidth(4);
    ll1.enableDashedLine(10, 10, 0);
    ll1.labelPosition = (LimitLabelPosition.RIGHT_TOP);
    ll1.textSize = (10);
    LimitLine ll2 = LimitLine(-30, "Lower Limit");
    ll2.setLineWidth(4);
    ll2.enableDashedLine(10, 10, 0);
    ll2.labelPosition = (LimitLabelPosition.RIGHT_BOTTOM);
    ll2.textSize = (10);
    lineChart = LineChart(lineData, axisLeftSettingFunction: (axisLeft, chart) {
      axisLeft
        ..drawLimitLineBehindData = true
        ..enableGridDashedLine(10, 10, 0)
        ..addLimitLine(ll1)
        ..addLimitLine(ll2)
        ..setAxisMaximum(200)
        ..setAxisMinimum(-50);
    }, axisRightSettingFunction: (axisRight, chart) {
      axisRight.enabled = (false);
    }, legendSettingFunction: (legend, chart) {
      legend.shape = (LegendForm.LINE);
    }, xAxisSettingFunction: (xAxis, chart) {
      xAxis
        ..drawLimitLineBehindData = true
        ..enableGridDashedLine(10, 10, 0);
    },
        touchEnabled: true,
        drawGridBackground: false,
        dragXEnabled: true,
        dragYEnabled: true,
        scaleXEnabled: true,
        scaleYEnabled: true,
        pinchZoomEnabled: true,
        description: desc);
    lineChart.animator.animateX1(1500);
  }
}
