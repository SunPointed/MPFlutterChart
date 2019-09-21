import 'package:flutter/painting.dart';
import 'package:mp_flutter_chart/chart/mp/core/axis/x_axis.dart';
import 'package:mp_flutter_chart/chart/mp/core/render/x_axis_renderer.dart';
import 'package:mp_flutter_chart/chart/mp/core/utils/painter_utils.dart';
import 'package:mp_flutter_chart/chart/mp/core/view_port.dart';
import 'package:mp_flutter_chart/chart/mp/painter/radar_chart_painter.dart';
import 'package:mp_flutter_chart/chart/mp/core/poolable/point.dart';
import 'package:mp_flutter_chart/chart/mp/core/utils/utils.dart';

class XAxisRendererRadarChart extends XAxisRenderer {
  RadarChartPainter _painter;

  XAxisRendererRadarChart(
      ViewPortHandler viewPortHandler, XAxis xAxis, RadarChartPainter chart)
      : super(viewPortHandler, xAxis, null) {
    _painter = chart;
  }

  @override
  void renderAxisLabels(Canvas c) {
    if (!xAxis.enabled || !xAxis.drawLabels) return;

    final double labelRotationAngleDegrees = xAxis.labelRotationAngle;
    final MPPointF drawLabelAnchor = MPPointF.getInstance1(0.5, 0.25);

//    axisLabelPaint.setTypeface(xAxis.getTypeface()); todo

    axisLabelPaint =
        PainterUtils.create(null, null, xAxis.textColor, xAxis.textSize);

    double sliceangle = _painter.getSliceAngle();

    // calculate the factor that is needed for transforming the value to
    // pixels
    double factor = _painter.getFactor();

    MPPointF center = _painter.getCenterOffsets();
    MPPointF pOut = MPPointF.getInstance1(0, 0);
    for (int i = 0;
        i < _painter.getData().getMaxEntryCountSet().getEntryCount();
        i++) {
      String label =
          xAxis.getValueFormatter().getAxisLabel(i.toDouble(), xAxis);

      double angle = (sliceangle * i + _painter.getRotationAngle()) % 360;

      Utils.getPosition(
          center,
          _painter.yAxis.axisRange * factor + xAxis.labelRotatedWidth / 2,
          angle,
          pOut);

      drawLabel(c, label, pOut.x, pOut.y - xAxis.labelRotatedHeight / 2.0,
          drawLabelAnchor, labelRotationAngleDegrees, xAxis.position);
    }

    MPPointF.recycleInstance(center);
    MPPointF.recycleInstance(pOut);
    MPPointF.recycleInstance(drawLabelAnchor);
  }

  /// XAxis LimitLines on RadarChart not yet supported.
  ///
  /// @param c
  @override
  void renderLimitLines(Canvas c) {
    // this space intentionally left blank
  }
}
