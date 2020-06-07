import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mp_chart/mp/chart/line_chart.dart';
import 'package:mp_chart/mp/controller/line_chart_controller.dart';
import 'package:mp_chart/mp/core/common_interfaces.dart';
import 'package:mp_chart/mp/core/data/line_data.dart';
import 'package:mp_chart/mp/core/data_set/line_data_set.dart';
import 'package:mp_chart/mp/core/description.dart';
import 'package:mp_chart/mp/core/entry/entry.dart';
import 'package:mp_chart/mp/core/enums/legend_form.dart';
import 'package:mp_chart/mp/core/highlight/highlight.dart';
import 'package:mp_chart/mp/core/image_loader.dart';
import 'package:mp_chart/mp/core/utils/color_utils.dart';
import 'package:example/demo/action_state.dart';

class LineChartInvertAxis extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LineChartInvertAxisState();
  }
}

class LineChartInvertAxisState extends LineActionState<LineChartInvertAxis>
    implements OnChartValueSelectedListener {
  var random = Random(1);
  int _count = 25;
  double _range = 50.0;

  @override
  void initState() {
    _initController();
    _initLineData(_count, _range);
    super.initState();
  }

  @override
  String getTitle() => "Line Chart Invert Axis";

  @override
  Widget getBody() {
    return Stack(
      children: <Widget>[
        Positioned(
            right: 0,
            left: 0,
            top: 0,
            bottom: 100,
            child: LineChart(controller)),
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
  void onValueSelected(Entry e, Highlight h) {}

  void _initController() {
    var desc = Description()..enabled = false;
    controller = LineChartController(
        axisLeftSettingFunction: (axisLeft, controller) {
          axisLeft
            ..setAxisMinimum(0)
            ..inverted = (true);
        },
        axisRightSettingFunction: (axisRight, controller) {
          axisRight.enabled = (false);
        },
        legendSettingFunction: (legend, controller) {
          legend.shape = (LegendForm.LINE);
        },
        xAxisSettingFunction: (xAxis, controller) {
          xAxis
            ..avoidFirstLastClipping = (true)
            ..setAxisMinimum(0);
        },
        drawGridBackground: true,
        dragXEnabled: true,
        dragYEnabled: true,
        scaleXEnabled: true,
        scaleYEnabled: true,
        pinchZoomEnabled: true,
        selectionListener: this,
        description: desc);
  }

  void _initLineData(int count, double range) async {
    var img = await ImageLoader.loadImage('assets/img/star.png');
    List<Entry> entries = List();

    for (int i = 0; i < count; i++) {
      double xVal = (random.nextDouble() * range);
      double yVal = (random.nextDouble() * range);
      entries.add(Entry(x: xVal.toDouble(), y: yVal, icon: img));
    }

    // sort by x-value
    entries.sort((entry1, entry2) {
      double diff = entry1.x - entry2.x;

      if (diff == 0)
        return 0;
      else {
        if (diff > 0)
          return 1;
        else
          return -1;
      }
    });

    // create a dataset and give it a type
    LineDataSet set1 = new LineDataSet(entries, "DataSet 1");
    set1.setLineWidth(1.5);
    set1.setCircleRadius(4);

    // create a data object with the data sets
    controller.data = LineData.fromList(List()..add(set1));

    setState(() {});
  }
}
