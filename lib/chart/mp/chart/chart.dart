import 'package:flutter/widgets.dart';
import 'package:mp_flutter_chart/chart/mp/core/animator.dart';
import 'package:mp_flutter_chart/chart/mp/core/data.dart';
import 'package:mp_flutter_chart/chart/mp/core/description.dart';
import 'package:mp_flutter_chart/chart/mp/core/interfaces.dart';
import 'package:mp_flutter_chart/chart/mp/core/render.dart';
import 'package:mp_flutter_chart/chart/mp/core/view_port.dart';
import 'package:mp_flutter_chart/chart/mp/listener.dart';
import 'package:mp_flutter_chart/chart/mp/painter/painter.dart';

abstract class Chart extends StatefulWidget {
  InitPainterCallback _initialPainterCallback;

  ////////////////////////////////////////////
  ChartData data;
  Color backgroundColor = null;
  Color borderColor = null;
  double borderStrokeWidth = 1.0;
  bool keepPositionOnRotation = false;
  bool pinchZoomEnabled = false;
  XAxisRenderer xAxisRenderer = null;
  YAxisRenderer rendererLeftYAxis = null;
  YAxisRenderer rendererRightYAxis = null;
  bool autoScaleMinMaxEnabled = false;
  double minOffset = 15;
  bool clipValuesToContent = false;
  bool drawBorders = false;
  bool drawGridBackground = false;
  bool doubleTapToZoomEnabled = true;
  bool scaleXEnabled = true;
  bool scaleYEnabled = true;
  bool dragXEnabled = true;
  bool dragYEnabled = true;
  bool highlightPerDragEnabled = true;
  int maxVisibleCount = 100;
  OnDrawListener drawListener = null;
  double minXRange = 1.0;
  double maxXRange = 1.0;
  double minimumScaleX = 1.0;
  double minimumScaleY = 1.0;
  double maxHighlightDistance = 0.0;
  bool highLightPerTapEnabled = true;
  bool dragDecelerationEnabled = true;
  double dragDecelerationFrictionCoef = 0.9;
  double extraLeftOffset = 0.0;
  double extraTopOffset = 0.0;
  double extraRightOffset = 0.0;
  double extraBottomOffset = 0.0;
  String noDataText = "No chart data available.";
  bool touchEnabled = true;
  IMarker marker = null;
  Description desc = null;
  bool drawMarkers = true;
  TextPainter infoPainter = null;
  TextPainter descPainter = null;
  IHighlighter highlighter = null;
  bool unbind = false;

/////////////////////////////////

  ViewPortHandler viewPortHandler = ViewPortHandler();

  Chart(ChartData data, InitPainterCallback initialPainterCallback,
      {Color backgroundColor = null,
      Color borderColor = null,
      double borderStrokeWidth = 1.0,
      bool keepPositionOnRotation = false,
      bool pinchZoomEnabled = false,
      XAxisRenderer xAxisRenderer = null,
      YAxisRenderer rendererLeftYAxis = null,
      YAxisRenderer rendererRightYAxis = null,
      bool autoScaleMinMaxEnabled = false,
      double minOffset = 30,
      bool clipValuesToContent = false,
      bool drawBorders = false,
      bool drawGridBackground = false,
      bool doubleTapToZoomEnabled = true,
      bool scaleXEnabled = true,
      bool scaleYEnabled = true,
      bool dragXEnabled = true,
      bool dragYEnabled = true,
      bool highlightPerDragEnabled = true,
      int maxVisibleCount = 100,
      OnDrawListener drawListener = null,
      double minXRange = 1.0,
      double maxXRange = 1.0,
      double minimumScaleX = 1.0,
      double minimumScaleY = 1.0,
      double maxHighlightDistance = 0.0,
      bool highLightPerTapEnabled = true,
      bool dragDecelerationEnabled = true,
      double dragDecelerationFrictionCoef = 0.9,
      double extraLeftOffset = 0.0,
      double extraTopOffset = 0.0,
      double extraRightOffset = 0.0,
      double extraBottomOffset = 0.0,
      String noDataText = "No chart data available.",
      bool touchEnabled = true,
      IMarker marker = null,
      Description desc = null,
      bool drawMarkers = true,
      TextPainter infoPainter = null,
      TextPainter descPainter = null,
      IHighlighter highlighter = null,
      bool unbind = false})
      : _initialPainterCallback = initialPainterCallback,
        data = data,
        backgroundColor = backgroundColor,
        borderColor = borderColor,
        borderStrokeWidth = borderStrokeWidth,
        keepPositionOnRotation = keepPositionOnRotation,
        pinchZoomEnabled = pinchZoomEnabled,
        xAxisRenderer = xAxisRenderer,
        rendererLeftYAxis = rendererLeftYAxis,
        rendererRightYAxis = rendererRightYAxis,
        autoScaleMinMaxEnabled = autoScaleMinMaxEnabled,
        minOffset = minOffset,
        clipValuesToContent = clipValuesToContent,
        drawBorders = drawBorders,
        drawGridBackground = drawGridBackground,
        doubleTapToZoomEnabled = doubleTapToZoomEnabled,
        scaleXEnabled = scaleXEnabled,
        scaleYEnabled = scaleYEnabled,
        dragXEnabled = dragXEnabled,
        dragYEnabled = dragYEnabled,
        highlightPerDragEnabled = highlightPerDragEnabled,
        maxVisibleCount = maxVisibleCount,
        drawListener = drawListener,
        minXRange = minXRange,
        maxXRange = maxXRange,
        minimumScaleX = minimumScaleX,
        minimumScaleY = minimumScaleY,
        maxHighlightDistance = maxHighlightDistance,
        highLightPerTapEnabled = highLightPerTapEnabled,
        dragDecelerationEnabled = dragDecelerationEnabled,
        dragDecelerationFrictionCoef = dragDecelerationFrictionCoef,
        extraLeftOffset = extraLeftOffset,
        extraTopOffset = extraTopOffset,
        extraRightOffset = extraRightOffset,
        extraBottomOffset = extraBottomOffset,
        noDataText = noDataText,
        touchEnabled = touchEnabled,
        marker = marker,
        desc = desc,
        drawMarkers = drawMarkers,
        infoPainter = infoPainter,
        descPainter = descPainter,
        highlighter = highlighter,
        unbind = unbind;
}

abstract class ChartState<P extends ChartPainter, T extends Chart>
    extends State<T> implements AnimatorUpdateListener {
  P painter;
  bool _singleTap = false;
  ChartAnimator animator = null;

  void initialPainter();

  @override
  void onAnimationUpdate(double x, double y) {
    setState(() {});
  }

  @override
  void initState() {
    animator = ChartAnimator(this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    initialPainter();
    widget._initialPainterCallback(painter);
    return Stack(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        children: [
          ConstrainedBox(
              constraints: BoxConstraints(
                  minHeight: double.infinity, minWidth: double.infinity),
              child: GestureDetector(
                  onTapDown: (detail) {
                    _singleTap = true;
                    onTapDown(detail);
                  },
                  onTapUp: (detail) {
                    if (_singleTap) {
                      _singleTap = false;
                      onSingleTapUp(detail);
                    }
                  },
                  onDoubleTap: () {
                    _singleTap = false;
                    onDoubleTap();
                  },
                  onScaleStart: (detail) {
                    onScaleStart(detail);
                  },
                  onScaleUpdate: (detail) {
                    _singleTap = false;
                    onScaleUpdate(detail);
                  },
                  onScaleEnd: (detail) {
                    onScaleEnd(detail);
                  },
                  child: CustomPaint(painter: painter))),
        ]);
  }

  @override
  void reassemble() {
    super.reassemble();
    animator.reset();
    painter?.reassemble();
  }

  void onDoubleTap();

  void onScaleStart(ScaleStartDetails detail);

  void onScaleUpdate(ScaleUpdateDetails detail);

  void onScaleEnd(ScaleEndDetails detail);

  void onTapDown(TapDownDetails detail);

  void onSingleTapUp(TapUpDetails detail);
}

typedef InitPainterCallback = void Function(ChartPainter painter);
