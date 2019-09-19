import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mp_flutter_chart/chart/mp/chart/line_chart.dart';
import 'package:mp_flutter_chart/chart/mp/core/data/line_data.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_interfaces/i_line_data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_provider/line_data_provider.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_set/line_data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/description.dart';
import 'package:mp_flutter_chart/chart/mp/core/entry/entry.dart';
import 'package:mp_flutter_chart/chart/mp/core/enums/axis_dependency.dart';
import 'package:mp_flutter_chart/chart/mp/core/fill_formatter/i_fill_formatter.dart';
import 'package:mp_flutter_chart/chart/mp/core/utils/color_utils.dart';
import 'package:mp_flutter_chart/chart/mp/painter/line_chart_painter.dart';
import 'package:mp_flutter_chart/demo/action_state.dart';

class LineChartFilled extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LineChartFilledState();
  }
}

class LineChartFilledState extends SimpleActionState<LineChartFilled> {
  LineChart _lineChart;
  LineData _lineData;
  var random = Random(1);

  int _count = 45;
  double _range = 100.0;

  @override
  void initState() {
    _initLineData(_count, _range);
    super.initState();
  }

  @override
  String getTitle() => "Line Chart Filled";

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
          child:
              _lineChart == null ? Center(child: Text("no data")) : _lineChart,
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

  void _initLineData(int count, double range) {
    List<Entry> values1 = new List();

    for (int i = 0; i < count; i++) {
      double val = (random.nextDouble() * range) + 50;
      values1.add(new Entry(x: i.toDouble(), y: val));
    }

    List<Entry> values2 = new List();

    for (int i = 0; i < count; i++) {
      double val = (random.nextDouble() * range) + 450;
      values2.add(new Entry(x: i.toDouble(), y: val));
    }

    LineDataSet set1, set2;

    // create a dataset and give it a type
    set1 = new LineDataSet(values1, "DataSet 1");

    set1.setAxisDependency(AxisDependency.LEFT);
    set1.setColor1(Color.fromARGB(255, 255, 241, 46));
    set1.setDrawCircles(false);
    set1.setLineWidth(2);
    set1.setCircleRadius(3);
    set1.setFillAlpha(255);
    set1.setDrawFilled(true);
    set1.setFillColor(ColorUtils.WHITE);
    set1.setHighLightColor(Color.fromARGB(255, 244, 117, 117));
    set1.setDrawCircleHole(false);
    set1.setFillFormatter(A());

    // create a dataset and give it a type
    set2 = new LineDataSet(values2, "DataSet 2");
    set2.setAxisDependency(AxisDependency.LEFT);
    set2.setColor1(Color.fromARGB(255, 255, 241, 46));
    set2.setDrawCircles(false);
    set2.setLineWidth(2);
    set2.setCircleRadius(3);
    set2.setFillAlpha(255);
    set2.setDrawFilled(true);
    set2.setFillColor(ColorUtils.WHITE);
    set2.setDrawCircleHole(false);
    set2.setHighLightColor(Color.fromARGB(255, 244, 117, 117));
    set2.setFillFormatter(B());

    // create a data object with the data sets
    _lineData = LineData.fromList(List()..add(set1)..add(set2));
    _lineData.setDrawValues(false);

    setState(() {});
  }

  Color _fillColor = Color.fromARGB(150, 51, 181, 229);

  void _initLineChart() {
    if (_lineData == null) return;

    if (_lineChart != null) {
      _lineChart?.data = _lineData;
      _lineChart?.getState()?.setStateIfNotDispose();
      return;
    }

    var desc = Description();
    desc.setEnabled(false);
    _lineChart = LineChart(_lineData, (painter) {
      painter.setGridBackgroundColor(_fillColor);
      painter.mLegend.setEnabled(false);
      painter.mXAxis.setEnabled(false);
      painter.mAxisLeft
        ..setAxisMaximum(900)
        ..setAxisMinimum(-250)
        ..setDrawAxisLine(false)
        ..setDrawZeroLine(false)
        ..setDrawGridLines(false);
      painter.mAxisRight.setEnabled(false);

      var formatter1 = painter.mData.getDataSetByIndex(0).getFillFormatter();
      if (formatter1 is A) {
        (formatter1 as A).setPainter(painter);
      }

      var formatter2 = painter.mData.getDataSetByIndex(1).getFillFormatter();
      if (formatter2 is B) {
        (formatter2 as B).setPainter(painter);
      }
    },
        drawBorders: true,
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

class B implements IFillFormatter {
  LineChartPainter _painter;

  void setPainter(LineChartPainter painter) {
    _painter = painter;
  }

  @override
  double getFillLinePosition(
      ILineDataSet dataSet, LineDataProvider dataProvider) {
    return _painter?.mAxisLeft?.getAxisMaximum();
  }
}
