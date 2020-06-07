import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mp_chart/mp/chart/bar_chart.dart';
import 'package:mp_chart/mp/controller/bar_chart_controller.dart';
import 'package:mp_chart/mp/core/common_interfaces.dart';
import 'package:mp_chart/mp/core/data/bar_data.dart';
import 'package:mp_chart/mp/core/data_interfaces/i_bar_data_set.dart';
import 'package:mp_chart/mp/core/data_set/bar_data_set.dart';
import 'package:mp_chart/mp/core/description.dart';
import 'package:mp_chart/mp/core/entry/bar_entry.dart';
import 'package:mp_chart/mp/core/entry/entry.dart';
import 'package:mp_chart/mp/core/enums/legend_form.dart';
import 'package:mp_chart/mp/core/enums/legend_horizontal_alignment.dart';
import 'package:mp_chart/mp/core/enums/legend_orientation.dart';
import 'package:mp_chart/mp/core/enums/legend_vertical_alignment.dart';
import 'package:mp_chart/mp/core/enums/x_axis_position.dart';
import 'package:mp_chart/mp/core/highlight/highlight.dart';
import 'package:mp_chart/mp/core/image_loader.dart';
import 'package:mp_chart/mp/core/utils/color_utils.dart';
import 'package:mp_chart/mp/core/value_formatter/my_value_formatter.dart';
import 'package:mp_chart/mp/core/value_formatter/stacked_value_formatter.dart';
import 'package:example/demo/action_state.dart';

class BarChartStacked extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return BarChartStackedState();
  }
}

class BarChartStackedState extends BarActionState<BarChartStacked>
    implements OnChartValueSelectedListener {
  var random = Random(1);
  int _count = 12;
  double _range = 100.0;

  @override
  void initState() {
    _initController();
    _initBarData(_count, _range);
    super.initState();
  }

  @override
  String getTitle() => "Bar Chart Stacked";

  @override
  Widget getBody() {
    return Stack(
      children: <Widget>[
        Positioned(
          right: 0,
          left: 0,
          top: 0,
          bottom: 100,
          child: BarChart(controller),
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
                            max: 200,
                            onChanged: (value) {
                              _range = value;
                              _initBarData(_count, _range);
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

  void _initBarData(int count, double range) async {
    var img = await ImageLoader.loadImage('assets/img/star.png');
    List<BarEntry> values = List();

    for (int i = 0; i < count; i++) {
      double mul = (range + 1);
      double val1 = (random.nextDouble() * mul) + mul / 3;
      double val2 = (random.nextDouble() * mul) + mul / 3;
      double val3 = (random.nextDouble() * mul) + mul / 3;

      values.add(BarEntry.fromListYVals(
          x: i.toDouble(),
          vals: List()..add(val1)..add(val2)..add(val3),
          icon: img));
    }

    BarDataSet set1;

    set1 = BarDataSet(values, "Statistics Vienna 2014");
    set1.setDrawIcons(false);
    set1.setColors1(_getColors());
    set1.setStackLabels(
        List()..add("Births")..add("Divorces")..add("Marriages"));

    List<IBarDataSet> dataSets = List();
    dataSets.add(set1);

    controller.data = BarData(dataSets);
    controller.data
      ..setValueFormatter(StackedValueFormatter(false, "", 1))
      ..setValueTextColor(ColorUtils.WHITE);

    setState(() {});
  }

  List<Color> _getColors() {
    return List()
      ..add(ColorUtils.MATERIAL_COLORS[0])
      ..add(ColorUtils.MATERIAL_COLORS[1])
      ..add(ColorUtils.MATERIAL_COLORS[2]);
  }

  void _initController() {
    var desc = Description()..enabled = false;
    controller = BarChartController(
        axisLeftSettingFunction: (axisLeft, controller) {
          axisLeft
            ..setValueFormatter(MyValueFormatter("K"))
            ..setAxisMinimum(0);
        },
        axisRightSettingFunction: (axisRight, controller) {
          axisRight.enabled = (false);
        },
        legendSettingFunction: (legend, controller) {
          legend
            ..verticalAlignment = (LegendVerticalAlignment.BOTTOM)
            ..horizontalAlignment = (LegendHorizontalAlignment.RIGHT)
            ..orientation = (LegendOrientation.HORIZONTAL)
            ..drawInside = (false)
            ..shape = (LegendForm.SQUARE)
            ..formSize = (8)
            ..formToTextSpace = (4)
            ..xEntrySpace = (6);
        },
        xAxisSettingFunction: (xAxis, controller) {
          xAxis.position = (XAxisPosition.TOP);
        },
        drawGridBackground: false,
        dragXEnabled: true,
        dragYEnabled: true,
        scaleXEnabled: true,
        scaleYEnabled: true,
        pinchZoomEnabled: false,
        maxVisibleCount: 60,
        fitBars: true,
        selectionListener: this,
        drawBarShadow: false,
        highlightFullBarEnabled: false,
        drawValueAboveBar: false,
        description: desc);
  }

  @override
  void onNothingSelected() {}

  @override
  void onValueSelected(Entry e, Highlight h) {}
}
