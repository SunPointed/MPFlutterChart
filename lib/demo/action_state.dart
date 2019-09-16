import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mp_flutter_chart/chart/mp/chart/bar_chart.dart';
import 'package:mp_flutter_chart/chart/mp/chart/horizontal_bar_chart.dart';
import 'package:mp_flutter_chart/chart/mp/chart/line_chart.dart';
import 'package:mp_flutter_chart/chart/mp/core/animator.dart';
import 'package:mp_flutter_chart/chart/mp/core/data/bar_data.dart';
import 'package:mp_flutter_chart/chart/mp/core/data/line_data.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_interfaces/i_bar_data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_interfaces/i_data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_interfaces/i_line_data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_set/bar_data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_set/line_data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/enums/mode.dart';
import 'package:mp_flutter_chart/chart/mp/core/utils/color_utils.dart';
import 'package:mp_flutter_chart/chart/mp/painter/bar_chart_painter.dart';
import 'package:mp_flutter_chart/chart/mp/painter/line_chart_painter.dart';
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
        // todo icons
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
        // todo icons
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

abstract class HorizontalBarActionState<T extends StatefulWidget> extends ActionState<T> {
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
      // todo icons
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
