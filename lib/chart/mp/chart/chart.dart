import 'package:flutter/widgets.dart';
import 'package:mp_flutter_chart/chart/mp/chart/horizontal_bar_chart.dart';
import 'package:mp_flutter_chart/chart/mp/core/animator.dart';
import 'package:mp_flutter_chart/chart/mp/core/common_interfaces.dart';
import 'package:mp_flutter_chart/chart/mp/core/data/chart_data.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_interfaces/i_data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/description.dart';
import 'package:mp_flutter_chart/chart/mp/core/entry/entry.dart';
import 'package:mp_flutter_chart/chart/mp/core/highlight/highlight.dart';
import 'package:mp_flutter_chart/chart/mp/core/highlight/i_highlighter.dart';
import 'package:mp_flutter_chart/chart/mp/core/marker/i_marker.dart';
import 'package:mp_flutter_chart/chart/mp/core/poolable/point.dart';
import 'package:mp_flutter_chart/chart/mp/core/render/x_axis_renderer.dart';
import 'package:mp_flutter_chart/chart/mp/core/render/y_axis_renderer.dart';
import 'package:mp_flutter_chart/chart/mp/core/utils/highlight_utils.dart';
import 'package:mp_flutter_chart/chart/mp/core/utils/utils.dart';
import 'package:mp_flutter_chart/chart/mp/core/view_port.dart';
import 'package:mp_flutter_chart/chart/mp/painter/bar_line_chart_painter.dart';
import 'package:mp_flutter_chart/chart/mp/painter/painter.dart';
import 'package:mp_flutter_chart/chart/mp/painter/pie_redar_chart_painter.dart';

abstract class Chart extends StatefulWidget {
  InitPainterCallback _initialPainterCallback;

  ChartData data;
  double minOffset = 15;
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

  ViewPortHandler viewPortHandler = ViewPortHandler();

  ChartState _state;

  ChartState getState() {
    return _state;
  }

  ChartState createChartState();

  @override
  State createState() {
    _state = createChartState();
    return _state;
  }

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
        minOffset = minOffset,
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
    setStateIfNotDispose();
  }

  @override
  void onRotateUpdate(double angle) {}

  void setStateIfNotDispose() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    animator = ChartAnimator(this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    initialPainter();
    if (painter.mData != null) {
      widget._initialPainterCallback(painter);
    }
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

abstract class PieRadarChart extends Chart {
  double rotationAngle;
  double rawRotationAngle;

  PieRadarChart(
      ChartData<IDataSet<Entry>> data, InitPainterCallback initPainterCallback,
      {double rotationAngle = 270,
      double rawRotationAngle = 270,
      double minOffset = 30,
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
      : rotationAngle = rotationAngle,
        rawRotationAngle = rawRotationAngle,
        super(data, initPainterCallback,
            maxHighlightDistance: maxHighlightDistance,
            highLightPerTapEnabled: highLightPerTapEnabled,
            dragDecelerationEnabled: dragDecelerationEnabled,
            dragDecelerationFrictionCoef: dragDecelerationFrictionCoef,
            extraLeftOffset: extraLeftOffset,
            extraTopOffset: extraTopOffset,
            extraRightOffset: extraRightOffset,
            extraBottomOffset: extraBottomOffset,
            touchEnabled: touchEnabled,
            noDataText: noDataText,
            marker: marker,
            desc: desc,
            drawMarkers: drawMarkers,
            infoPainter: infoPainter,
            descPainter: descPainter,
            highlighter: highlighter,
            unbind: unbind);
}

abstract class PieRadarChartState<P extends PieRadarChartPainter,
    T extends PieRadarChart> extends ChartState<P, T> {
  Highlight lastHighlighted;
  MPPointF _touchStartPoint = MPPointF.getInstance1(0, 0);
  double _startAngle = 0.0;

  void _setGestureStartAngle(double x, double y) {
    _startAngle =
        painter.getAngleForPoint(x, y) - painter.getRawRotationAngle();
  }

  void _updateGestureRotation(double x, double y) {
    double angle = painter.getAngleForPoint(x, y) - _startAngle;
    widget.rawRotationAngle = angle;
    widget.rotationAngle = Utils.getNormalizedAngle(widget.rawRotationAngle);
  }

  @override
  void onRotateUpdate(double angle) {
    widget.rawRotationAngle = angle;
    widget.rotationAngle = Utils.getNormalizedAngle(widget.rawRotationAngle);
    setState(() {});
  }

  @override
  void onDoubleTap() {}

  @override
  void onScaleEnd(ScaleEndDetails detail) {}

  @override
  void onScaleStart(ScaleStartDetails detail) {
    _setGestureStartAngle(detail.localFocalPoint.dx, detail.localFocalPoint.dy);
    _touchStartPoint
      ..x = detail.localFocalPoint.dx
      ..y = detail.localFocalPoint.dy;
  }

  @override
  void onScaleUpdate(ScaleUpdateDetails detail) {
    _updateGestureRotation(
        detail.localFocalPoint.dx, detail.localFocalPoint.dy);
    setStateIfNotDispose();
  }

  @override
  void onSingleTapUp(TapUpDetails detail) {
    if (painter.mHighLightPerTapEnabled) {
      Highlight h = painter.getHighlightByTouchPoint(
          detail.localPosition.dx, detail.localPosition.dy);
      lastHighlighted =
          HighlightUtils.performHighlight(painter, h, lastHighlighted);
      painter.getOnChartGestureListener()?.onChartSingleTapped(
          detail.localPosition.dx, detail.localPosition.dy);
      setStateIfNotDispose();
    } else {
      lastHighlighted = null;
    }
  }

  @override
  void onTapDown(TapDownDetails detail) {}
}

abstract class BarLineScatterCandleBubbleState<
    P extends BarLineChartBasePainter,
    T extends Chart> extends ChartState<P, T> {
  IDataSet _closestDataSetToTouch;

  Highlight lastHighlighted;
  double _curX = 0.0;
  double _curY = 0.0;
  double _scaleX = -1.0;
  double _scaleY = -1.0;
  bool _isZoom = false;

  MPPointF _getTrans(double x, double y) {
    ViewPortHandler vph = painter.mViewPortHandler;

    double xTrans = x - vph.offsetLeft();
    double yTrans = 0.0;

    // check if axis is inverted
    if (_inverted()) {
      yTrans = -(y - vph.offsetTop());
    } else {
      yTrans = -(painter.getMeasuredHeight() - y - vph.offsetBottom());
    }

    return MPPointF.getInstance1(xTrans, yTrans);
  }

  bool _inverted() {
    return (_closestDataSetToTouch == null && painter.isAnyAxisInverted()) ||
        (_closestDataSetToTouch != null &&
            painter.isInverted(_closestDataSetToTouch.getAxisDependency()));
  }

  @override
  void onTapDown(TapDownDetails detail) {
    _curX = detail.localPosition.dx;
    _curY = detail.localPosition.dy;
    _closestDataSetToTouch = painter.getDataSetByTouchPoint(
        detail.localPosition.dx, detail.localPosition.dy);
  }

  @override
  void onDoubleTap() {
    if (painter.mDoubleTapToZoomEnabled && painter.mData.getEntryCount() > 0) {
      MPPointF trans = _getTrans(_curX, _curY);
      painter.zoom(painter.mScaleXEnabled ? 1.4 : 1,
          painter.mScaleYEnabled ? 1.4 : 1, trans.x, trans.y);
      painter.getOnChartGestureListener()?.onChartDoubleTapped(_curX, _curY);
      setStateIfNotDispose();
      MPPointF.recycleInstance(trans);
    }
  }

  @override
  void onScaleEnd(ScaleEndDetails detail) {
    if (_isZoom) {
      _isZoom = false;
    }
    _scaleX = -1.0;
    _scaleY = -1.0;
  }

  @override
  void onScaleStart(ScaleStartDetails detail) {
    _curX = detail.localFocalPoint.dx;
    _curY = detail.localFocalPoint.dy;
  }

  @override
  void onScaleUpdate(ScaleUpdateDetails detail) {
    if (_scaleX == -1.0 && _scaleY == -1.0) {
      _scaleX = detail.horizontalScale;
      _scaleY = detail.verticalScale;
      return;
    }

    OnChartGestureListener listener = painter.getOnChartGestureListener();
    if (_scaleX == detail.horizontalScale && _scaleY == detail.verticalScale) {
      if (_isZoom) {
        return;
      }

      var dx = detail.localFocalPoint.dx - _curX;
      var dy = detail.localFocalPoint.dy - _curY;
      if (painter.mDragYEnabled && painter.mDragXEnabled) {
        painter.translate(dx, dy);
        _dragHighlight(
            Offset(detail.localFocalPoint.dx, detail.localFocalPoint.dy));
        listener?.onChartTranslate(
            detail.localFocalPoint.dx, detail.localFocalPoint.dy, dx, dy);
        setStateIfNotDispose();
      } else {
        if (painter.mDragXEnabled) {
          painter.translate(dx, 0.0);
          _dragHighlight(Offset(detail.localFocalPoint.dx, 0.0));
          listener?.onChartTranslate(
              detail.localFocalPoint.dx, detail.localFocalPoint.dy, dx, dy);
          setStateIfNotDispose();
        } else if (painter.mDragYEnabled) {
          if (_inverted()) {
            // if there is an inverted horizontalbarchart
            if (widget is HorizontalBarChart) {
              dx = -dx;
            } else {
              dy = -dy;
            }
          }
          painter.translate(0.0, dy);
          _dragHighlight(Offset(0.0, detail.localFocalPoint.dy));
          listener?.onChartTranslate(
              detail.localFocalPoint.dx, detail.localFocalPoint.dy, dx, dy);
          setStateIfNotDispose();
        }
      }
      _curX = detail.localFocalPoint.dx;
      _curY = detail.localFocalPoint.dy;
    } else {
      var scaleX = detail.horizontalScale / _scaleX;
      var scaleY = detail.verticalScale / _scaleY;

      if (!_isZoom) {
        scaleX = detail.horizontalScale;
        scaleY = detail.verticalScale;
        _isZoom = true;
      }

      MPPointF trans = _getTrans(_curX, _curY);

      scaleX = painter.mScaleXEnabled ? scaleX : 1.0;
      scaleY = painter.mScaleYEnabled ? scaleY : 1.0;
      painter.zoom(scaleX, scaleY, trans.x, trans.y);
      listener?.onChartScale(
          detail.localFocalPoint.dx, detail.localFocalPoint.dy, scaleX, scaleY);
      setStateIfNotDispose();
      MPPointF.recycleInstance(trans);
    }
    _scaleX = detail.horizontalScale;
    _scaleY = detail.verticalScale;
    _curX = detail.localFocalPoint.dx;
    _curY = detail.localFocalPoint.dy;
  }

  void _dragHighlight(Offset offset) {
    if (painter.mHighlightPerDragEnabled) {
      Highlight h = painter.getHighlightByTouchPoint(offset.dx, offset.dy);
      if (h != null && !h.equalTo(lastHighlighted)) {
        lastHighlighted = h;
        painter.highlightValue6(h, true);
      }
    } else {
      lastHighlighted = null;
    }
  }

  @override
  void onSingleTapUp(TapUpDetails detail) {
    if (painter.mHighLightPerTapEnabled) {
      Highlight h = painter.getHighlightByTouchPoint(
          detail.localPosition.dx, detail.localPosition.dy);
      lastHighlighted =
          HighlightUtils.performHighlight(painter, h, lastHighlighted);
      painter.getOnChartGestureListener()?.onChartSingleTapped(
          detail.localPosition.dx, detail.localPosition.dy);
      setStateIfNotDispose();
    } else {
      lastHighlighted = null;
    }
  }
}
