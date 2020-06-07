import 'dart:math';

import 'package:mp_chart/mp/controller/horizontal_bar_chart_controller.dart';
import 'package:mp_chart/mp/core/common_interfaces.dart';
import 'package:flutter/material.dart';
import 'package:mp_chart/mp/chart/horizontal_bar_chart.dart';
import 'package:mp_chart/mp/core/data/bar_data.dart';
import 'package:mp_chart/mp/core/data_interfaces/i_bar_data_set.dart';
import 'package:mp_chart/mp/core/data_set/bar_data_set.dart';
import 'package:mp_chart/mp/core/description.dart';
import 'package:mp_chart/mp/core/entry/bar_entry.dart';
import 'package:mp_chart/mp/core/entry/entry.dart';
import 'package:mp_chart/mp/core/enums/legend_horizontal_alignment.dart';
import 'package:mp_chart/mp/core/enums/legend_orientation.dart';
import 'package:mp_chart/mp/core/enums/legend_vertical_alignment.dart';
import 'package:mp_chart/mp/core/enums/limit_label_postion.dart';
import 'package:mp_chart/mp/core/enums/x_axis_position.dart';
import 'package:mp_chart/mp/core/highlight/highlight.dart';
import 'package:mp_chart/mp/core/image_loader.dart';
import 'package:mp_chart/mp/core/limit_line.dart';
import 'package:mp_chart/mp/core/utils/color_utils.dart';
import 'package:example/demo/action_state.dart';
import 'package:example/demo/util.dart';

class BarChartHorizontal extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return BarChartHorizontalState();
  }
}

class BarChartHorizontalState
    extends HorizontalBarActionState<BarChartHorizontal>
    implements OnChartValueSelectedListener {
  var random = Random(1);
  int _count = 12;
  double _range = 50.0;

  @override
  void initState() {
    _initController();
    _initBarData(_count, _range);
    super.initState();
  }

  @override
  String getTitle() => "Bar Chart Horizontal";

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
                            max: 500,
                            onChanged: (value) {
                              _count = value.toInt();
                              _initBarData(_count, _range);
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
                      constraints: BoxConstraints.expand(height: 50, width: 60),
                      padding: EdgeInsets.only(right: 15.0),
                      child: Center(
                          child: Text(
                        "${_range.toInt()}",
                        textDirection: TextDirection.ltr,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: ColorUtils.BLACK,
                            fontSize: 12,
                            fontWeight: FontWeight.bold),
                      ))),
                ],
              )
            ],
          ),
        )
      ],
    );
  }

  void _initBarData(int count, double range) async {
    var img = await ImageLoader.loadImage('assets/img/star.png');
    double barWidth = 9;
    double spaceForBar = 10;
    List<BarEntry> values = List();

    for (int i = 0; i < count; i++) {
      double val = random.nextDouble() * range;
      values.add(BarEntry(x: i * spaceForBar, y: val, icon: img));
    }

    BarDataSet set1;

    set1 = BarDataSet(values, "DataSet 1");

    set1.setDrawIcons(false);

    List<IBarDataSet> dataSets = List();
    dataSets.add(set1);

    controller.data = BarData(dataSets);
    controller.data
      ..setValueTextSize(10)
      ..setValueTypeface(Util.LIGHT)
      ..barWidth = barWidth;

    setState(() {});
  }

  void _initController() {
    LimitLine ll1 = LimitLine(47, "Upper Limit");
    ll1.setLineWidth(1);
    ll1.enableDashedLine(10, 10, 0);
    ll1.labelPosition = (LimitLabelPosition.CENTER_TOP);
    ll1.textSize = (10);
    ll1.typeface = Util.EXTRA_BOLD;
    var desc = Description()..enabled = false;
    LimitLine ll2 = LimitLine(10, "Lower Limit");
    ll2.setLineWidth(1);
    ll2.enableDashedLine(10, 10, 0);
    ll2.labelPosition = (LimitLabelPosition.CENTER_BOTTOM);
    ll2.textSize = (10);
    ll2.typeface = Util.EXTRA_BOLD;
    LimitLine ll3 = LimitLine(47, "Upper Limit");
    ll3.setLineWidth(1);
    ll3.drawBackground = true;
    ll3.enableDashedLine(10, 10, 0);
    ll3.labelPosition = (LimitLabelPosition.LEFT_CENTER);
    ll3.textSize = (10);
    ll3.typeface = Util.EXTRA_BOLD;
    LimitLine ll4 = LimitLine(10, "Lower Limit");
    ll4.drawBackground = true;
    ll4.setLineWidth(1);
    ll4.enableDashedLine(10, 10, 0);
    ll4.labelPosition = (LimitLabelPosition.RIGHT_CENTER);
    ll4.textSize = (10);
    ll4.typeface = Util.EXTRA_BOLD;
    controller = HorizontalBarChartController(
        axisLeftSettingFunction: (axisLeft, controller) {
          axisLeft
            ..addLimitLine(ll1)
            ..addLimitLine(ll2)
            ..typeface = Util.LIGHT
            ..drawAxisLine = true
            ..drawGridLines = true
            ..setAxisMinimum(0);
        },
        axisRightSettingFunction: (axisRight, controller) {
          axisRight
            ..typeface = Util.LIGHT
            ..drawAxisLine = true
            ..drawGridLines = false
            ..setAxisMinimum(0);
        },
        legendSettingFunction: (legend, controller) {
          legend
            ..verticalAlignment = (LegendVerticalAlignment.BOTTOM)
            ..horizontalAlignment = (LegendHorizontalAlignment.LEFT)
            ..orientation = (LegendOrientation.HORIZONTAL)
            ..drawInside = (false)
            ..formSize = (8)
            ..xEntrySpace = (4);
        },
        xAxisSettingFunction: (xAxis, controller) {
          xAxis
            ..addLimitLine(ll3)
            ..addLimitLine(ll4)
            ..position = XAxisPosition.BOTTOM
            ..typeface = Util.LIGHT
            ..drawAxisLine = true
            ..drawGridLines = false
            ..setGranularity(10);
        },
        drawGridBackground: false,
        dragXEnabled: true,
        dragYEnabled: true,
        scaleXEnabled: true,
        scaleYEnabled: true,
        pinchZoomEnabled: false,
        maxVisibleCount: 60,
        description: desc,
        selectionListener: this,
        drawBarShadow: false,
        drawValueAboveBar: false,
        fitBars: true);
  }

  Widget _initBarChart() {
    var barChart = HorizontalBarChart(controller);
    controller.animator
      ..reset()
      ..animateY1(2500);
    return barChart;
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
