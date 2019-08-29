import 'dart:math';

import 'package:flutter/painting.dart';
import 'package:mp_flutter_chart/chart/mp/core/axis/y_axis.dart';
import 'package:mp_flutter_chart/chart/mp/core/limit_line.dart';
import 'package:mp_flutter_chart/chart/mp/core/render/y_axis_renderer.dart';
import 'package:mp_flutter_chart/chart/mp/core/view_port.dart';
import 'package:mp_flutter_chart/chart/mp/painter/radar_chart_painter.dart';
import 'package:mp_flutter_chart/chart/mp/core/poolable/point.dart';
import 'package:mp_flutter_chart/chart/mp/core/util.dart';

class YAxisRendererRadarChart extends YAxisRenderer {
  RadarChartPainter mChart;

  YAxisRendererRadarChart(
      ViewPortHandler viewPortHandler, YAxis yAxis, RadarChartPainter chart)
      : super(viewPortHandler, yAxis, null) {
    this.mChart = chart;
  }

  @override
  void computeAxisValues(double min, double max) {
    double yMin = min;
    double yMax = max;

    int labelCount = mAxis.getLabelCount();
    double range = (yMax - yMin).abs();

    if (labelCount == 0 || range <= 0 || range.isInfinite) {
      mAxis.mEntries = List();
      mAxis.mCenteredEntries = List();
      mAxis.mEntryCount = 0;
      return;
    }

    // Find out how much spacing (in y value space) between axis values
    double rawInterval = range / labelCount;
    double interval = Utils.roundToNextSignificant(rawInterval);

    // If granularity is enabled, then do not allow the interval to go below specified granularity.
    // This is used to avoid repeated values when rounding values for display.
    if (mAxis.isGranularityEnabled())
      interval =
          interval < mAxis.getGranularity() ? mAxis.getGranularity() : interval;

    // Normalize interval
    double intervalMagnitude =
        Utils.roundToNextSignificant(pow(10.0, log(interval) / ln10));
    int intervalSigDigit = (interval ~/ intervalMagnitude);
    if (intervalSigDigit > 5) {
      // Use one order of magnitude higher, to avoid intervals like 0.9 or
      // 90
      interval = (10 * intervalMagnitude).floor().toDouble();
    }

    bool centeringEnabled = mAxis.isCenterAxisLabelsEnabled();
    int n = centeringEnabled ? 1 : 0;

    // force label count
    if (mAxis.isForceLabelsEnabled()) {
      double step = range / (labelCount - 1);
      mAxis.mEntryCount = labelCount;

      if (mAxis.mEntries.length < labelCount) {
        // Ensure stops contains at least numStops elements.
        mAxis.mEntries = List(labelCount);
      }

      double v = min;

      for (int i = 0; i < labelCount; i++) {
        mAxis.mEntries[i] = v;
        v += step;
      }

      n = labelCount;

      // no forced count
    } else {
      double first =
          interval == 0.0 ? 0.0 : (yMin / interval).ceil() * interval;
      if (centeringEnabled) {
        first -= interval;
      }

      double last = interval == 0.0
          ? 0.0
          : Utils.nextUp((yMax / interval).floor() * interval);

      double f;
      int i;

      if (interval != 0.0) {
        for (f = first; f <= last; f += interval) {
          ++n;
        }
      }

      n++;

      mAxis.mEntryCount = n;

      if (mAxis.mEntries.length < n) {
        // Ensure stops contains at least numStops elements.
        mAxis.mEntries = List(n);
      }

      f = first;
      for (i = 0; i < n; f += interval, ++i) {
        if (f ==
            0.0) // Fix for negative zero case (Where value == -0.0, and 0.0 == -0.0)
          f = 0.0;

        mAxis.mEntries[i] = f.toDouble();
      }
    }

    // set decimals
    if (interval < 1) {
      mAxis.mDecimals = (-log(interval) / ln10).ceil();
    } else {
      mAxis.mDecimals = 0;
    }

    if (centeringEnabled) {
      if (mAxis.mCenteredEntries.length < n) {
        mAxis.mCenteredEntries = List(n);
      }

      double offset = (mAxis.mEntries[1] - mAxis.mEntries[0]) / 2;

      for (int i = 0; i < n; i++) {
        mAxis.mCenteredEntries[i] = mAxis.mEntries[i] + offset;
      }
    }

    mAxis.mAxisMinimum = mAxis.mEntries[0];
    mAxis.mAxisMaximum = mAxis.mEntries[n - 1];
    mAxis.mAxisRange = (mAxis.mAxisMaximum - mAxis.mAxisMinimum).abs();
  }

  @override
  void renderAxisLabels(Canvas c) {
    if (!mYAxis.isEnabled() || !mYAxis.isDrawLabelsEnabled()) return;

//    mAxisLabelPaint.setTypeface(mYAxis.getTypeface());

    MPPointF center = mChart.getCenterOffsets();
    MPPointF pOut = MPPointF.getInstance1(0, 0);
    double factor = mChart.getFactor();

    final int from = mYAxis.isDrawBottomYLabelEntryEnabled() ? 0 : 1;
    final int to = mYAxis.isDrawTopYLabelEntryEnabled()
        ? mYAxis.mEntryCount
        : (mYAxis.mEntryCount - 1);

    for (int j = from; j < to; j++) {
      double r = (mYAxis.mEntries[j] - mYAxis.mAxisMinimum) * factor;

      Utils.getPosition(center, r, mChart.getRotationAngle(), pOut);

      String label = mYAxis.getFormattedLabel(j);

      mAxisLabelPaint = TextPainter(
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
          text: TextSpan(
              text: label,
              style: TextStyle(
                  color: mYAxis.getTextColor(),
                  fontSize: mYAxis.getTextSize())));
      mAxisLabelPaint.layout();
      mAxisLabelPaint.paint(
          c,
          Offset(pOut.x + 10 - mAxisLabelPaint.width,
              pOut.y - mAxisLabelPaint.height));
    }
    MPPointF.recycleInstance(center);
    MPPointF.recycleInstance(pOut);
  }

  Path mRenderLimitLinesPathBuffer = new Path();

  @override
  void renderLimitLines(Canvas c) {
    List<LimitLine> limitLines = mYAxis.getLimitLines();

    if (limitLines == null) return;

    double sliceangle = mChart.getSliceAngle();

    // calculate the factor that is needed for transforming the value to
    // pixels
    double factor = mChart.getFactor();

    MPPointF center = mChart.getCenterOffsets();
    MPPointF pOut = MPPointF.getInstance1(0, 0);
    for (int i = 0; i < limitLines.length; i++) {
      LimitLine l = limitLines[i];

      if (!l.isEnabled()) continue;

      mLimitLinePaint
        ..color = (l.getLineColor())
        ..strokeWidth = l.getLineWidth();
//      mLimitLinePaint.setPathEffect(l.getDashPathEffect()); todo

      double r = (l.getLimit() - mChart.getYChartMin()) * factor;

      Path limitPath = mRenderLimitLinesPathBuffer;
      limitPath.reset();

      for (int j = 0;
          j < mChart.getData().getMaxEntryCountSet().getEntryCount();
          j++) {
        Utils.getPosition(
            center, r, sliceangle * j + mChart.getRotationAngle(), pOut);

        if (j == 0)
          limitPath.moveTo(pOut.x, pOut.y);
        else
          limitPath.lineTo(pOut.x, pOut.y);
      }
      limitPath.close();

      c.drawPath(limitPath, mLimitLinePaint);
    }
    MPPointF.recycleInstance(center);
    MPPointF.recycleInstance(pOut);
  }
}
