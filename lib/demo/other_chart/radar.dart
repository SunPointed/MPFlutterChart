import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mp_flutter_chart/chart/mp/chart/radar_chart.dart';
import 'package:mp_flutter_chart/chart/mp/core/animator.dart';
import 'package:mp_flutter_chart/chart/mp/core/data/radar_data.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_interfaces/i_radar_data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_set/radar_data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/description.dart';
import 'package:mp_flutter_chart/chart/mp/core/entry/radar_entry.dart';
import 'package:mp_flutter_chart/chart/mp/core/enums/legend_horizontal_alignment.dart';
import 'package:mp_flutter_chart/chart/mp/core/enums/legend_orientation.dart';
import 'package:mp_flutter_chart/chart/mp/core/enums/legend_vertical_alignment.dart';
import 'package:mp_flutter_chart/chart/mp/core/util.dart';
import 'package:mp_flutter_chart/chart/mp/core/value_formatter/value_formatter.dart';

class OtherChartRadar extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return OtherChartRadarState();
  }
}

class OtherChartRadarState extends State<OtherChartRadar> {
  RadarChart _radarChart;
  RadarData _radarData;

  var random = Random(1);

  @override
  void initState() {
    _initRadarData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _initCandleChart();
    return Scaffold(
        appBar: AppBar(
            // Here we take the value from the MyHomePage object that was created by
            // the App.build method, and use it to set our appbar title.
            title: Text("Other Chart Radar")),
        body: Container(
            color: Color.fromARGB(255, 60, 65, 82),
            child: Stack(
              children: <Widget>[
                Positioned(
                  right: 0,
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: _radarChart,
                ),
              ],
            )));
  }

  void _initRadarData() {
    double mul = 80;
    double min = 20;
    int cnt = 5;

    List<RadarEntry> entries1 = List();
    List<RadarEntry> entries2 = List();

    // NOTE: The order of the entries when being added to the entries array determines their position around the center of
    // the chart.
    for (int i = 0; i < cnt; i++) {
      double val1 = (random.nextDouble() * mul) + min;
      entries1.add(RadarEntry(value: val1));

      double val2 = (random.nextDouble() * mul) + min;
      entries2.add(RadarEntry(value: val2));
    }

    RadarDataSet set1 = RadarDataSet(entries1, "Last Week");
    set1.setColor1(Color.fromARGB(255, 103, 110, 129));
    set1.setFillColor(Color.fromARGB(255, 103, 110, 129));
    set1.setDrawFilled(true);
    set1.setFillAlpha(180);
    set1.setLineWidth(2);
    set1.setDrawHighlightCircleEnabled(true);
    set1.setDrawHighlightIndicators(false);

    RadarDataSet set2 = RadarDataSet(entries2, "This Week");
    set2.setColor1(Color.fromARGB(255, 121, 162, 175));
    set2.setFillColor(Color.fromARGB(255, 121, 162, 175));
    set2.setDrawFilled(true);
    set2.setFillAlpha(180);
    set2.setLineWidth(2);
    set2.setDrawHighlightCircleEnabled(true);
    set2.setDrawHighlightIndicators(false);

    List<IRadarDataSet> sets = List();
    sets.add(set1);
    sets.add(set2);

    _radarData = RadarData.fromList(sets);
//    _radarData.setValueTypeface(tfLight);
    _radarData.setValueTextSize(8);
    _radarData.setDrawValues(false);
    _radarData.setValueTextColor(ColorUtils.WHITE);
  }

  void _initCandleChart() {
    var desc = Description();
    desc.setEnabled(false);
    _radarChart = RadarChart(_radarData, (painter) {
      painter
        ..setWebColor(ColorUtils.LTGRAY)
        ..setWebColorInner(ColorUtils.LTGRAY);
//      // create a custom MarkerView (extend MarkerView) and specify the layout
//      // to use for it
//      MarkerView mv =  RadarMarkerView(this, R.layout.radar_markerview);
//      mv.setChartView(chart); // For bounds control
//      chart.setMarker(mv); //

      painter.mXAxis
        ..setTextSize(9)
//      ..setTypeface(tf)
        ..setYOffset(0)
        ..setXOffset(0)
        ..setTextColor(ColorUtils.WHITE)
        ..setValueFormatter(A());

      painter.mYAxis
//      ..setTypeface(tf)
        ..setLabelCount2(5, false)
        ..setTextSize(9)
        ..setAxisMinimum(0)
        ..setAxisMaximum(80)
        ..setDrawLabels(false);

      painter.mLegend
        ..setVerticalAlignment(LegendVerticalAlignment.TOP)
        ..setHorizontalAlignment(LegendHorizontalAlignment.CENTER)
        ..setOrientation(LegendOrientation.HORIZONTAL)
        ..setDrawInside(false)
//      ..setTypeface(tf)
        ..setXEntrySpace(7)
        ..setYEntrySpace(5)
        ..setTextColor(ColorUtils.WHITE);

      painter.mAnimator.animateXY2(1400, 1400, Easing.EaseInOutQuad);
    },
        webLineWidth: 1.0,
        webAlpha: 100,
        innerWebLineWidth: 1.0,
        touchEnabled: true,
        desc: desc);
  }
}

class A extends ValueFormatter {
  final List<String> mActivities = List()
    ..add("Burger")
    ..add("Steak")
    ..add("Salad")
    ..add("Pasta")
    ..add("Pizza");

  @override
  String getFormattedValue1(double value) {
    return mActivities[value.toInt() % mActivities.length];
  }
}
