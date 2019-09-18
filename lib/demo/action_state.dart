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
import 'package:mp_flutter_chart/chart/mp/painter/bar_chart_painter.dart';
import 'package:mp_flutter_chart/chart/mp/painter/bubble_chart_painter.dart';
import 'package:mp_flutter_chart/chart/mp/painter/candlestick_chart_painter.dart';
import 'package:mp_flutter_chart/chart/mp/painter/combined_chart_painter.dart';
import 'package:mp_flutter_chart/chart/mp/painter/line_chart_painter.dart';
import 'package:mp_flutter_chart/chart/mp/painter/pie_chart_painter.dart';
import 'package:mp_flutter_chart/chart/mp/painter/radar_chart_painter.dart';
import 'package:mp_flutter_chart/chart/mp/painter/scatter_chart_painter.dart';
import 'package:mp_flutter_chart/demo/util.dart';

PopupMenuItem _item(String text, String id) {
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
        <PopupMenuItem<String>>[_item('View on GitHub', 'A')];
  }
}

abstract class LineActionState<T extends StatefulWidget>
    extends ActionState<T> {
  LineChart lineChart;
  LineData lineData;

  @override
  getBuilder() {
    return (BuildContext context) => <PopupMenuItem<String>>[
          _item('View on GitHub', 'A'),
          _item('Toggle Values', 'B'),
          _item('Toggle Icons', 'C'),
          _item('Toggle Filled', 'D'),
          _item('Toggle Circles', 'E'),
          _item('Toggle Cubic', 'F'),
          _item('Toggle Stepped', 'G'),
          _item('Toggle Horizontal Cubic', 'H'),
          _item('Toggle PinchZoom', 'I'),
          _item('Toggle Auto Scale', 'J'),
          _item('Toggle Highlight', 'K'),
          _item('Animate X', 'L'),
          _item('Animate Y', 'M'),
          _item('Animate XY', 'N'),
          _item('Save to Gallery', 'O'),
        ];
  }

  @override
  void itemClick(String action) {
    var state = lineChart?.getState();
    var painter = state?.painter as LineChartPainter;
    if (state == null || painter == null) {
      return;
    }

    switch (action) {
      case 'A':
        Util.openGithub();
        break;
      case 'B':
        List<ILineDataSet> sets = painter.getData().getDataSets();
        for (ILineDataSet iSet in sets) {
          LineDataSet set = iSet as LineDataSet;
          set.setDrawValues(!set.isDrawValuesEnabled());
        }
        state.setState(() {});
        break;
      case 'C':
        List<ILineDataSet> sets = painter.getData().getDataSets();
        for (ILineDataSet iSet in sets) {
          LineDataSet set = iSet as LineDataSet;
          set.setDrawIcons(!set.isDrawIconsEnabled());
        }
        state.setState(() {});
        break;
      case 'D':
        List<ILineDataSet> sets = painter.getData().getDataSets();

        for (ILineDataSet iSet in sets) {
          LineDataSet set = iSet as LineDataSet;
          if (set.isDrawFilledEnabled())
            set.setDrawFilled(false);
          else
            set.setDrawFilled(true);
        }
        state.setState(() {});
        break;
      case 'E':
        List<ILineDataSet> sets = painter.getData().getDataSets();

        for (ILineDataSet iSet in sets) {
          LineDataSet set = iSet as LineDataSet;
          if (set.isDrawCirclesEnabled())
            set.setDrawCircles(false);
          else
            set.setDrawCircles(true);
        }
        state.setState(() {});
        break;
      case 'F':
        List<ILineDataSet> sets = painter.getData().getDataSets();

        for (ILineDataSet iSet in sets) {
          LineDataSet set = iSet as LineDataSet;
          set.setMode(set.getMode() == Mode.CUBIC_BEZIER
              ? Mode.LINEAR
              : Mode.CUBIC_BEZIER);
        }
        state.setState(() {});
        break;
      case 'G':
        List<ILineDataSet> sets = painter.getData().getDataSets();

        for (ILineDataSet iSet in sets) {
          LineDataSet set = iSet as LineDataSet;
          set.setMode(
              set.getMode() == Mode.STEPPED ? Mode.LINEAR : Mode.STEPPED);
        }
        state.setState(() {});
        break;
      case 'H':
        List<ILineDataSet> sets = painter.getData().getDataSets();

        for (ILineDataSet iSet in sets) {
          LineDataSet set = iSet as LineDataSet;
          set.setMode(set.getMode() == Mode.HORIZONTAL_BEZIER
              ? Mode.LINEAR
              : Mode.HORIZONTAL_BEZIER);
        }
        state.setState(() {});
        break;
      case 'I':
        painter.mPinchZoomEnabled = !painter.mPinchZoomEnabled;
        state.setState(() {});
        break;
      case 'J':
        painter.mAutoScaleMinMaxEnabled = !painter.mAutoScaleMinMaxEnabled;
        state.setState(() {});
        break;
      case 'K':
        if (painter.getData() != null) {
          painter
              .getData()
              .setHighlightEnabled(!painter.getData().isHighlightEnabled());
          state.setState(() {});
        }
        break;
      case 'L':
        painter.mAnimator
          ..reset()
          ..animateX1(2000);
        break;
      case 'M':
        painter.mAnimator
          ..reset()
          ..animateY2(2000, Easing.EaseInCubic);
        break;
      case 'N':
        painter.mAnimator
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
          _item('View on GitHub', 'A'),
          _item('Toggle Bar Borders', 'B'),
          _item('Toggle Values', 'C'),
          _item('Toggle Icons', 'D'),
          _item('Toggle Highlight', 'E'),
          _item('Toggle PinchZoom', 'F'),
          _item('Toggle Auto Scale', 'G'),
          _item('Animate X', 'H'),
          _item('Animate Y', 'I'),
          _item('Animate XY', 'J'),
          _item('Save to Gallery', 'K'),
        ];
  }

  @override
  void itemClick(String action) {
    var state = barChart?.getState();
    var painter = state?.painter as BarChartPainter;
    if (state == null || painter == null) {
      return;
    }

    switch (action) {
      case 'A':
        Util.openGithub();
        break;
      case 'B':
        for (IBarDataSet set in painter.getData().getDataSets())
          (set as BarDataSet)
              .setBarBorderWidth(set.getBarBorderWidth() == 1.0 ? 0.0 : 1.0);
        state.setState(() {});
        break;
      case 'C':
        for (IDataSet set in painter.getData().getDataSets())
          set.setDrawValues(!set.isDrawValuesEnabled());
        state.setState(() {});
        break;
      case 'D':
        List<IBarDataSet> sets = painter.getData().getDataSets();
        for (IBarDataSet iSet in sets) {
          BarDataSet set = iSet as BarDataSet;
          set.setDrawIcons(!set.isDrawIconsEnabled());
        }
        state.setState(() {});
        break;
      case 'E':
        if (painter.getData() != null) {
          painter
              .getData()
              .setHighlightEnabled(!painter.getData().isHighlightEnabled());
          state.setState(() {});
        }
        break;
      case 'F':
        painter.mPinchZoomEnabled = !painter.mPinchZoomEnabled;
        state.setState(() {});
        break;
      case 'G':
        painter.mAutoScaleMinMaxEnabled = !painter.mAutoScaleMinMaxEnabled;
        state.setState(() {});
        break;
      case 'H':
        painter.mAnimator
          ..reset()
          ..animateX1(2000);
        break;
      case 'I':
        painter.mAnimator
          ..reset()
          ..animateY1(2000);
        break;
      case 'J':
        painter.mAnimator
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
          _item('View on GitHub', 'A'),
          _item('Toggle Bar Borders', 'B'),
          _item('Toggle Values', 'C'),
          _item('Toggle Icons', 'D'),
          _item('Toggle Highlight', 'E'),
          _item('Toggle PinchZoom', 'F'),
          _item('Toggle Auto Scale', 'G'),
          _item('Animate X', 'H'),
          _item('Animate Y', 'I'),
          _item('Animate XY', 'J'),
          _item('Save to Gallery', 'K'),
        ];
  }

  @override
  void itemClick(String action) {
    var state = barChart?.getState();
    var painter = state?.painter as BarChartPainter;
    if (state == null || painter == null) {
      return;
    }

    switch (action) {
      case 'A':
        Util.openGithub();
        break;
      case 'B':
        for (IBarDataSet set in painter.getData().getDataSets())
          (set as BarDataSet)
              .setBarBorderWidth(set.getBarBorderWidth() == 1.0 ? 0.0 : 1.0);
        state.setState(() {});
        break;
      case 'C':
        for (IDataSet set in painter.getData().getDataSets())
          set.setDrawValues(!set.isDrawValuesEnabled());
        state.setState(() {});
        break;
      case 'D':
        List<IBarDataSet> sets = painter.getData().getDataSets();
        for (IBarDataSet iSet in sets) {
          BarDataSet set = iSet as BarDataSet;
          set.setDrawIcons(!set.isDrawIconsEnabled());
        }
        state.setState(() {});
        break;
      case 'E':
        if (painter.getData() != null) {
          painter
              .getData()
              .setHighlightEnabled(!painter.getData().isHighlightEnabled());
          state.setState(() {});
        }
        break;
      case 'F':
        painter.mPinchZoomEnabled = !painter.mPinchZoomEnabled;
        state.setState(() {});
        break;
      case 'G':
        painter.mAutoScaleMinMaxEnabled = !painter.mAutoScaleMinMaxEnabled;
        state.setState(() {});
        break;
      case 'H':
        painter.mAnimator
          ..reset()
          ..animateX1(2000);
        break;
      case 'I':
        painter.mAnimator
          ..reset()
          ..animateY1(2000);
        break;
      case 'J':
        painter.mAnimator
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
          _item('View on GitHub', 'A'),
          _item('Toggle Y-Values', 'B'),
          _item('Toggle X-Values', 'C'),
          _item('Toggle Icons', 'D'),
          _item('Toggle Percent', 'E'),
          _item('Toggle Minimum Angles', 'F'),
          _item('Toggle Hole', 'G'),
          _item('Toggle Curved Slices Cubic', 'H'),
          _item('Draw Center Text', 'I'),
          _item('Spin Animation', 'J'),
          _item('Animate X', 'K'),
          _item('Animate Y', 'L'),
          _item('Animate XY', 'M'),
          _item('Save to Gallery', 'N'),
        ];
  }

  @override
  void itemClick(String action) {
    var state = pieChart?.getState();
    var painter = state?.painter as PieChartPainter;
    if (state == null || painter == null) {
      return;
    }

    switch (action) {
      case 'A':
        Util.openGithub();
        break;
      case 'B':
        for (IDataSet set in painter.getData().getDataSets())
          set.setDrawValues(!set.isDrawValuesEnabled());
        state.setState(() {});
        break;
      case 'C':
        painter.mDrawEntryLabels = !painter.mDrawEntryLabels;
        state.setState(() {});
        break;
      case 'D':
        // todo icons
        break;
      case 'E':
        painter.setUsePercentValues(!painter.isUsePercentValuesEnabled());
        state.setState(() {});
        break;
      case 'F':
        if (painter.mMinAngleForSlices == 0)
          painter.mMinAngleForSlices = 36;
        else
          painter.mMinAngleForSlices = 0;
        state.setState(() {});
        break;
      case 'G':
        if (painter.isDrawHoleEnabled())
          painter.setDrawHoleEnabled(false);
        else
          painter.setDrawHoleEnabled(true);
        state.setState(() {});
        break;
      case 'H':
        bool toSet = !painter.isDrawRoundedSlicesEnabled() ||
            !painter.isDrawHoleEnabled();
        painter.mDrawRoundedSlices = toSet;
        if (toSet && !painter.isDrawHoleEnabled()) {
          painter.setDrawHoleEnabled(true);
        }
        if (toSet && painter.isDrawSlicesUnderHoleEnabled()) {
          painter.setDrawSlicesUnderHole(false);
        }
        state.setState(() {});
        break;
      case 'I':
        painter.mDrawCenterText = !painter.mDrawCenterText;
        state.setState(() {});
        break;
      case 'J':
        //        painter.spin(1000, chart.getRotationAngle(), chart.getRotationAngle() + 360, Easing.EaseInOutCubic);
        // todo
        break;
      case 'K':
        painter.mAnimator
          ..reset()
          ..animateX1(1400);
        break;
      case 'L':
        painter.mAnimator
          ..reset()
          ..animateY1(1400);
        break;
      case 'M':
        painter.mAnimator
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
          _item('View on GitHub', 'A'),
          _item('Toggle Line Values', 'B'),
          _item('Toggle Bar Values', 'C'),
          _item('Remove Data Set', 'D')
        ];
  }

  @override
  void itemClick(String action) {
    var state = combinedChart?.getState();
    var painter = state?.painter as CombinedChartPainter;
    if (state == null || painter == null) {
      return;
    }

    switch (action) {
      case 'A':
        Util.openGithub();
        break;
      case 'B':
        for (IDataSet set in painter.getData().getDataSets()) {
          if (set is LineDataSet) set.setDrawValues(!set.isDrawValuesEnabled());
        }
        state.setState(() {});
        break;
      case 'C':
        for (IDataSet set in painter.getData().getDataSets()) {
          if (set is BarDataSet) set.setDrawValues(!set.isDrawValuesEnabled());
        }
        state.setState(() {});
        break;
      case 'D':
        int rnd = _getRandom(painter.getData().getDataSetCount().toDouble(), 0)
            as int;
        painter
            .getData()
            .removeDataSet1(painter.getData().getDataSetByIndex(rnd));
        painter.getData().notifyDataChanged();
        state.setState(() {});
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
          _item('View on GitHub', 'A'),
          _item('Toggle Values', 'B'),
          _item('Toggle Icons', 'C'),
          _item('Toggle Highlight', 'D'),
          _item('Animate X', 'E'),
          _item('Animate Y', 'F'),
          _item('Animate XY', 'G'),
          _item('Toggle PinchZoom', 'H'),
          _item('Toggle Auto Scale', 'I'),
          _item('Save to Gallery', 'J'),
        ];
  }

  @override
  void itemClick(String action) {
    var state = scatterChart?.getState();
    var painter = state?.painter as ScatterChartPainter;
    if (state == null || painter == null) {
      return;
    }

    switch (action) {
      case 'A':
        Util.openGithub();
        break;
      case 'B':
        List<IScatterDataSet> sets = painter.getData().getDataSets();
        for (IScatterDataSet iSet in sets) {
          ScatterDataSet set = iSet as ScatterDataSet;
          set.setDrawValues(!set.isDrawValuesEnabled());
        }
        state.setState(() {});
        break;
      case 'C':
        // todo icons
        break;
      case 'D':
        if (painter.getData() != null) {
          painter
              .getData()
              .setHighlightEnabled(!painter.getData().isHighlightEnabled());
          state.setState(() {});
        }
        break;
      case 'E':
        painter.mAnimator
          ..reset()
          ..animateX1(3000);
        break;
      case 'F':
        painter.mAnimator
          ..reset()
          ..animateY1(3000);
        break;
      case 'G':
        painter.mAnimator
          ..reset()
          ..animateXY1(3000, 3000);
        break;
      case 'H':
        painter.mPinchZoomEnabled = !painter.mPinchZoomEnabled;
        state.setState(() {});
        break;
      case 'I':
        painter.mAutoScaleMinMaxEnabled = !painter.mAutoScaleMinMaxEnabled;
        state.setState(() {});
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
          _item('View on GitHub', 'A'),
          _item('Toggle Values', 'B'),
          _item('Toggle Icons', 'C'),
          _item('Toggle Highlight', 'D'),
          _item('Toggle PinchZoom', 'H'),
          _item('Toggle Auto Scale', 'I'),
          _item('Animate X', 'E'),
          _item('Animate Y', 'F'),
          _item('Animate XY', 'G'),
          _item('Save to Gallery', 'J'),
        ];
  }

  @override
  void itemClick(String action) {
    var state = bubbleChart?.getState();
    var painter = state?.painter as BubbleChartPainter;
    if (state == null || painter == null) {
      return;
    }

    switch (action) {
      case 'A':
        Util.openGithub();
        break;
      case 'B':
        for (IDataSet set in painter.getData().getDataSets())
          set.setDrawValues(!set.isDrawValuesEnabled());
        state.setState(() {});
        break;
      case 'C':
        // todo icons
        break;
      case 'D':
        if (painter.getData() != null) {
          painter
              .getData()
              .setHighlightEnabled(!painter.getData().isHighlightEnabled());
          state.setState(() {});
        }
        break;
      case 'E':
        painter.mAnimator
          ..reset()
          ..animateX1(2000);
        break;
      case 'F':
        painter.mAnimator
          ..reset()
          ..animateY1(2000);
        break;
      case 'G':
        painter.mAnimator
          ..reset()
          ..animateXY1(2000, 2000);
        break;
      case 'H':
        painter.mPinchZoomEnabled = !painter.mPinchZoomEnabled;
        state.setState(() {});
        break;
      case 'I':
        painter.mAutoScaleMinMaxEnabled = !painter.mAutoScaleMinMaxEnabled;
        state.setState(() {});
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
          _item('View on GitHub', 'A'),
          _item('Toggle Values', 'B'),
          _item('Toggle Icons', 'C'),
          _item('Toggle Highlight', 'D'),
          _item('Toggle Shadow Color', 'K'),
          _item('Toggle PinchZoom', 'H'),
          _item('Toggle Auto Scale', 'I'),
          _item('Animate X', 'E'),
          _item('Animate Y', 'F'),
          _item('Animate XY', 'G'),
          _item('Save to Gallery', 'J'),
        ];
  }

  @override
  void itemClick(String action) {
    var state = candlestickChart?.getState();
    var painter = state?.painter as CandlestickChartPainter;
    if (state == null || painter == null) {
      return;
    }

    switch (action) {
      case 'A':
        Util.openGithub();
        break;
      case 'B':
        for (IDataSet set in painter.getData().getDataSets())
          set.setDrawValues(!set.isDrawValuesEnabled());
        state.setState(() {});
        break;
      case 'C':
        // todo icons
        break;
      case 'D':
        if (painter.getData() != null) {
          painter
              .getData()
              .setHighlightEnabled(!painter.getData().isHighlightEnabled());
          state.setState(() {});
        }
        break;
      case 'E':
        painter.mAnimator
          ..reset()
          ..animateX1(2000);
        break;
      case 'F':
        painter.mAnimator
          ..reset()
          ..animateY1(2000);
        break;
      case 'G':
        painter.mAnimator
          ..reset()
          ..animateXY1(2000, 2000);
        break;
      case 'H':
        painter.mPinchZoomEnabled = !painter.mPinchZoomEnabled;
        state.setState(() {});
        break;
      case 'I':
        painter.mAutoScaleMinMaxEnabled = !painter.mAutoScaleMinMaxEnabled;
        state.setState(() {});
        break;
      case 'J':
        // todo save
        break;
      case 'K':
        for (ICandleDataSet set in painter.getData().getDataSets()) {
          (set as CandleDataSet)
              .setShadowColorSameAsCandle(!set.getShadowColorSameAsCandle());
        }
        state.setState(() {});
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
          _item('View on GitHub', 'A'),
          _item('Toggle Values', 'B'),
          _item('Toggle Icons', 'C'),
          _item('Toggle Filled', 'D'),
          _item('Toggle Highlight', 'E'),
          _item('Toggle Highlight Circle', 'F'),
          _item('Toggle Rotation', 'G'),
          _item('Toggle Y-Values', 'H'),
          _item('Toggle X-Values', 'I'),
          _item('Spin Animation', 'J'),
          _item('Animate X', 'K'),
          _item('Animate Y', 'L'),
          _item('Animate XY', 'M'),
          _item('Save to Gallery', 'N'),
        ];
  }

  @override
  void itemClick(String action) {
    var state = radarChart?.getState();
    var painter = state?.painter as RadarChartPainter;
    if (state == null || painter == null) {
      return;
    }

    switch (action) {
      case 'A':
        Util.openGithub();
        break;
      case 'B':
        for (IDataSet set in painter.getData().getDataSets())
          set.setDrawValues(!set.isDrawValuesEnabled());
        state.setState(() {});
        break;
      case 'C':
        // todo icons
        break;
      case 'D':
        List<IRadarDataSet> sets = painter.getData().getDataSets();
        for (IRadarDataSet set in sets) {
          if (set.isDrawFilledEnabled())
            set.setDrawFilled(false);
          else
            set.setDrawFilled(true);
        }
        state.setState(() {});
        break;
      case 'E':
        if (painter.getData() != null) {
          painter
              .getData()
              .setHighlightEnabled(!painter.getData().isHighlightEnabled());
          state.setState(() {});
        }
        break;
      case 'F':
        List<IRadarDataSet> sets = painter.getData().getDataSets();
        for (IRadarDataSet set in sets) {
          set.setDrawHighlightCircleEnabled(
              !set.isDrawHighlightCircleEnabled());
        }
        state.setState(() {});
        break;
      case 'G':
        if (painter.isRotationEnabled())
          painter.setRotationEnabled(false);
        else
          painter.setRotationEnabled(true);
        state.setState(() {});
        break;
      case 'H':
        painter.getYAxis().setEnabled(!painter.getYAxis().isEnabled());
        state.setState(() {});
        break;
      case 'I':
        painter.mXAxis.setEnabled(!painter.mXAxis.isEnabled());
        state.setState(() {});
        break;
      case 'J':
        // chart.spin(2000, chart.getRotationAngle(), chart.getRotationAngle() + 360, Easing.EaseInOutCubic);
        //                todo
        break;
      case 'K':
        painter.mAnimator
          ..reset()
          ..animateX1(1400);
        break;
      case 'L':
        painter.mAnimator
          ..reset()
          ..animateY1(1400);
        break;
      case 'M':
        painter.mAnimator
          ..reset()
          ..animateXY1(1400, 1400);
        break;
      case 'N':
        // todo save
        break;
    }
  }
}
