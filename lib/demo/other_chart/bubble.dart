import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mp_flutter_chart/chart/mp/chart/bubble_chart.dart';
import 'package:mp_flutter_chart/chart/mp/core/data/bubble_data.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_interfaces/i_bubble_data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_set/bubble_data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/description.dart';
import 'package:mp_flutter_chart/chart/mp/core/entry/bubble_entry.dart';
import 'package:mp_flutter_chart/chart/mp/core/entry/entry.dart';
import 'package:mp_flutter_chart/chart/mp/core/enums/legend_horizontal_alignment.dart';
import 'package:mp_flutter_chart/chart/mp/core/enums/legend_orientation.dart';
import 'package:mp_flutter_chart/chart/mp/core/enums/legend_vertical_alignment.dart';
import 'package:mp_flutter_chart/chart/mp/core/enums/x_axis_position.dart';
import 'package:mp_flutter_chart/chart/mp/core/highlight/highlight.dart';
import 'package:mp_flutter_chart/chart/mp/core/poolable/point.dart';
import 'package:mp_flutter_chart/chart/mp/listener.dart';
import 'package:mp_flutter_chart/chart/mp/core/util.dart';

class OtherChartBubble extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return OtherChartBubbleState();
  }
}

class OtherChartBubbleState extends State<OtherChartBubble>
    implements OnChartValueSelectedListener {
  BubbleChart _bubbleChart;
  BubbleData _bubbleData;

  var random = Random(1);

  int _count = 10;
  double _range = 50.0;

  @override
  void initState() {
    _initBubbleData(_count, _range);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _initBubbleChart();
    return Scaffold(
        appBar: AppBar(
            // Here we take the value from the MyHomePage object that was created by
            // the App.build method, and use it to set our appbar title.
            title: Text("Other Chart Bubble")),
        body: Stack(
          children: <Widget>[
            Positioned(
              right: 0,
              left: 0,
              top: 0,
              bottom: 100,
              child: _bubbleChart,
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
                                max: 100,
                                onChanged: (value) {
                                  _count = value.toInt();
                                  _initBubbleData(_count, _range);
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
                                  _initBubbleData(_count, _range);
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

  void _initBubbleData(int count, double range) {
    List<BubbleEntry> values1 = List();
    List<BubbleEntry> values2 = List();
    List<BubbleEntry> values3 = List();

    for (int i = 0; i < count; i++) {
      values1.add(BubbleEntry(
          x: i.toDouble(),
          y: (random.nextDouble() * range),
          size: (random.nextDouble() * range)));
      values2.add(BubbleEntry(
          x: i.toDouble(),
          y: (random.nextDouble() * range),
          size: (random.nextDouble() * range)));
      values3.add(BubbleEntry(
          x: i.toDouble(),
          y: (random.nextDouble() * range),
          size: (random.nextDouble() * range)));
    }

    // create a dataset and give it a type
    BubbleDataSet set1 = BubbleDataSet(values1, "DS 1");
    set1.setDrawIcons(false);
    set1.setColor3(ColorUtils.COLORFUL_COLORS[0], 130);
    set1.setDrawValues(true);

    BubbleDataSet set2 = BubbleDataSet(values2, "DS 2");
    set2.setDrawIcons(false);
    set2.setIconsOffset(MPPointF(0, 15));
    set2.setColor3(ColorUtils.COLORFUL_COLORS[1], 130);
    set2.setDrawValues(true);

    BubbleDataSet set3 = BubbleDataSet(values3, "DS 3");
    set3.setColor3(ColorUtils.COLORFUL_COLORS[2], 130);
    set3.setDrawValues(true);

    List<IBubbleDataSet> dataSets = List();
    dataSets.add(set1); // add the data sets
    dataSets.add(set2);
    dataSets.add(set3);

    // create a data object with the data sets
    _bubbleData = BubbleData.fromList(dataSets);
    _bubbleData.setDrawValues(false);
//    _bubbleData.setValueTypeface(tfLight);
    _bubbleData.setValueTextSize(8);
    _bubbleData.setValueTextColor(ColorUtils.WHITE);
    _bubbleData.setHighlightCircleWidth(1.5);
  }

  void _initBubbleChart() {
    var desc = Description();
    desc.setEnabled(false);
    _bubbleChart = BubbleChart(_bubbleData, (painter) {
      painter..setOnChartValueSelectedListener(this);

      painter.mLegend
        ..setVerticalAlignment(LegendVerticalAlignment.TOP)
        ..setHorizontalAlignment(LegendHorizontalAlignment.RIGHT)
        ..setOrientation(LegendOrientation.VERTICAL)
        ..setDrawInside(false);
//      ..setTypeface(tf)

      painter.mAxisLeft
        ..setSpaceTop(30)
        ..setSpaceBottom(30)
//      ..setTypeface(tf)
        ..setDrawZeroLine(false);

      painter.mAxisRight.setEnabled(false);

      painter.mXAxis..setPosition(XAxisPosition.BOTTOM);
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
        desc: desc);
  }

  @override
  void onNothingSelected() {}

  @override
  void onValueSelected(Entry e, Highlight h) {}
}
