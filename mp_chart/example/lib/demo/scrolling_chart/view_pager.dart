import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mp_chart/mp/chart/bar_chart.dart';
import 'package:mp_chart/mp/chart/line_chart.dart';
import 'package:mp_chart/mp/chart/pie_chart.dart';
import 'package:mp_chart/mp/chart/scatter_chart.dart';
import 'package:mp_chart/mp/controller/bar_chart_controller.dart';
import 'package:mp_chart/mp/controller/line_chart_controller.dart';
import 'package:mp_chart/mp/controller/pie_chart_controller.dart';
import 'package:mp_chart/mp/controller/scatter_chart_controller.dart';
import 'package:mp_chart/mp/core/data/bar_data.dart';
import 'package:mp_chart/mp/core/data/line_data.dart';
import 'package:mp_chart/mp/core/data/pie_data.dart';
import 'package:mp_chart/mp/core/data/scatter_data.dart';
import 'package:mp_chart/mp/core/data_interfaces/i_bar_data_set.dart';
import 'package:mp_chart/mp/core/data_interfaces/i_line_data_set.dart';
import 'package:mp_chart/mp/core/data_interfaces/i_scatter_data_set.dart';
import 'package:mp_chart/mp/core/data_set/bar_data_set.dart';
import 'package:mp_chart/mp/core/data_set/line_data_set.dart';
import 'package:mp_chart/mp/core/data_set/pie_data_set.dart';
import 'package:mp_chart/mp/core/data_set/scatter_data_set.dart';
import 'package:mp_chart/mp/core/description.dart';
import 'package:mp_chart/mp/core/entry/bar_entry.dart';
import 'package:mp_chart/mp/core/entry/entry.dart';
import 'package:mp_chart/mp/core/entry/pie_entry.dart';
import 'package:mp_chart/mp/core/enums/legend_horizontal_alignment.dart';
import 'package:mp_chart/mp/core/enums/legend_orientation.dart';
import 'package:mp_chart/mp/core/enums/legend_vertical_alignment.dart';
import 'package:mp_chart/mp/core/enums/scatter_shape.dart';
import 'package:mp_chart/mp/core/enums/x_axis_position.dart';
import 'package:mp_chart/mp/core/utils/color_utils.dart';
import 'package:example/demo/action_state.dart';
import 'package:example/demo/util.dart';

class ScrollingChartViewPager extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ScrollingChartViewPagerState();
  }
}

class ScrollingChartViewPagerState
    extends SimpleActionState<ScrollingChartViewPager> {
  LineChartController _lineChartController1;
  LineChartController _lineChartController2;
  BarChartController _barChartController;
  ScatterChartController _scatterChartController;
  PieChartController _pieChartController;
  var random = Random(1);

  @override
  void initState() {
    _initController();
    _initLineData1();
    _initLineData2();
    _initBarData();
    _initScatterData();
    _initPieData();
    super.initState();
  }

  @override
  String getTitle() => "Scrolling Chart View Pager";

  @override
  Widget getBody() {
    return Stack(
      children: <Widget>[
        Positioned(
          right: 0,
          left: 0,
          top: 0,
          bottom: 0,
          child: PageView.builder(
            physics: PageScrollPhysics(),
            itemBuilder: (context, index) {
              switch (index) {
                case 0:
                  {
                    _initLineChart1();
                    return getChildWidget(LineChart(_lineChartController1));
                  }
                case 1:
                  {
                    _initLineChart2();
                    return getChildWidget(LineChart(_lineChartController2),
                        showText:
                            "this chart's controller not set resolveGestureHorizontalConflict, so chart move horizontal conflict with page view");
                  }
                case 2:
                  {
                    _initBarChart();
                    return getChildWidget(BarChart(_barChartController));
                  }
                case 3:
                  {
                    _initScatterChart();
                    return getChildWidget(
                        ScatterChart(_scatterChartController));
                  }
                default:
                  {
                    _initPieChart();
                    return getChildWidget(PieChart(_pieChartController));
                  }
              }
            },
            itemCount: 5,
          ),
        ),
      ],
    );
  }

  Widget getChildWidget(Widget child,
      {String showText =
          "this chart's controller set resolveGestureHorizontalConflict, so only can scroll this place to move page"}) {
    return Stack(
      children: <Widget>[
        Positioned(right: 0, left: 0, top: 0, bottom: 100, child: child),
        Positioned(
            right: 0,
            left: 0,
            bottom: 0,
            child: Container(
                color: ColorUtils.HOLO_BLUE_LIGHT,
                constraints: BoxConstraints.expand(height: 100),
                child: Center(
                    child: Text(
                  showText,
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      color: ColorUtils.BLACK,
                      fontSize: 12,
                      fontWeight: FontWeight.bold),
                ))))
      ],
    );
  }

  void _initController() {
    var desc = Description()..enabled = false;

    _lineChartController1 = LineChartController(
        resolveGestureHorizontalConflict: true,
        axisLeftSettingFunction: (axisLeft, controller) {
          axisLeft
            ..setAxisMaximum(1.2)
            ..setAxisMinimum(-1.2);
        },
        axisRightSettingFunction: (axisRight, controller) {
          axisRight.enabled = (false);
        },
        xAxisSettingFunction: (xAxis, controller) {
          xAxis.enabled = (false);
        },
        drawGridBackground: false,
        dragXEnabled: true,
        dragYEnabled: true,
        scaleXEnabled: true,
        scaleYEnabled: true,
        description: desc);

    _lineChartController2 = LineChartController(
        axisRightSettingFunction: (axisRight, controller) {
          axisRight.enabled = (false);
        },
        xAxisSettingFunction: (xAxis, controller) {
          xAxis.enabled = (false);
        },
        drawGridBackground: false,
        dragXEnabled: true,
        dragYEnabled: true,
        scaleXEnabled: true,
        scaleYEnabled: true,
        description: desc);

    _barChartController = BarChartController(
        resolveGestureHorizontalConflict: true,
        axisLeftSettingFunction: (axisLeft, controller) {
          axisLeft.setAxisMinimum(0);
        },
        axisRightSettingFunction: (axisRight, controller) {
          axisRight.enabled = (false);
        },
        xAxisSettingFunction: (xAxis, controller) {
          xAxis.enabled = (false);
        },
        drawGridBackground: false,
        dragXEnabled: true,
        dragYEnabled: true,
        scaleXEnabled: true,
        scaleYEnabled: true,
        drawBarShadow: false,
        description: desc);

    _scatterChartController = ScatterChartController(
        resolveGestureHorizontalConflict: true,
        axisRightSettingFunction: (axisRight, controller) {
          axisRight.drawGridLines = (false);
        },
        legendSettingFunction: (legend, controller) {
          legend
            ..wordWrapEnabled = (true)
            ..formSize = (14)
            ..textSize = (9)
            ..yOffset = (13);
        },
        xAxisSettingFunction: (xAxis, controller) {
          xAxis.position = (XAxisPosition.BOTTOM);
        },
        drawGridBackground: false,
        dragXEnabled: true,
        dragYEnabled: true,
        scaleXEnabled: true,
        scaleYEnabled: true,
        extraBottomOffset: 16,
        description: desc);

    _pieChartController = PieChartController(
        resolveGestureHorizontalConflict: true,
        legendSettingFunction: (legend, controller) {
          legend
            ..verticalAlignment = (LegendVerticalAlignment.TOP)
            ..horizontalAlignment = (LegendHorizontalAlignment.RIGHT)
            ..orientation = (LegendOrientation.VERTICAL)
            ..drawInside = (false);
        },
        centerText: _generateCenterText(),
        holeRadiusPercent: 45,
        transparentCircleRadiusPercent: 50,
        description: desc);
  }

  void _initLineData1() {
    List<ILineDataSet> sets = List();

    Util.loadAsset("sine.txt").then((value) {
      List<Entry> data = List();
      List<String> lines = value.split("\n");
      for (int i = 0; i < lines.length; i++) {
        var datas = lines[i].split("#");
        var x = double.parse(datas[1]);
        var y = double.parse(datas[0]);
        data.add(Entry(x: x, y: y));
      }
      LineDataSet ds1 = LineDataSet(data, "Sine function");
      ds1.setLineWidth(2);
      ds1.setDrawCircles(false);
      ds1.setColor1(ColorUtils.VORDIPLOM_COLORS[0]);
      sets.add(ds1);
      if (sets.length == 2) {
        _lineChartController1.data = LineData.fromList(sets);
        //    _lineData1.setValueTypeface(tf);
        setState(() {});
      }
    });

    Util.loadAsset("cosine.txt").then((value) {
      List<Entry> data = List();
      List<String> lines = value.split("\n");
      for (int i = 0; i < lines.length; i++) {
        var datas = lines[i].split("#");
        var x = double.parse(datas[1]);
        var y = double.parse(datas[0]);
        data.add(Entry(x: x, y: y));
      }
      LineDataSet ds2 = LineDataSet(data, "Cosine function");
      ds2.setLineWidth(2);
      ds2.setDrawCircles(false);
      ds2.setColor1(ColorUtils.VORDIPLOM_COLORS[1]);
      sets.add(ds2);
      if (sets.length == 2) {
        _lineChartController1.data = LineData.fromList(sets);
        //    _lineData1.setValueTypeface(tf);
        setState(() {});
      }
    });
  }

  void _initLineData2() {
    List<ILineDataSet> sets = List();

    Util.loadAsset("n.txt").then((value) {
      List<Entry> data = List();
      List<String> lines = value.split("\n");
      for (int i = 0; i < lines.length; i++) {
        var datas = lines[i].split("#");
        var x = double.parse(datas[1]);
        var y = double.parse(datas[0]);
        data.add(Entry(x: x, y: y));
      }
      LineDataSet ds = LineDataSet(data, "O(n)");
      ds.setLineWidth(2.5);
      ds.setCircleRadius(3);
      ds.setDrawCircles(false);
      ds.setColor1(ColorUtils.VORDIPLOM_COLORS[0]);
      ds.setCircleColor(ColorUtils.VORDIPLOM_COLORS[0]);
      sets.add(ds);
      if (sets.length == 4) {
        _lineChartController2.data = LineData.fromList(sets);
        //    _lineData1.setValueTypeface(tf);
        setState(() {});
      }
    });

    Util.loadAsset("nlogn.txt").then((value) {
      List<Entry> data = List();
      List<String> lines = value.split("\n");
      for (int i = 0; i < lines.length; i++) {
        var datas = lines[i].split("#");
        var x = double.parse(datas[1]);
        var y = double.parse(datas[0]);
        data.add(Entry(x: x, y: y));
      }
      LineDataSet ds = LineDataSet(data, "O(nlogn)");
      ds.setLineWidth(2.5);
      ds.setCircleRadius(3);
      ds.setDrawCircles(false);
      ds.setColor1(ColorUtils.VORDIPLOM_COLORS[1]);
      ds.setCircleColor(ColorUtils.VORDIPLOM_COLORS[1]);
      sets.add(ds);
      if (sets.length == 4) {
        _lineChartController2.data = LineData.fromList(sets);
        //    _lineData1.setValueTypeface(tf);
        setState(() {});
      }
    });

    Util.loadAsset("square.txt").then((value) {
      List<Entry> data = List();
      List<String> lines = value.split("\n");
      for (int i = 0; i < lines.length; i++) {
        var datas = lines[i].split("#");
        var x = double.parse(datas[1]);
        var y = double.parse(datas[0]);
        data.add(Entry(x: x, y: y));
      }
      LineDataSet ds = LineDataSet(data, "O(n\u00B2)");
      ds.setLineWidth(2.5);
      ds.setCircleRadius(3);
      ds.setDrawCircles(false);
      ds.setColor1(ColorUtils.VORDIPLOM_COLORS[2]);
      ds.setCircleColor(ColorUtils.VORDIPLOM_COLORS[2]);
      sets.add(ds);
      if (sets.length == 4) {
        _lineChartController2.data = LineData.fromList(sets);
        //    _lineData1.setValueTypeface(tf);
        setState(() {});
      }
    });

    Util.loadAsset("three.txt").then((value) {
      List<Entry> data = List();
      List<String> lines = value.split("\n");
      for (int i = 0; i < lines.length; i++) {
        var datas = lines[i].split("#");
        var x = double.parse(datas[1]);
        var y = double.parse(datas[0]);
        data.add(Entry(x: x, y: y));
      }
      LineDataSet ds = LineDataSet(data, "O(n³)");
      ds.setLineWidth(2.5);
      ds.setCircleRadius(3);
      ds.setDrawCircles(false);
      ds.setColor1(ColorUtils.VORDIPLOM_COLORS[3]);
      ds.setCircleColor(ColorUtils.VORDIPLOM_COLORS[3]);
      sets.add(ds);
      if (sets.length == 4) {
        _lineChartController2.data = LineData.fromList(sets);
        //    _lineData1.setValueTypeface(tf);
        setState(() {});
      }
    });
  }

  List<String> _labels = List()
    ..add("Company A")
    ..add("Company B")
    ..add("Company C")
    ..add("Company D")
    ..add("Company E")
    ..add("Company F");

  void _initBarData() {
    List<IBarDataSet> sets = List();

    var range = 20000;
    for (int i = 0; i < 1; i++) {
      List<BarEntry> entries = List();

      for (int j = 0; j < 12; j++) {
        entries.add(BarEntry(
            x: j.toDouble(), y: (random.nextDouble() * range) + range / 4));
      }

      BarDataSet ds = BarDataSet(entries, _labels[i]);
      ds.setColors1(ColorUtils.VORDIPLOM_COLORS);
      sets.add(ds);
    }

    _barChartController.data = BarData(sets);
//    _barData.setValueTypeface(tf);
  }

  void _initScatterData() {
    var dataSets = 6;
    var range = 10000;
    var count = 200;
    List<IScatterDataSet> sets = List();

    List<ScatterShape> shapes = ScatterShape.values;

    for (int i = 0; i < dataSets; i++) {
      List<Entry> entries = List();

      for (int j = 0; j < count; j++) {
        entries.add(Entry(
            x: j.toDouble(), y: (random.nextDouble() * range) + range / 4));
      }

      ScatterDataSet ds = ScatterDataSet(entries, _labels[i]);
      ds.setScatterShapeSize(12);
      ds.setScatterShape(shapes[i % shapes.length]);
      ds.setColors1(ColorUtils.COLORFUL_COLORS);
      ds.setScatterShapeSize(9);
      sets.add(ds);
    }

    _scatterChartController.data = ScatterData.fromList(sets);
//    _scatterData.setValueTypeface(tf);
  }

  void _initPieData() {
    int count = 4;

    List<PieEntry> entries1 = List();

    for (int i = 0; i < count; i++) {
      entries1.add(PieEntry(
          value: (random.nextDouble() * 60) + 40, label: "Quarter ${i + 1}"));
    }

    PieDataSet ds1 = PieDataSet(entries1, "Quarterly Revenues 2015");
    ds1.setColors1(ColorUtils.VORDIPLOM_COLORS);
    ds1.setSliceSpace(2);
    ds1.setValueTextColor(ColorUtils.WHITE);
    ds1.setValueTextSize(12);

    _pieChartController.data = PieData(ds1);
//    _pieData.setValueTypeface(tf);
  }

  Widget _initLineChart1() {
    var lineChart = LineChart(_lineChartController1);
    _lineChartController1.animator
      ..reset()
      ..animateX1(3000);
    return lineChart;
  }

  Widget _initLineChart2() {
    var lineChart = LineChart(_lineChartController2);
    _lineChartController2.animator
      ..reset()
      ..animateX1(3000);
    return lineChart;
  }

  Widget _initBarChart() {
    return BarChart(_barChartController);
  }

  Widget _initScatterChart() {
    return ScatterChart(_scatterChartController);
  }

  Widget _initPieChart() {
    return PieChart(_pieChartController);
  }

  String _generateCenterText() {
    return "Revenues\nQuarters 2015";
//    SpannableString s =  SpannableString("Revenues\nQuarters 2015");
//    s.setSpan( RelativeSizeSpan(2f), 0, 8, 0);
//    s.setSpan( ForegroundColorSpan(Color.GRAY), 8, s.length(), 0);
//    return s;
  }
}
