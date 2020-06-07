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
import 'package:mp_chart/mp/core/image_loader.dart';
import 'package:mp_chart/mp/core/utils/color_utils.dart';
import 'package:example/demo/action_state.dart';

class BarChartBasic2 extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return BarChartBasic2State();
  }
}

class BarChartBasic2State extends BarActionState<BarChartBasic2> {
  var random = Random(1);
  int _count = 10;
  double _range = 100.0;

  @override
  void initState() {
    _initController();
    _initBarData(_count, _range);
    super.initState();
  }

  @override
  String getTitle() => "Bar Chart Basic2";

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
                            max: 1500,
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
    List<BarEntry> values = List();

    for (int i = 0; i < count; i++) {
      double multi = (range + 1);
      double val = (random.nextDouble() * multi) + multi / 3;
      values.add(new BarEntry(x: i.toDouble(), y: val, icon: img));
    }

    BarDataSet set1;

    set1 = new BarDataSet(values, "Data Set");
    set1.setColors1(ColorUtils.VORDIPLOM_COLORS);
    set1.setDrawValues(false);

    List<IBarDataSet> dataSets = List();
    dataSets.add(set1);

    controller.data = BarData(dataSets);
    controller.data
      ..setValueTextSize(10)
      ..barWidth = 0.9;

    setState(() {});
  }

  void _initController() {
    var desc = Description()..enabled = false;
    controller = BarChartController(
      axisLeftSettingFunction: (axisLeft, controller) {
        axisLeft.drawGridLines = false;
      },
      legendSettingFunction: (legend, controller) {
        legend.enabled = false;
      },
      xAxisSettingFunction: (xAxis, controller) {
        xAxis
          ..position = XAxisPosition.BOTTOM
          ..drawGridLines = false;
      },
      drawGridBackground: false,
      dragXEnabled: true,
      dragYEnabled: true,
      scaleXEnabled: true,
      scaleYEnabled: true,
      pinchZoomEnabled: false,
      maxVisibleCount: 60,
      description: desc,
      fitBars: true,
    );
  }

  Widget _initBarChart() {
    var barChart = BarChart(controller);
    controller.animator
      ..reset()
      ..animateY1(1500);
    return barChart;
  }
}
