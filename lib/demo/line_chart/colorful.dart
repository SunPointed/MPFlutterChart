import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mp_flutter_chart/chart/mp/chart/line_chart.dart';
import 'package:mp_flutter_chart/chart/mp/core/data/line_data.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_set/line_data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/description.dart';
import 'package:mp_flutter_chart/chart/mp/core/entry/entry.dart';
import 'package:mp_flutter_chart/chart/mp/core/utils/color_utils.dart';
import 'package:mp_flutter_chart/demo/action_state.dart';

class LineChartColorful extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LineChartColorfulState();
  }
}

class LineChartColorfulState extends SimpleActionState<LineChartColorful> {
  List<LineChart> _lineCharts = List(4);
  List<LineData> _lineDatas = List(4);
  var random = Random(1);

  int _count = 36;
  double _range = 100.0;

  List<Color> _colors = List()
    ..add(Color.fromARGB(255, 137, 230, 81))
    ..add(Color.fromARGB(255, 240, 240, 30))
    ..add(Color.fromARGB(255, 89, 199, 250))
    ..add(Color.fromARGB(255, 250, 104, 104));

  @override
  void initState() {
    _initLineData(_count, _range);
    super.initState();
  }

  @override
  String getTitle() => "Line Chart Colorful";

  @override
  void chartInit() {
    _initLineChart();
  }

  @override
  Widget getBody() {
    return Stack(
      children: <Widget>[
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          bottom: 0,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(child: _lineCharts[0]),
              Expanded(child: _lineCharts[1]),
              Expanded(child: _lineCharts[2]),
              Expanded(child: _lineCharts[3]),
            ],
          ),
        )
      ],
    );
  }

  void _initLineData(int count, double range) {
//    Typeface mTf = Typeface.createFromAsset(getAssets(), "OpenSans-Bold.ttf");
    for (int i = 0; i < _lineDatas.length; i++) {
      _lineDatas[i] = _getData(36, 100);
//      data.setValueTypeface(mTf);
    }
  }

  LineData _getData(int count, double range) {
    List<Entry> values = List();

    for (int i = 0; i < count; i++) {
      double val = (random.nextDouble() * range) + 3;
      values.add(new Entry(x: i.toDouble(), y: val));
    }

    // create a dataset and give it a type
    LineDataSet set1 = new LineDataSet(values, "DataSet 1");
    // set1.setFillAlpha(110);
    // set1.setFillColor(Color.RED);

    set1.setLineWidth(1.75);
    set1.setCircleRadius(5);
    set1.setCircleHoleRadius(2.5);
    set1.setColor1(ColorUtils.WHITE);
    set1.setCircleColor(ColorUtils.WHITE);
    set1.setHighLightColor(ColorUtils.WHITE);
    set1.setDrawValues(false);

    // create a data object with the data sets
    return LineData.fromList(List()..add(set1));
  }

  void _initLineChart() {
    for (int i = 0; i < _lineDatas.length; i++) {
      // add some transparency to the color with "& 0x90FFFFFF"
      _lineCharts[i] = _setupChart(_lineDatas[i], _colors[i % _colors.length]);
    }
  }

  LineChart _setupChart(LineData data, Color color) {
    (data.getDataSetByIndex(0) as LineDataSet).setCircleHoleColor(color);

    var desc = Description();
    return LineChart(data, (painter) {
      (data.getDataSetByIndex(0) as LineDataSet).setCircleHoleColor(color);

      // no description text
      painter
        ..mDescription.setEnabled(false)
        ..setGridBackgroundColor(color)
        ..setViewPortOffsets(0, 0, 0, 0);

      painter.mLegend.setEnabled(false);

      painter.mAxisLeft
        ..setEnabled(false)
        ..setSpaceTop(40)
        ..setSpaceBottom(40);
      painter.mAxisRight.setEnabled(false);
      painter.mXAxis.setEnabled(false);

      // animate calls invalidate()...
      painter.mAnimator.animateX1(2500);
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
