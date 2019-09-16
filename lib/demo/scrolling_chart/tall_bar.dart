import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mp_flutter_chart/chart/mp/chart/bar_chart.dart';
import 'package:mp_flutter_chart/chart/mp/core/data/bar_data.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_interfaces/i_bar_data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_set/bar_data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/description.dart';
import 'package:mp_flutter_chart/chart/mp/core/entry/bar_entry.dart';
import 'package:mp_flutter_chart/chart/mp/core/enums/x_axis_position.dart';
import 'package:mp_flutter_chart/chart/mp/core/utils/color_utils.dart';
import 'package:mp_flutter_chart/demo/util.dart';

class ScrollingChartTallBar extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ScrollingChartTallBarState();
  }
}

class ScrollingChartTallBarState extends State<ScrollingChartTallBar> {
  BarData _barData;

  var random = Random(1);

  bool _isParentMove = true;
  double _curX = 0.0;
  int _preTime = 0;

  @override
  void initState() {
    _initBarData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            // Here we take the value from the MyHomePage object that was created by
            // the App.build method, and use it to set our appbar title.
            title: Text("Scrolling Chart Tall Bar")),
        body: Stack(
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
        ));
  }

  Widget _renderItem() {
    var desc = Description();
    desc.setEnabled(false);
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
                child: BarChart(_barData, (painter) {
                  painter
                    ..setFitBars(true)
                    ..setDrawBarShadow(false);
                  painter.mAxisLeft..setDrawGridLines(false);

                  painter.mLegend.setEnabled(false);

                  painter.mXAxis
                    ..setPosition(XAxisPosition.BOTTOM)
                    ..setDrawGridLines(false);

                  painter.mAnimator.animateY1(800);
                },
                    touchEnabled: true,
                    pinchZoomEnabled: false,
                    drawGridBackground: false,
                    dragXEnabled: true,
                    dragYEnabled: true,
                    scaleXEnabled: true,
                    scaleYEnabled: true,
                    desc: desc),
              )),
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

  void _initBarData() {
    _barData = (generateData());
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
