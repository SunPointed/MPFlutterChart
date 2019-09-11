import 'dart:ui';

import 'package:flutter/painting.dart';
import 'package:mp_flutter_chart/chart/mp/core/axis/y_axis.dart';
import 'package:mp_flutter_chart/chart/mp/core/enums/axis_dependency.dart';
import 'package:mp_flutter_chart/chart/mp/core/enums/limite_label_postion.dart';
import 'package:mp_flutter_chart/chart/mp/core/enums/y_axis_label_position.dart';
import 'package:mp_flutter_chart/chart/mp/core/limit_line.dart';
import 'package:mp_flutter_chart/chart/mp/core/render/y_axis_renderer.dart';
import 'package:mp_flutter_chart/chart/mp/core/transformer/transformer.dart';
import 'package:mp_flutter_chart/chart/mp/core/utils/painter_utils.dart';
import 'package:mp_flutter_chart/chart/mp/core/view_port.dart';
import 'package:mp_flutter_chart/chart/mp/core/poolable/point.dart';
import 'package:mp_flutter_chart/chart/mp/core/utils/utils.dart';

class YAxisRendererHorizontalBarChart extends YAxisRenderer {
  YAxisRendererHorizontalBarChart(
      ViewPortHandler viewPortHandler, YAxis yAxis, Transformer trans)
      : super(viewPortHandler, yAxis, trans);

  /// Computes the axis values.
  ///
  /// @param yMin - the minimum y-value in the data object for this axis
  /// @param yMax - the maximum y-value in the data object for this axis
  @override
  void computeAxis(double yMin, double yMax, bool inverted) {
    // calculate the starting and entry point of the y-labels (depending on
    // zoom / contentrect bounds)
    if (mViewPortHandler.contentHeight() > 10 &&
        !mViewPortHandler.isFullyZoomedOutX()) {
      MPPointD p1 = mTrans.getValuesByTouchPoint1(
          mViewPortHandler.contentLeft(), mViewPortHandler.contentTop());
      MPPointD p2 = mTrans.getValuesByTouchPoint1(
          mViewPortHandler.contentRight(), mViewPortHandler.contentTop());

      if (!inverted) {
        yMin = p1.x;
        yMax = p2.x;
      } else {
        yMin = p2.x;
        yMax = p1.x;
      }

      MPPointD.recycleInstance2(p1);
      MPPointD.recycleInstance2(p2);
    }

    computeAxisValues(yMin, yMax);
  }

  /// draws the y-axis labels to the screen
  @override
  void renderAxisLabels(Canvas c) {
    if (!mYAxis.isEnabled() || !mYAxis.isDrawLabelsEnabled()) return;

    List<double> positions = getTransformedPositions();

    mAxisLabelPaint = PainterUtils.create(
        mAxisLabelPaint, null, mYAxis.getTextColor(), mYAxis.getTextSize());

//    double baseYOffset = Utils.convertDpToPixel(2.5);
//    double textHeight = Utils.calcTextHeight(mAxisLabelPaint, "Q").toDouble();

    AxisDependency dependency = mYAxis.getAxisDependency();
    YAxisLabelPosition labelPosition = mYAxis.getLabelPosition();

    double yPos = 0;

    if (dependency == AxisDependency.LEFT) {
      if (labelPosition == YAxisLabelPosition.OUTSIDE_CHART) {
        yPos = mViewPortHandler.contentTop();
      } else {
        yPos = mViewPortHandler.contentTop();
      }
    } else {
      if (labelPosition == YAxisLabelPosition.OUTSIDE_CHART) {
        yPos = mViewPortHandler.contentBottom();
      } else {
        yPos = mViewPortHandler.contentBottom();
      }
    }

    drawYLabels(c, yPos, positions, dependency, labelPosition);
  }

  @override
  void renderAxisLine(Canvas c) {
    if (!mYAxis.isEnabled() || !mYAxis.isDrawAxisLineEnabled()) return;
    mAxisLinePaint = Paint()
      ..color = mYAxis.getAxisLineColor()
      ..strokeWidth = mYAxis.getAxisLineWidth();

    if (mYAxis.getAxisDependency() == AxisDependency.LEFT) {
      c.drawLine(
          Offset(mViewPortHandler.contentLeft(), mViewPortHandler.contentTop()),
          Offset(
              mViewPortHandler.contentRight(), mViewPortHandler.contentTop()),
          mAxisLinePaint);
    } else {
      c.drawLine(
          Offset(
              mViewPortHandler.contentLeft(), mViewPortHandler.contentBottom()),
          Offset(mViewPortHandler.contentRight(),
              mViewPortHandler.contentBottom()),
          mAxisLinePaint);
    }
  }

  /// draws the y-labels on the specified x-position
  ///
  /// @param fixedPosition
  /// @param positions
  @override
  void drawYLabels(Canvas c, double fixedPosition, List<double> positions,
      AxisDependency axisDependency, YAxisLabelPosition position) {
    mAxisLabelPaint = PainterUtils.create(
        mAxisLabelPaint, null, mYAxis.getTextColor(), mYAxis.getTextSize());

    final int from = mYAxis.isDrawBottomYLabelEntryEnabled() ? 0 : 1;
    final int to = mYAxis.isDrawTopYLabelEntryEnabled()
        ? mYAxis.mEntryCount
        : (mYAxis.mEntryCount - 1);

    for (int i = from; i < to; i++) {
      String text = mYAxis.getFormattedLabel(i);
      mAxisLabelPaint.text =
          TextSpan(text: text, style: mAxisLabelPaint.text.style);
      mAxisLabelPaint.layout();

      if (axisDependency == AxisDependency.LEFT) {
        if (position == YAxisLabelPosition.OUTSIDE_CHART) {
          mAxisLabelPaint.paint(
              c,
              Offset(positions[i * 2] - mAxisLabelPaint.width / 2,
                  fixedPosition - mAxisLabelPaint.height));
        } else {
          mAxisLabelPaint.paint(
              c,
              Offset(
                  positions[i * 2] - mAxisLabelPaint.width / 2, fixedPosition));
        }
      } else {
        if (position == YAxisLabelPosition.OUTSIDE_CHART) {
          mAxisLabelPaint.paint(
              c,
              Offset(
                  positions[i * 2] - mAxisLabelPaint.width / 2, fixedPosition));
        } else {
          mAxisLabelPaint.paint(
              c,
              Offset(positions[i * 2] - mAxisLabelPaint.width / 2,
                  fixedPosition - mAxisLabelPaint.height));
        }
      }
    }
  }

  @override
  List<double> getTransformedPositions() {
    if (mGetTransformedPositionsBuffer.length != mYAxis.mEntryCount * 2) {
      mGetTransformedPositionsBuffer = List(mYAxis.mEntryCount * 2);
    }
    List<double> positions = mGetTransformedPositionsBuffer;

    for (int i = 0; i < positions.length; i += 2) {
      // only fill x values, y values are not needed for x-labels
      positions[i] = mYAxis.mEntries[i ~/ 2];
    }

    mTrans.pointValuesToPixel(positions);
    return positions;
  }

  @override
  Rect getGridClippingRect() {
    mGridClippingRect = Rect.fromLTRB(
        mViewPortHandler.getContentRect().left - mAxis.getGridLineWidth(),
        mViewPortHandler.getContentRect().top - mAxis.getGridLineWidth(),
        mViewPortHandler.getContentRect().right,
        mViewPortHandler.getContentRect().bottom);
    return mGridClippingRect;
  }

  @override
  Path linePath(Path p, int i, List<double> positions) {
    p.moveTo(positions[i], mViewPortHandler.contentTop());
    p.lineTo(positions[i], mViewPortHandler.contentBottom());
    return p;
  }

  Path mDrawZeroLinePathBuffer = Path();

  @override
  void drawZeroLine(Canvas c) {
    c.save();
    mZeroLineClippingRect = Rect.fromLTRB(
        mViewPortHandler.getContentRect().left - mYAxis.getZeroLineWidth(),
        mViewPortHandler.getContentRect().top - mYAxis.getZeroLineWidth(),
        mViewPortHandler.getContentRect().right,
        mViewPortHandler.getContentRect().bottom);
    c.clipRect(mLimitLineClippingRect);

    // draw zero line
    MPPointD pos = mTrans.getPixelForValues(0, 0);

    mZeroLinePaint
      ..color = mYAxis.getZeroLineColor()
      ..strokeWidth = mYAxis.getZeroLineWidth();

    Path zeroLinePath = mDrawZeroLinePathBuffer;
    zeroLinePath.reset();

    zeroLinePath.moveTo(pos.x - 1, mViewPortHandler.contentTop());
    zeroLinePath.lineTo(pos.x - 1, mViewPortHandler.contentBottom());

    // draw a path because lines don't support dashing on lower android versions
    c.drawPath(zeroLinePath, mZeroLinePaint);

    c.restore();
  }

  Path mRenderLimitLinesPathBuffer = Path();
  List<double> mRenderLimitLinesBuffer = List(4);

  /// Draws the LimitLines associated with this axis to the screen.
  /// This is the standard XAxis renderer using the YAxis limit lines.
  ///
  /// @param c
  @override
  void renderLimitLines(Canvas c) {
    List<LimitLine> limitLines = mYAxis.getLimitLines();

    if (limitLines == null || limitLines.length <= 0) return;

    List<double> pts = mRenderLimitLinesBuffer;
    pts[0] = 0;
    pts[1] = 0;
    pts[2] = 0;
    pts[3] = 0;
    Path limitLinePath = mRenderLimitLinesPathBuffer;
    limitLinePath.reset();

    for (int i = 0; i < limitLines.length; i++) {
      LimitLine l = limitLines[i];

      if (!l.isEnabled()) continue;

      c.save();
      mLimitLineClippingRect = Rect.fromLTRB(
          mViewPortHandler.getContentRect().left - l.getLineWidth(),
          mViewPortHandler.getContentRect().top - l.getLineWidth(),
          mViewPortHandler.getContentRect().right,
          mViewPortHandler.getContentRect().bottom);
      c.clipRect(mLimitLineClippingRect);

      pts[0] = l.getLimit();
      pts[2] = l.getLimit();

      mTrans.pointValuesToPixel(pts);

      pts[1] = mViewPortHandler.contentTop();
      pts[3] = mViewPortHandler.contentBottom();

      limitLinePath.moveTo(pts[0], pts[1]);
      limitLinePath.lineTo(pts[2], pts[3]);

      mLimitLinePaint
        ..style = PaintingStyle.stroke
        ..color = l.getLineColor()
        ..strokeWidth = l.getLineWidth();
//      mLimitLinePaint.setPathEffect(l.getDashPathEffect());

      c.drawPath(limitLinePath, mLimitLinePaint);
      limitLinePath.reset();

      String label = l.getLabel();

      // if drawing the limit-value label is enabled
      if (label != null && label.isNotEmpty) {
        mAxisLabelPaint = PainterUtils.create(
            mAxisLabelPaint, label, l.getTextColor(), l.getTextSize());
        mAxisLabelPaint.layout();
//        mLimitLinePaint.setPathEffect(null);
//        mLimitLinePaint.setStrokeWidth(0.5f);

        double xOffset = l.getLineWidth() + l.getXOffset();
        double yOffset = Utils.convertDpToPixel(2) + l.getYOffset();

        final LimitLabelPosition position = l.getLabelPosition();

        if (position == LimitLabelPosition.RIGHT_TOP) {
          final double labelLineHeight =
              Utils.calcTextHeight(mAxisLabelPaint, label).toDouble();
          mAxisLabelPaint.paint(c,
              Offset(pts[0], mViewPortHandler.contentTop() + labelLineHeight));
        } else if (position == LimitLabelPosition.RIGHT_BOTTOM) {
          mAxisLabelPaint.paint(
              c, Offset(pts[0], mViewPortHandler.contentBottom()));
        } else if (position == LimitLabelPosition.LEFT_TOP) {
          final double labelLineHeight =
              Utils.calcTextHeight(mAxisLabelPaint, label).toDouble();
          mAxisLabelPaint.paint(c,
              Offset(pts[0], mViewPortHandler.contentTop() + labelLineHeight));
        } else {
          mAxisLabelPaint.paint(
              c, Offset(pts[0], mViewPortHandler.contentBottom()));
        }
      }

      c.restore();
    }
  }
}
