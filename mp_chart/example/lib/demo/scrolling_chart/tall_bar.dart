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

class ScrollingChartTallBar extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ScrollingChartTallBarState();
  }
}

class ScrollingChartTallBarState
    extends SimpleActionState<ScrollingChartTallBar> {
  BarChartController _controller;
  var random = Random(1);
  bool _isParentMove = true;
  double _curX = 0.0;
  int _preTime = 0;

  @override
  void initState() {
    _initController();
    _initBarData();
    super.initState();
  }

  @override
  String getTitle() => "Scrolling Chart Tall Bar";

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
                itemCount: 1,
                itemBuilder: (context, index) {
                  return _renderItem();
                },
                physics: _isParentMove
                    ? PageScrollPhysics()
                    : NeverScrollableScrollPhysics()),
          ),
        ),
      ],
    );
  }

  Widget _renderItem() {
    var barChart = BarChart(_controller);
    _controller.animator
      ..reset()
      ..animateY1(800);
    return Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
              padding: EdgeInsets.all(15.0),
              child: Center(
                  child: Text(
                "START",
                textDirection: TextDirection.ltr,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: ColorUtils.BLACK,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ))),
          Container(
              height: 1000,
              child: Padding(
                  padding: EdgeInsets.only(top: 100, bottom: 100),
                  child: barChart)),
          Container(
              padding: EdgeInsets.all(15.0),
              child: Center(
                  child: Text(
                "END",
                textDirection: TextDirection.ltr,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: ColorUtils.BLACK,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ))),
        ]);
  }

  void _initController() {
    var desc = Description()..enabled = false;
    _controller = BarChartController(
        axisLeftSettingFunction: (axisLeft, controller) {
          axisLeft.drawGridLines = (false);
        },
        legendSettingFunction: (legend, controller) {
          legend.enabled = (false);
        },
        xAxisSettingFunction: (xAxis, controller) {
          xAxis
            ..position = (XAxisPosition.BOTTOM)
            ..drawGridLines = (false);
        },
        pinchZoomEnabled: false,
        drawGridBackground: false,
        dragXEnabled: true,
        dragYEnabled: true,
        scaleXEnabled: true,
        scaleYEnabled: true,
        fitBars: true,
        drawBarShadow: false,
        description: desc);
  }

  void _initBarData() {
    _controller.data = generateData();
  }

  BarData generateData() {
    List<BarEntry> entries = List();

    for (int i = 0; i < 10; i++) {
      entries
          .add(BarEntry(x: i.toDouble(), y: (random.nextDouble() * 10) + 15));
    }

    BarDataSet d = BarDataSet(entries, "Data Set");
    d.setColors1(ColorUtils.VORDIPLOM_COLORS);
    d.setDrawValues(false);

    List<IBarDataSet> sets = List();
    sets.add(d);

    return BarData(sets);
  }
}
