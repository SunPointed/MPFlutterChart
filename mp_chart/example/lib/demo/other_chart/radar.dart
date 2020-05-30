import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mp_chart/mp/chart/radar_chart.dart';
import 'package:mp_chart/mp/controller/radar_chart_controller.dart';
import 'package:mp_chart/mp/core/animator.dart';
import 'package:mp_chart/mp/core/data/radar_data.dart';
import 'package:mp_chart/mp/core/data_interfaces/i_radar_data_set.dart';
import 'package:mp_chart/mp/core/data_set/radar_data_set.dart';
import 'package:mp_chart/mp/core/description.dart';
import 'package:mp_chart/mp/core/entry/radar_entry.dart';
import 'package:mp_chart/mp/core/enums/legend_horizontal_alignment.dart';
import 'package:mp_chart/mp/core/enums/legend_orientation.dart';
import 'package:mp_chart/mp/core/enums/legend_vertical_alignment.dart';
import 'package:mp_chart/mp/core/image_loader.dart';
import 'package:mp_chart/mp/core/utils/color_utils.dart';
import 'package:mp_chart/mp/core/utils/utils.dart';
import 'package:mp_chart/mp/core/value_formatter/value_formatter.dart';
import 'package:example/demo/action_state.dart';
import 'package:example/demo/util.dart';

class OtherChartRadar extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return OtherChartRadarState();
  }
}

class OtherChartRadarState extends RadarActionState<OtherChartRadar> {
  var random = Random(1);

  @override
  void initState() {
    _initController();
    _initRadarData();
    super.initState();
  }

  @override
  String getTitle() => "Other Chart Radar";

  @override
  Widget getBody() {
    return Container(
        color: Color.fromARGB(255, 60, 65, 82),
        child: Stack(
          children: <Widget>[
            Positioned(
                right: 0,
                left: 0,
                top: 0,
                bottom: 0,
                child: _initCandleChart()),
          ],
        ));
  }

  void _initController() {
    var desc = Description()..enabled = false;
    controller = RadarChartController(
        yAxisSettingFunction: (yAxis, controller) {
          yAxis
            ..typeface = Util.LIGHT
            ..setLabelCount2(5, false)
            ..textSize = (9)
            ..setAxisMinimum(0)
            ..setAxisMaximum(80)
            ..drawLabels = (false);
        },
        legendSettingFunction: (legend, controller) {
          legend
            ..verticalAlignment = (LegendVerticalAlignment.TOP)
            ..horizontalAlignment = (LegendHorizontalAlignment.CENTER)
            ..orientation = (LegendOrientation.HORIZONTAL)
            ..drawInside = (false)
            ..typeface = Util.LIGHT
            ..xEntrySpace = (7)
            ..yEntrySpace = (5)
            ..formSize = Utils.convertDpToPixel(25)
            ..textColor = (ColorUtils.RED);
        },
        xAxisSettingFunction: (xAxis, controller) {
          xAxis
            ..textSize = (9)
            ..typeface = Util.LIGHT
            ..yOffset = (0)
            ..xOffset = (0)
            ..textColor = (ColorUtils.WHITE)
            ..setValueFormatter(A());
        },
        webLineWidth: 1.0,
        webAlpha: 100,
        innerWebLineWidth: 1.0,
        webColor: ColorUtils.LTGRAY,
        webColorInner: ColorUtils.LTGRAY,
        backgroundColor: ColorUtils.DKGRAY,
        description: desc);
  }

  void _initRadarData() async {
    var img = await ImageLoader.loadImage('assets/img/star.png');
    double mul = 80;
    double min = 20;
    int cnt = 5;

    List<RadarEntry> entries1 = List();
    List<RadarEntry> entries2 = List();

    // NOTE: The order of the entries when being added to the entries array determines their position around the center of
    // the chart.
    for (int i = 0; i < cnt; i++) {
      double val1 = (random.nextDouble() * mul) + min;
      entries1.add(RadarEntry(value: val1, icon: img));

      double val2 = (random.nextDouble() * mul) + min;
      entries2.add(RadarEntry(value: val2, icon: img));
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
    set2.setGradientColor(ColorUtils.BLUE, ColorUtils.YELLOW);
    set2.setDrawFilled(true);
    set2.setFillAlpha(180);
    set2.setLineWidth(2);
    set2.setDrawHighlightCircleEnabled(true);
    set2.setDrawHighlightIndicators(false);

    List<IRadarDataSet> sets = List();
    sets.add(set1);
    sets.add(set2);

    controller.data = RadarData.fromList(sets);
    controller.data
      ..setValueTypeface(Util.LIGHT)
      ..setValueTextSize(8)
      ..setDrawValues(false)
      ..setValueTextColor(ColorUtils.WHITE);

    setState(() {});
  }

  Widget _initCandleChart() {
    var radarChart = RadarChart(controller);
    controller.animator
      ..reset()
      ..animateXY2(1400, 1400, Easing.EaseInOutQuad);
    return radarChart;
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
