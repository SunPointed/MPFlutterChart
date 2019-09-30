import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/src/gestures/scale.dart';
import 'package:flutter/src/gestures/tap.dart';
import 'package:mp_chart/mp/chart/bar_line_scatter_candle_bubble_chart.dart';
import 'package:mp_chart/mp/chart/chart.dart';
import 'package:mp_chart/mp/controller/combined_chart_controller.dart';
import 'package:mp_chart/mp/core/data_interfaces/i_data_set.dart';
import 'package:mp_chart/mp/core/highlight/highlight.dart';
import 'package:mp_chart/mp/core/poolable/point.dart';
import 'package:mp_chart/mp/core/utils/highlight_utils.dart';
import 'package:mp_chart/mp/core/view_port.dart';
import 'package:mp_chart/mp/painter/combined_chart_painter.dart';

class CombinedChart extends BarLineScatterCandleBubbleChart<
    CombinedChartPainter, CombinedChartController> {
  CombinedChart(CombinedChartController controller) : super(controller);

  @override
  CombinedChartState createChartState() {
    return CombinedChartState();
  }

  CombinedChartPainter get painter => super.painter;

  @override
  void initialPainter() {
    painter = CombinedChartPainter(
        controller.data,
        animator,
        controller.viewPortHandler,
        controller.maxHighlightDistance,
        controller.highLightPerTapEnabled,
        controller.extraLeftOffset,
        controller.extraTopOffset,
        controller.extraRightOffset,
        controller.extraBottomOffset,
        controller.marker,
        controller.description,
        controller.drawMarkers,
        controller.infoPaint,
        controller.descPaint,
        controller.xAxis,
        controller.legend,
        controller.legendRenderer,
        controller.rendererSettingFunction,
        controller.selectionListener,
        controller.maxVisibleCount,
        controller.autoScaleMinMaxEnabled,
        controller.pinchZoomEnabled,
        controller.doubleTapToZoomEnabled,
        controller.highlightPerDragEnabled,
        controller.dragXEnabled,
        controller.dragYEnabled,
        controller.scaleXEnabled,
        controller.scaleYEnabled,
        controller.gridBackgroundPaint,
        controller.borderPaint,
        controller.drawGridBackground,
        controller.drawBorders,
        controller.clipValuesToContent,
        controller.minOffset,
        controller.keepPositionOnRotation,
        controller.drawListener,
        controller.axisLeft,
        controller.axisRight,
        controller.axisRendererLeft,
        controller.axisRendererRight,
        controller.leftAxisTransformer,
        controller.rightAxisTransformer,
        controller.xAxisRenderer,
        controller.zoomMatrixBuffer,
        controller.customViewPortEnabled,
        controller.minXRange,
        controller.maxXRange,
        controller.minimumScaleX,
        controller.minimumScaleY,
        controller.highlightFullBarEnabled,
        controller.drawValueAboveBar,
        controller.drawBarShadow,
        controller.fitBars,
        controller.drawOrder);
  }
}

class CombinedChartState extends ChartState<CombinedChart> {
  @override
  void updatePainter() {
    widget.painter.highlightValue6(_lastHighlighted, false);
  }

  IDataSet _closestDataSetToTouch;

  double _curX = 0.0;
  double _curY = 0.0;
  double _scaleX = -1.0;
  double _scaleY = -1.0;
  bool _isZoom = false;

  MPPointF _getTrans(double x, double y) {
    ViewPortHandler vph = widget.painter.viewPortHandler;

    double xTrans = x - vph.offsetLeft();
    double yTrans = 0.0;

    // check if axis is inverted
    if (_inverted()) {
      yTrans = -(y - vph.offsetTop());
    } else {
      yTrans = -(widget.painter.getMeasuredHeight() - y - vph.offsetBottom());
    }

    return MPPointF.getInstance1(xTrans, yTrans);
  }

  bool _inverted() {
    return (_closestDataSetToTouch == null &&
            widget.painter.isAnyAxisInverted()) ||
        (_closestDataSetToTouch != null &&
            widget.painter
                .isInverted(_closestDataSetToTouch.getAxisDependency()));
  }

  @override
  void onTapDown(TapDownDetails detail) {
    _curX = detail.localPosition.dx;
    _curY = detail.localPosition.dy;
    _closestDataSetToTouch = widget.painter.getDataSetByTouchPoint(
        detail.localPosition.dx, detail.localPosition.dy);
  }

  @override
  void onDoubleTap() {
    if (widget.painter.doubleTapToZoomEnabled &&
        widget.painter.getData().getEntryCount() > 0) {
      MPPointF trans = _getTrans(_curX, _curY);
      widget.painter.zoom(widget.painter.scaleXEnabled ? 1.4 : 1,
          widget.painter.scaleYEnabled ? 1.4 : 1, trans.x, trans.y);
//      painter.getOnChartGestureListener()?.onChartDoubleTapped(_curX, _curY);
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

//    OnChartGestureListener listener = painter.getOnChartGestureListener();
    if (_scaleX == detail.horizontalScale && _scaleY == detail.verticalScale) {
      if (_isZoom) {
        return;
      }

      var dx = detail.localFocalPoint.dx - _curX;
      var dy = detail.localFocalPoint.dy - _curY;
      if (widget.painter.dragYEnabled && widget.painter.dragXEnabled) {
        if (_inverted()) {
          dy = -dy;
        }
        widget.painter.translate(dx, dy);
        _dragHighlight(
            Offset(detail.localFocalPoint.dx, detail.localFocalPoint.dy));
//        listener?.onChartTranslate(
//            detail.localFocalPoint.dx, detail.localFocalPoint.dy, dx, dy);
        setStateIfNotDispose();
      } else {
        if (widget.painter.dragXEnabled) {
          widget.painter.translate(dx, 0.0);
          _dragHighlight(Offset(detail.localFocalPoint.dx, 0.0));
//          listener?.onChartTranslate(
//              detail.localFocalPoint.dx, detail.localFocalPoint.dy, dx, dy);
          setStateIfNotDispose();
        } else if (widget.painter.dragYEnabled) {
          if (_inverted()) {
            dy = -dy;
          }
          widget.painter.translate(0.0, dy);
          _dragHighlight(Offset(0.0, detail.localFocalPoint.dy));
//          listener?.onChartTranslate(
//              detail.localFocalPoint.dx, detail.localFocalPoint.dy, dx, dy);
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

      scaleX = widget.painter.scaleXEnabled ? scaleX : 1.0;
      scaleY = widget.painter.scaleYEnabled ? scaleY : 1.0;
      widget.painter.zoom(scaleX, scaleY, trans.x, trans.y);
//      listener?.onChartScale(
//          detail.localFocalPoint.dx, detail.localFocalPoint.dy, scaleX, scaleY);
      setStateIfNotDispose();
      MPPointF.recycleInstance(trans);
    }
    _scaleX = detail.horizontalScale;
    _scaleY = detail.verticalScale;
    _curX = detail.localFocalPoint.dx;
    _curY = detail.localFocalPoint.dy;
  }

  void _dragHighlight(Offset offset) {
    if (widget.painter.highlightPerDragEnabled) {
      Highlight h =
          widget.painter.getHighlightByTouchPoint(offset.dx, offset.dy);
      if (h != null && !h.equalTo(_lastHighlighted)) {
        _lastHighlighted = h;
        widget.painter.highlightValue6(h, true);
      }
    } else {
      _lastHighlighted = null;
    }
  }

  Highlight _lastHighlighted;

  @override
  void onSingleTapUp(TapUpDetails detail) {
    if (widget.painter.highlightPerDragEnabled) {
      Highlight h = widget.painter.getHighlightByTouchPoint(
          detail.localPosition.dx, detail.localPosition.dy);
      _lastHighlighted =
          HighlightUtils.performHighlight(widget.painter, h, _lastHighlighted);
//      painter.getOnChartGestureListener()?.onChartSingleTapped(
//          detail.localPosition.dx, detail.localPosition.dy);
      setStateIfNotDispose();
    } else {
      _lastHighlighted = null;
    }
  }
}
