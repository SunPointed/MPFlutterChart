import 'dart:ui';

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

class CombinedChart
    extends BarLineScatterCandleBubbleChart<CombinedChartController> {
  const CombinedChart(CombinedChartController controller) : super(controller);
}

class CombinedChartState extends ChartState<CombinedChart> {
  @override
  void updatePainter() {
    widget.controller.painter.highlightValue6(_lastHighlighted, false);
  }

  IDataSet _closestDataSetToTouch;

  double _curX = 0.0;
  double _curY = 0.0;
  double _scaleX = -1.0;
  double _scaleY = -1.0;
  bool _isZoom = false;

  MPPointF _getTrans(double x, double y) {
    ViewPortHandler vph = widget.controller.painter.viewPortHandler;

    double xTrans = x - vph.offsetLeft();
    double yTrans = 0.0;

    /// check if axis is inverted
    if (_inverted()) {
      yTrans = -(y - vph.offsetTop());
    } else {
      yTrans = -(widget.controller.painter.getMeasuredHeight() -
          y -
          vph.offsetBottom());
    }

    return MPPointF.getInstance1(xTrans, yTrans);
  }

  bool _inverted() {
    return (_closestDataSetToTouch == null &&
            widget.controller.painter.isAnyAxisInverted()) ||
        (_closestDataSetToTouch != null &&
            widget.controller.painter
                .isInverted(_closestDataSetToTouch.getAxisDependency()));
  }

  @override
  void onTapDown(TapDownDetails detail, Offset localPosition) {
    _curX = localPosition.dx;
    _curY = localPosition.dy;
    _closestDataSetToTouch = widget.controller.painter
        .getDataSetByTouchPoint(localPosition.dx, localPosition.dy);
  }

  @override
  void onDoubleTap() {
    if (widget.controller.painter.doubleTapToZoomEnabled &&
        widget.controller.painter.getData().getEntryCount() > 0) {
      MPPointF trans = _getTrans(_curX, _curY);
      widget.controller.painter.zoom(
          widget.controller.painter.scaleXEnabled ? 1.4 : 1,
          widget.controller.painter.scaleYEnabled ? 1.4 : 1,
          trans.x,
          trans.y);
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
  void onScaleStart(ScaleStartDetails detail, Offset localFocalPoint) {
    _curX = localFocalPoint.dx;
    _curY = localFocalPoint.dy;
  }

  @override
  void onScaleUpdate(ScaleUpdateDetails detail, Offset localFocalPoint) {
    if (_scaleX == -1.0 && _scaleY == -1.0) {
      _scaleX = detail.horizontalScale;
      _scaleY = detail.verticalScale;
      return;
    }

    if (_scaleX == detail.horizontalScale && _scaleY == detail.verticalScale) {
      if (_isZoom) {
        return;
      }

      var dx = localFocalPoint.dx - _curX;
      var dy = localFocalPoint.dy - _curY;
      if (widget.controller.painter.dragYEnabled &&
          widget.controller.painter.dragXEnabled) {
        if (_inverted()) {
          dy = -dy;
        }
        widget.controller.painter.translate(dx, dy);
        setStateIfNotDispose();
      } else {
        if (widget.controller.painter.dragXEnabled) {
          widget.controller.painter.translate(dx, 0.0);
          setStateIfNotDispose();
        } else if (widget.controller.painter.dragYEnabled) {
          if (_inverted()) {
            dy = -dy;
          }
          widget.controller.painter.translate(0.0, dy);
          setStateIfNotDispose();
        }
      }
      _curX = localFocalPoint.dx;
      _curY = localFocalPoint.dy;
    } else {
      var scaleX = detail.horizontalScale / _scaleX;
      var scaleY = detail.verticalScale / _scaleY;

      if (!_isZoom) {
        scaleX = detail.horizontalScale;
        scaleY = detail.verticalScale;
        _isZoom = true;
      }

      MPPointF trans = _getTrans(_curX, _curY);

      scaleX = widget.controller.painter.scaleXEnabled ? scaleX : 1.0;
      scaleY = widget.controller.painter.scaleYEnabled ? scaleY : 1.0;
      widget.controller.painter.zoom(scaleX, scaleY, trans.x, trans.y);
      setStateIfNotDispose();
      MPPointF.recycleInstance(trans);
    }
    _scaleX = detail.horizontalScale;
    _scaleY = detail.verticalScale;
    _curX = localFocalPoint.dx;
    _curY = localFocalPoint.dy;
  }

  Highlight _lastHighlighted;

  @override
  void onSingleTapUp(TapUpDetails detail, Offset localPosition) {
    if (widget.controller.painter.highlightPerDragEnabled) {
      Highlight h = widget.controller.painter
          .getHighlightByTouchPoint(localPosition.dx, localPosition.dy);
      _lastHighlighted = HighlightUtils.performHighlight(
          widget.controller.painter, h, _lastHighlighted);
      setStateIfNotDispose();
    } else {
      _lastHighlighted = null;
    }
  }
}
