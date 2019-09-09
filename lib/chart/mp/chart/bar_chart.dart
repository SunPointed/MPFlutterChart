import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:mp_flutter_chart/chart/mp/core/common_interfaces.dart';
import 'package:mp_flutter_chart/chart/mp/core/data/bar_data.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_interfaces/i_data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/description.dart';
import 'package:mp_flutter_chart/chart/mp/core/highlight/highlight.dart';
import 'package:mp_flutter_chart/chart/mp/core/highlight/i_highlighter.dart';
import 'package:mp_flutter_chart/chart/mp/core/marker/bar_chart_marker.dart';
import 'package:mp_flutter_chart/chart/mp/core/marker/i_marker.dart';
import 'package:mp_flutter_chart/chart/mp/core/poolable/point.dart';
import 'package:mp_flutter_chart/chart/mp/core/render/x_axis_renderer.dart';
import 'package:mp_flutter_chart/chart/mp/core/render/y_axis_renderer.dart';
import 'package:mp_flutter_chart/chart/mp/core/utils/highlight_utils.dart';
import 'package:mp_flutter_chart/chart/mp/core/view_port.dart';
import 'package:mp_flutter_chart/chart/mp/listener.dart';
import 'package:mp_flutter_chart/chart/mp/painter/bar_chart_painter.dart';

import 'chart.dart';

class BarChart extends Chart {
  Color backgroundColor = null;
  Color borderColor = null;
  double borderStrokeWidth = 1.0;
  bool keepPositionOnRotation = false;
  bool pinchZoomEnabled = false;
  XAxisRenderer xAxisRenderer = null;
  YAxisRenderer rendererLeftYAxis = null;
  YAxisRenderer rendererRightYAxis = null;
  bool autoScaleMinMaxEnabled = false;
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

  BarChart(
      BarData data, InitBarChartPainterCallback initBarChartPainterCallback,
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
      : backgroundColor = backgroundColor,
        borderColor = borderColor,
        borderStrokeWidth = borderStrokeWidth,
        keepPositionOnRotation = keepPositionOnRotation,
        pinchZoomEnabled = pinchZoomEnabled,
        xAxisRenderer = xAxisRenderer,
        rendererLeftYAxis = rendererLeftYAxis,
        rendererRightYAxis = rendererRightYAxis,
        autoScaleMinMaxEnabled = autoScaleMinMaxEnabled,
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
        super(
          data,
          (painter) {
            if (painter is BarChartPainter) {
              initBarChartPainterCallback(painter);
            }
          },
          backgroundColor: backgroundColor,
          borderColor: borderColor,
          borderStrokeWidth: borderStrokeWidth,
          keepPositionOnRotation: keepPositionOnRotation,
          pinchZoomEnabled: pinchZoomEnabled,
          xAxisRenderer: xAxisRenderer,
          rendererLeftYAxis: rendererLeftYAxis,
          rendererRightYAxis: rendererRightYAxis,
          autoScaleMinMaxEnabled: autoScaleMinMaxEnabled,
          clipValuesToContent: clipValuesToContent,
          drawBorders: drawBorders,
          drawGridBackground: drawGridBackground,
          doubleTapToZoomEnabled: doubleTapToZoomEnabled,
          scaleXEnabled: scaleXEnabled,
          scaleYEnabled: scaleYEnabled,
          dragXEnabled: dragXEnabled,
          dragYEnabled: dragYEnabled,
          highlightPerDragEnabled: highlightPerDragEnabled,
          maxVisibleCount: maxVisibleCount,
          drawListener: drawListener,
          minXRange: minXRange,
          maxXRange: maxXRange,
          minimumScaleX: minimumScaleX,
          minimumScaleY: minimumScaleY,
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
          unbind: unbind,
        ) {
    this.marker = BarChartMarker();
  }

  @override
  State<StatefulWidget> createState() {
    return BarChartState();
  }
}

class BarChartState extends ChartState<BarChartPainter, BarChart> {
  IDataSet _closestDataSetToTouch;

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
  void initialPainter() {
    painter = BarChartPainter(widget.data,
        viewPortHandler: widget.viewPortHandler,
        animator: animator,
        backgroundColor: widget.backgroundColor,
        borderColor: widget.borderColor,
        borderStrokeWidth: widget.borderStrokeWidth,
        keepPositionOnRotation: widget.keepPositionOnRotation,
        pinchZoomEnabled: widget.pinchZoomEnabled,
        xAxisRenderer: widget.xAxisRenderer,
        rendererLeftYAxis: widget.rendererLeftYAxis,
        rendererRightYAxis: widget.rendererRightYAxis,
        autoScaleMinMaxEnabled: widget.autoScaleMinMaxEnabled,
        minOffset: widget.minOffset,
        clipValuesToContent: widget.clipValuesToContent,
        drawBorders: widget.drawBorders,
        drawGridBackground: widget.drawGridBackground,
        doubleTapToZoomEnabled: widget.doubleTapToZoomEnabled,
        scaleXEnabled: widget.scaleXEnabled,
        scaleYEnabled: widget.scaleYEnabled,
        dragXEnabled: widget.dragXEnabled,
        dragYEnabled: widget.dragYEnabled,
        highlightPerDragEnabled: widget.highlightPerDragEnabled,
        maxVisibleCount: widget.maxVisibleCount,
        drawListener: widget.drawListener,
        minXRange: widget.minXRange,
        maxXRange: widget.maxXRange,
        minimumScaleX: widget.minimumScaleX,
        minimumScaleY: widget.minimumScaleY,
        maxHighlightDistance: widget.maxHighlightDistance,
        highLightPerTapEnabled: widget.highLightPerTapEnabled,
        dragDecelerationEnabled: widget.dragDecelerationEnabled,
        dragDecelerationFrictionCoef: widget.dragDecelerationFrictionCoef,
        extraLeftOffset: widget.extraLeftOffset,
        extraTopOffset: widget.extraTopOffset,
        extraRightOffset: widget.extraRightOffset,
        extraBottomOffset: widget.extraBottomOffset,
        noDataText: widget.noDataText,
        touchEnabled: widget.touchEnabled,
        marker: widget.marker,
        desc: widget.desc,
        drawMarkers: widget.drawMarkers,
        infoPainter: widget.infoPainter,
        descPainter: widget.descPainter,
        highlighter: widget.highlighter,
        unbind: widget.unbind);
    painter.highlightValue6(_lastHighlighted, false);
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
        setState(() {});
      } else {
        if (painter.mDragXEnabled) {
          painter.translate(dx, 0.0);
          _dragHighlight(Offset(detail.localFocalPoint.dx, 0.0));
          listener?.onChartTranslate(
              detail.localFocalPoint.dx, detail.localFocalPoint.dy, dx, dy);
          setState(() {});
        } else if (painter.mDragYEnabled) {
          if (_inverted()) {
            // if there is an inverted horizontalbarchart
//      if (mChart instanceof HorizontalBarChart) {
//        dx = -dx;
//      } else {
            dy = -dy;
//      }
          }
          painter.translate(0.0, dy);
          _dragHighlight(Offset(0.0, detail.localFocalPoint.dy));
          listener?.onChartTranslate(
              detail.localFocalPoint.dx, detail.localFocalPoint.dy, dx, dy);
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

      scaleX = painter.mScaleXEnabled ? scaleX : 1.0;
      scaleY = painter.mScaleYEnabled ? scaleY : 1.0;
      painter.zoom(scaleX, scaleY, trans.x, trans.y);
      listener?.onChartScale(
          detail.localFocalPoint.dx, detail.localFocalPoint.dy, scaleX, scaleY);
      setState(() {});
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
      painter.getOnChartGestureListener()?.onChartSingleTapped(
          detail.localPosition.dx, detail.localPosition.dy);
      setState(() {});
    } else {
      _lastHighlighted = null;
    }
  }
}

typedef InitBarChartPainterCallback = void Function(BarChartPainter painter);
