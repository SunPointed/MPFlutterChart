import 'dart:math';
import 'dart:ui';

import 'package:flutter/painting.dart';
import 'package:mp_flutter_chart/chart/mp/core/axis/axis_base.dart';
import 'package:mp_flutter_chart/chart/mp/core/render/renderer.dart';
import 'package:mp_flutter_chart/chart/mp/core/transformer/transformer.dart';
import 'package:mp_flutter_chart/chart/mp/core/utils/color_utils.dart';
import 'package:mp_flutter_chart/chart/mp/core/utils/painter_utils.dart';
import 'package:mp_flutter_chart/chart/mp/core/view_port.dart';
import 'package:mp_flutter_chart/chart/mp/core/poolable/point.dart';
import 'package:mp_flutter_chart/chart/mp/core/utils/utils.dart';

abstract class AxisRenderer extends Renderer {
  /// base axis this axis renderer works with */
  AxisBase mAxis;

  /// transformer to transform values to screen pixels and return */
  Transformer mTrans;

  /// paint object for the grid lines
  Paint mGridPaint;

  /// paint for the x-label values
  TextPainter mAxisLabelPaint;

  /// paint for the line surrounding the chart
  Paint mAxisLinePaint;

  /// paint used for the limit lines
  Paint mLimitLinePaint;

  AxisRenderer(
      ViewPortHandler viewPortHandler, Transformer trans, AxisBase axis)
      : super(viewPortHandler) {
    this.mTrans = trans;
    this.mAxis = axis;
    if (mViewPortHandler != null) {
      mGridPaint = Paint()
        ..color = Color.fromARGB(90, 160, 160, 160)
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke;

      mAxisLabelPaint = PainterUtils.create(null, null, ColorUtils.BLACK, null);

      mLimitLinePaint = Paint()
        ..isAntiAlias = true
        ..style = PaintingStyle.stroke;
    }
  }

  /// Returns the Paint object used for drawing the axis (labels).
  ///
  /// @return
  TextPainter getPaintAxisLabels() {
    return mAxisLabelPaint;
  }

  /// Returns the Paint object that is used for drawing the grid-lines of the
  /// axis.
  ///
  /// @return
  Paint getPaintGrid() {
    return mGridPaint;
  }

  /// Returns the Paint object that is used for drawing the axis-line that goes
  /// alongside the axis.
  ///
  /// @return
  Paint getPaintAxisLine() {
    return mAxisLinePaint;
  }

  /// Returns the Transformer object used for transforming the axis values.
  ///
  /// @return
  Transformer getTransformer() {
    return mTrans;
  }

  /// Computes the axis values.
  ///
  /// @param min - the minimum value in the data object for this axis
  /// @param max - the maximum value in the data object for this axis
  void computeAxis(double min, double max, bool inverted) {
    // calculate the starting and entry point of the y-labels (depending on
    // zoom / contentrect bounds)
    if (mViewPortHandler != null &&
        mViewPortHandler.contentWidth() > 10 &&
        !mViewPortHandler.isFullyZoomedOutY()) {
      MPPointD p1 = mTrans.getValuesByTouchPoint1(
          mViewPortHandler.contentLeft(), mViewPortHandler.contentTop());
      MPPointD p2 = mTrans.getValuesByTouchPoint1(
          mViewPortHandler.contentLeft(), mViewPortHandler.contentBottom());

      if (!inverted) {
        min = p2.y;
        max = p1.y;
      } else {
        min = p1.y;
        max = p2.y;
      }

      MPPointD.recycleInstance2(p1);
      MPPointD.recycleInstance2(p2);
    }

    computeAxisValues(min, max);
  }

  /// Sets up the axis values. Computes the desired number of labels between the two given extremes.
  ///
  /// @return
  void computeAxisValues(double min, double max) {
    double yMin = min;
    double yMax = max;

    int labelCount = mAxis.getLabelCount();
    double range = (yMax - yMin).abs();

    if (labelCount == 0 || range <= 0 || range.isInfinite) {
      mAxis.mEntries = List<double>();
      mAxis.mCenteredEntries = List<double>();
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
        Utils.roundToNextSignificant(pow(10.0, log(interval) ~/ ln10));
    int intervalSigDigit = interval ~/ intervalMagnitude;
    if (intervalSigDigit > 5) {
      // Use one order of magnitude higher, to avoid intervals like 0.9 or
      // 90
      interval = (10 * intervalMagnitude).floorToDouble();
    }

    int n = mAxis.isCenterAxisLabelsEnabled() ? 1 : 0;

    // force label count
    if (mAxis.isForceLabelsEnabled()) {
      interval = range / (labelCount - 1);
      mAxis.mEntryCount = labelCount;

      if (mAxis.mEntries.length < labelCount) {
        // Ensure stops contains at least numStops elements.
        mAxis.mEntries = List(labelCount);
      }

      double v = min;

      for (int i = 0; i < labelCount; i++) {
        mAxis.mEntries[i] = v;
        v += interval;
      }

      n = labelCount;

      // no forced count
    } else {
      double first =
          interval == 0.0 ? 0.0 : (yMin / interval).ceil() * interval;
      if (mAxis.isCenterAxisLabelsEnabled()) {
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

      mAxis.mEntryCount = n;

      if (mAxis.mEntries.length < n) {
        // Ensure stops contains at least numStops elements.
        mAxis.mEntries = List(n);
      }

      i = 0;
      for (f = first; i < n; f += interval, ++i) {
        if (f ==
            0.0) // Fix for negative zero case (Where value == -0.0, and 0.0 == -0.0)
          f = 0.0;

        mAxis.mEntries[i] = f;
      }
    }

    // set decimals
    if (interval < 1) {
      mAxis.mDecimals = (-log(interval) / ln10).ceil();
    } else {
      mAxis.mDecimals = 0;
    }

    if (mAxis.isCenterAxisLabelsEnabled()) {
      if (mAxis.mCenteredEntries.length < n) {
        mAxis.mCenteredEntries = List(n);
      }

      double offset = interval / 2.0;

      for (int i = 0; i < n; i++) {
        mAxis.mCenteredEntries[i] = mAxis.mEntries[i] + offset;
      }
    }
  }

  /// Draws the axis labels to the screen.
  ///
  /// @param c
  void renderAxisLabels(Canvas c);

  /// Draws the grid lines belonging to the axis.
  ///
  /// @param c
  void renderGridLines(Canvas c);

  /// Draws the line that goes alongside the axis.
  ///
  /// @param c
  void renderAxisLine(Canvas c);

  /// Draws the LimitLines associated with this axis to the screen.
  ///
  /// @param c
  void renderLimitLines(Canvas c);
}
