import 'package:flutter/widgets.dart';
import 'package:mp_chart/mp/chart/chart.dart';
import 'package:mp_chart/mp/controller/pie_radar_controller.dart';
import 'package:mp_chart/mp/core/highlight/highlight.dart';
import 'package:mp_chart/mp/core/poolable/point.dart';
import 'package:mp_chart/mp/core/utils/highlight_utils.dart';
import 'package:mp_chart/mp/core/utils/utils.dart';
import 'package:mp_chart/mp/painter/pie_redar_chart_painter.dart';

abstract class PieRadarChart<P extends PieRadarChartPainter,
    C extends PieRadarController> extends Chart<P, C> {
  PieRadarChart(C controller) : super(controller);

  @override
  void onRotateUpdate(double angle) {
    controller.rawRotationAngle = angle;
    controller.rotationAngle =
        Utils.getNormalizedAngle(controller.rawRotationAngle);
    state.setStateIfNotDispose();
  }

  PieRadarChartPainter get painter => super.painter;
}

abstract class PieRadarChartState<T extends PieRadarChart>
    extends ChartState<T> {
  Highlight lastHighlighted;
  MPPointF _touchStartPoint = MPPointF.getInstance1(0, 0);
  double _startAngle = 0.0;

  void _setGestureStartAngle(double x, double y) {
    _startAngle = widget.painter.getAngleForPoint(x, y) -
        widget.painter.getRawRotationAngle();
  }

  void _updateGestureRotation(double x, double y) {
    double angle = widget.painter.getAngleForPoint(x, y) - _startAngle;
    widget.controller.rawRotationAngle = angle;
    widget.controller.rotationAngle =
        Utils.getNormalizedAngle(widget.controller.rawRotationAngle);
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
    if (widget.painter.highLightPerTapEnabled) {
      Highlight h = widget.painter.getHighlightByTouchPoint(
          detail.localPosition.dx, detail.localPosition.dy);
      lastHighlighted =
          HighlightUtils.performHighlight(widget.painter, h, lastHighlighted);
//      painter.getOnChartGestureListener()?.onChartSingleTapped(
//          detail.localPosition.dx, detail.localPosition.dy);
      setStateIfNotDispose();
    } else {
      lastHighlighted = null;
    }
  }

  @override
  void onTapDown(TapDownDetails detail) {}
}
