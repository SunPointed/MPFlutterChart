import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mp_chart/mp/chart/line_chart.dart';
import 'package:mp_chart/mp/controller/line_chart_controller.dart';
import 'package:mp_chart/mp/core/adapter_android_mp.dart';
import 'package:mp_chart/mp/core/chart_trans_listener.dart';
import 'package:mp_chart/mp/core/data/line_data.dart';
import 'package:mp_chart/mp/core/data_interfaces/i_line_data_set.dart';
import 'package:mp_chart/mp/core/data_set/line_data_set.dart';
import 'package:mp_chart/mp/core/description.dart';
import 'package:mp_chart/mp/core/entry/entry.dart';
import 'package:mp_chart/mp/core/enums/legend_form.dart';
import 'package:mp_chart/mp/core/enums/limit_label_postion.dart';
import 'package:mp_chart/mp/core/enums/x_axis_position.dart';
import 'package:mp_chart/mp/core/image_loader.dart';
import 'package:mp_chart/mp/core/limit_line.dart';
import 'package:mp_chart/mp/core/utils/color_utils.dart';
import 'package:example/demo/action_state.dart';
import 'package:example/demo/util.dart';

class LineChartWithRange extends StatefulWidget  {
  @override
  State<StatefulWidget> createState() {
    return LineChartWithRangeState();
  }


}

class LineChartWithRangeState extends State<LineChartWithRange> with ChartTransListener {
  var random = Random(1);
  int _count = 45;
  double _range = 180.0;

  LineChartController controller;
  LineChartController miniController;

  @override
  void scale(double scaleX, double scaleY, double x, double y) {
    var k ="";
  }

  @override
  void translate(double dx, double dy) {
    var k ="";
  }

  @override
  void initState() {

    _initMiniController();
    _initController();
    _initLineData(_count, _range);
    super.initState();
  }

  Widget getBody() {
    return Stack(
      children: <Widget>[
        Positioned(
            right: 0,
            left: 0,
            top: 0,
            bottom: 72,
            child: _initLineChart()),
        Positioned(
            height: 40,
            right: 16,
            left: 16,
            bottom: 16,
            child: _initMiniLineChart()),
      ],
    );
  }


  String getTitle() {
    return "Line Chart Basic";
  }

  void _initController() {
    var desc = Description()..enabled = false;
    controller = LineChartController(
        axisLeftSettingFunction: (axisLeft, controller) {
          axisLeft
            ..setAxisMaximum(200)
            ..setAxisMinimum(-50)
            ..labelAxisPadding = 10;
        },
        axisRightSettingFunction: (axisRight, controller) {
          axisRight..enabled = (false)
            ..labelAxisPadding = 10;
        },
        legendSettingFunction: (legend, controller) {
          legend.shape = (LegendForm.LINE);
        },
        xAxisSettingFunction: (xAxis, controller) {
          xAxis..position = XAxisPosition.BOTTOM
              ..labelAxisPadding = 10;
        },
        drawGridBackground: false,
        backgroundColor: ColorUtils.WHITE,
        dragXEnabled: true,
        dragYEnabled: true,
        scaleXEnabled: true,
        scaleYEnabled: true,
        pinchZoomEnabled: true,
        chartPositionListener: miniController,
        description: desc);
  }

  void _initMiniController() {
    var desc = Description()..enabled = false;
    miniController = LineChartController(
        axisLeftSettingFunction: (axisLeft, controller) {
          axisLeft
            ..setAxisMaximum(200)
            ..setAxisMinimum(-50)
          ..enabled = false;
        },
        axisRightSettingFunction: (axisRight, controller) {
          axisRight.enabled = (false);
        },
        legendSettingFunction: (legend, controller) {
          legend.enabled = false;
        },
        xAxisSettingFunction: (xAxis, controller) {
          xAxis..enabled = (true)
            ..drawGridLines = (true)
            ..position = (XAxisPosition.BOTTOM_INSIDE_RIGHT);
        },
        drawGridBackground: false,
        backgroundColor: ColorUtils.WHITE,
        dragXEnabled: true,
        dragYEnabled: true,
        scaleXEnabled: true,
        scaleYEnabled: true,
        pinchZoomEnabled: true,
        description: desc,
        rangeColor: Colors.red,
      drawRange: true
    );
    miniController.setViewPortOffsets(0, 0, 0, 0);
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


    // black lines and points
    set1.setColor1(ColorUtils.BLACK);
    set1.setCircleColor(ColorUtils.BLACK);
    set1.setHighLightColor(ColorUtils.PURPLE);

    // line thickness and point size
    set1.setLineWidth(1);
    set1.setCircleRadius(3);

    // draw points as solid circles
    set1.setDrawCircleHole(false);

    // customize legend entry
    set1.setFormLineWidth(1);
    set1.setFormLineDashEffect(DashPathEffect(10, 5, 0));
    set1.setFormSize(15);

    // draw selection line as dashed
    set1.enableDashedHighlightLine(10, 5, 0);

    set1.setDrawValues(false);

    // set the filled area
    set1.setDrawFilled(true);
//    set1.setFillFormatter(A(lineChart.painter));

    // set color of filled area
    set1.setGradientColor(ColorUtils.BLUE, ColorUtils.RED);

    List<ILineDataSet> dataSets = List();
    dataSets.add(set1); // add the data sets

    // create a data object with the data sets
    controller.data = LineData.fromList(dataSets);
    miniController.data = LineData.fromList(dataSets);

    setState(() {});
  }

  Widget _initLineChart() {
    var lineChart = LineChart(controller);
    controller.animator
      ..reset()
      ..animateX1(1500);
    return lineChart;
  }

  Widget _initMiniLineChart() {
    var lineChart = LineChart(miniController);
    controller.animator
      ..reset()
      ..animateX1(1500);
    return lineChart;
  }

  @override
  Widget build(BuildContext context) {
    return  getBody();
  }
}
