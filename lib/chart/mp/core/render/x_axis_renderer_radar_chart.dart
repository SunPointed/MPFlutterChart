import 'package:flutter/painting.dart';
import 'package:mp_flutter_chart/chart/mp/core/axis/x_axis.dart';
import 'package:mp_flutter_chart/chart/mp/core/render/x_axis_renderer.dart';
import 'package:mp_flutter_chart/chart/mp/core/utils/painter_utils.dart';
import 'package:mp_flutter_chart/chart/mp/core/view_port.dart';
import 'package:mp_flutter_chart/chart/mp/painter/radar_chart_painter.dart';
import 'package:mp_flutter_chart/chart/mp/core/poolable/point.dart';
import 'package:mp_flutter_chart/chart/mp/core/utils/utils.dart';

class XAxisRendererRadarChart extends XAxisRenderer {
  RadarChartPainter mChart;

  XAxisRendererRadarChart(
      ViewPortHandler viewPortHandler, XAxis xAxis, RadarChartPainter chart)
      : super(viewPortHandler, xAxis, null) {
    mChart = chart;
  }

  @override
  void renderAxisLabels(Canvas c) {
    if (!mXAxis.isEnabled() || !mXAxis.isDrawLabelsEnabled()) return;

    final double labelRotationAngleDegrees = mXAxis.getLabelRotationAngle();
    final MPPointF drawLabelAnchor = MPPointF.getInstance1(0.5, 0.25);

//    mAxisLabelPaint.setTypeface(mXAxis.getTypeface()); todo

    mAxisLabelPaint = PainterUtils.create(
        null, null, mXAxis.getTextColor(), mXAxis.getTextSize());

    double sliceangle = mChart.getSliceAngle();

    // calculate the factor that is needed for transforming the value to
    // pixels
    double factor = mChart.getFactor();

    MPPointF center = mChart.getCenterOffsets();
    MPPointF pOut = MPPointF.getInstance1(0, 0);
    for (int i = 0;
        i < mChart.getData().getMaxEntryCountSet().getEntryCount();
        i++) {
      String label =
          mXAxis.getValueFormatter().getAxisLabel(i.toDouble(), mXAxis);

      double angle = (sliceangle * i + mChart.getRotationAngle()) % 360;

      Utils.getPosition(
          center,
          mChart.getYRange() * factor + mXAxis.mLabelRotatedWidth / 2,
          angle,
          pOut);

      drawLabel(c, label, pOut.x, pOut.y - mXAxis.mLabelRotatedHeight / 2.0,
          drawLabelAnchor, labelRotationAngleDegrees, mXAxis.getPosition());
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
