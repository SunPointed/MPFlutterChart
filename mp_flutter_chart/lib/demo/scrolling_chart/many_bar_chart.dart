import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mp_chart/mp/chart/bar_chart.dart';
import 'package:mp_chart/mp/core/data/bar_data.dart';
import 'package:mp_chart/mp/core/data_interfaces/i_bar_data_set.dart';
import 'package:mp_chart/mp/core/data_set/bar_data_set.dart';
import 'package:mp_chart/mp/core/description.dart';
import 'package:mp_chart/mp/core/entry/bar_entry.dart';
import 'package:mp_chart/mp/core/enums/x_axis_position.dart';
import 'package:mp_chart/mp/core/utils/color_utils.dart';
import 'package:mp_flutter_chart/demo/action_state.dart';
import 'package:mp_flutter_chart/demo/util.dart';

class ScrollingChartManyBar extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ScrollingChartManyBarState();
  }
}

class ScrollingChartManyBarState
    extends SimpleActionState<ScrollingChartManyBar> {
  List<BarData> _barDatas = List();
  List<BarChart> _barCharts;

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
  String getTitle() => "Scrolling Chart Many Bar";

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
                itemCount: _barDatas.length,
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
    var data = _barDatas[index];
    if (data == null) {
      return Container(
        child: Center(child: Text("no data")),
        height: 200,
      );
    }

    if (_barCharts[index] == null) {
      var desc = Description()..enabled = false;
      _barCharts[index] = BarChart(data,
          axisLeftSettingFunction: (axisLeft, chart) {
        axisLeft
          ..setLabelCount2(5, false)
          ..spacePercentTop = (15);
      }, axisRightSettingFunction: (axisRight, chart) {
        axisRight
          ..setLabelCount2(5, false)
          ..spacePercentTop = (15);
      }, xAxisSettingFunction: (xAxis, chart) {
        xAxis
          ..position = (XAxisPosition.BOTTOM)
          ..drawGridLines = (false);
      },
          drawGridBackground: false,
          dragXEnabled: true,
          dragYEnabled: true,
          scaleXEnabled: true,
          scaleYEnabled: true,
          fitBars: true,
          description: desc);
      _barCharts[index].animator..animateY1(700);
    }
    return Container(height: 200, child: _barCharts[index]);
  }

  void _initBarDatas() {
    _barDatas.clear();
    for (int i = 0; i < 20; i++) {
      _barDatas.add(generateData(i + 1));
    }
    _barCharts = List(_barDatas.length);
  }

  BarData generateData(int cnt) {
    List<BarEntry> entries = List();

    for (int i = 0; i < 12; i++) {
      entries
          .add(BarEntry(x: i.toDouble(), y: (random.nextDouble() * 70) + 30));
    }

    BarDataSet d = BarDataSet(entries, "New DataSet $cnt");
    d.setColors1(ColorUtils.VORDIPLOM_COLORS);
    d.setBarShadowColor(Color.fromARGB(255, 203, 203, 203));

    List<IBarDataSet> sets = List();
    sets.add(d);

    BarData cd = BarData(sets);
    cd.barWidth = (0.9);
    return cd;
  }
}
