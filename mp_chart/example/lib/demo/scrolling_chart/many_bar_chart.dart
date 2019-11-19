import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mp_chart/mp/chart/bar_chart.dart';
import 'package:mp_chart/mp/controller/bar_chart_controller.dart';
import 'package:mp_chart/mp/core/data/bar_data.dart';
import 'package:mp_chart/mp/core/data_interfaces/i_bar_data_set.dart';
import 'package:mp_chart/mp/core/data_set/bar_data_set.dart';
import 'package:mp_chart/mp/core/description.dart';
import 'package:mp_chart/mp/core/entry/bar_entry.dart';
import 'package:mp_chart/mp/core/enums/x_axis_position.dart';
import 'package:mp_chart/mp/core/utils/color_utils.dart';
import 'package:example/demo/action_state.dart';
import 'package:example/demo/util.dart';

class ScrollingChartManyBar extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ScrollingChartManyBarState();
  }
}

class ScrollingChartManyBarState
    extends SimpleActionState<ScrollingChartManyBar> {
  List<BarChartController> _controllers = List();
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
  String getTitle() => "Scrolling Chart Many Bar";

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

  void _initController() {
    _controllers.clear();
    var desc = Description()..enabled = false;
    for (int i = 0; i < 20; i++) {
      _controllers.add(BarChartController(
          axisLeftSettingFunction: (axisLeft, controller) {
            axisLeft
              ..setLabelCount2(5, false)
              ..spacePercentTop = (15);
          },
          axisRightSettingFunction: (axisRight, controller) {
            axisRight
              ..setLabelCount2(5, false)
              ..spacePercentTop = (15);
          },
          xAxisSettingFunction: (xAxis, controller) {
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
          description: desc));
    }
  }

  Widget _renderItem(int index) {
    var barChart = BarChart(_controllers[index]);
    _controllers[index].animator
      ..reset()
      ..animateY1(700);
    return Container(height: 200, child: barChart);
  }

  void _initBarDatas() {
    for (int i = 0; i < _controllers.length; i++) {
      _controllers[i].data = generateData(i + 1);
    }
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
