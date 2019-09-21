import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mp_flutter_chart/chart/mp/chart/bar_chart.dart';
import 'package:mp_flutter_chart/chart/mp/chart/bubble_chart.dart';
import 'package:mp_flutter_chart/chart/mp/chart/candlestick_chart.dart';
import 'package:mp_flutter_chart/chart/mp/chart/combined_chart.dart';
import 'package:mp_flutter_chart/chart/mp/chart/horizontal_bar_chart.dart';
import 'package:mp_flutter_chart/chart/mp/chart/line_chart.dart';
import 'package:mp_flutter_chart/chart/mp/chart/pie_chart.dart';
import 'package:mp_flutter_chart/chart/mp/chart/radar_chart.dart';
import 'package:mp_flutter_chart/chart/mp/chart/scatter_chart.dart';
import 'package:mp_flutter_chart/chart/mp/core/animator.dart';
import 'package:mp_flutter_chart/chart/mp/core/data/bar_data.dart';
import 'package:mp_flutter_chart/chart/mp/core/data/bubble_data.dart';
import 'package:mp_flutter_chart/chart/mp/core/data/candle_data.dart';
import 'package:mp_flutter_chart/chart/mp/core/data/combined_data.dart';
import 'package:mp_flutter_chart/chart/mp/core/data/line_data.dart';
import 'package:mp_flutter_chart/chart/mp/core/data/pie_data.dart';
import 'package:mp_flutter_chart/chart/mp/core/data/radar_data.dart';
import 'package:mp_flutter_chart/chart/mp/core/data/scatter_data.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_interfaces/i_bar_data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_interfaces/i_candle_data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_interfaces/i_data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_interfaces/i_line_data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_interfaces/i_radar_data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_interfaces/i_scatter_data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_set/bar_data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_set/candle_data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_set/line_data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_set/scatter_data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/enums/mode.dart';
import 'package:mp_flutter_chart/chart/mp/core/utils/color_utils.dart';
import 'package:mp_flutter_chart/demo/util.dart';

PopupMenuItem item(String text, String id) {
  return PopupMenuItem<String>(
      value: id,
      child: Container(
          padding: EdgeInsets.only(top: 15.0),
          child: Center(
              child: Text(
            text,
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: ColorUtils.BLACK,
                fontSize: 18,
                fontWeight: FontWeight.bold),
          ))));
}

abstract class ActionState<T extends StatefulWidget> extends State<T> {
  @override
  Widget build(BuildContext context) {
    chartInit();
    return Scaffold(
        appBar: AppBar(
            actions: <Widget>[
              PopupMenuButton<String>(
                itemBuilder: getBuilder(),
                onSelected: (String action) {
                  itemClick(action);
                },
              ),
            ],
            // Here we take the value from the MyHomePage object that was created by
            // the App.build method, and use it to set our appbar title.
            title: Text(getTitle())),
        body: getBody());
  }

  void itemClick(String action);

  void chartInit();

  Widget getBody();

  String getTitle();

  PopupMenuItemBuilder<String> getBuilder();
}

abstract class SimpleActionState<T extends StatefulWidget>
    extends ActionState<T> {
  @override
  void itemClick(String action) {
    Util.openGithub();
  }

  @override
  getBuilder() {
    return (BuildContext context) =>
        <PopupMenuItem<String>>[item('View on GitHub', 'A')];
  }
}

abstract class LineActionState<T extends StatefulWidget>
    extends ActionState<T> {
  LineChart lineChart;
  LineData lineData;

  @override
  getBuilder() {
    return (BuildContext context) => <PopupMenuItem<String>>[
          item('View on GitHub', 'A'),
          item('Toggle Values', 'B'),
          item('Toggle Icons', 'C'),
          item('Toggle Filled', 'D'),
          item('Toggle Circles', 'E'),
          item('Toggle Cubic', 'F'),
          item('Toggle Stepped', 'G'),
          item('Toggle Horizontal Cubic', 'H'),
          item('Toggle PinchZoom', 'I'),
          item('Toggle Auto Scale', 'J'),
          item('Toggle Highlight', 'K'),
          item('Animate X', 'L'),
          item('Animate Y', 'M'),
          item('Animate XY', 'N'),
          item('Save to Gallery', 'O'),
        ];
  }

  @override
  void itemClick(String action) {
    var state = lineChart?.getState() as LineChartState;
    if (state == null) {
      return;
    }

    switch (action) {
      case 'A':
        Util.openGithub();
        break;
      case 'B':
        List<ILineDataSet> sets = lineChart.data.dataSets;
        for (ILineDataSet iSet in sets) {
          LineDataSet set = iSet as LineDataSet;
          set.setDrawValues(!set.isDrawValuesEnabled());
        }
        state.setStateIfNotDispose();
        break;
      case 'C':
        List<ILineDataSet> sets = lineChart.data.dataSets;
        for (ILineDataSet iSet in sets) {
          LineDataSet set = iSet as LineDataSet;
          set.setDrawIcons(!set.isDrawIconsEnabled());
        }
        state.setStateIfNotDispose();
        break;
      case 'D':
        List<ILineDataSet> sets = lineChart.data.dataSets;

        for (ILineDataSet iSet in sets) {
          LineDataSet set = iSet as LineDataSet;
          if (set.isDrawFilledEnabled())
            set.setDrawFilled(false);
          else
            set.setDrawFilled(true);
        }
        state.setStateIfNotDispose();
        break;
      case 'E':
        List<ILineDataSet> sets = lineChart.data.dataSets;

        for (ILineDataSet iSet in sets) {
          LineDataSet set = iSet as LineDataSet;
          if (set.isDrawCirclesEnabled())
            set.setDrawCircles(false);
          else
            set.setDrawCircles(true);
        }
        state.setStateIfNotDispose();
        break;
      case 'F':
        List<ILineDataSet> sets = lineChart.data.dataSets;

        for (ILineDataSet iSet in sets) {
          LineDataSet set = iSet as LineDataSet;
          set.setMode(set.getMode() == Mode.CUBIC_BEZIER
              ? Mode.LINEAR
              : Mode.CUBIC_BEZIER);
        }
        state.setStateIfNotDispose();
        break;
      case 'G':
        List<ILineDataSet> sets = lineChart.data.dataSets;

        for (ILineDataSet iSet in sets) {
          LineDataSet set = iSet as LineDataSet;
          set.setMode(
              set.getMode() == Mode.STEPPED ? Mode.LINEAR : Mode.STEPPED);
        }
        state.setStateIfNotDispose();
        break;
      case 'H':
        List<ILineDataSet> sets = lineChart.data.dataSets;

        for (ILineDataSet iSet in sets) {
          LineDataSet set = iSet as LineDataSet;
          set.setMode(set.getMode() == Mode.HORIZONTAL_BEZIER
              ? Mode.LINEAR
              : Mode.HORIZONTAL_BEZIER);
        }
        state.setStateIfNotDispose();
        break;
      case 'I':
        state.widget.pinchZoomEnabled = !state.widget.pinchZoomEnabled;
        state.setStateIfNotDispose();
        break;
      case 'J':
        state.widget.autoScaleMinMaxEnabled =
            !state.widget.autoScaleMinMaxEnabled;
        state.setStateIfNotDispose();
        break;
      case 'K':
        if (lineChart.data != null) {
          lineChart.data
              .setHighlightEnabled(!lineChart.data.isHighlightEnabled());
          state.setStateIfNotDispose();
        }
        break;
      case 'L':
        lineChart.animator
          ..reset()
          ..animateX1(2000);
        break;
      case 'M':
        lineChart.animator
          ..reset()
          ..animateY2(2000, Easing.EaseInCubic);
        break;
      case 'N':
        lineChart.animator
          ..reset()
          ..animateXY1(2000, 2000);
        break;
      case 'O':
        // todo save
        break;
    }
  }
}

abstract class BarActionState<T extends StatefulWidget> extends ActionState<T> {
  BarChart barChart;
  BarData barData;

  @override
  getBuilder() {
    return (BuildContext context) => <PopupMenuItem<String>>[
          item('View on GitHub', 'A'),
          item('Toggle Bar Borders', 'B'),
          item('Toggle Values', 'C'),
          item('Toggle Icons', 'D'),
          item('Toggle Highlight', 'E'),
          item('Toggle PinchZoom', 'F'),
          item('Toggle Auto Scale', 'G'),
          item('Animate X', 'H'),
          item('Animate Y', 'I'),
          item('Animate XY', 'J'),
          item('Save to Gallery', 'K'),
        ];
  }

  @override
  void itemClick(String action) {
    var state = barChart?.getState() as BarChartState;
    var painter = barChart?.painter;
    if (state == null || painter == null) {
      return;
    }

    switch (action) {
      case 'A':
        Util.openGithub();
        break;
      case 'B':
        for (IBarDataSet set in painter.getData().dataSets)
          (set as BarDataSet)
              .setBarBorderWidth(set.getBarBorderWidth() == 1.0 ? 0.0 : 1.0);
        state.setStateIfNotDispose();
        break;
      case 'C':
        for (IDataSet set in painter.getData().dataSets)
          set.setDrawValues(!set.isDrawValuesEnabled());
        state.setStateIfNotDispose();
        break;
      case 'D':
        List<IBarDataSet> sets = painter.getData().dataSets;
        for (IBarDataSet iSet in sets) {
          BarDataSet set = iSet as BarDataSet;
          set.setDrawIcons(!set.isDrawIconsEnabled());
        }
        state.setStateIfNotDispose();
        break;
      case 'E':
        if (painter.getData() != null) {
          painter
              .getData()
              .setHighlightEnabled(!painter.getData().isHighlightEnabled());
          state.setStateIfNotDispose();
        }
        break;
      case 'F':
        state.widget.pinchZoomEnabled = !state.widget.pinchZoomEnabled;
        state.setStateIfNotDispose();
        break;
      case 'G':
        state.widget.autoScaleMinMaxEnabled =
            !state.widget.autoScaleMinMaxEnabled;
        state.setStateIfNotDispose();
        break;
      case 'H':
        painter.animator
          ..reset()
          ..animateX1(2000);
        break;
      case 'I':
        painter.animator
          ..reset()
          ..animateY1(2000);
        break;
      case 'J':
        painter.animator
          ..reset()
          ..animateXY1(2000, 2000);
        break;
      case 'K':
        // todo save
        break;
    }
  }
}

abstract class HorizontalBarActionState<T extends StatefulWidget>
    extends ActionState<T> {
  HorizontalBarChart barChart;
  BarData barData;

  @override
  getBuilder() {
    return (BuildContext context) => <PopupMenuItem<String>>[
          item('View on GitHub', 'A'),
          item('Toggle Bar Borders', 'B'),
          item('Toggle Values', 'C'),
          item('Toggle Icons', 'D'),
          item('Toggle Highlight', 'E'),
          item('Toggle PinchZoom', 'F'),
          item('Toggle Auto Scale', 'G'),
          item('Animate X', 'H'),
          item('Animate Y', 'I'),
          item('Animate XY', 'J'),
          item('Save to Gallery', 'K'),
        ];
  }

  @override
  void itemClick(String action) {
    var state = barChart?.getState() as HorizontalBarChartState;
    if (state == null) {
      return;
    }

    switch (action) {
      case 'A':
        Util.openGithub();
        break;
      case 'B':
        for (IBarDataSet set in barChart.data.dataSets)
          (set as BarDataSet)
              .setBarBorderWidth(set.getBarBorderWidth() == 1.0 ? 0.0 : 1.0);
        state.setStateIfNotDispose();
        break;
      case 'C':
        for (IDataSet set in barChart.data.dataSets)
          set.setDrawValues(!set.isDrawValuesEnabled());
        state.setStateIfNotDispose();
        break;
      case 'D':
        List<IBarDataSet> sets = barChart.data.dataSets;
        for (IBarDataSet iSet in sets) {
          BarDataSet set = iSet as BarDataSet;
          set.setDrawIcons(!set.isDrawIconsEnabled());
        }
        state.setStateIfNotDispose();
        break;
      case 'E':
        if (barChart.data != null) {
          barChart.data
              .setHighlightEnabled(!barChart.data.isHighlightEnabled());
          state.setStateIfNotDispose();
        }
        break;
      case 'F':
        state.widget.pinchZoomEnabled = !state.widget.pinchZoomEnabled;
        state.setStateIfNotDispose();
        break;
      case 'G':
        state.widget.autoScaleMinMaxEnabled =
            !state.widget.autoScaleMinMaxEnabled;
        state.setStateIfNotDispose();
        break;
      case 'H':
        barChart.animator
          ..reset()
          ..animateX1(2000);
        break;
      case 'I':
        barChart.animator
          ..reset()
          ..animateY1(2000);
        break;
      case 'J':
        barChart.animator
          ..reset()
          ..animateXY1(2000, 2000);
        break;
      case 'K':
        // todo save
        break;
    }
  }
}

abstract class PieActionState<T extends StatefulWidget> extends ActionState<T> {
  PieChart pieChart;
  PieData pieData;

  @override
  getBuilder() {
    return (BuildContext context) => <PopupMenuItem<String>>[
          item('View on GitHub', 'A'),
          item('Toggle Y-Values', 'B'),
          item('Toggle X-Values', 'C'),
          item('Toggle Icons', 'D'),
          item('Toggle Percent', 'E'),
          item('Toggle Minimum Angles', 'F'),
          item('Toggle Hole', 'G'),
          item('Toggle Curved Slices Cubic', 'H'),
          item('Draw Center Text', 'I'),
          item('Spin Animation', 'J'),
          item('Animate X', 'K'),
          item('Animate Y', 'L'),
          item('Animate XY', 'M'),
          item('Save to Gallery', 'N'),
        ];
  }

  @override
  void itemClick(String action) {
    var state = pieChart?.getState() as PieChartState;
    if (state == null) {
      return;
    }

    switch (action) {
      case 'A':
        Util.openGithub();
        break;
      case 'B':
        for (IDataSet set in pieChart.data.dataSets)
          set.setDrawValues(!set.isDrawValuesEnabled());
        state.setStateIfNotDispose();
        break;
      case 'C':
        state.widget.drawEntryLabels = !state.widget.drawEntryLabels;
        state.setStateIfNotDispose();
        break;
      case 'D':
        for (IDataSet set in pieChart.data.dataSets)
          set.setDrawIcons(!set.isDrawIconsEnabled());
        state.setStateIfNotDispose();
        break;
      case 'E':
        state.widget.usePercentValues = !state.widget.usePercentValues;
        state.setStateIfNotDispose();
        break;
      case 'F':
        if (state.widget.minAngleForSlices == 0) {
          state.widget.minAngleForSlices = 36;
        } else {
          state.widget.minAngleForSlices = 0;
        }
        state.setStateIfNotDispose();
        break;
      case 'G':
        state.widget.drawHole = !state.widget.drawHole;
        state.setStateIfNotDispose();
        break;
      case 'H':
        bool toSet = !pieChart.drawRoundedSlices || !pieChart.drawHole;
        state.widget.drawRoundedSlices = toSet;
        if (toSet && !pieChart.drawHole) {
          state.widget.drawHole = true;
        }
        if (toSet && pieChart.drawSlicesUnderHole) {
          state.widget.drawSlicesUnderHole = false;
        }
        state.setStateIfNotDispose();
        break;
      case 'I':
        state.widget.drawCenterText = !state.widget.drawCenterText;
        state.setStateIfNotDispose();
        break;
      case 'J':
        pieChart.animator
          ..reset()
          ..spin(2000, pieChart.rotationAngle, pieChart.rotationAngle + 360,
              Easing.EaseInOutCubic);
        break;
      case 'K':
        pieChart.animator
          ..reset()
          ..animateX1(1400);
        break;
      case 'L':
        pieChart.animator
          ..reset()
          ..animateY1(1400);
        break;
      case 'M':
        pieChart.animator
          ..reset()
          ..animateXY1(1400, 1400);
        break;
      case 'N':
        // todo save
        break;
    }
  }
}

abstract class CombinedActionState<T extends StatefulWidget>
    extends ActionState<T> {
  CombinedChart combinedChart;
  CombinedData combinedData;

  @override
  getBuilder() {
    return (BuildContext context) => <PopupMenuItem<String>>[
          item('View on GitHub', 'A'),
          item('Toggle Line Values', 'B'),
          item('Toggle Bar Values', 'C'),
          item('Remove Data Set', 'D')
        ];
  }

  @override
  void itemClick(String action) {
    var state = combinedChart?.getState();
    if (state == null) {
      return;
    }

    switch (action) {
      case 'A':
        Util.openGithub();
        break;
      case 'B':
        for (IDataSet set in combinedChart.data.dataSets) {
          if (set is LineDataSet) set.setDrawValues(!set.isDrawValuesEnabled());
        }
        state.setStateIfNotDispose();
        break;
      case 'C':
        for (IDataSet set in combinedChart.data.dataSets) {
          if (set is BarDataSet) set.setDrawValues(!set.isDrawValuesEnabled());
        }
        state.setStateIfNotDispose();
        break;
      case 'D':
        if (combinedChart.data.getDataSetCount() > 1) {
          int rnd =
              _getRandom(combinedChart.data.getDataSetCount().toDouble(), 0)
                  .toInt();
          combinedChart.data
              .removeDataSet1(combinedChart.data.getDataSetByIndex(rnd));
          combinedChart.data.notifyDataChanged();
          state.setStateIfNotDispose();
        }
        break;
    }
  }

  double _getRandom(double range, double start) {
    return (Random(1).nextDouble() * range) + start;
  }
}

abstract class ScatterActionState<T extends StatefulWidget>
    extends ActionState<T> {
  ScatterChart scatterChart;
  ScatterData scatterData;

  @override
  getBuilder() {
    return (BuildContext context) => <PopupMenuItem<String>>[
          item('View on GitHub', 'A'),
          item('Toggle Values', 'B'),
          item('Toggle Icons', 'C'),
          item('Toggle Highlight', 'D'),
          item('Animate X', 'E'),
          item('Animate Y', 'F'),
          item('Animate XY', 'G'),
          item('Toggle PinchZoom', 'H'),
          item('Toggle Auto Scale', 'I'),
          item('Save to Gallery', 'J'),
        ];
  }

  @override
  void itemClick(String action) {
    var state = scatterChart?.getState();
    if (state == null) {
      return;
    }

    switch (action) {
      case 'A':
        Util.openGithub();
        break;
      case 'B':
        List<IScatterDataSet> sets = scatterChart.data.dataSets;
        for (IScatterDataSet iSet in sets) {
          ScatterDataSet set = iSet as ScatterDataSet;
          set.setDrawValues(!set.isDrawValuesEnabled());
        }
        state.setStateIfNotDispose();
        break;
      case 'C':
        for (IDataSet set in scatterChart.data.dataSets)
          set.setDrawIcons(!set.isDrawIconsEnabled());
        state.setStateIfNotDispose();
        break;
      case 'D':
        if (scatterChart.data != null) {
          scatterChart.data
              .setHighlightEnabled(!scatterChart.data.isHighlightEnabled());
          state.setStateIfNotDispose();
        }
        break;
      case 'E':
        scatterChart.animator
          ..reset()
          ..animateX1(3000);
        break;
      case 'F':
        scatterChart.animator
          ..reset()
          ..animateY1(3000);
        break;
      case 'G':
        scatterChart.animator
          ..reset()
          ..animateXY1(3000, 3000);
        break;
      case 'H':
        scatterChart.pinchZoomEnabled = !scatterChart.pinchZoomEnabled;
        state.setStateIfNotDispose();
        break;
      case 'I':
        scatterChart.autoScaleMinMaxEnabled =
            !scatterChart.autoScaleMinMaxEnabled;
        state.setStateIfNotDispose();
        break;
      case 'J':
        // todo save
        break;
    }
  }
}

abstract class BubbleActionState<T extends StatefulWidget>
    extends ActionState<T> {
  BubbleChart bubbleChart;
  BubbleData bubbleData;

  @override
  getBuilder() {
    return (BuildContext context) => <PopupMenuItem<String>>[
          item('View on GitHub', 'A'),
          item('Toggle Values', 'B'),
          item('Toggle Icons', 'C'),
          item('Toggle Highlight', 'D'),
          item('Toggle PinchZoom', 'H'),
          item('Toggle Auto Scale', 'I'),
          item('Animate X', 'E'),
          item('Animate Y', 'F'),
          item('Animate XY', 'G'),
          item('Save to Gallery', 'J'),
        ];
  }

  @override
  void itemClick(String action) {
    var state = bubbleChart?.getState();
    if (state == null) {
      return;
    }

    switch (action) {
      case 'A':
        Util.openGithub();
        break;
      case 'B':
        for (IDataSet set in bubbleChart.data.dataSets)
          set.setDrawValues(!set.isDrawValuesEnabled());
        state.setStateIfNotDispose();
        break;
      case 'C':
        for (IDataSet set in bubbleChart.data.dataSets)
          set.setDrawIcons(!set.isDrawIconsEnabled());
        state.setStateIfNotDispose();
        break;
      case 'D':
        if (bubbleChart.data != null) {
          bubbleChart.data
              .setHighlightEnabled(!bubbleChart.data.isHighlightEnabled());
          state.setStateIfNotDispose();
        }
        break;
      case 'E':
        bubbleChart.animator
          ..reset()
          ..animateX1(2000);
        break;
      case 'F':
        bubbleChart.animator
          ..reset()
          ..animateY1(2000);
        break;
      case 'G':
        bubbleChart.animator
          ..reset()
          ..animateXY1(2000, 2000);
        break;
      case 'H':
        bubbleChart.pinchZoomEnabled = !bubbleChart.pinchZoomEnabled;
        state.setStateIfNotDispose();
        break;
      case 'I':
        bubbleChart.autoScaleMinMaxEnabled =
            !bubbleChart.autoScaleMinMaxEnabled;
        state.setStateIfNotDispose();
        break;
      case 'J':
        // todo save
        break;
    }
  }
}

abstract class CandlestickActionState<T extends StatefulWidget>
    extends ActionState<T> {
  CandlestickChart candlestickChart;
  CandleData candleData;

  @override
  getBuilder() {
    return (BuildContext context) => <PopupMenuItem<String>>[
          item('View on GitHub', 'A'),
          item('Toggle Values', 'B'),
          item('Toggle Icons', 'C'),
          item('Toggle Highlight', 'D'),
          item('Toggle Shadow Color', 'K'),
          item('Toggle PinchZoom', 'H'),
          item('Toggle Auto Scale', 'I'),
          item('Animate X', 'E'),
          item('Animate Y', 'F'),
          item('Animate XY', 'G'),
          item('Save to Gallery', 'J'),
        ];
  }

  @override
  void itemClick(String action) {
    var state = candlestickChart?.getState();
    if (state == null) {
      return;
    }

    switch (action) {
      case 'A':
        Util.openGithub();
        break;
      case 'B':
        for (IDataSet set in candlestickChart.data.dataSets)
          set.setDrawValues(!set.isDrawValuesEnabled());
        state.setStateIfNotDispose();
        break;
      case 'C':
        for (IDataSet set in candlestickChart.data.dataSets)
          set.setDrawIcons(!set.isDrawIconsEnabled());
        state.setStateIfNotDispose();
        break;
      case 'D':
        if (candlestickChart.data != null) {
          candlestickChart.data
              .setHighlightEnabled(!candlestickChart.data.isHighlightEnabled());
          state.setStateIfNotDispose();
        }
        break;
      case 'E':
        candlestickChart.animator
          ..reset()
          ..animateX1(2000);
        break;
      case 'F':
        candlestickChart.animator
          ..reset()
          ..animateY1(2000);
        break;
      case 'G':
        candlestickChart.animator
          ..reset()
          ..animateXY1(2000, 2000);
        break;
      case 'H':
        candlestickChart.pinchZoomEnabled = !candlestickChart.pinchZoomEnabled;
        state.setStateIfNotDispose();
        break;
      case 'I':
        candlestickChart.autoScaleMinMaxEnabled =
            !candlestickChart.autoScaleMinMaxEnabled;
        state.setStateIfNotDispose();
        break;
      case 'J':
        // todo save
        break;
      case 'K':
        for (ICandleDataSet set in candlestickChart.data.dataSets) {
          (set as CandleDataSet)
              .setShadowColorSameAsCandle(!set.getShadowColorSameAsCandle());
        }
        state.setStateIfNotDispose();
        break;
    }
  }
}

abstract class RadarActionState<T extends StatefulWidget>
    extends ActionState<T> {
  RadarChart radarChart;
  RadarData radarData;

  @override
  getBuilder() {
    return (BuildContext context) => <PopupMenuItem<String>>[
          item('View on GitHub', 'A'),
          item('Toggle Values', 'B'),
          item('Toggle Icons', 'C'),
          item('Toggle Filled', 'D'),
          item('Toggle Highlight', 'E'),
          item('Toggle Highlight Circle', 'F'),
          item('Toggle Rotation', 'G'),
          item('Toggle Y-Values', 'H'),
          item('Toggle X-Values', 'I'),
          item('Spin Animation', 'J'),
          item('Animate X', 'K'),
          item('Animate Y', 'L'),
          item('Animate XY', 'M'),
          item('Save to Gallery', 'N'),
        ];
  }

  @override
  void itemClick(String action) {
    var state = radarChart?.getState();
    if (state == null) {
      return;
    }

    switch (action) {
      case 'A':
        Util.openGithub();
        break;
      case 'B':
        for (IDataSet set in radarChart.data.dataSets)
          set.setDrawValues(!set.isDrawValuesEnabled());
        state.setStateIfNotDispose();
        break;
      case 'C':
        for (IDataSet set in radarChart.data.dataSets)
          set.setDrawIcons(!set.isDrawIconsEnabled());
        state.setStateIfNotDispose();
        break;
      case 'D':
        List<IRadarDataSet> sets = radarChart.data.dataSets;
        for (IRadarDataSet set in sets) {
          if (set.isDrawFilledEnabled())
            set.setDrawFilled(false);
          else
            set.setDrawFilled(true);
        }
        state.setStateIfNotDispose();
        break;
      case 'E':
        if (radarChart.data != null) {
          radarChart.data
              .setHighlightEnabled(!radarChart.data.isHighlightEnabled());
          state.setStateIfNotDispose();
        }
        break;
      case 'F':
        List<IRadarDataSet> sets = radarChart.data.dataSets;
        for (IRadarDataSet set in sets) {
          set.setDrawHighlightCircleEnabled(
              !set.isDrawHighlightCircleEnabled());
        }
        state.setStateIfNotDispose();
        break;
      case 'G':
        radarChart.rotateEnabled = !radarChart.rotateEnabled;
        state.setStateIfNotDispose();
        break;
      case 'H':
        radarChart.yAxis.enabled = !radarChart.yAxis.enabled;
        state.setStateIfNotDispose();
        break;
      case 'I':
        radarChart.xAxis.enabled = !radarChart.xAxis.enabled;
        state.setStateIfNotDispose();
        break;
      case 'J':
        radarChart.animator
          ..reset()
          ..spin(2000, radarChart.rotationAngle, radarChart.rotationAngle + 360,
              Easing.EaseInOutCubic);
        break;
      case 'K':
        radarChart.animator
          ..reset()
          ..animateX1(1400);
        break;
      case 'L':
        radarChart.animator
          ..reset()
          ..animateY1(1400);
        break;
      case 'M':
        radarChart.animator
          ..reset()
          ..animateXY1(1400, 1400);
        break;
      case 'N':
        // todo save
        break;
    }
  }
}
