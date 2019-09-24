import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mp_flutter_chart/chart/mp/chart/bar_chart.dart';
import 'package:mp_flutter_chart/chart/mp/chart/chart.dart';
import 'package:mp_flutter_chart/chart/mp/chart/line_chart.dart';
import 'package:mp_flutter_chart/chart/mp/chart/pie_chart.dart';
import 'package:mp_flutter_chart/chart/mp/core/data/bar_data.dart';
import 'package:mp_flutter_chart/chart/mp/core/data/chart_data.dart';
import 'package:mp_flutter_chart/chart/mp/core/data/line_data.dart';
import 'package:mp_flutter_chart/chart/mp/core/data/pie_data.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_interfaces/i_line_data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_set/bar_data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_set/line_data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_set/pie_data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/description.dart';
import 'package:mp_flutter_chart/chart/mp/core/entry/bar_entry.dart';
import 'package:mp_flutter_chart/chart/mp/core/entry/entry.dart';
import 'package:mp_flutter_chart/chart/mp/core/entry/pie_entry.dart';
import 'package:mp_flutter_chart/chart/mp/core/enums/legend_horizontal_alignment.dart';
import 'package:mp_flutter_chart/chart/mp/core/enums/legend_orientation.dart';
import 'package:mp_flutter_chart/chart/mp/core/enums/legend_vertical_alignment.dart';
import 'package:mp_flutter_chart/chart/mp/core/enums/x_axis_position.dart';
import 'package:mp_flutter_chart/chart/mp/core/utils/color_utils.dart';
import 'package:mp_flutter_chart/chart/mp/core/value_formatter/percent_formatter.dart';
import 'package:mp_flutter_chart/demo/action_state.dart';
import 'package:mp_flutter_chart/demo/util.dart';

class ScrollingChartMultiple extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ScrollingChartMultipleState();
  }
}

class ScrollingChartMultipleState
    extends SimpleActionState<ScrollingChartMultiple> {
  List<ChartData> _chartDatas = List();

  var random = Random(1);

  bool _isParentMove = true;
  double _curX = 0.0;
  int _preTime = 0;

  @override
  void initState() {
    _initBarDatas();
    super.initState();
  }

  @override
  String getTitle() => "Scrolling Chart Multiple";

  @override
  void chartInit() {}

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
              if (_preTime + 500 < Util.currentTimeMillis()) {
                if ((_curX - e.localPosition.dx) < 5) {
                  _isParentMove = false;
                  if (mounted) {
                    setState(() {});
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
                itemCount: _chartDatas.length,
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
    var data = _chartDatas[index];
    if (data == null) {
      return Container(
        child: Center(child: Text("no data")),
        height: 200,
      );
    }

    var desc = Description()..enabled = false;
    Chart chart;
    if (data is LineData) {
      chart = _getLineChart(data);
    } else if (data is BarData) {
      chart = _getBarChart(data);
    } else {
      chart = _getPieChart(data);
    }

    return Container(height: 200, child: chart);
  }

  void _initBarDatas() {
    _chartDatas.clear();
    for (int i = 0; i < 30; i++) {
      if (i % 3 == 0) {
        _chartDatas.add(_generateDataLine(i + 1));
      } else if (i % 3 == 1) {
        _chartDatas.add(_generateDataBar(i + 1));
      } else if (i % 3 == 2) {
        _chartDatas.add(_generateDataPie());
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

  LineChart _getLineChart(LineData data) {
    var desc = Description()..enabled = false;
    var chart = LineChart(data, axisLeftSettingFunction: (axisLeft, chart) {
      axisLeft
        ..setLabelCount2(5, false)
        ..setAxisMinimum(0);
    }, axisRightSettingFunction: (axisRight, chart) {
      axisRight
        ..setLabelCount2(5, false)
        ..drawGridLines = (false)
        ..setAxisMinimum(0);
    }, xAxisSettingFunction: (xAxis, chart) {
      xAxis
        ..position = (XAxisPosition.BOTTOM)
        ..drawGridLines = (false)
        ..drawAxisLine = (true);
    },
        touchEnabled: true,
        drawGridBackground: false,
        dragXEnabled: true,
        dragYEnabled: true,
        scaleXEnabled: true,
        scaleYEnabled: true,
        description: desc);
    chart.animator.animateX1(750);
    return chart;
  }

  BarChart _getBarChart(BarData data) {
    var desc = Description()..enabled = false;
    var chart = BarChart(data,
        axisLeftSettingFunction: (axisLeft, chart) {},
        axisRightSettingFunction: (axisRight, chart) {},
        legendSettingFunction: (legend, chart) {},
        xAxisSettingFunction: (xAxis, chart) {},
        drawBarShadow: false,
        fitBars: true,
        touchEnabled: true,
        drawGridBackground: false,
        dragXEnabled: true,
        dragYEnabled: true,
        scaleXEnabled: true,
        scaleYEnabled: true,
        description: desc);
    chart.axisLeft
      ..setLabelCount2(5, false)
      ..setAxisMinimum(0)
      ..spacePercentTop = (20);
    chart.axisRight
      ..setLabelCount2(5, false)
      ..setAxisMinimum(0)
      ..spacePercentTop = (20);
    chart.xAxis
      ..position = (XAxisPosition.BOTTOM)
      ..drawAxisLine = (true)
      ..drawGridLines = (false);
    chart.animator.animateY1(700);
    return chart;
  }

  PieChart _getPieChart(PieData data) {
    var desc = Description()..enabled = false;
    var chart = PieChart(data,
        legendSettingFunction: (legend, chart) {},
        xAxisSettingFunction: (xAxis, chart) {},
        touchEnabled: true,
        extraLeftOffset: 5,
        extraRightOffset: 50,
        extraTopOffset: 10,
        extraBottomOffset: 10,
        holeRadiusPercent: 52,
        transparentCircleRadiusPercent: 57,
        centerText: generateCenterText(),
        usePercentValues: true,
        description: desc);
    data
      ..setValueFormatter(PercentFormatter())
      ..setValueTextSize(11)
      ..setValueTextColor(ColorUtils.WHITE);
    chart.legend
      ..verticalAlignment = (LegendVerticalAlignment.TOP)
      ..horizontalAlignment = (LegendHorizontalAlignment.RIGHT)
      ..orientation = (LegendOrientation.VERTICAL)
      ..drawInside = (false)
      ..yEntrySpace = (0)
      ..yOffset = (0);
    chart.animator.animateY1(900);
    return chart;
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
