import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mp_chart/mp/chart/bar_chart.dart';
import 'package:mp_chart/mp/chart/chart.dart';
import 'package:mp_chart/mp/chart/line_chart.dart';
import 'package:mp_chart/mp/chart/pie_chart.dart';
import 'package:mp_chart/mp/controller/bar_chart_controller.dart';
import 'package:mp_chart/mp/controller/controller.dart';
import 'package:mp_chart/mp/controller/line_chart_controller.dart';
import 'package:mp_chart/mp/controller/pie_chart_controller.dart';
import 'package:mp_chart/mp/core/data/bar_data.dart';
import 'package:mp_chart/mp/core/data/line_data.dart';
import 'package:mp_chart/mp/core/data/pie_data.dart';
import 'package:mp_chart/mp/core/data_interfaces/i_line_data_set.dart';
import 'package:mp_chart/mp/core/data_set/bar_data_set.dart';
import 'package:mp_chart/mp/core/data_set/line_data_set.dart';
import 'package:mp_chart/mp/core/data_set/pie_data_set.dart';
import 'package:mp_chart/mp/core/description.dart';
import 'package:mp_chart/mp/core/entry/bar_entry.dart';
import 'package:mp_chart/mp/core/entry/entry.dart';
import 'package:mp_chart/mp/core/entry/pie_entry.dart';
import 'package:mp_chart/mp/core/enums/legend_horizontal_alignment.dart';
import 'package:mp_chart/mp/core/enums/legend_orientation.dart';
import 'package:mp_chart/mp/core/enums/legend_vertical_alignment.dart';
import 'package:mp_chart/mp/core/enums/x_axis_position.dart';
import 'package:mp_chart/mp/core/utils/color_utils.dart';
import 'package:mp_chart/mp/core/value_formatter/percent_formatter.dart';
import 'package:example/demo/action_state.dart';
import 'package:example/demo/util.dart';

class ScrollingChartMultiple extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ScrollingChartMultipleState();
  }
}

class ScrollingChartMultipleState
    extends SimpleActionState<ScrollingChartMultiple> {
  List<Controller> _controllers = List();
  var random = Random(1);
  bool _isParentMove = true;
  double _curX = 0.0;
  int _preTime = 0;

  @override
  void initState() {
    _initController();
    _initBarDatas();
    super.initState();
  }

  @override
  String getTitle() => "Scrolling Chart Multiple";

  @override
  Widget getBody() {
    return Stack(
      children: <Widget>[
        Positioned(
          right: 0,
          left: 0,
          top: 0,
          bottom: 0,
          child: Listener(
            onPointerDown: (e) {
              _curX = e.localPosition.dx;
              _preTime = Util.currentTimeMillis();
            },
            onPointerMove: (e) {
              if (_isParentMove) {
                var diff = Util.currentTimeMillis() - _preTime;
                if (diff >= 500 && diff <= 600) {
                  if ((_curX - e.localPosition.dx).abs() < 5) {
                    _isParentMove = false;
                    if (mounted) {
                      setState(() {});
                    }
                  }
                }
              }
            },
            onPointerUp: (e) {
              if (!_isParentMove) {
                _isParentMove = true;
                if (mounted) {
                  setState(() {});
                }
              }
            },
            child: ListView.builder(
                itemCount: _controllers.length,
                itemBuilder: (context, index) {
                  return _renderItem(index);
                },
                physics: _isParentMove
                    ? PageScrollPhysics()
                    : NeverScrollableScrollPhysics()),
          ),
        ),
      ],
    );
  }

  Widget _renderItem(int index) {
    Chart chart;
    if (_controllers[index] is LineChartController) {
      chart = _getLineChart(_controllers[index]);
    } else if (_controllers[index] is BarChartController) {
      chart = _getBarChart(_controllers[index]);
    } else if (_controllers[index] is PieChartController) {
      chart = _getPieChart(_controllers[index]);
    }

    return Container(height: 200, child: chart);
  }

  void _initController() {
    _controllers.clear();
    var desc = Description()..enabled = false;
    for (int i = 0; i < 30; i++) {
      if (i % 3 == 0) {
        _controllers.add(LineChartController(
            axisLeftSettingFunction: (axisLeft, controller) {
              axisLeft
                ..setLabelCount2(5, false)
                ..setAxisMinimum(0);
            },
            axisRightSettingFunction: (axisRight, controller) {
              axisRight
                ..setLabelCount2(5, false)
                ..drawGridLines = (false)
                ..setAxisMinimum(0);
            },
            xAxisSettingFunction: (xAxis, controller) {
              xAxis
                ..position = (XAxisPosition.BOTTOM)
                ..drawGridLines = (false)
                ..drawAxisLine = (true);
            },
            drawGridBackground: false,
            dragXEnabled: true,
            dragYEnabled: true,
            scaleXEnabled: true,
            scaleYEnabled: true,
            description: desc));
      } else if (i % 3 == 1) {
        _controllers.add(BarChartController(
            axisLeftSettingFunction: (axisLeft, controller) {
              axisLeft
                ..setLabelCount2(5, false)
                ..setAxisMinimum(0)
                ..spacePercentTop = (20);
            },
            axisRightSettingFunction: (axisRight, controller) {
              axisRight
                ..setLabelCount2(5, false)
                ..setAxisMinimum(0)
                ..spacePercentTop = (20);
            },
            xAxisSettingFunction: (xAxis, controller) {
              xAxis
                ..position = (XAxisPosition.BOTTOM)
                ..drawAxisLine = (true)
                ..drawGridLines = (false);
            },
            drawBarShadow: false,
            fitBars: true,
            drawGridBackground: false,
            dragXEnabled: true,
            dragYEnabled: true,
            scaleXEnabled: true,
            scaleYEnabled: true,
            description: desc));
      } else if (i % 3 == 2) {
        _controllers.add(PieChartController(
            legendSettingFunction: (legend, controller) {
              legend
                ..verticalAlignment = (LegendVerticalAlignment.TOP)
                ..horizontalAlignment = (LegendHorizontalAlignment.RIGHT)
                ..orientation = (LegendOrientation.VERTICAL)
                ..drawInside = (false)
                ..yEntrySpace = (0)
                ..yOffset = (0);
            },
            extraLeftOffset: 5,
            extraRightOffset: 50,
            extraTopOffset: 10,
            extraBottomOffset: 10,
            holeRadiusPercent: 52,
            transparentCircleRadiusPercent: 57,
            centerText: generateCenterText(),
            usePercentValues: true,
            description: desc));
      }
    }
  }

  void _initBarDatas() {
    for (int i = 0; i < _controllers.length; i++) {
      if (i % 3 == 0) {
        _controllers[i].data = _generateDataLine(i + 1);
      } else if (i % 3 == 1) {
        _controllers[i].data = _generateDataBar(i + 1);
      } else if (i % 3 == 2) {
        _controllers[i].data = _generateDataPie();
      }
    }
  }

  LineData _generateDataLine(int cnt) {
    List<Entry> values1 = List();

    for (int i = 0; i < 12; i++) {
      values1.add(Entry(x: i.toDouble(), y: (random.nextDouble() * 65) + 40));
    }

    LineDataSet d1 = LineDataSet(values1, "New DataSet $cnt, (1)");
    d1.setLineWidth(2.5);
    d1.setCircleRadius(4.5);
    d1.setHighLightColor(Color.fromARGB(255, 244, 117, 117));
    d1.setDrawValues(false);

    List<Entry> values2 = List();

    for (int i = 0; i < 12; i++) {
      values2.add(Entry(x: i.toDouble(), y: values1[i].y - 30));
    }

    LineDataSet d2 = LineDataSet(values2, "New DataSet $cnt, (2)");
    d2.setLineWidth(2.5);
    d2.setCircleRadius(4.5);
    d2.setHighLightColor(Color.fromARGB(255, 244, 117, 117));
    d2.setColor1(ColorUtils.VORDIPLOM_COLORS[0]);
    d2.setCircleColor(ColorUtils.VORDIPLOM_COLORS[0]);
    d2.setDrawValues(false);

    List<ILineDataSet> sets = List();
    sets.add(d1);
    sets.add(d2);

    return LineData.fromList(sets);
  }

  BarData _generateDataBar(int cnt) {
    List<BarEntry> entries = List();

    for (int i = 0; i < 12; i++) {
      entries
          .add(BarEntry(x: i.toDouble(), y: (random.nextDouble() * 70) + 30));
    }

    BarDataSet d = BarDataSet(entries, "New DataSet $cnt");
    d.setColors1(ColorUtils.VORDIPLOM_COLORS);
    d.setHighLightAlpha(255);

    BarData cd = BarData(List()..add(d));
    cd.barWidth = (0.9);
    return cd;
  }

  PieData _generateDataPie() {
    List<PieEntry> entries = List();

    for (int i = 0; i < 4; i++) {
      entries.add(PieEntry(
          value: ((random.nextDouble() * 70) + 30), label: "Quarter ${i + 1}"));
    }

    PieDataSet d = PieDataSet(entries, "");

    // space between slices
    d.setSliceSpace(2);
    d.setColors1(ColorUtils.VORDIPLOM_COLORS);

    return PieData(d);
  }

  LineChart _getLineChart(LineChartController controller) {
    var lineChart = LineChart(controller);
    controller.animator
      ..reset()
      ..animateX1(750);
    return lineChart;
  }

  BarChart _getBarChart(BarChartController controller) {
    var barChart = BarChart(controller);
    controller.animator
      ..reset()
      ..animateY1(700);
    return barChart;
  }

  PieChart _getPieChart(PieChartController controller) {
    controller.data
      ..setValueFormatter(PercentFormatter())
      ..setValueTextSize(11)
      ..setValueTextColor(ColorUtils.WHITE);
    var pieChart = PieChart(controller);
    controller.animator
      ..reset()
      ..animateY1(900);
    return pieChart;
  }

  String generateCenterText() {
//    SpannableString s = new SpannableString("MPAndroidChart\ncreated by\nPhilipp Jahoda");
//    s.setSpan(new RelativeSizeSpan(1.6f), 0, 14, 0);
//    s.setSpan(new ForegroundColorSpan(ColorTemplate.VORDIPLOM_COLORS[0]), 0, 14, 0);
//    s.setSpan(new RelativeSizeSpan(.9f), 14, 25, 0);
//    s.setSpan(new ForegroundColorSpan(Color.GRAY), 14, 25, 0);
//    s.setSpan(new RelativeSizeSpan(1.4f), 25, s.length(), 0);
//    s.setSpan(new ForegroundColorSpan(ColorTemplate.getHoloBlue()), 25, s.length(), 0);
//    return s;
    return "mutiple";
  }
}
