import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mp_flutter_chart/chart/mp/chart/line_chart.dart';
import 'package:mp_flutter_chart/chart/mp/core/data/line_data.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_interfaces/i_line_data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_provider/line_data_provider.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_set/line_data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/description.dart';
import 'package:mp_flutter_chart/chart/mp/core/entry/entry.dart';
import 'package:mp_flutter_chart/chart/mp/core/enums/mode.dart';
import 'package:mp_flutter_chart/chart/mp/core/enums/y_axis_label_position.dart';
import 'package:mp_flutter_chart/chart/mp/core/fill_formatter/i_fill_formatter.dart';
import 'package:mp_flutter_chart/chart/mp/core/image_loader.dart';
import 'package:mp_flutter_chart/chart/mp/core/utils/color_utils.dart';
import 'package:mp_flutter_chart/chart/mp/painter/line_chart_painter.dart';
import 'package:mp_flutter_chart/demo/action_state.dart';

class LineChartCubic extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LineChartCubicState();
  }
}

class LineChartCubicState extends LineActionState<LineChartCubic> {
  var random = Random(1);
  int _count = 45;
  double _range = 100.0;

  @override
  void initState() {
    _initLineData(_count, _range);
    super.initState();
  }

  @override
  String getTitle() => "Line Chart Cubic";

  @override
  void chartInit() {
    _initLineChart();
  }

  @override
  Widget getBody() {
    return Stack(
      children: <Widget>[
        Positioned(
          right: 0,
          left: 0,
          top: 0,
          bottom: 100,
          child: lineChart == null ? Center(child: Text("no data")) : lineChart,
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
                            max: 700,
                            onChanged: (value) {
                              _count = value.toInt();
                              _initLineData(_count, _range);
                              setState(() {});
                            })),
                  ),
                  Container(
                      padding: EdgeInsets.only(right: 15.0),
                      child: Text(
                        "$_count",
                        textDirection: TextDirection.ltr,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: ColorUtils.BLACK,
                            fontSize: 12,
                            fontWeight: FontWeight.bold),
                      )),
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
                              setState(() {});
                            })),
                  ),
                  Container(
                      padding: EdgeInsets.only(right: 15.0),
                      child: Text(
                        "${_range.toInt()}",
                        textDirection: TextDirection.ltr,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: ColorUtils.BLACK,
                            fontSize: 12,
                            fontWeight: FontWeight.bold),
                      )),
                ],
              )
            ],
          ),
        )
      ],
    );
  }

  void _initLineData(int count, double range) async {
    var img = await ImageLoader.loadImage('assets/img/star.png');
    List<Entry> values = List();

    for (int i = 0; i < count; i++) {
      double val = (random.nextDouble() * (range + 1)) + 20;
      values.add(Entry(x: i.toDouble(), y: val, icon: img));
    }

    LineDataSet set1;
    // create a dataset and give it a type
    set1 = LineDataSet(values, "DataSet 1");

    set1.setMode(Mode.CUBIC_BEZIER);
    set1.setCubicIntensity(0.2);
    set1.setDrawFilled(true);
    set1.setDrawCircles(false);
    set1.setLineWidth(1.8);
    set1.setCircleRadius(4);
    set1.setCircleColor(ColorUtils.WHITE);
    set1.setHighLightColor(Color.fromARGB(255, 244, 117, 117));
    set1.setColor1(ColorUtils.WHITE);
    set1.setFillColor(ColorUtils.WHITE);
    set1.setFillAlpha(100);
    set1.setDrawHorizontalHighlightIndicator(false);
    set1.setFillFormatter(A());

    // create a data object with the data sets
    lineData = LineData.fromList(List()..add(set1))
//    ..setValueTypeface(tfLight)
      ..setValueTextSize(9)
      ..setDrawValues(false);

    setState(() {});
  }

  void _initLineChart() {
    if (lineData == null) return;

    var desc = Description();
    desc.setEnabled(false);
    lineChart = LineChart(lineData, (painter) {
      painter
        ..setViewPortOffsets(0, 0, 0, 0)
        ..setGridBackgroundColor(Color.fromARGB(255, 104, 241, 175));

      painter.mXAxis.setEnabled(false);

      painter.mAxisLeft
//      ..setTypeface(tf)
        ..setLabelCount2(6, false)
        ..setTextColor(ColorUtils.WHITE)
        ..setPosition(YAxisLabelPosition.INSIDE_CHART)
        ..setDrawGridLines(false)
        ..setAxisLineColor(ColorUtils.WHITE);

      painter.mAxisRight.setEnabled(false);

      painter.mLegend.setEnabled(false);

      var formatter = painter.mData.getDataSetByIndex(0).getFillFormatter();
      if (formatter is A) {
        (formatter as A).setPainter(painter);
      }

      painter.mAnimator.animateXY1(2000, 2000);
    },
        touchEnabled: true,
        drawGridBackground: true,
        dragXEnabled: true,
        dragYEnabled: true,
        scaleXEnabled: true,
        scaleYEnabled: true,
        pinchZoomEnabled: false,
        desc: desc);
  }
}

class A implements IFillFormatter {
  LineChartPainter _painter;

  void setPainter(LineChartPainter painter) {
    _painter = painter;
  }

  @override
  double getFillLinePosition(
      ILineDataSet dataSet, LineDataProvider dataProvider) {
    return _painter?.mAxisLeft?.getAxisMinimum();
  }
}
