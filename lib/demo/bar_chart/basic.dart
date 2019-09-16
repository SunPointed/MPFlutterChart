import 'dart:math';

import 'package:mp_flutter_chart/chart/mp/chart/chart.dart';
import 'package:mp_flutter_chart/chart/mp/core/common_interfaces.dart';
import 'package:flutter/material.dart';
import 'package:mp_flutter_chart/chart/mp/chart/bar_chart.dart';
import 'package:mp_flutter_chart/chart/mp/core/color/gradient_color.dart';
import 'package:mp_flutter_chart/chart/mp/core/data/bar_data.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_interfaces/i_bar_data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_set/bar_data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/description.dart';
import 'package:mp_flutter_chart/chart/mp/core/entry/bar_entry.dart';
import 'package:mp_flutter_chart/chart/mp/core/entry/entry.dart';
import 'package:mp_flutter_chart/chart/mp/core/enums/legend_form.dart';
import 'package:mp_flutter_chart/chart/mp/core/enums/legend_orientation.dart';
import 'package:mp_flutter_chart/chart/mp/core/enums/legend_vertical_alignment.dart';
import 'package:mp_flutter_chart/chart/mp/core/enums/x_axis_position.dart';
import 'package:mp_flutter_chart/chart/mp/core/enums/y_axis_label_position.dart';
import 'package:mp_flutter_chart/chart/mp/core/highlight/highlight.dart';
import 'package:mp_flutter_chart/chart/mp/core/utils/color_utils.dart';
import 'package:mp_flutter_chart/chart/mp/core/value_formatter/day_axis_value_formatter.dart';
import 'package:mp_flutter_chart/chart/mp/core/value_formatter/my_value_formatter.dart';
import 'package:mp_flutter_chart/chart/mp/core/value_formatter/value_formatter.dart';
import 'package:mp_flutter_chart/chart/mp/painter/painter.dart';
import 'package:mp_flutter_chart/demo/action_state.dart';

class BarChartBasic extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return BarChartBasicState();
  }
}

class BarChartBasicState extends ActionState<BarChartBasic>
    implements OnChartValueSelectedListener {
  BarChart _barChart;
  BarData _barData;

  var random = Random(1);

  int _count = 12;
  double _range = 50.0;

  @override
  void initState() {
    _initBarData(_count, _range);
    super.initState();
  }

  @override
  void chartInit() {
    _initBarChart();
  }


  @override
  void itemClick(String action) {

  }

  @override
  Widget getBody() {
    return Stack(
      children: <Widget>[
        Positioned(
          right: 0,
          left: 0,
          top: 0,
          bottom: 100,
          child: _barChart,
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
                            max: 1500,
                            onChanged: (value) {
                              _count = value.toInt();
                              _initBarData(_count, _range);
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
                              _initBarData(_count, _range);
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
    );
  }

  @override
  String getTitle() {
    return "Bar Chart Basic";
  }

  void _initBarData(int count, double range) {
    double start = 1;

    List<BarEntry> values = List();

    for (int i = start.toInt(); i < start + count; i++) {
      double val = (random.nextDouble() * (range + 1));
// todo
//      if (random.nextDouble() * 100 < 25) {
//        values.add( BarEntry(x:i.toDouble(), y:val, getResources().getDrawable(R.drawable.star)));
//      } else {
//        values.add( BarEntry(x:i.toDouble(), y:val));
//      }
      values.add(BarEntry(x: i.toDouble(), y: val));
    }

    BarDataSet set1;

    set1 = BarDataSet(values, "The year 2017");

    set1.setDrawIcons(false);

//            set1.setColors(ColorTemplate.MATERIAL_COLORS);

    /*int startColor = ContextCompat.getColor(this, android.R.color.holo_blue_dark);
            int endColor = ContextCompat.getColor(this, android.R.color.holo_blue_bright);
            set1.setGradientColor(startColor, endColor);*/

    Color startColor1 = ColorUtils.HOLO_ORANGE_LIGHT;
    Color startColor2 = ColorUtils.HOLO_BLUE_LIGHT;
    Color startColor3 = ColorUtils.HOLO_ORANGE_LIGHT;
    Color startColor4 = ColorUtils.HOLO_GREEN_LIGHT;
    Color startColor5 = ColorUtils.HOLO_RED_LIGHT;
    Color endColor1 = ColorUtils.HOLO_BLUE_DARK;
    Color endColor2 = ColorUtils.HOLO_PURPLE;
    Color endColor3 = ColorUtils.HOLO_GREEN_DARK;
    Color endColor4 = ColorUtils.HOLO_RED_DARK;
    Color endColor5 = ColorUtils.HOLO_ORANGE_DARK;

    List<GradientColor> gradientColors = List();
    gradientColors.add(GradientColor(startColor1, endColor1));
    gradientColors.add(GradientColor(startColor2, endColor2));
    gradientColors.add(GradientColor(startColor3, endColor3));
    gradientColors.add(GradientColor(startColor4, endColor4));
    gradientColors.add(GradientColor(startColor5, endColor5));

    set1.setGradientColors(gradientColors);

    List<IBarDataSet> dataSets = List();
    dataSets.add(set1);

    _barData = BarData(dataSets);
    _barData.setValueTextSize(10);
//    _barData.setValueTypeface(tfLight);
    _barData.setBarWidth(0.9);
  }

  void _initBarChart() {
    var desc = Description();
    desc.setEnabled(false);
    _barChart = BarChart(_barData, (painter) {
      painter
        ..setOnChartValueSelectedListener(this)
        ..setDrawBarShadow(false)
        ..setDrawValueAboveBar(true);

      ValueFormatter xAxisFormatter = DayAxisValueFormatter(painter);
      painter.mXAxis
        ..setPosition(XAxisPosition.BOTTOM)
//      ..setTypeface(tf)
        ..setDrawGridLines(false)
        ..setGranularity(1.0)
        ..setLabelCount1(7)
        ..setValueFormatter(xAxisFormatter);

      ValueFormatter custom = MyValueFormatter("\$");
      painter.mAxisLeft
        ..setLabelCount2(8, false)
//      ..setTypeface(tf)
        ..setValueFormatter(custom)
        ..setPosition(YAxisLabelPosition.OUTSIDE_CHART)
        ..setSpaceTop(15)
        ..setAxisMinimum(0);

      painter.mAxisRight
        ..setDrawGridLines(false)
//      ..setTypeface(tf)
        ..setLabelCount2(8, false)
        ..setValueFormatter(custom)
        ..setSpaceTop(15)
        ..setAxisMinimum(0);

      painter.mLegend
        ..setVerticalAlignment(LegendVerticalAlignment.BOTTOM)
        ..setOrientation(LegendOrientation.HORIZONTAL)
        ..setDrawInside(false)
        ..setForm(LegendForm.SQUARE)
        ..setFormSize(9)
        ..setTextSize(11)
        ..setXEntrySpace(4);
    },
        touchEnabled: true,
        drawGridBackground: false,
        dragXEnabled: true,
        dragYEnabled: true,
        scaleXEnabled: true,
        scaleYEnabled: true,
        pinchZoomEnabled: false,
        maxVisibleCount: 60,
        desc: desc);
  }

  @override
  void onNothingSelected() {}

  @override
  void onValueSelected(Entry e, Highlight h) {
//    if (e == null)
//      return;
//
//    RectF bounds = onValueSelectedRectF;
//    chart.getBarBounds((BarEntry) e, bounds);
//    MPPointF position = chart.getPosition(e, AxisDependency.LEFT);
//
//    Log.i("bounds", bounds.toString());
//    Log.i("position", position.toString());
//
//    Log.i("x-index",
//        "low: " + chart.getLowestVisibleX() + ", high: "
//            + chart.getHighestVisibleX());
//
//    MPPointF.recycleInstance(position);
  }
}
