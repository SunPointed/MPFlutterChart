import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mp_flutter_chart/chart/mp/chart/line_chart.dart';
import 'package:mp_flutter_chart/chart/mp/core/common_interfaces.dart';
import 'package:mp_flutter_chart/chart/mp/core/data/line_data.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_interfaces/i_line_data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_set/line_data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/description.dart';
import 'package:mp_flutter_chart/chart/mp/core/entry/entry.dart';
import 'package:mp_flutter_chart/chart/mp/core/enums/axis_dependency.dart';
import 'package:mp_flutter_chart/chart/mp/core/highlight/highlight.dart';
import 'package:mp_flutter_chart/chart/mp/core/utils/color_utils.dart';
import 'package:mp_flutter_chart/demo/action_state.dart';
import 'package:mp_flutter_chart/demo/util.dart';

class EvenMoreDynamic extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return EvenMoreDynamicState();
  }
}

class EvenMoreDynamicState extends ActionState<EvenMoreDynamic>
    implements OnChartValueSelectedListener {
  LineChart lineChart;
  LineData lineData;

  @override
  void chartInit() {
    _initLineChart();
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
          child: lineChart == null
              ? Center(
                  child: Text(
                      "No chart data available. \nUse the menu to add entries and data sets!"))
              : lineChart,
        ),
      ],
    );
  }

  @override
  getBuilder() {
    return (BuildContext context) => <PopupMenuItem<String>>[
          item('View on GitHub', 'A'),
          item('Add Entry', 'B'),
          item('Remove Entry', 'C'),
          item('Add Data Set', 'D'),
          item('Remove Data Set', 'E'),
          item('Clear chart', 'F'),
          item('Save to Gallery', 'G'),
        ];
  }

  @override
  String getTitle() {
    return "Even More Dynamic";
  }

  @override
  void itemClick(String action) {
    var state = lineChart?.getState() as LineChartState;
    var painter = state?.painter;
    if (state == null || painter == null) {
      return;
    }

    switch (action) {
      case 'A':
        Util.openGithub();
        break;
      case 'B':
        _addEntry();
        state.setStateIfNotDispose();
        break;
      case 'C':
        _removeLastEntry();
        state.setStateIfNotDispose();
        break;
      case 'D':
        _addDataSet();
        state.setStateIfNotDispose();
        break;
      case 'E':
        _removeDataSet();
        state.setStateIfNotDispose();
        break;
      case 'F':
        lineChart.data = null;
        state.setStateIfNotDispose();
        break;
      case 'G':
        // todo save
        break;
    }
  }

  void _initLineChart() {
    if (lineChart != null) {
      lineChart?.data = lineData;
      lineChart?.getState()?.setStateIfNotDispose();
      return;
    }

    var desc = Description()..enabled = false;
    lineChart = LineChart(lineData,
        touchEnabled: true,
        noDataText:
            "No chart data available. \nUse the menu to add entries and data sets!",
        drawGridBackground: false,
        dragXEnabled: true,
        dragYEnabled: true,
        scaleXEnabled: true,
        scaleYEnabled: true,
        selectionListener: this,
        pinchZoomEnabled: true,
        description: desc);
  }

  @override
  void onNothingSelected() {}

  @override
  void onValueSelected(Entry e, Highlight h) {}

  final List<Color> colors = ColorUtils.VORDIPLOM_COLORS;
  var random = Random(1);

  void _addEntry() {
    LineData data = lineChart.data;

    if (data == null) {
      data = LineData();
      lineChart.data = data;
    }

    ILineDataSet set = data.getDataSetByIndex(0);
    // set.addEntry(...); // can be called as well

    if (set == null) {
      set = _createSet();
      data.addDataSet(set);
    }

    // choose a random dataSet
    int randomDataSetIndex =
        (random.nextDouble() * data.getDataSetCount()).toInt();
    ILineDataSet randomSet = data.getDataSetByIndex(randomDataSetIndex);
    double value = (random.nextDouble() * 50) + 50 * (randomDataSetIndex + 1);

    data.addEntry(Entry(x: randomSet.getEntryCount().toDouble(), y: value),
        randomDataSetIndex);
    data.notifyDataChanged();

//    var painter = lineChart.getState()?.painter;
//    if (painter != null) {
//      double xScale = painter.mXAxis.mAxisRange / 6;
//      lineChart.viewPortHandler.setMinimumScaleX(xScale);
////      chart.moveViewTo(data.getEntryCount() - 7, 50f, AxisDependency.LEFT);
//    }
  }

  LineDataSet _createSet() {
    LineDataSet set = LineDataSet(null, "DataSet 1");
    set.setLineWidth(2.5);
    set.setCircleRadius(4.5);
    set.setColor1(Color.fromARGB(255, 240, 99, 99));
    set.setCircleColor(Color.fromARGB(255, 240, 99, 99));
    set.setHighLightColor(Color.fromARGB(255, 190, 190, 190));
    set.setAxisDependency(AxisDependency.LEFT);
    set.setValueTextSize(10);
    return set;
  }

  void _removeLastEntry() {
    LineData data = lineChart.data;
    if (data != null) {
      ILineDataSet set = data.getDataSetByIndex(0);
      if (set != null) {
        Entry e = set.getEntryForXValue2(
            (set.getEntryCount() - 1).toDouble(), double.nan);
        data.removeEntry1(e, 0);
      }
    }
  }

  void _addDataSet() {
    LineData data = lineChart.data;
    if (data == null) {
      lineChart.data = LineData();
    } else {
      int count = (data.getDataSetCount() + 1);
      int amount = data.getDataSetByIndex(0).getEntryCount();
      List<Entry> values = List();
      for (int i = 0; i < amount; i++) {
        values.add(new Entry(
            x: i.toDouble(), y: (random.nextDouble() * 50) + 50 * count));
      }
      LineDataSet set = new LineDataSet(values, "DataSet $count");
      set.setLineWidth(2.5);
      set.setCircleRadius(4.5);
      Color color = colors[count % colors.length];
      set.setColor1(color);
      set.setCircleColor(color);
      set.setHighLightColor(color);
      set.setValueTextSize(10);
      set.setValueTextColor(color);
      data.addDataSet(set);
    }
  }

  void _removeDataSet() {
    LineData data = lineChart.data;
    if (data != null) {
      data.removeDataSet1(data.getDataSetByIndex(data.getDataSetCount() - 1));
    }
  }
}
