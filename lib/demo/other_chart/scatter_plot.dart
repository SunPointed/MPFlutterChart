import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mp_flutter_chart/chart/mp/chart/scatter_chart.dart';
import 'package:mp_flutter_chart/chart/mp/core/data/scatter_data.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_interfaces/i_scatter_data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_set/scatter_data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/description.dart';
import 'package:mp_flutter_chart/chart/mp/core/entry/entry.dart';
import 'package:mp_flutter_chart/chart/mp/core/enums/legend_horizontal_alignment.dart';
import 'package:mp_flutter_chart/chart/mp/core/enums/legend_orientation.dart';
import 'package:mp_flutter_chart/chart/mp/core/enums/legend_vertical_alignment.dart';
import 'package:mp_flutter_chart/chart/mp/core/enums/scatter_shape.dart';
import 'package:mp_flutter_chart/chart/mp/core/highlight/highlight.dart';
import 'package:mp_flutter_chart/chart/mp/core/render/i_shape_renderer.dart';
import 'package:mp_flutter_chart/chart/mp/core/utils/color_utils.dart';
import 'package:mp_flutter_chart/chart/mp/core/utils/utils.dart';
import 'package:mp_flutter_chart/chart/mp/core/view_port.dart';
import 'package:mp_flutter_chart/chart/mp/core/common_interfaces.dart';

class OtherChartScatterPlot extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return OtherChartScatterPlotState();
  }
}

class OtherChartScatterPlotState extends State<OtherChartScatterPlot>
    implements OnChartValueSelectedListener {
  ScatterChart _scatterChart;
  ScatterData _scatterData;

  var random = Random(1);

  int _count = 45;
  double _range = 100.0;

  @override
  void initState() {
    _initScatterData(_count, _range);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _initScatterChart();
    return Scaffold(
        appBar: AppBar(
            // Here we take the value from the MyHomePage object that was created by
            // the App.build method, and use it to set our appbar title.
            title: Text("Other Chart Scatter Plot")),
        body: Stack(
          children: <Widget>[
            Positioned(
              right: 0,
              left: 0,
              top: 0,
              bottom: 100,
              child: _scatterChart,
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
                                  _initScatterData(_count, _range);
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
                                max: 200,
                                onChanged: (value) {
                                  _range = value;
                                  _initScatterData(_count, _range);
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

  void _initScatterData(int count, double range) {
    List<Entry> values1 = List();
    List<Entry> values2 = List();
    List<Entry> values3 = List();

    for (int i = 0; i < count; i++) {
      double val = (random.nextDouble() * range) + 3;
      values1.add(Entry(x: i.toDouble(), y: val));
    }

    for (int i = 0; i < count; i++) {
      double val = (random.nextDouble() * range) + 3;
      values2.add(Entry(x: i + 0.33, y: val));
    }

    for (int i = 0; i < count; i++) {
      double val = (random.nextDouble() * range) + 3;
      values3.add(Entry(x: i + 0.66, y: val));
    }

    // create a dataset and give it a type
    ScatterDataSet set1 = ScatterDataSet(values1, "DS 1");
    set1.setScatterShape(ScatterShape.SQUARE);
    set1.setColor1(ColorUtils.COLORFUL_COLORS[0]);
    ScatterDataSet set2 = ScatterDataSet(values2, "DS 2");
    set2.setScatterShape(ScatterShape.CIRCLE);
    set2.setScatterShapeHoleColor(ColorUtils.COLORFUL_COLORS[3]);
    set2.setScatterShapeHoleRadius(3);
    set2.setColor1(ColorUtils.COLORFUL_COLORS[1]);
    ScatterDataSet set3 = ScatterDataSet(values3, "DS 3");
    set3.setShapeRenderer(CustomScatterShapeRenderer());
    set3.setColor1(ColorUtils.COLORFUL_COLORS[2]);

    set1.setScatterShapeSize(8);
    set2.setScatterShapeSize(8);
    set3.setScatterShapeSize(8);

    List<IScatterDataSet> dataSets = List();
    dataSets.add(set1); // add the data sets
    dataSets.add(set2);
    dataSets.add(set3);

    // create a data object with the data sets
    _scatterData = ScatterData.fromList(dataSets);
//    _scatterData.setValueTypeface(tfLight);
  }

  void _initScatterChart() {
    var desc = Description();
    desc.setEnabled(false);
    _scatterChart = ScatterChart(_scatterData, (painter) {
      painter..setOnChartValueSelectedListener(this);

      painter.mLegend
        ..setVerticalAlignment(LegendVerticalAlignment.TOP)
        ..setHorizontalAlignment(LegendHorizontalAlignment.RIGHT)
        ..setOrientation(LegendOrientation.VERTICAL)
        ..setDrawInside(false)
//      ..setTypeface(tf)
        ..setXOffset(5);

      painter.mAxisLeft..setAxisMinimum(0);
//      ..setTypeface(tf)

      painter.mAxisRight.setEnabled(false);
      painter.mXAxis..setDrawGridLines(false);
//      ..setTypeface(tf)
    },
        touchEnabled: true,
        drawGridBackground: false,
        dragXEnabled: true,
        dragYEnabled: true,
        scaleXEnabled: true,
        scaleYEnabled: true,
        pinchZoomEnabled: true,
        maxVisibleCount: 200,
        maxHighlightDistance: 50,
        desc: desc);
  }

  @override
  void onNothingSelected() {}

  @override
  void onValueSelected(Entry e, Highlight h) {}
}

class CustomScatterShapeRenderer implements IShapeRenderer {
  @override
  void renderShape(
      Canvas c,
      IScatterDataSet dataSet,
      ViewPortHandler viewPortHandler,
      double posX,
      double posY,
      Paint renderPaint) {
    final double shapeHalf = dataSet.getScatterShapeSize() / 2;

    c.drawLine(Offset(posX - shapeHalf, posY - shapeHalf),
        Offset(posX + shapeHalf, posY + shapeHalf), renderPaint);
  }
}
