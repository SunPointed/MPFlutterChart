import 'package:flutter/widgets.dart';
import 'package:mp_chart/mp/chart/chart.dart';
import 'package:mp_chart/mp/chart/horizontal_bar_chart.dart';
import 'package:mp_chart/mp/controller/bar_line_scatter_candle_bubble_controller.dart';
import 'package:mp_chart/mp/core/data_interfaces/i_data_set.dart';
import 'package:mp_chart/mp/core/highlight/highlight.dart';
import 'package:mp_chart/mp/core/poolable/point.dart';
import 'package:mp_chart/mp/core/utils/highlight_utils.dart';
import 'package:mp_chart/mp/core/utils/utils.dart';
import 'package:mp_chart/mp/core/view_port.dart';
import 'package:optimized_gesture_detector/details.dart';
import 'package:optimized_gesture_detector/direction.dart';

abstract class BarLineScatterCandleBubbleChart<
    C extends BarLineScatterCandleBubbleController> extends Chart<C> {
  const BarLineScatterCandleBubbleChart(C controller) : super(controller);
}

class BarLineScatterCandleBubbleState<T extends BarLineScatterCandleBubbleChart>
    extends ChartState<T> {
  IDataSet _closestDataSetToTouch;

  Highlight lastHighlighted;
  double _curX = 0.0;
  double _curY = 0.0;
  double _scale = -1.0;

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
    var res = (_closestDataSetToTouch == null &&
            widget.controller.painter.isAnyAxisInverted()) ||
        (_closestDataSetToTouch != null &&
            widget.controller.painter
                .isInverted(_closestDataSetToTouch.getAxisDependency()));
    return res;
  }

  @override
  void onTapDown(TapDownDetails detail) {
    widget.controller.stopDeceleration();
    _curX = detail.localPosition.dx;
    _curY = detail.localPosition.dy;
    _closestDataSetToTouch = widget.controller.painter.getDataSetByTouchPoint(
        detail.localPosition.dx, detail.localPosition.dy);
  }

  @override
  void onSingleTapUp(TapUpDetails detail) {
    if (widget.controller.painter.highLightPerTapEnabled) {
      Highlight h = widget.controller.painter.getHighlightByTouchPoint(
          detail.localPosition.dx, detail.localPosition.dy);
      lastHighlighted = HighlightUtils.performHighlight(
          widget.controller.painter, h, lastHighlighted);
      setStateIfNotDispose();
    } else {
      lastHighlighted = null;
    }
  }

  @override
  void onDoubleTapUp(details) {
    widget.controller.stopDeceleration();
    if (widget.controller.painter.doubleTapToZoomEnabled &&
        widget.controller.painter.getData().getEntryCount() > 0) {
      MPPointF trans =
          _getTrans(details.localPosition.dx, details.localPosition.dy);
      widget.controller.painter.zoom(
          widget.controller.painter.scaleXEnabled ? 1.2 : 1,
          widget.controller.painter.scaleYEnabled ? 1.2 : 1,
          trans.x,
          trans.y);
      setStateIfNotDispose();
      MPPointF.recycleInstance(trans);
    }
  }

  @override
  void onMoveStart(OpsMoveStartDetails details) {
    widget.controller.stopDeceleration();
    _curX = details.localPoint.dx;
    _curY = details.localPoint.dy;
  }

  @override
  void onMoveUpdate(OpsMoveUpdateDetails details) {
    var dx = details.localPoint.dx - _curX;
    var dy = details.localPoint.dy - _curY;
    if (widget.controller.painter.dragYEnabled &&
        widget.controller.painter.dragXEnabled) {
      if (_inverted()) {
        /// if there is an inverted horizontalbarchart
        if (widget is HorizontalBarChart) {
          dx = -dx;
        } else {
          dy = -dy;
        }
      }
      widget.controller.painter.translate(dx, dy);
      setStateIfNotDispose();
    } else {
      if (widget.controller.painter.dragXEnabled) {
        if (_inverted()) {
          /// if there is an inverted horizontalbarchart
          if (widget is HorizontalBarChart) {
            dx = -dx;
          } else {
            dy = -dy;
          }
        }
        widget.controller.painter.translate(dx, 0.0);
        setStateIfNotDispose();
      } else if (widget.controller.painter.dragYEnabled) {
        if (_inverted()) {
          /// if there is an inverted horizontalbarchart
          if (widget is HorizontalBarChart) {
            dx = -dx;
          } else {
            dy = -dy;
          }
        }
        widget.controller.painter.translate(0.0, dy);
        setStateIfNotDispose();
      }
    }
    _curX = details.localPoint.dx;
    _curY = details.localPoint.dy;
  }

  @override
  void onMoveEnd(OpsMoveEndDetails details) {
    widget.controller
      ..stopDeceleration()
      ..setDecelerationVelocity(details.velocity.pixelsPerSecond)
      ..computeScroll();
  }

  @override
  void onScaleStart(OpsScaleStartDetails details) {
    widget.controller.stopDeceleration();
    _curX = details.localPoint.dx;
    _curY = details.localPoint.dy;
  }

  @override
  void onScaleUpdate(OpsScaleUpdateDetails details) {
    var pinchZoomEnabled = widget.controller.pinchZoomEnabled;
    var isYDirection = details.mainDirection == Direction.Y;
    if (_scale == -1.0) {
      if (pinchZoomEnabled) {
        _scale = details.scale;
      } else {
        _scale = isYDirection
            ? details.verticalScale
            : details.horizontalScale;
      }
      return;
    }

    var scale = 1.0;
    if (pinchZoomEnabled) {
      scale = details.scale / _scale;
    } else {
      scale = isYDirection
          ? details.verticalScale / _scale
          : details.horizontalScale / _scale;
    }
    MPPointF trans = _getTrans(_curX, _curY);
    var h = widget.controller.painter.viewPortHandler;
    scale = Utils.optimizeScale(scale);
    if (pinchZoomEnabled) {
      bool canZoomMoreX = scale < 1 ? h.canZoomOutMoreX() : h.canZoomInMoreX();
      bool canZoomMoreY = scale < 1 ? h.canZoomOutMoreY() : h.canZoomInMoreY();
      widget.controller.painter.zoom(
          canZoomMoreX ? scale : 1, canZoomMoreY ? scale : 1, trans.x, trans.y);
      setStateIfNotDispose();
    } else {
      if (isYDirection) {
        if (widget.controller.painter.scaleYEnabled) {
          bool canZoomMoreY =
              scale < 1 ? h.canZoomOutMoreY() : h.canZoomInMoreY();
          widget.controller.painter
              .zoom(1, canZoomMoreY ? scale : 1, trans.x, trans.y);
          setStateIfNotDispose();
        }
      } else {
        if (widget.controller.painter.scaleXEnabled) {
          bool canZoomMoreX =
              scale < 1 ? h.canZoomOutMoreX() : h.canZoomInMoreX();
          widget.controller.painter
              .zoom(canZoomMoreX ? scale : 1, 1, trans.x, trans.y);
          setStateIfNotDispose();
        }
      }
    }
    MPPointF.recycleInstance(trans);

    if (pinchZoomEnabled) {
      _scale = details.scale;
    } else {
      _scale = isYDirection
          ? details.verticalScale
          : details.horizontalScale;
    }
  }

  @override
  void onScaleEnd(OpsScaleEndDetails detail) {
    _scale = -1.0;
  }

  @override
  void updatePainter() {
    if (widget.controller.painter.getData() != null &&
        widget.controller.painter.getData().dataSets != null &&
        widget.controller.painter.getData().dataSets.length > 0)
      widget.controller.painter.highlightValue6(lastHighlighted, false);
  }
}
