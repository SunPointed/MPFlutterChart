import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mp_flutter_chart/chart/mp/chart/pie_chart.dart';
import 'package:mp_flutter_chart/chart/mp/core/animator.dart';
import 'package:mp_flutter_chart/chart/mp/core/data.dart';
import 'package:mp_flutter_chart/chart/mp/core/description.dart';
import 'package:mp_flutter_chart/chart/mp/core/format.dart';
import 'package:mp_flutter_chart/chart/mp/core/highlight.dart';
import 'package:mp_flutter_chart/chart/mp/core/legend.dart';
import 'package:mp_flutter_chart/chart/mp/listener.dart';
import 'package:mp_flutter_chart/chart/mp/poolable/point.dart';
import 'package:mp_flutter_chart/chart/mp/util.dart';

class PieChartBasic extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return PieChartBasicState();
  }
}

class PieChartBasicState extends State<PieChartBasic>
    implements OnChartValueSelectedListener {
  PieChart _pieChart;
  PieData _pieData;
  PercentFormatter _formatter = PercentFormatter();

  var random = Random(1);

  int _count = 4;
  double _range = 10.0;

  @override
  void initState() {
    _initPieData(_count, _range);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _initPieChart();
    return Scaffold(
        appBar: AppBar(
            // Here we take the value from the MyHomePage object that was created by
            // the App.build method, and use it to set our appbar title.
            title: Text("Pie Chart Basic")),
        body: Stack(
          children: <Widget>[
            Positioned(
              right: 0,
              left: 0,
              top: 0,
              bottom: 100,
              child: _pieChart,
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
                                max: 25,
                                onChanged: (value) {
                                  _count = value.toInt();
                                  _initPieData(_count, _range);
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
                                  _initPieData(_count, _range);
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

  final List<String> PARTIES = List()
    ..add("Party A")
    ..add("Party B")
    ..add("Party C")
    ..add("Party D")
    ..add("Party E")
    ..add("Party F")
    ..add("Party G")
    ..add("Party H")
    ..add("Party I")
    ..add("Party J")
    ..add("Party K")
    ..add("Party L")
    ..add("Party M")
    ..add("Party N")
    ..add("Party O")
    ..add("Party P")
    ..add("Party Q")
    ..add("Party R")
    ..add("Party S")
    ..add("Party T")
    ..add("Party U")
    ..add("Party V")
    ..add("Party W")
    ..add("Party X")
    ..add("Party Y")
    ..add("Party Z");

  void _initPieData(int count, double range) {
    List<PieEntry> entries = List();

    // NOTE: The order of the entries when being added to the entries array determines their position around the center of
    // the chart.
    for (int i = 0; i < count; i++) {
      entries.add(PieEntry(
        value: ((random.nextDouble() * range) + range / 5),
        label: PARTIES[i % PARTIES.length],
//          getResources().getDrawable(R.drawable.star)
      ));
    }

    PieDataSet dataSet = PieDataSet(entries, "Election Results");

    dataSet.setDrawIcons(false);

    dataSet.setSliceSpace(3);
    dataSet.setIconsOffset(MPPointF(0, 40));
    dataSet.setSelectionShift(5);

    // add a lot of colors

    List<Color> colors = List();

    for (Color c in ColorUtils.VORDIPLOM_COLORS) colors.add(c);

    for (Color c in ColorUtils.JOYFUL_COLORS) colors.add(c);

    for (Color c in ColorUtils.COLORFUL_COLORS) colors.add(c);

    for (Color c in ColorUtils.LIBERTY_COLORS) colors.add(c);

    for (Color c in ColorUtils.PASTEL_COLORS) colors.add(c);

    colors.add(ColorUtils.HOLO_BLUE);

    dataSet.setColors1(colors);
    //dataSet.setSelectionShift(0f);

    _pieData = PieData(dataSet);
    _pieData.setValueFormatter(_formatter);
    _pieData.setValueTextSize(11);
    _pieData.setValueTextColor(ColorUtils.WHITE);
//    data.setValueTypeface(tfLight);
  }

  void _initPieChart() {
    var desc = Description();
    desc.setEnabled(false);
    _pieChart = PieChart(_pieData, (painter) {
      _formatter.setPieChartPainter(painter);

      painter
        ..setCenterText(_generateCenterSpannableText())
//            ..setCenterTextTypeface(tf)
        ..setHoleColor(ColorUtils.WHITE)
        ..setTransparentCircleColor(ColorUtils.WHITE)
        ..setTransparentCircleAlpha(110)
        ..setHoleRadius(58.0)
        ..setTransparentCircleRadius(61)
        ..setDrawCenterText(true)
        ..mHighLightPerTapEnabled = true
        ..setOnChartValueSelectedListener(this)
        ..setEntryLabelColor(ColorUtils.WHITE)
        ..setEntryLabelTextSize(12);
//        ..highlightValues(null);
//          ..setEntryLabelTypeface(tf)

      painter.mLegend
        ..setVerticalAlignment(LegendVerticalAlignment.TOP)
        ..setHorizontalAlignment(LegendHorizontalAlignment.RIGHT)
        ..setOrientation(LegendOrientation.VERTICAL)
        ..setDrawInside(false)
        ..setXEntrySpace(7)
        ..setYEntrySpace(0)
        ..setYOffset(0);

      painter.mAnimator.animateY2(1400, Easing.EaseInOutQuad);
    },
        rotateEnabled: true,
        drawHole: true,
        extraLeftOffset: 5,
        extraTopOffset: 10,
        extraRightOffset: 5,
        extraBottomOffset: 5,
        usePercentValues: true,
        touchEnabled: true,
        dragDecelerationFrictionCoef: 0.95,
        desc: desc);
  }

  @override
  void onNothingSelected() {}

  @override
  void onValueSelected(Entry e, Highlight h) {}

  String _generateCenterSpannableText() {
    return "basic pie chart";
  }
}
