import 'package:flutter/widgets.dart';
import 'package:mp_chart/mp/chart/chart.dart';
import 'package:mp_chart/mp/chart/horizontal_bar_chart.dart';
import 'package:mp_chart/mp/controller/bar_line_scatter_candle_bubble_controller.dart';
import 'package:mp_chart/mp/core/data_interfaces/i_data_set.dart';
import 'package:mp_chart/mp/core/enums/scale_orientation.dart';
import 'package:mp_chart/mp/core/highlight/highlight.dart';
import 'package:mp_chart/mp/core/poolable/point.dart';
import 'package:mp_chart/mp/core/utils/highlight_utils.dart';
import 'package:mp_chart/mp/core/utils/utils.dart';
import 'package:mp_chart/mp/core/view_port.dart';

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
  ScaleOrientation _scaleOrientation;
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
  void onDoubleTap() {
    widget.controller.stopDeceleration();
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
    } else {
      widget.controller
        ..stopDeceleration()
        ..setDecelerationVelocity(detail.velocity.pixelsPerSecond)
        ..computeScroll();
    }
    _scaleOrientation = null;
    _scale = -1.0;
  }

  @override
  void onScaleStart(ScaleStartDetails detail) {
    widget.controller.stopDeceleration();
    _curX = detail.localFocalPoint.dx;
    _curY = detail.localFocalPoint.dy;
  }

  @override
  void onScaleUpdate(ScaleUpdateDetails detail) {
    var pinchZoomEnabled = widget.controller.pinchZoomEnabled;
    if (_scale == -1.0) {
      if (pinchZoomEnabled) {
        _scale = detail.scale;
      } else {
        var which = detail.verticalScale > detail.horizontalScale;
        _scaleOrientation =
            which ? ScaleOrientation.VERTICAL : ScaleOrientation.HORIZONTAL;
        _scale = which ? detail.verticalScale : detail.horizontalScale;
      }
      return;
    }

    var isDrag = (pinchZoomEnabled && _scale == detail.scale) ||
        (!pinchZoomEnabled &&
            _scaleOrientation == ScaleOrientation.VERTICAL &&
            _scale == detail.verticalScale) ||
        (!pinchZoomEnabled &&
            _scaleOrientation == ScaleOrientation.HORIZONTAL &&
            _scale == detail.horizontalScale);
    if (isDrag) {
      if (_isZoom) {
        return;
      }

      var dx = detail.localFocalPoint.dx - _curX;
      var dy = detail.localFocalPoint.dy - _curY;
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
      _curX = detail.localFocalPoint.dx;
      _curY = detail.localFocalPoint.dy;
    } else {
      var scale = 1.0;
      if (pinchZoomEnabled) {
        scale = detail.scale / _scale;
      } else {
        scale = _scaleOrientation == ScaleOrientation.VERTICAL
            ? detail.verticalScale / _scale
            : detail.horizontalScale / _scale;
      }

      if (!_isZoom) {
        if (pinchZoomEnabled) {
          scale = detail.scale;
        } else {
          scale = _scaleOrientation == ScaleOrientation.VERTICAL
              ? detail.verticalScale
              : detail.horizontalScale;
        }
        _isZoom = true;
      }

      MPPointF trans = _getTrans(_curX, _curY);
      var h = widget.controller.painter.viewPortHandler;
      scale = Utils.optimizeScale(scale);
      if (pinchZoomEnabled) {
        bool canZoomMoreX =
            scale < 1 ? h.canZoomOutMoreX() : h.canZoomInMoreX();
        bool canZoomMoreY =
            scale < 1 ? h.canZoomOutMoreY() : h.canZoomInMoreY();
        widget.controller.painter.zoom(canZoomMoreX ? scale : 1,
            canZoomMoreY ? scale : 1, trans.x, trans.y);
        setStateIfNotDispose();
      } else {
        if (_scaleOrientation == ScaleOrientation.VERTICAL) {
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
    }
    if (pinchZoomEnabled) {
      _scale = detail.scale;
    } else {
      _scale = _scaleOrientation == ScaleOrientation.VERTICAL
          ? detail.verticalScale
          : detail.horizontalScale;
    }
    _curX = detail.localFocalPoint.dx;
    _curY = detail.localFocalPoint.dy;
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
  void updatePainter() {
    if (widget.controller.painter.getData() != null &&
        widget.controller.painter.getData().dataSets != null &&
        widget.controller.painter.getData().dataSets.length > 0)
      widget.controller.painter.highlightValue6(lastHighlighted, false);
  }
}
