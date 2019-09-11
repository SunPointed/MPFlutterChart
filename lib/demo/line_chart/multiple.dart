import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mp_flutter_chart/chart/mp/chart/line_chart.dart';
import 'package:mp_flutter_chart/chart/mp/core/data/line_data.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_interfaces/i_line_data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_set/line_data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/description.dart';
import 'package:mp_flutter_chart/chart/mp/core/entry/entry.dart';
import 'package:mp_flutter_chart/chart/mp/core/enums/legend_horizontal_alignment.dart';
import 'package:mp_flutter_chart/chart/mp/core/enums/legend_orientation.dart';
import 'package:mp_flutter_chart/chart/mp/core/enums/legend_vertical_alignment.dart';
import 'package:mp_flutter_chart/chart/mp/core/highlight/highlight.dart';
import 'package:mp_flutter_chart/chart/mp/core/utils/color_utils.dart';
import 'package:mp_flutter_chart/chart/mp/core/common_interfaces.dart';

class LineChartMultiple extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LineChartMultipleState();
  }
}

class LineChartMultipleState extends State<LineChartMultiple>
    implements OnChartValueSelectedListener, OnChartGestureListener {
  LineChart _lineChart;
  LineData _lineData;
  var random = Random(1);

  int _count = 20;
  double _range = 100.0;

  List<Color> colors = List()
    ..add(ColorUtils.VORDIPLOM_COLORS[0])
    ..add(ColorUtils.VORDIPLOM_COLORS[1])
    ..add(ColorUtils.VORDIPLOM_COLORS[2]);

  @override
  void onChartDoubleTapped(double positionX, double positionY) {
    print("Chart double-tapped.");
  }

  @override
  void onChartScale(
      double positionX, double positionY, double scaleX, double scaleY) {
    print("ScaleX: $scaleX, ScaleY: $scaleY");
  }

  @override
  void onChartSingleTapped(double positionX, double positionY) {
    print("Chart single-tapped.");
  }

  @override
  void onChartTranslate(
      double positionX, double positionY, double dX, double dY) {
    print("dX: $dX, dY: $dY");
  }

  @override
  void onNothingSelected() {}

  @override
  void onValueSelected(Entry e, Highlight h) {
    print(
        "VAL SELECTED Value: ${e.y}, xIndex: ${e.x}, DataSet index: ${h.getDataSetIndex()}");
  }

  @override
  void initState() {
    _initLineData(_count, _range);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _initLineChart();
    return Scaffold(
        appBar: AppBar(
            // Here we take the value from the MyHomePage object that was created by
            // the App.build method, and use it to set our appbar title.
            title: Text("Line Chart Multiple")),
        body: Stack(
          children: <Widget>[
            Positioned(
              right: 0,
              left: 0,
              top: 0,
              bottom: 100,
              child: _lineChart,
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
                                max: 500,
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
        ));
  }

  void _initLineData(int count, double range) {
    List<ILineDataSet> dataSets = List();

    for (int z = 0; z < 3; z++) {
      List<Entry> values = List();

      for (int i = 0; i < count; i++) {
        double val = (random.nextDouble() * range) + 3;
        values.add(new Entry(x: i.toDouble(), y: val));
      }

      LineDataSet d = new LineDataSet(values, "DataSet ${z + 1}");
      d.setLineWidth(2.5);
      d.setCircleRadius(4);
      d.setCircleHoleRadius(3);

      Color color = colors[z % colors.length];
      d.setColor1(color);
      d.setCircleColor(color);
      dataSets.add(d);
    }

    // make the first DataSet dashed
//    (dataSets[0] as LineDataSet).enableDashedLine(10, 10, 0);
    (dataSets[0] as LineDataSet).setColors1(ColorUtils.VORDIPLOM_COLORS);
    (dataSets[0] as LineDataSet).setCircleColors(ColorUtils.VORDIPLOM_COLORS);

    _lineData = LineData.fromList(dataSets);
  }

  void _initLineChart() {
    var desc = Description();
    _lineChart = LineChart(_lineData, (painter) {
      painter.setOnChartValueSelectedListener(this);
      painter.setOnChartGestureListener(this);
      painter
        ..mDrawGridBackground = false
        ..mDescription.setEnabled(false)
        ..mDrawBorders = false
        ..mTouchEnabled = true
        ..mDragXEnabled = true
        ..mDragYEnabled = true
        ..mScaleYEnabled = true
        ..mScaleXEnabled = true
        ..mPinchZoomEnabled = false;

      painter.mAxisLeft.setEnabled(false);
      painter.mAxisRight
        ..setDrawAxisLine(false)
        ..setDrawGridLines(false);
      painter.mXAxis
        ..setDrawAxisLine(false)
        ..setDrawGridLines(false);

      painter.mLegend
        ..setVerticalAlignment(LegendVerticalAlignment.TOP)
        ..setHorizontalAlignment(LegendHorizontalAlignment.RIGHT)
        ..setOrientation(LegendOrientation.VERTICAL)
        ..setDrawInside(false);
    },
        touchEnabled: true,
        drawGridBackground: false,
        dragXEnabled: true,
        dragYEnabled: true,
        scaleXEnabled: true,
        scaleYEnabled: true,
        pinchZoomEnabled: true,
        desc: desc);
  }
}
