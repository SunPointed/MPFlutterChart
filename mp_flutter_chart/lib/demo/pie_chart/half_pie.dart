import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mp_chart/mp/chart/pie_chart.dart';
import 'package:mp_chart/mp/core/animator.dart';
import 'package:mp_chart/mp/core/data/pie_data.dart';
import 'package:mp_chart/mp/core/data_set/pie_data_set.dart';
import 'package:mp_chart/mp/core/description.dart';
import 'package:mp_chart/mp/core/entry/pie_entry.dart';
import 'package:mp_chart/mp/core/enums/legend_horizontal_alignment.dart';
import 'package:mp_chart/mp/core/enums/legend_orientation.dart';
import 'package:mp_chart/mp/core/enums/legend_vertical_alignment.dart';
import 'package:mp_chart/mp/core/image_loader.dart';
import 'package:mp_chart/mp/core/render/pie_chart_renderer.dart';
import 'package:mp_chart/mp/core/utils/color_utils.dart';
import 'package:mp_chart/mp/core/value_formatter/percent_formatter.dart';
import 'package:mp_flutter_chart/demo/action_state.dart';
import 'package:mp_flutter_chart/demo/util.dart';

class PieChartHalfPie extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return PieChartHalfPieState();
  }
}

class PieChartHalfPieState extends SimpleActionState<PieChartHalfPie> {
  PieChart _pieChart;
  PieData _pieData;

  var random = Random(1);

  @override
  void initState() {
    _initPieData();
    super.initState();
  }

  @override
  String getTitle() => "Pie Chart Half Pie";

  @override
  void chartInit() {
    _initPieChart();
  }

  @override
  Widget getBody() {
    return Stack(
      children: <Widget>[
        Positioned(
          right: 0,
          left: 0,
          top: 0,
          bottom: 0,
          child: _pieChart == null ? Center(child: Text("no data")) : _pieChart,
        )
      ],
    );
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

  PercentFormatter _formatter = PercentFormatter();

  void _initPieData() async {
    var img = await ImageLoader.loadImage('assets/img/star.png');
    var count = 4;
    var range = 100;

    List<PieEntry> values = List();

    for (int i = 0; i < count; i++) {
      values.add(new PieEntry(
          icon: img,
          value: ((random.nextDouble() * range) + range / 5),
          label: PARTIES[i % PARTIES.length]));
    }

    PieDataSet dataSet = PieDataSet(values, "Election Results");
    dataSet.setSliceSpace(3);
    dataSet.setSelectionShift(5);

    dataSet.setColors1(ColorUtils.MATERIAL_COLORS);
    //dataSet.setSelectionShift(0f);

    _pieData = PieData(dataSet)
      ..setValueFormatter(new PercentFormatter())
      ..setValueTextColor(ColorUtils.WHITE)
      ..setValueTypeface(Util.LIGHT);

    setState(() {});
  }

  void _initPieChart() {
    if (_pieData == null) return;

    if (_pieChart != null) {
      _pieChart.data = _pieData;
      _pieChart.getState()?.setStateIfNotDispose();
      return;
    }

    var desc = Description()..enabled = false;
    _pieChart = PieChart(_pieData, legendSettingFunction: (legend, chart) {
      _formatter.setPieChartPainter(chart);
      legend
        ..verticalAlignment = (LegendVerticalAlignment.TOP)
        ..horizontalAlignment = (LegendHorizontalAlignment.CENTER)
        ..orientation = (LegendOrientation.HORIZONTAL)
        ..drawInside = (false)
        ..xEntrySpace = (7)
        ..yEntrySpace = (0)
        ..yOffset = (0);
    }, rendererSettingFunction: (renderer) {
      (renderer as PieChartRenderer)
        ..setHoleColor(ColorUtils.WHITE)
        ..setTransparentCircleColor(ColorUtils.WHITE)
        ..setTransparentCircleAlpha(110)
        ..setEntryLabelColor(ColorUtils.WHITE)
        ..setEntryLabelTextSize(12);
    },
        rotateEnabled: false,
        drawHole: true,
        usePercentValues: true,
        drawCenterText: true,
        touchEnabled: true,
        highLightPerTapEnabled: true,
        dragDecelerationFrictionCoef: 0.95,
        maxAngle: 180,
        rawRotationAngle: 180,
        rotationAngle: 180,
        centerText: "half pie",
        centerTextOffsetX: 0,
        centerTextOffsetY: -20,
        centerTextTypeface: Util.LIGHT,
        entryLabelTypeface: Util.LIGHT,
        holeRadiusPercent: 58,
        transparentCircleRadiusPercent: 61,
        description: desc);
    _pieChart.animator.animateY2(1400, Easing.EaseInOutQuad);
  }
}
