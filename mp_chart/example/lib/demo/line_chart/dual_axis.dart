import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:mp_chart/mp/chart/line_chart.dart';
import 'package:mp_chart/mp/controller/line_chart_controller.dart';
import 'package:mp_chart/mp/core/common_interfaces.dart';
import 'package:mp_chart/mp/core/data/line_data.dart';
import 'package:mp_chart/mp/core/data_set/line_data_set.dart';
import 'package:mp_chart/mp/core/description.dart';
import 'package:mp_chart/mp/core/entry/entry.dart';
import 'package:mp_chart/mp/core/enums/axis_dependency.dart';
import 'package:mp_chart/mp/core/enums/legend_form.dart';
import 'package:mp_chart/mp/core/enums/legend_horizontal_alignment.dart';
import 'package:mp_chart/mp/core/enums/legend_orientation.dart';
import 'package:mp_chart/mp/core/enums/legend_vertical_alignment.dart';
import 'package:mp_chart/mp/core/highlight/highlight.dart';
import 'package:mp_chart/mp/core/image_loader.dart';
import 'package:mp_chart/mp/core/utils/color_utils.dart';
import 'package:example/demo/action_state.dart';
import 'package:example/demo/util.dart';

class LineChartDualAxis extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LineChartDualAxisState();
  }
}

class LineChartDualAxisState extends LineActionState<LineChartDualAxis>
    implements OnChartValueSelectedListener {
  var random = Random(1);
  int _count = 20;
  double _range = 30.0;

  @override
  void initState() {
    _initController();
    _initLineData(_count, _range);
    super.initState();
  }

  @override
  String getTitle() => "Line Chart Dual Axis";

  @override
  Widget getBody() {
    return Stack(
      children: <Widget>[
        Positioned(
          right: 0,
          left: 0,
          top: 0,
          bottom: 100,
          child: _initLineChart(),
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
                            max: 150,
                            onChanged: (value) {
                              _range = value;
                              _initLineData(_count, _range);
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

  @override
  void onNothingSelected() {}

  @override
  void onValueSelected(Entry e, Highlight h) {
    controller?.centerViewToAnimated(
        e.x,
        e.y,
        controller.data.getDataSetByIndex(h.dataSetIndex).getAxisDependency(),
        500);
  }

  void _initController() {
    var desc = Description()..enabled = false;
    controller = LineChartController(
        axisLeftSettingFunction: (axisLeft, controller) {
          axisLeft
            ..textColor = (ColorUtils.HOLO_BLUE)
            ..setAxisMaximum(200.0)
            ..setAxisMinimum(0.0)
            ..typeface = Util.LIGHT
            ..drawGridLines = (true)
            ..drawAxisLine = (true)
            ..granularityEnabled = (true);
        },
        axisRightSettingFunction: (axisRight, controller) {
          axisRight
            ..textColor = (ColorUtils.RED)
            ..setAxisMaximum(900.0)
            ..setAxisMinimum(-200)
            ..typeface = Util.LIGHT
            ..drawGridLines = (false)
            ..setDrawZeroLine(false)
            ..granularityEnabled = (false);
        },
        legendSettingFunction: (legend, controller) {
          legend
            ..shape = (LegendForm.LINE)
            ..textSize = (11)
            ..typeface = Util.LIGHT
            ..textColor = (ColorUtils.BLUE)
            ..verticalAlignment = (LegendVerticalAlignment.BOTTOM)
            ..horizontalAlignment = (LegendHorizontalAlignment.LEFT)
            ..orientation = (LegendOrientation.HORIZONTAL)
            ..drawInside = (false);
        },
        xAxisSettingFunction: (xAxis, controller) {
          xAxis
            ..typeface = Util.LIGHT
            ..textColor = (ColorUtils.WHITE)
            ..textSize = (11)
            ..drawGridLines = (false)
            ..drawAxisLine = (false);
        },
        drawGridBackground: true,
        dragXEnabled: true,
        dragYEnabled: true,
        scaleXEnabled: true,
        scaleYEnabled: true,
        pinchZoomEnabled: true,
        selectionListener: this,
        highLightPerTapEnabled: true,
        gridBackColor: ColorUtils.LTGRAY,
        backgroundColor: ColorUtils.WHITE,
        description: desc);
  }

  void _initLineData(int count, double range) async {
    List<ui.Image> imgs = List(3);
    imgs[0] = await ImageLoader.loadImage('assets/img/star.png');
    imgs[1] = await ImageLoader.loadImage('assets/img/add.png');
    imgs[2] = await ImageLoader.loadImage('assets/img/close.png');
    List<Entry> values1 = List();

    for (int i = 0; i < count; i++) {
      double val = (random.nextDouble() * (range / 2.0)) + 50;
      values1.add(Entry(x: i.toDouble(), y: val, icon: imgs[0]));
    }

    List<Entry> values2 = List();

    for (int i = 0; i < count; i++) {
      double val = (random.nextDouble() * range) + 450;
      values2.add(new Entry(x: i.toDouble(), y: val, icon: imgs[1]));
    }

    List<Entry> values3 = List();

    for (int i = 0; i < count; i++) {
      double val = (random.nextDouble() * range) + 500;
      values3.add(new Entry(x: i.toDouble(), y: val, icon: imgs[2]));
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
    controller.data =
        LineData.fromList(List()..add(set1)..add(set2)..add(set3));
    controller.data
      ..setValueTextColor(ColorUtils.WHITE)
      ..setValueTextSize(9);

    setState(() {});
  }

  Widget _initLineChart() {
    var lineChart = LineChart(controller);
    controller.animator
      ..reset()
      ..animateX1(1500);
    return lineChart;
  }
}
