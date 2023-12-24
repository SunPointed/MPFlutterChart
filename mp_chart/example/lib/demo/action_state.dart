import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mp_chart/mp/controller/bar_chart_controller.dart';
import 'package:mp_chart/mp/controller/bubble_chart_controller.dart';
import 'package:mp_chart/mp/controller/candlestick_chart_controller.dart';
import 'package:mp_chart/mp/controller/combined_chart_controller.dart';
import 'package:mp_chart/mp/controller/horizontal_bar_chart_controller.dart';
import 'package:mp_chart/mp/controller/line_chart_controller.dart';
import 'package:mp_chart/mp/controller/pie_chart_controller.dart';
import 'package:mp_chart/mp/controller/radar_chart_controller.dart';
import 'package:mp_chart/mp/controller/scatter_chart_controller.dart';
import 'package:mp_chart/mp/core/animator.dart';
import 'package:mp_chart/mp/core/data_interfaces/i_bar_data_set.dart';
import 'package:mp_chart/mp/core/data_interfaces/i_candle_data_set.dart';
import 'package:mp_chart/mp/core/data_interfaces/i_data_set.dart';
import 'package:mp_chart/mp/core/data_interfaces/i_line_data_set.dart';
import 'package:mp_chart/mp/core/data_interfaces/i_radar_data_set.dart';
import 'package:mp_chart/mp/core/data_interfaces/i_scatter_data_set.dart';
import 'package:mp_chart/mp/core/data_set/bar_data_set.dart';
import 'package:mp_chart/mp/core/data_set/candle_data_set.dart';
import 'package:mp_chart/mp/core/data_set/line_data_set.dart';
import 'package:mp_chart/mp/core/data_set/scatter_data_set.dart';
import 'package:mp_chart/mp/core/enums/axis_dependency.dart';
import 'package:mp_chart/mp/core/enums/mode.dart';
import 'package:mp_chart/mp/core/utils/color_utils.dart';
import 'package:example/demo/util.dart';
import 'package:permission_handler/permission_handler.dart';

PopupMenuItem item(String text, String id) {
  return PopupMenuItem<String>(
    value: id,
    child: Container(
      padding: EdgeInsets.only(top: 15),
      child: Center(
        child: Text(
          text,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: ColorUtils.BLACK,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),
  );
}

abstract class ActionState<T extends StatefulWidget> extends State<T> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          PopupMenuButton<String>(
            itemBuilder: getBuilder(),
            onSelected: itemClick,
          ),
        ],
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(getTitle()),
      ),
      body: getBody(),
    );
  }

  void itemClick(String action);

  Widget getBody();

  String getTitle();

  PopupMenuItemBuilder<String> getBuilder();

  Future<void> captureImg(CaptureCallback callback) async {
    final status = await Permission.storage.request();
    if (status.isGranted) {
      callback();
      return;
    }
    if (Platform.isIOS) {
      if (status.isRestricted) {
        callback();
        return;
      }
    }
  }
}

typedef CaptureCallback = void Function();

abstract class SimpleActionState<T extends StatefulWidget>
    extends ActionState<T> {
  @override
  void itemClick(String action) {
    Util.openGithub();
  }

  @override
  getBuilder() {
    return (context) => <PopupMenuItem<String>>[
          item('View on GitHub', 'A') as PopupMenuItem<String>
        ];
  }
}

abstract class LineActionState<T extends StatefulWidget>
    extends ActionState<T> {
  LineChartController? controller;

  @override
  getBuilder() {
    return (context) => <PopupMenuItem<String>>[
          item('View on GitHub', 'A') as PopupMenuItem<String>,
          item('Toggle Values', 'B') as PopupMenuItem<String>,
          item('Toggle Icons', 'C') as PopupMenuItem<String>,
          item('Toggle Filled', 'D') as PopupMenuItem<String>,
          item('Toggle Circles', 'E') as PopupMenuItem<String>,
          item('Toggle Cubic', 'F') as PopupMenuItem<String>,
          item('Toggle Stepped', 'G') as PopupMenuItem<String>,
          item('Toggle Horizontal Cubic', 'H') as PopupMenuItem<String>,
          item('Toggle PinchZoom', 'I') as PopupMenuItem<String>,
          item('Toggle Auto Scale', 'J') as PopupMenuItem<String>,
          item('Toggle Highlight', 'K') as PopupMenuItem<String>,
          item('Animate X', 'L') as PopupMenuItem<String>,
          item('Animate Y', 'M') as PopupMenuItem<String>,
          item('Animate XY', 'N') as PopupMenuItem<String>,
          item('Save to Gallery', 'O') as PopupMenuItem<String>,
        ];
  }

  @override
  void itemClick(String action) {
    if (controller!.state == null) {
      return;
    }

    switch (action) {
      case 'A':
        Util.openGithub();
        break;
      case 'B':
        List<ILineDataSet> sets = controller!.data!.dataSets!;
        for (ILineDataSet iSet in sets) {
          LineDataSet set = iSet as LineDataSet;
          set.setDrawValues(!set.isDrawValuesEnabled());
        }
        controller!.state!.setStateIfNotDispose();
        break;
      case 'C':
        List<ILineDataSet> sets = controller!.data!.dataSets!;
        for (ILineDataSet iSet in sets) {
          LineDataSet set = iSet as LineDataSet;
          set.setDrawIcons(!set.isDrawIconsEnabled());
        }
        controller!.state!.setStateIfNotDispose();
        break;
      case 'D':
        List<ILineDataSet> sets = controller!.data!.dataSets!;

        for (ILineDataSet iSet in sets) {
          LineDataSet set = iSet as LineDataSet;
          if (set.isDrawFilledEnabled())
            set.setDrawFilled(false);
          else
            set.setDrawFilled(true);
        }
        controller!.state!.setStateIfNotDispose();
        break;
      case 'E':
        List<ILineDataSet> sets = controller!.data!.dataSets!;

        for (ILineDataSet iSet in sets) {
          LineDataSet set = iSet as LineDataSet;
          if (set.isDrawCirclesEnabled())
            set.setDrawCircles(false);
          else
            set.setDrawCircles(true);
        }
        controller!.state!.setStateIfNotDispose();
        break;
      case 'F':
        List<ILineDataSet> sets = controller!.data!.dataSets!;

        for (ILineDataSet iSet in sets) {
          LineDataSet set = iSet as LineDataSet;
          set.setMode(set.getMode() == Mode.CUBIC_BEZIER
              ? Mode.LINEAR
              : Mode.CUBIC_BEZIER);
        }
        controller!.state!.setStateIfNotDispose();
        break;
      case 'G':
        List<ILineDataSet> sets = controller!.data!.dataSets!;

        for (ILineDataSet iSet in sets) {
          LineDataSet set = iSet as LineDataSet;
          set.setMode(
              set.getMode() == Mode.STEPPED ? Mode.LINEAR : Mode.STEPPED);
        }
        controller!.state!.setStateIfNotDispose();
        break;
      case 'H':
        List<ILineDataSet> sets = controller!.data!.dataSets!;

        for (ILineDataSet iSet in sets) {
          LineDataSet set = iSet as LineDataSet;
          set.setMode(set.getMode() == Mode.HORIZONTAL_BEZIER
              ? Mode.LINEAR
              : Mode.HORIZONTAL_BEZIER);
        }
        controller!.state!.setStateIfNotDispose();
        break;
      case 'I':
        controller!.pinchZoomEnabled = !controller!.pinchZoomEnabled;
        controller!.state!.setStateIfNotDispose();
        break;
      case 'J':
        controller!.autoScaleMinMaxEnabled =
            !controller!.autoScaleMinMaxEnabled;
        controller!.state!.setStateIfNotDispose();
        break;
      case 'K':
        if (controller!.data != null) {
          controller!.data!
              .setHighlightEnabled(!controller!.data!.isHighlightEnabled());
          controller!.state!.setStateIfNotDispose();
        }
        break;
      case 'L':
        controller!.animator!
          ..reset()
          ..animateX1(2000);
        break;
      case 'M':
        controller!.animator!
          ..reset()
          ..animateY2(2000, MpEasing.EaseInCubic);
        break;
      case 'N':
        controller!.animator!
          ..reset()
          ..animateXY1(2000, 2000);
        break;
      case 'O':
        captureImg(() {
          controller!.state!.capture();
        });
        break;
    }
  }
}

abstract class BarActionState<T extends StatefulWidget> extends ActionState<T> {
  late BarChartController controller;

  @override
  getBuilder() {
    return (context) => <PopupMenuItem<String>>[
          item('View on GitHub', 'A') as PopupMenuItem<String>,
          item('Toggle Bar Borders', 'B') as PopupMenuItem<String>,
          item('Toggle Values', 'C') as PopupMenuItem<String>,
          item('Toggle Icons', 'D') as PopupMenuItem<String>,
          item('Toggle Highlight', 'E') as PopupMenuItem<String>,
          item('Toggle PinchZoom', 'F') as PopupMenuItem<String>,
          item('Toggle Auto Scale', 'G') as PopupMenuItem<String>,
          item('Animate X', 'H') as PopupMenuItem<String>,
          item('Animate Y', 'I') as PopupMenuItem<String>,
          item('Animate XY', 'J') as PopupMenuItem<String>,
          item('Save to Gallery', 'K') as PopupMenuItem<String>,
        ];
  }

  @override
  void itemClick(String action) {
    if (controller.state == null) {
      return;
    }

    switch (action) {
      case 'A':
        Util.openGithub();
        break;
      case 'B':
        for (IBarDataSet set in controller.data!.dataSets!)
          (set as BarDataSet)
              .setBarBorderWidth(set.getBarBorderWidth() == 1.0 ? 0.0 : 1.0);
        controller.state!.setStateIfNotDispose();
        break;
      case 'C':
        for (IDataSet set in controller.data!.dataSets!)
          set.setDrawValues(!set.isDrawValuesEnabled());
        controller.state!.setStateIfNotDispose();
        break;
      case 'D':
        List<IBarDataSet> sets = controller.data!.dataSets!;
        for (IBarDataSet iSet in sets) {
          BarDataSet set = iSet as BarDataSet;
          set.setDrawIcons(!set.isDrawIconsEnabled());
        }
        controller.state!.setStateIfNotDispose();
        break;
      case 'E':
        if (controller.data != null) {
          controller.data!
              .setHighlightEnabled(!controller.data!.isHighlightEnabled());
          controller.state!.setStateIfNotDispose();
        }
        break;
      case 'F':
        controller.pinchZoomEnabled = !controller.pinchZoomEnabled;
        controller.state!.setStateIfNotDispose();
        break;
      case 'G':
        controller.autoScaleMinMaxEnabled = !controller.autoScaleMinMaxEnabled;
        controller.state!.setStateIfNotDispose();
        break;
      case 'H':
        controller.animator!
          ..reset()
          ..animateX1(2000);
        break;
      case 'I':
        controller.animator!
          ..reset()
          ..animateY1(2000);
        break;
      case 'J':
        controller.animator!
          ..reset()
          ..animateXY1(2000, 2000);
        break;
      case 'K':
        captureImg(() {
          controller.state!.capture();
        });
        break;
    }
  }
}

abstract class HorizontalBarActionState<T extends StatefulWidget>
    extends ActionState<T> {
  late HorizontalBarChartController controller;

  @override
  getBuilder() {
    return (context) => <PopupMenuItem<String>>[
          item('View on GitHub', 'A') as PopupMenuItem<String>,
          item('Toggle Bar Borders', 'B') as PopupMenuItem<String>,
          item('Toggle Values', 'C') as PopupMenuItem<String>,
          item('Toggle Icons', 'D') as PopupMenuItem<String>,
          item('Toggle Highlight', 'E') as PopupMenuItem<String>,
          item('Toggle PinchZoom', 'F') as PopupMenuItem<String>,
          item('Toggle Auto Scale', 'G') as PopupMenuItem<String>,
          item('Animate X', 'H') as PopupMenuItem<String>,
          item('Animate Y', 'I') as PopupMenuItem<String>,
          item('Animate XY', 'J') as PopupMenuItem<String>,
          item('Save to Gallery', 'K') as PopupMenuItem<String>,
        ];
  }

  @override
  void itemClick(String action) {
    if (controller.state == null) {
      return;
    }

    switch (action) {
      case 'A':
        Util.openGithub();
        break;
      case 'B':
        for (IBarDataSet set in controller.data!.dataSets!)
          (set as BarDataSet)
              .setBarBorderWidth(set.getBarBorderWidth() == 1.0 ? 0.0 : 1.0);
        controller.state!.setStateIfNotDispose();
        break;
      case 'C':
        for (IDataSet set in controller.data!.dataSets!)
          set.setDrawValues(!set.isDrawValuesEnabled());
        controller.state!.setStateIfNotDispose();
        break;
      case 'D':
        List<IBarDataSet> sets = controller.data!.dataSets!;
        for (IBarDataSet iSet in sets) {
          BarDataSet set = iSet as BarDataSet;
          set.setDrawIcons(!set.isDrawIconsEnabled());
        }
        controller.state!.setStateIfNotDispose();
        break;
      case 'E':
        if (controller.data != null) {
          controller.data!
              .setHighlightEnabled(!controller.data!.isHighlightEnabled());
          controller.state!.setStateIfNotDispose();
        }
        break;
      case 'F':
        controller.pinchZoomEnabled = !controller.pinchZoomEnabled;
        controller.state!.setStateIfNotDispose();
        break;
      case 'G':
        controller.autoScaleMinMaxEnabled = !controller.autoScaleMinMaxEnabled;
        controller.state!.setStateIfNotDispose();
        break;
      case 'H':
        controller.animator!
          ..reset()
          ..animateX1(2000);
        break;
      case 'I':
        controller.animator!
          ..reset()
          ..animateY1(2000);
        break;
      case 'J':
        controller.animator!
          ..reset()
          ..animateXY1(2000, 2000);
        break;
      case 'K':
        captureImg(() {
          controller.state!.capture();
        });
        break;
    }
  }
}

abstract class PieActionState<T extends StatefulWidget> extends ActionState<T> {
  late PieChartController controller;

  @override
  getBuilder() {
    return (context) => <PopupMenuItem<String>>[
          item('View on GitHub', 'A') as PopupMenuItem<String>,
          item('Toggle Y-Values', 'B') as PopupMenuItem<String>,
          item('Toggle X-Values', 'C') as PopupMenuItem<String>,
          item('Toggle Icons', 'D') as PopupMenuItem<String>,
          item('Toggle Percent', 'E') as PopupMenuItem<String>,
          item('Toggle Minimum Angles', 'F') as PopupMenuItem<String>,
          item('Toggle Hole', 'G') as PopupMenuItem<String>,
          item('Toggle Curved Slices Cubic', 'H') as PopupMenuItem<String>,
          item('Draw Center Text', 'I') as PopupMenuItem<String>,
          item('Spin Animation', 'J') as PopupMenuItem<String>,
          item('Animate X', 'K') as PopupMenuItem<String>,
          item('Animate Y', 'L') as PopupMenuItem<String>,
          item('Animate XY', 'M') as PopupMenuItem<String>,
          item('Save to Gallery', 'N') as PopupMenuItem<String>,
        ];
  }

  @override
  void itemClick(String action) {
    if (controller.state == null) {
      return;
    }

    switch (action) {
      case 'A':
        Util.openGithub();
        break;
      case 'B':
        for (IDataSet set in controller.data!.dataSets!)
          set.setDrawValues(!set.isDrawValuesEnabled());
        controller.state!.setStateIfNotDispose();
        break;
      case 'C':
        controller.drawEntryLabels = !controller.drawEntryLabels;
        controller.state!.setStateIfNotDispose();
        break;
      case 'D':
        for (IDataSet set in controller.data!.dataSets!)
          set.setDrawIcons(!set.isDrawIconsEnabled());
        controller.state!.setStateIfNotDispose();
        break;
      case 'E':
        controller.usePercentValues = !controller.usePercentValues;
        controller.state!.setStateIfNotDispose();
        break;
      case 'F':
        if (controller.minAngleForSlices == 0) {
          controller.minAngleForSlices = 36;
        } else {
          controller.minAngleForSlices = 0;
        }
        controller.state!.setStateIfNotDispose();
        break;
      case 'G':
        controller.drawHole = !controller.drawHole;
        controller.state!.setStateIfNotDispose();
        break;
      case 'H':
        bool toSet = !controller.drawRoundedSlices || !controller.drawHole;
        controller.drawRoundedSlices = toSet;
        if (toSet && !controller.drawHole) {
          controller.drawHole = true;
        }
        if (toSet && controller.drawSlicesUnderHole) {
          controller.drawSlicesUnderHole = false;
        }
        controller.state!.setStateIfNotDispose();
        break;
      case 'I':
        controller.drawCenterText = !controller.drawCenterText;
        controller.state!.setStateIfNotDispose();
        break;
      case 'J':
        controller.animator!
          ..reset()
          ..spin(2000, controller.rotationAngle, controller.rotationAngle + 360,
              MpEasing.EaseInOutCubic);
        break;
      case 'K':
        controller.animator!
          ..reset()
          ..animateX1(1400);
        break;
      case 'L':
        controller.animator!
          ..reset()
          ..animateY1(1400);
        break;
      case 'M':
        controller.animator!
          ..reset()
          ..animateXY1(1400, 1400);
        break;
      case 'N':
        captureImg(() {
          controller.state!.capture();
        });
        break;
    }
  }
}

abstract class CombinedActionState<T extends StatefulWidget>
    extends ActionState<T> {
  late CombinedChartController controller;

  @override
  getBuilder() {
    return (context) => <PopupMenuItem<String>>[
          item('View on GitHub', 'A') as PopupMenuItem<String>,
          item('Toggle Line Values', 'B') as PopupMenuItem<String>,
          item('Toggle Bar Values', 'C') as PopupMenuItem<String>,
          item('Remove Data Set', 'D') as PopupMenuItem<String>,
          item('Set Y Range Test', 'E') as PopupMenuItem<String>
        ];
  }

  @override
  void itemClick(String action) {
    if (controller.state == null) {
      return;
    }

    switch (action) {
      case 'A':
        Util.openGithub();
        break;
      case 'B':
        for (IDataSet set in controller.data!.dataSets!) {
          if (set is LineDataSet) set.setDrawValues(!set.isDrawValuesEnabled());
        }
        controller.state!.setStateIfNotDispose();
        break;
      case 'C':
        for (IDataSet set in controller.data!.dataSets!) {
          if (set is BarDataSet) set.setDrawValues(!set.isDrawValuesEnabled());
        }
        controller.state!.setStateIfNotDispose();
        break;
      case 'D':
        if (controller.data!.getDataSetCount() > 1) {
          int rnd = _getRandom(controller.data!.getDataSetCount().toDouble(), 0)
              .toInt();
          controller.data!
              .removeDataSet1(controller.data!.getDataSetByIndex(rnd));
          controller.data!.notifyDataChanged();
          controller.state!.setStateIfNotDispose();
        }
        break;
      case 'E':
        controller.setVisibleYRangeMaximum(100, AxisDependency.LEFT);
        controller.state!.setStateIfNotDispose();
        break;
    }
  }

  double _getRandom(double range, double start) {
    return (Random(1).nextDouble() * range) + start;
  }
}

abstract class ScatterActionState<T extends StatefulWidget>
    extends ActionState<T> {
  late ScatterChartController controller;

  @override
  getBuilder() {
    return (context) => <PopupMenuItem<String>>[
          item('View on GitHub', 'A') as PopupMenuItem<String>,
          item('Toggle Values', 'B') as PopupMenuItem<String>,
          item('Toggle Icons', 'C') as PopupMenuItem<String>,
          item('Toggle Highlight', 'D') as PopupMenuItem<String>,
          item('Animate X', 'E') as PopupMenuItem<String>,
          item('Animate Y', 'F') as PopupMenuItem<String>,
          item('Animate XY', 'G') as PopupMenuItem<String>,
          item('Toggle PinchZoom', 'H') as PopupMenuItem<String>,
          item('Toggle Auto Scale', 'I') as PopupMenuItem<String>,
          item('Save to Gallery', 'J') as PopupMenuItem<String>,
        ];
  }

  @override
  void itemClick(String action) {
    if (controller.state == null) {
      return;
    }

    switch (action) {
      case 'A':
        Util.openGithub();
        break;
      case 'B':
        List<IScatterDataSet> sets = controller.data!.dataSets!;
        for (IScatterDataSet iSet in sets) {
          ScatterDataSet set = iSet as ScatterDataSet;
          set.setDrawValues(!set.isDrawValuesEnabled());
        }
        controller.state!.setStateIfNotDispose();
        break;
      case 'C':
        for (IDataSet set in controller.data!.dataSets!)
          set.setDrawIcons(!set.isDrawIconsEnabled());
        controller.state!.setStateIfNotDispose();
        break;
      case 'D':
        if (controller.data != null) {
          controller.data!
              .setHighlightEnabled(!controller.data!.isHighlightEnabled());
          controller.state!.setStateIfNotDispose();
        }
        break;
      case 'E':
        controller.animator!
          ..reset()
          ..animateX1(3000);
        break;
      case 'F':
        controller.animator!
          ..reset()
          ..animateY1(3000);
        break;
      case 'G':
        controller.animator!
          ..reset()
          ..animateXY1(3000, 3000);
        break;
      case 'H':
        controller.pinchZoomEnabled = !controller.pinchZoomEnabled;
        controller.state!.setStateIfNotDispose();
        break;
      case 'I':
        controller.autoScaleMinMaxEnabled = !controller.autoScaleMinMaxEnabled;
        controller.state!.setStateIfNotDispose();
        break;
      case 'J':
        captureImg(() {
          controller.state!.capture();
        });
        break;
    }
  }
}

abstract class BubbleActionState<T extends StatefulWidget>
    extends ActionState<T> {
  late BubbleChartController controller;

  @override
  getBuilder() {
    return (context) => <PopupMenuItem<String>>[
          item('View on GitHub', 'A') as PopupMenuItem<String>,
          item('Toggle Values', 'B') as PopupMenuItem<String>,
          item('Toggle Icons', 'C') as PopupMenuItem<String>,
          item('Toggle Highlight', 'D') as PopupMenuItem<String>,
          item('Toggle PinchZoom', 'H') as PopupMenuItem<String>,
          item('Toggle Auto Scale', 'I') as PopupMenuItem<String>,
          item('Animate X', 'E') as PopupMenuItem<String>,
          item('Animate Y', 'F') as PopupMenuItem<String>,
          item('Animate XY', 'G') as PopupMenuItem<String>,
          item('Save to Gallery', 'J') as PopupMenuItem<String>,
        ];
  }

  @override
  void itemClick(String action) {
    if (controller.state == null) {
      return;
    }

    switch (action) {
      case 'A':
        Util.openGithub();
        break;
      case 'B':
        for (IDataSet set in controller.data!.dataSets!)
          set.setDrawValues(!set.isDrawValuesEnabled());
        controller.state!.setStateIfNotDispose();
        break;
      case 'C':
        for (IDataSet set in controller.data!.dataSets!)
          set.setDrawIcons(!set.isDrawIconsEnabled());
        controller.state!.setStateIfNotDispose();
        break;
      case 'D':
        if (controller.data != null) {
          controller.data!
              .setHighlightEnabled(!controller.data!.isHighlightEnabled());
          controller.state!.setStateIfNotDispose();
        }
        break;
      case 'E':
        controller.animator!
          ..reset()
          ..animateX1(2000);
        break;
      case 'F':
        controller.animator!
          ..reset()
          ..animateY1(2000);
        break;
      case 'G':
        controller.animator!
          ..reset()
          ..animateXY1(2000, 2000);
        break;
      case 'H':
        controller.pinchZoomEnabled = !controller.pinchZoomEnabled;
        controller.state!.setStateIfNotDispose();
        break;
      case 'I':
        controller.autoScaleMinMaxEnabled = !controller.autoScaleMinMaxEnabled;
        controller.state!.setStateIfNotDispose();
        break;
      case 'J':
        captureImg(() {
          controller.state!.capture();
        });
        break;
    }
  }
}

abstract class CandlestickActionState<T extends StatefulWidget>
    extends ActionState<T> {
  late CandlestickChartController controller;

  @override
  getBuilder() {
    return (context) => <PopupMenuItem<String>>[
          item('View on GitHub', 'A') as PopupMenuItem<String>,
          item('Toggle Values', 'B') as PopupMenuItem<String>,
          item('Toggle Icons', 'C') as PopupMenuItem<String>,
          item('Toggle Highlight', 'D') as PopupMenuItem<String>,
          item('Toggle Shadow Color', 'K') as PopupMenuItem<String>,
          item('Toggle PinchZoom', 'H') as PopupMenuItem<String>,
          item('Toggle Auto Scale', 'I') as PopupMenuItem<String>,
          item('Animate X', 'E') as PopupMenuItem<String>,
          item('Animate Y', 'F') as PopupMenuItem<String>,
          item('Animate XY', 'G') as PopupMenuItem<String>,
          item('Save to Gallery', 'J') as PopupMenuItem<String>,
        ];
  }

  @override
  void itemClick(String action) {
    if (controller.state == null) {
      return;
    }

    switch (action) {
      case 'A':
        Util.openGithub();
        break;
      case 'B':
        for (IDataSet set in controller.data!.dataSets!)
          set.setDrawValues(!set.isDrawValuesEnabled());
        controller.state!.setStateIfNotDispose();
        break;
      case 'C':
        for (IDataSet set in controller.data!.dataSets!)
          set.setDrawIcons(!set.isDrawIconsEnabled());
        controller.state!.setStateIfNotDispose();
        break;
      case 'D':
        if (controller.data != null) {
          controller.data!
              .setHighlightEnabled(!controller.data!.isHighlightEnabled());
          controller.state!.setStateIfNotDispose();
        }
        break;
      case 'E':
        controller.animator!
          ..reset()
          ..animateX1(2000);
        break;
      case 'F':
        controller.animator!
          ..reset()
          ..animateY1(2000);
        break;
      case 'G':
        controller.animator!
          ..reset()
          ..animateXY1(2000, 2000);
        break;
      case 'H':
        controller.pinchZoomEnabled = !controller.pinchZoomEnabled;
        controller.state!.setStateIfNotDispose();
        break;
      case 'I':
        controller.autoScaleMinMaxEnabled = !controller.autoScaleMinMaxEnabled;
        controller.state!.setStateIfNotDispose();
        break;
      case 'J':
        captureImg(() {
          controller.state!.capture();
        });
        break;
      case 'K':
        for (ICandleDataSet set in controller.data!.dataSets!) {
          (set as CandleDataSet)
              .setShadowColorSameAsCandle(!set.getShadowColorSameAsCandle());
        }
        controller.state!.setStateIfNotDispose();
        break;
    }
  }
}

abstract class RadarActionState<T extends StatefulWidget>
    extends ActionState<T> {
  late RadarChartController controller;

  @override
  getBuilder() {
    return (context) => <PopupMenuItem<String>>[
          item('View on GitHub', 'A') as PopupMenuItem<String>,
          item('Toggle Values', 'B') as PopupMenuItem<String>,
          item('Toggle Icons', 'C') as PopupMenuItem<String>,
          item('Toggle Filled', 'D') as PopupMenuItem<String>,
          item('Toggle Highlight', 'E') as PopupMenuItem<String>,
          item('Toggle Highlight Circle', 'F') as PopupMenuItem<String>,
          item('Toggle Rotation', 'G') as PopupMenuItem<String>,
          item('Toggle Y-Values', 'H') as PopupMenuItem<String>,
          item('Toggle X-Values', 'I') as PopupMenuItem<String>,
          item('Spin Animation', 'J') as PopupMenuItem<String>,
          item('Animate X', 'K') as PopupMenuItem<String>,
          item('Animate Y', 'L') as PopupMenuItem<String>,
          item('Animate XY', 'M') as PopupMenuItem<String>,
          item('Save to Gallery', 'N') as PopupMenuItem<String>,
        ];
  }

  @override
  void itemClick(String action) {
    if (controller.state == null) {
      return;
    }

    switch (action) {
      case 'A':
        Util.openGithub();
        break;
      case 'B':
        for (IDataSet set in controller.data!.dataSets!)
          set.setDrawValues(!set.isDrawValuesEnabled());
        controller.state!.setStateIfNotDispose();
        break;
      case 'C':
        for (IDataSet set in controller.data!.dataSets!)
          set.setDrawIcons(!set.isDrawIconsEnabled());
        controller.state!.setStateIfNotDispose();
        break;
      case 'D':
        List<IRadarDataSet> sets = controller.data!.dataSets!;
        for (IRadarDataSet set in sets) {
          if (set.isDrawFilledEnabled())
            set.setDrawFilled(false);
          else
            set.setDrawFilled(true);
        }
        controller.state!.setStateIfNotDispose();
        break;
      case 'E':
        if (controller.data != null) {
          controller.data!
              .setHighlightEnabled(!controller.data!.isHighlightEnabled());
          controller.state!.setStateIfNotDispose();
        }
        break;
      case 'F':
        List<IRadarDataSet> sets = controller.data!.dataSets!;
        for (IRadarDataSet set in sets) {
          set.setDrawHighlightCircleEnabled(
              !set.isDrawHighlightCircleEnabled());
        }
        controller.state!.setStateIfNotDispose();
        break;
      case 'G':
        controller.rotateEnabled = !controller.rotateEnabled;
        controller.state!.setStateIfNotDispose();
        break;
      case 'H':
        controller.yAxis!.enabled = !controller.yAxis!.enabled;
        controller.state!.setStateIfNotDispose();
        break;
      case 'I':
        controller.xAxis!.enabled = !controller.xAxis!.enabled;
        controller.state!.setStateIfNotDispose();
        break;
      case 'J':
        controller.animator!
          ..reset()
          ..spin(2000, controller.rotationAngle, controller.rotationAngle + 360,
              MpEasing.EaseInOutCubic);
        break;
      case 'K':
        controller.animator!
          ..reset()
          ..animateX1(1400);
        break;
      case 'L':
        controller.animator!
          ..reset()
          ..animateY1(1400);
        break;
      case 'M':
        controller.animator!
          ..reset()
          ..animateXY1(1400, 1400);
        break;
      case 'N':
        captureImg(() {
          controller.state!.capture();
        });
        break;
    }
  }
}
