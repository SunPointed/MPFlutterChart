import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mp_flutter_chart/chart/mp/chart/combined_chart.dart';
import 'package:mp_flutter_chart/chart/mp/core/axis.dart';
import 'package:mp_flutter_chart/chart/mp/core/data.dart';
import 'package:mp_flutter_chart/chart/mp/core/description.dart';
import 'package:mp_flutter_chart/chart/mp/core/format.dart';
import 'package:mp_flutter_chart/chart/mp/core/legend.dart';
import 'package:mp_flutter_chart/chart/mp/mode.dart';
import 'package:mp_flutter_chart/chart/mp/painter/combined_chart_painter.dart';
import 'package:mp_flutter_chart/chart/mp/util.dart';

class OtherChartCombined extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return OtherChartCombinedState();
  }
}

class OtherChartCombinedState extends State<OtherChartCombined> {
  CombinedChart _combinedChart;
  CombinedData _combinedData;
  int _count = 12;
  var random = Random(1);

  @override
  void initState() {
    _initCombinedData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _initCombinedChart();
    return Scaffold(
        appBar: AppBar(
            // Here we take the value from the MyHomePage object that was created by
            // the App.build method, and use it to set our appbar title.
            title: Text("Other Chart Combined")),
        body: Stack(
          children: <Widget>[
            Positioned(
              right: 0,
              left: 0,
              top: 0,
              bottom: 0,
              child: _combinedChart,
            ),
          ],
        ));
  }

  void _initCombinedData() {
    _combinedData = CombinedData();
    _combinedData.setData1(generateLineData());
    _combinedData.setData2(generateBarData());
    _combinedData.setData5(generateBubbleData());
    _combinedData.setData3(generateScatterData());
    _combinedData.setData4(generateCandleData());
//    data.setValueTypeface(tfLight);
  }

  void _initCombinedChart() {
    var desc = Description();
    desc.setEnabled(false);
    _combinedChart = CombinedChart(_combinedData, (painter) {
      painter
        ..setDrawOrder(List()
          ..add(DrawOrder.BAR)
          ..add(DrawOrder.BUBBLE)
          ..add(DrawOrder.CANDLE)
          ..add(DrawOrder.LINE)
          ..add(DrawOrder.SCATTER));

      painter.mLegend
        ..setWordWrapEnabled(true)
        ..setVerticalAlignment(LegendVerticalAlignment.BOTTOM)
        ..setHorizontalAlignment(LegendHorizontalAlignment.CENTER)
        ..setOrientation(LegendOrientation.HORIZONTAL)
        ..setDrawInside(false);

      painter.mAxisRight
        ..setDrawGridLines(false)
        ..setAxisMinimum(0);

      painter.mAxisLeft
        ..setDrawGridLines(false)
        ..setAxisMinimum(0);

      painter.mXAxis
        ..setPosition(XAxisPosition.BOTH_SIDED)
        ..setAxisMinimum(0)
        ..setGranularity(1)
        ..setValueFormatter(A())
        ..setAxisMaximum(
            _combinedData == null ? 0 : _combinedData.getXMax() + 0.25);
    },
        drawGridBackground: false,
        drawBarShadow: false,
        highlightFullBarEnabled: false,
        touchEnabled: true,
        dragXEnabled: true,
        dragYEnabled: true,
        scaleXEnabled: true,
        scaleYEnabled: true,
        pinchZoomEnabled: false,
        maxVisibleCount: 60,
        desc: desc);
  }

  double getRandom(double range, double start) {
    return (random.nextDouble() * range) + start;
  }

  LineData generateLineData() {
    LineData d = LineData();

    List<Entry> entries = List();

    for (int index = 0; index < _count; index++)
      entries.add(Entry(x: index + 0.5, y: getRandom(15, 5)));

    LineDataSet set = LineDataSet(entries, "Line DataSet");
    set.setColor1(Color.fromARGB(255, 240, 238, 70));
    set.setLineWidth(2.5);
    set.setCircleColor(Color.fromARGB(255, 240, 238, 70));
    set.setCircleRadius(5);
    set.setFillColor(Color.fromARGB(255, 240, 238, 70));
    set.setMode(Mode.CUBIC_BEZIER);
    set.setDrawValues(true);
    set.setValueTextSize(10);
    set.setValueTextColor(Color.fromARGB(255, 240, 238, 70));

    set.setAxisDependency(AxisDependency.LEFT);
    d.addDataSet(set);

    return d;
  }

  BarData generateBarData() {
    List<BarEntry> entries1 = List();
    List<BarEntry> entries2 = List();

    for (int index = 0; index < _count; index++) {
      entries1.add(BarEntry(x: 0, y: getRandom(25, 25)));

      // stacked
      entries2.add(BarEntry.fromListYVals(
          x: 0,
          vals: List<double>()
            ..add(getRandom(13, 12))
            ..add(getRandom(13, 12))));
    }

    BarDataSet set1 = BarDataSet(entries1, "Bar 1");
    set1.setColor1(Color.fromARGB(255, 60, 220, 78));
    set1.setValueTextColor(Color.fromARGB(255, 60, 220, 78));
    set1.setValueTextSize(10);
    set1.setAxisDependency(AxisDependency.LEFT);

    BarDataSet set2 = BarDataSet(entries2, "");
    set2.setStackLabels(List<String>()..add("Stack 1")..add("Stack 2"));
    set2.setColors1(List<Color>()
      ..add(Color.fromARGB(255, 61, 165, 255))
      ..add(Color.fromARGB(255, 23, 197, 255)));
    set2.setValueTextColor(Color.fromARGB(255, 61, 165, 255));
    set2.setValueTextSize(10);
    set2.setAxisDependency(AxisDependency.LEFT);

    double groupSpace = 0.06;
    double barSpace = 0.02; // x2 dataset
    double barWidth = 0.45; // x2 dataset
    // (0.45 + 0.02) * 2 + 0.06 = 1.00 -> interval per "group"

    BarData d = BarData(List()..add(set1)..add(set2));
    d.setBarWidth(barWidth);

    // make this BarData object grouped
    d.groupBars(0, groupSpace, barSpace); // start at x = 0

    return d;
  }

  ScatterData generateScatterData() {
    ScatterData d = ScatterData();

    List<Entry> entries = List();

    for (double index = 0; index < _count; index += 0.5)
      entries.add(Entry(x: index + 0.25, y: getRandom(10, 55)));

    ScatterDataSet set = ScatterDataSet(entries, "Scatter DataSet");
    set.setColors1(ColorUtils.MATERIAL_COLORS);
    set.setScatterShapeSize(7.5);
    set.setDrawValues(false);
    set.setValueTextSize(10);
    d.addDataSet(set);

    return d;
  }

  CandleData generateCandleData() {
    CandleData d = CandleData();

    List<CandleEntry> entries = List();

    for (int index = 0; index < _count; index += 2)
      entries.add(CandleEntry(
          x: index + 1.0, shadowH: 90, shadowL: 70, open: 85, close: 75));

    CandleDataSet set = CandleDataSet(entries, "Candle DataSet");
    set.setDecreasingColor(Color.fromARGB(255, 142, 150, 175));
    set.setShadowColor(ColorUtils.DKGRAY);
    set.setBarSpace(0.3);
    set.setValueTextSize(10);
    set.setDrawValues(false);
    d.addDataSet(set);

    return d;
  }

  BubbleData generateBubbleData() {
    BubbleData bd = BubbleData();

    List<BubbleEntry> entries = List();

    for (int index = 0; index < _count; index++) {
      double y = getRandom(10, 105);
      double size = getRandom(100, 105);
      entries.add(BubbleEntry(x: index + 0.5, y: y, size: size));
    }

    BubbleDataSet set = BubbleDataSet(entries, "Bubble DataSet");
    set.setColors1(ColorUtils.VORDIPLOM_COLORS);
    set.setValueTextSize(10);
    set.setValueTextColor(ColorUtils.WHITE);
    set.setHighlightCircleWidth(1.5);
    set.setDrawValues(true);
    bd.addDataSet(set);

    return bd;
  }
}

final List<String> months = List()
  ..add("Jan")
  ..add("Feb")
  ..add("Mar")
  ..add("Apr")
  ..add("May")
  ..add("Jun")
  ..add("Jul")
  ..add("Aug")
  ..add("Sep")
  ..add("Okt")
  ..add("Nov")
  ..add("Dec");

class A extends ValueFormatter {
  @override
  String getFormattedValue1(double value) {
    return months[value.toInt() % months.length];
  }
}
