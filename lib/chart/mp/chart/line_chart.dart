import 'package:flutter/gestures.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:mp_flutter_chart/chart/mp/chart/chart.dart';
import 'package:mp_flutter_chart/chart/mp/core/data.dart';
import 'package:mp_flutter_chart/chart/mp/core/description.dart';
import 'package:mp_flutter_chart/chart/mp/core/highlight.dart';
import 'package:mp_flutter_chart/chart/mp/core/interfaces.dart';
import 'package:mp_flutter_chart/chart/mp/core/marker.dart';
import 'package:mp_flutter_chart/chart/mp/painter/line_chart_painter.dart';
import 'package:mp_flutter_chart/chart/mp/painter/painter.dart';
import 'package:mp_flutter_chart/chart/mp/poolable/point.dart';
import 'package:mp_flutter_chart/chart/mp/core/render.dart';
import 'package:mp_flutter_chart/chart/mp/core/view_port.dart';
import 'package:mp_flutter_chart/chart/mp/util.dart';

class LineChart extends Chart {
  LineChartState _state;

  LineChart(LineChartState state) : super() {
    _state = state;
  }

  @override
  State<StatefulWidget> createState() {
    return _state;
  }
}

class LineChartState extends ChartState<LineChart> {
  LineChartPainter painter;
  InitPainterCallback initialPainterCallback;

  ////////////////////////////////////////////
  LineData _data;
  Color _backgroundColor = null;
  Color _borderColor = null;
  double _borderStrokeWidth = 1.0;
  bool _keepPositionOnRotation = false;
  bool _pinchZoomEnabled = false;
  XAxisRenderer _xAxisRenderer = null;
  YAxisRenderer _rendererLeftYAxis = null;
  YAxisRenderer _rendererRightYAxis = null;
  bool _autoScaleMinMaxEnabled = false;
  double _minOffset = 15;
  bool _clipValuesToContent = false;
  bool _drawBorders = false;
  bool _drawGridBackground = false;
  bool _doubleTapToZoomEnabled = true;
  bool _scaleXEnabled = true;
  bool _scaleYEnabled = true;
  bool _dragXEnabled = true;
  bool _dragYEnabled = true;
  bool _highlightPerDragEnabled = true;
  int _maxVisibleCount = 100;
  OnDrawListener _drawListener = null;
  double _minXRange = 1.0;
  double _maxXRange = 1.0;
  double _minimumScaleX = 1.0;
  double _minimumScaleY = 1.0;
  double _maxHighlightDistance = 0.0;
  bool _highLightPerTapEnabled = true;
  bool _dragDecelerationEnabled = true;
  double _dragDecelerationFrictionCoef = 0.9;
  double _extraLeftOffset = 0.0;
  double _extraTopOffset = 0.0;
  double _extraRightOffset = 0.0;
  double _extraBottomOffset = 0.0;
  String _noDataText = "No chart data available.";
  bool _touchEnabled = true;
  IMarker _marker = null;
  Description _desc = null;
  bool _drawMarkers = true;
  TextPainter _infoPainter = null;
  TextPainter _descPainter = null;
  IHighlighter _highlighter = null;
  bool _unbind = false;

  ViewPortHandler _viewPortHandler = ViewPortHandler();

  /////////////////////////////////

  IDataSet _closestDataSetToTouch;

  double _curX = 0.0;
  double _curY = 0.0;
  double _scaleX = -1.0;
  double _scaleY = -1.0;
  bool _isZoom = false;

  LineChartState(InitPainterCallback initialPainterCallback, LineData data,
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
      : this.initialPainterCallback = initialPainterCallback,
        _data = data,
        _backgroundColor = backgroundColor,
        _borderColor = borderColor,
        _borderStrokeWidth = borderStrokeWidth,
        _keepPositionOnRotation = keepPositionOnRotation,
        _pinchZoomEnabled = pinchZoomEnabled,
        _xAxisRenderer = xAxisRenderer,
        _rendererLeftYAxis = rendererLeftYAxis,
        _rendererRightYAxis = rendererRightYAxis,
        _autoScaleMinMaxEnabled = autoScaleMinMaxEnabled,
        _minOffset = minOffset,
        _clipValuesToContent = clipValuesToContent,
        _drawBorders = drawBorders,
        _drawGridBackground = drawGridBackground,
        _doubleTapToZoomEnabled = doubleTapToZoomEnabled,
        _scaleXEnabled = scaleXEnabled,
        _scaleYEnabled = scaleYEnabled,
        _dragXEnabled = dragXEnabled,
        _dragYEnabled = dragYEnabled,
        _highlightPerDragEnabled = highlightPerDragEnabled,
        _maxVisibleCount = maxVisibleCount,
        _drawListener = drawListener,
        _minXRange = minXRange,
        _maxXRange = maxXRange,
        _minimumScaleX = minimumScaleX,
        _minimumScaleY = minimumScaleY,
        _maxHighlightDistance = maxHighlightDistance,
        _highLightPerTapEnabled = highLightPerTapEnabled,
        _dragDecelerationEnabled = dragDecelerationEnabled,
        _dragDecelerationFrictionCoef = dragDecelerationFrictionCoef,
        _extraLeftOffset = extraLeftOffset,
        _extraTopOffset = extraTopOffset,
        _extraRightOffset = extraRightOffset,
        _extraBottomOffset = extraBottomOffset,
        _noDataText = noDataText,
        _touchEnabled = touchEnabled,
        _marker = marker,
        _desc = desc,
        _drawMarkers = drawMarkers,
        _infoPainter = infoPainter,
        _descPainter = descPainter,
        _highlighter = highlighter,
        _unbind = unbind,
        super() {
    _marker ??= Marker();
  }

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
  Widget build(BuildContext context) {
    painter = LineChartPainter(_data,
        viewPortHandler: _viewPortHandler,
        backgroundColor: _backgroundColor,
        borderColor: _borderColor,
        borderStrokeWidth: _borderStrokeWidth,
        keepPositionOnRotation: _keepPositionOnRotation,
        pinchZoomEnabled: _pinchZoomEnabled,
        xAxisRenderer: _xAxisRenderer,
        rendererLeftYAxis: _rendererLeftYAxis,
        rendererRightYAxis: _rendererRightYAxis,
        autoScaleMinMaxEnabled: _autoScaleMinMaxEnabled,
        minOffset: _minOffset,
        clipValuesToContent: _clipValuesToContent,
        drawBorders: _drawBorders,
        drawGridBackground: _drawGridBackground,
        doubleTapToZoomEnabled: _doubleTapToZoomEnabled,
        scaleXEnabled: _scaleXEnabled,
        scaleYEnabled: _scaleYEnabled,
        dragXEnabled: _dragXEnabled,
        dragYEnabled: _dragYEnabled,
        highlightPerDragEnabled: _highlightPerDragEnabled,
        maxVisibleCount: _maxVisibleCount,
        drawListener: _drawListener,
        minXRange: _minXRange,
        maxXRange: _maxXRange,
        minimumScaleX: _minimumScaleX,
        minimumScaleY: _minimumScaleY,
        maxHighlightDistance: _maxHighlightDistance,
        highLightPerTapEnabled: _highLightPerTapEnabled,
        dragDecelerationEnabled: _dragDecelerationEnabled,
        dragDecelerationFrictionCoef: _dragDecelerationFrictionCoef,
        extraLeftOffset: _extraLeftOffset,
        extraTopOffset: _extraTopOffset,
        extraRightOffset: _extraRightOffset,
        extraBottomOffset: _extraBottomOffset,
        noDataText: _noDataText,
        touchEnabled: _touchEnabled,
        marker: _marker,
        desc: _desc,
        drawMarkers: _drawMarkers,
        infoPainter: _infoPainter,
        descPainter: _descPainter,
        highlighter: _highlighter,
        unbind: _unbind);
    painter.highlightValue6(_lastHighlighted, false);
    initialPainterCallback(painter);
    return super.build(context);
  }

  @override
  ChartPainter getPainter() {
    return painter;
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

      setState(() {});

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

    if (_scaleX == detail.horizontalScale && _scaleY == detail.verticalScale) {
      if (_isZoom) {
        return;
      }

      if (painter.mDragYEnabled && painter.mDragXEnabled) {
        var dx = detail.localFocalPoint.dx - _curX;
        var dy = detail.localFocalPoint.dy - _curY;

        painter.translate(dx, dy);
        dragHighlight(Offset(detail.localFocalPoint.dx, detail.localFocalPoint.dy));
        setState(() {});
      } else {
        if (painter.mDragXEnabled) {
          var dx = detail.localFocalPoint.dx - _curX;
          painter.translate(dx, 0.0);
          dragHighlight(Offset(detail.localFocalPoint.dx, 0.0));
          setState(() {});
        } else if (painter.mDragYEnabled) {
          var dy = detail.localFocalPoint.dy - _curY;

          if (_inverted()) {
            // if there is an inverted horizontalbarchart
//      if (mChart instanceof HorizontalBarChart) {
//        dx = -dx;
//      } else {
            dy = -dy;
//      }
          }
          painter.translate(0.0, dy);
          dragHighlight(Offset(0.0, detail.localFocalPoint.dy));
          setState(() {});
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

      painter.zoom(painter.mScaleXEnabled ? scaleX : 1.0,
          painter.mScaleYEnabled ? scaleY : 1.0, trans.x, trans.y);
      setState(() {});
      MPPointF.recycleInstance(trans);
    }
    _scaleX = detail.horizontalScale;
    _scaleY = detail.verticalScale;
    _curX = detail.localFocalPoint.dx;
    _curY = detail.localFocalPoint.dy;
  }

  void dragHighlight(Offset offset) {
    if (painter.mHighlightPerDragEnabled) {
      Highlight h = painter.getHighlightByTouchPoint(offset.dx, offset.dy);
      if (h != null && !h.equalTo(_lastHighlighted)) {
        _lastHighlighted = h;
        painter.highlightValue6(h, true);
      }
    } else {
      _lastHighlighted = null;
    }
  }

  Highlight _lastHighlighted;

  @override
  void onSingleTapUp(TapUpDetails detail) {
    if (painter.mHighLightPerTapEnabled) {
      Highlight h = painter.getHighlightByTouchPoint(
          detail.localPosition.dx, detail.localPosition.dy);
      _lastHighlighted =
          HighlightUtils.performHighlight(painter, h, _lastHighlighted);
      setState(() {});
    } else {
      _lastHighlighted = null;
    }
  }
}

typedef InitPainterCallback = void Function(LineChartPainter painter);
