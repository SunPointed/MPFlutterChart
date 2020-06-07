import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:mp_chart/mp/chart/line_chart.dart';
import 'package:mp_chart/mp/controller/line_chart_controller.dart';
import 'package:mp_chart/mp/core/common_interfaces.dart';
import 'package:mp_chart/mp/core/data/line_data.dart';
import 'package:mp_chart/mp/core/data_interfaces/i_line_data_set.dart';
import 'package:mp_chart/mp/core/data_set/line_data_set.dart';
import 'package:mp_chart/mp/core/description.dart';
import 'package:mp_chart/mp/core/entry/entry.dart';
import 'package:mp_chart/mp/core/enums/legend_horizontal_alignment.dart';
import 'package:mp_chart/mp/core/enums/legend_orientation.dart';
import 'package:mp_chart/mp/core/enums/legend_vertical_alignment.dart';
import 'package:mp_chart/mp/core/highlight/highlight.dart';
import 'package:mp_chart/mp/core/image_loader.dart';
import 'package:mp_chart/mp/core/utils/color_utils.dart';
import 'package:example/demo/action_state.dart';

class LineChartMultiple extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LineChartMultipleState();
  }
}

class LineChartMultipleState extends LineActionState<LineChartMultiple>
    implements OnChartValueSelectedListener, OnChartGestureListener {
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
        "VAL SELECTED Value: ${e.y}, xIndex: ${e.x}, DataSet index: ${h.dataSetIndex}");
  }

  @override
  void initState() {
    _initController();
    _initLineData(_count, _range);
    super.initState();
  }

  @override
  String getTitle() => "Line Chart Multiple";

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

  void _initController() {
    var desc = Description()..enabled = false;
    controller = LineChartController(
        axisLeftSettingFunction: (axisLeft, controller) {
          axisLeft.enabled = (false);
        },
        axisRightSettingFunction: (axisRight, controller) {
          axisRight
            ..drawAxisLine = (false)
            ..drawGridLines = (false);
        },
        legendSettingFunction: (legend, controller) {
          legend
            ..verticalAlignment = (LegendVerticalAlignment.TOP)
            ..horizontalAlignment = (LegendHorizontalAlignment.RIGHT)
            ..orientation = (LegendOrientation.VERTICAL)
            ..drawInside = (false);
        },
        xAxisSettingFunction: (xAxis, controller) {
          xAxis
            ..drawAxisLine = (false)
            ..drawGridLines = (false);
        },
        drawGridBackground: false,
        backgroundColor: ColorUtils.WHITE,
        dragXEnabled: true,
        dragYEnabled: true,
        scaleXEnabled: true,
        scaleYEnabled: true,
        pinchZoomEnabled: false,
//        selectionListener: this,
        drawBorders: false,
        description: desc);
  }

  void _initLineData(int count, double range) async {
    List<ui.Image> imgs = List(3);
    imgs[0] = await ImageLoader.loadImage('assets/img/star.png');
    imgs[1] = await ImageLoader.loadImage('assets/img/add.png');
    imgs[2] = await ImageLoader.loadImage('assets/img/close.png');
    List<ILineDataSet> dataSets = List();

    for (int z = 0; z < 3; z++) {
      List<Entry> values = List();

      for (int i = 0; i < count; i++) {
        double val = (random.nextDouble() * range) + 3;
        values.add(new Entry(x: i.toDouble(), y: val, icon: imgs[z]));
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
    (dataSets[0] as LineDataSet).enableDashedLine(10, 10, 0);
    (dataSets[0] as LineDataSet).setColors1(ColorUtils.VORDIPLOM_COLORS);
    (dataSets[0] as LineDataSet).setCircleColors(ColorUtils.VORDIPLOM_COLORS);

    controller.data = LineData.fromList(dataSets);

    setState(() {});
  }
}
