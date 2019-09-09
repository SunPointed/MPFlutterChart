import 'dart:ui';

import 'package:flutter/painting.dart';
import 'package:mp_flutter_chart/chart/mp/core/axis/y_axis.dart';
import 'package:mp_flutter_chart/chart/mp/core/enums/axis_dependency.dart';
import 'package:mp_flutter_chart/chart/mp/core/enums/limite_label_postion.dart';
import 'package:mp_flutter_chart/chart/mp/core/enums/y_axis_label_position.dart';
import 'package:mp_flutter_chart/chart/mp/core/limit_line.dart';
import 'package:mp_flutter_chart/chart/mp/core/poolable/point.dart';
import 'package:mp_flutter_chart/chart/mp/core/render/axis_renderer.dart';
import 'package:mp_flutter_chart/chart/mp/core/transformer/transformer.dart';
import 'package:mp_flutter_chart/chart/mp/core/utils/color_utils.dart';
import 'package:mp_flutter_chart/chart/mp/core/utils/painter_utils.dart';
import 'package:mp_flutter_chart/chart/mp/core/utils/utils.dart';
import 'package:mp_flutter_chart/chart/mp/core/view_port.dart';

class YAxisRenderer extends AxisRenderer {
  YAxis mYAxis;

  Paint mZeroLinePaint;

  YAxisRenderer(ViewPortHandler viewPortHandler, YAxis yAxis, Transformer trans)
      : super(viewPortHandler, trans, yAxis) {
    this.mYAxis = yAxis;

    if (mViewPortHandler != null) {
      mAxisLabelPaint = PainterUtils.create(
          mAxisLabelPaint, null, ColorUtils.BLACK, Utils.convertDpToPixel(10));

      mZeroLinePaint = Paint()
        ..isAntiAlias = true
        ..color = ColorUtils.GRAY
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke;
    }
  }

  /**
   * draws the y-axis labels to the screen
   */
  @override
  void renderAxisLabels(Canvas c) {
    if (!mYAxis.isEnabled() || !mYAxis.isDrawLabelsEnabled()) return;

    List<double> positions = getTransformedPositions();

    AxisDependency dependency = mYAxis.getAxisDependency();
    YAxisLabelPosition labelPosition = mYAxis.getLabelPosition();

    double xPos = 0;

    if (dependency == AxisDependency.LEFT) {
      if (labelPosition == YAxisLabelPosition.OUTSIDE_CHART) {
        mAxisLabelPaint = PainterUtils.create(
            mAxisLabelPaint, null, mYAxis.getTextColor(), mYAxis.getTextSize());
        xPos = mViewPortHandler.offsetLeft();
      } else {
        mAxisLabelPaint = PainterUtils.create(
            mAxisLabelPaint, null, mYAxis.getTextColor(), mYAxis.getTextSize());
        xPos = mViewPortHandler.offsetLeft();
      }
    } else {
      if (labelPosition == YAxisLabelPosition.OUTSIDE_CHART) {
        mAxisLabelPaint = PainterUtils.create(
            mAxisLabelPaint, null, mYAxis.getTextColor(), mYAxis.getTextSize());
        xPos = mViewPortHandler.contentRight();
      } else {
        mAxisLabelPaint = PainterUtils.create(
            mAxisLabelPaint, null, mYAxis.getTextColor(), mYAxis.getTextSize());
        xPos = mViewPortHandler.contentRight();
      }
    }

    drawYLabels(c, xPos, positions, dependency, labelPosition);
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
              mViewPortHandler.contentLeft(), mViewPortHandler.contentBottom()),
          mAxisLinePaint);
    } else {
      c.drawLine(
          Offset(
              mViewPortHandler.contentRight(), mViewPortHandler.contentTop()),
          Offset(mViewPortHandler.contentRight(),
              mViewPortHandler.contentBottom()),
          mAxisLinePaint);
    }
  }

  /**
   * draws the y-labels on the specified x-position
   *
   * @param fixedPosition
   * @param positions
   */
  void drawYLabels(
    Canvas c,
    double fixedPosition,
    List<double> positions,
    AxisDependency axisDependency,
    YAxisLabelPosition position,
  ) {
    final int from = mYAxis.isDrawBottomYLabelEntryEnabled() ? 0 : 1;
    final int to = mYAxis.isDrawTopYLabelEntryEnabled()
        ? mYAxis.mEntryCount
        : (mYAxis.mEntryCount - 1);

    // draw
    for (int i = from; i < to; i++) {
      String text = mYAxis.getFormattedLabel(i);

      mAxisLabelPaint.text =
          TextSpan(text: text, style: mAxisLabelPaint.text.style);
      mAxisLabelPaint.layout();
      if (axisDependency == AxisDependency.LEFT) {
        if (position == YAxisLabelPosition.OUTSIDE_CHART) {
          mAxisLabelPaint.paint(
              c,
              Offset(fixedPosition - mAxisLabelPaint.width,
                  positions[i * 2 + 1] - mAxisLabelPaint.height / 2));
        } else {
          mAxisLabelPaint.paint(
              c,
              Offset(fixedPosition,
                  positions[i * 2 + 1] - mAxisLabelPaint.height / 2));
        }
      } else {
        if (position == YAxisLabelPosition.OUTSIDE_CHART) {
          mAxisLabelPaint.paint(
              c,
              Offset(fixedPosition,
                  positions[i * 2 + 1] - mAxisLabelPaint.height / 2));
        } else {
          mAxisLabelPaint.paint(
              c,
              Offset(fixedPosition - mAxisLabelPaint.width,
                  positions[i * 2 + 1] - mAxisLabelPaint.height / 2));
        }
      }
    }
  }

  Path mRenderGridLinesPath = Path();

  @override
  void renderGridLines(Canvas c) {
    if (!mYAxis.isEnabled()) return;

    if (mYAxis.isDrawGridLinesEnabled()) {
      c.save();
      c.clipRect(getGridClippingRect());

      List<double> positions = getTransformedPositions();

      mGridPaint
        ..color = mYAxis.getGridColor()
        ..strokeWidth = mYAxis.getGridLineWidth();

      Path gridLinePath = mRenderGridLinesPath;
      gridLinePath.reset();

      // draw the grid
      for (int i = 0; i < positions.length; i += 2) {
        // draw a path because lines don't support dashing on lower android versions
        c.drawPath(linePath(gridLinePath, i, positions), mGridPaint);
        gridLinePath.reset();
      }

      c.restore();
    }

    if (mYAxis.isDrawZeroLineEnabled()) {
      drawZeroLine(c);
    }
  }

  Rect mGridClippingRect = Rect.zero;

  Rect getGridClippingRect() {
    mGridClippingRect = Rect.fromLTRB(
        mViewPortHandler.getContentRect().left,
        mViewPortHandler.getContentRect().top,
        mViewPortHandler.getContentRect().right + mAxis.getGridLineWidth(),
        mViewPortHandler.getContentRect().bottom + mAxis.getGridLineWidth());
    return mGridClippingRect;
  }

  /**
   * Calculates the path for a grid line.
   *
   * @param p
   * @param i
   * @param positions
   * @return
   */
  Path linePath(Path p, int i, List<double> positions) {
    p.moveTo(mViewPortHandler.offsetLeft(), positions[i + 1]);
    p.lineTo(mViewPortHandler.contentRight(), positions[i + 1]);

    return p;
  }

  List<double> mGetTransformedPositionsBuffer = List(2);

  /**
   * Transforms the values contained in the axis entries to screen pixels and returns them in form of a double array
   * of x- and y-coordinates.
   *
   * @return
   */
  List<double> getTransformedPositions() {
    if (mGetTransformedPositionsBuffer.length != mYAxis.mEntryCount * 2) {
      mGetTransformedPositionsBuffer = List(mYAxis.mEntryCount * 2);
    }
    List<double> positions = mGetTransformedPositionsBuffer;

    for (int i = 0; i < positions.length; i += 2) {
      // only fill y values, x values are not needed for y-labels
      positions[i] = 0.0;
      positions[i + 1] = mYAxis.mEntries[i ~/ 2];
    }

    mTrans.pointValuesToPixel(positions);
    return positions;
  }

  Path mDrawZeroLinePath = Path();
  Rect mZeroLineClippingRect = Rect.zero;

  /**
   * Draws the zero line.
   */
  void drawZeroLine(Canvas c) {
    c.save();
    mZeroLineClippingRect = Rect.fromLTRB(
        mViewPortHandler.getContentRect().left,
        mViewPortHandler.getContentRect().top,
        mViewPortHandler.getContentRect().right + mYAxis.getZeroLineWidth(),
        mViewPortHandler.getContentRect().bottom + mYAxis.getZeroLineWidth());
    c.clipRect(mZeroLineClippingRect);

    // draw zero line
    MPPointD pos = mTrans.getPixelForValues(0, 0);

    mZeroLinePaint
      ..color = mYAxis.getZeroLineColor()
      ..strokeWidth = mYAxis.getZeroLineWidth();

    Path zeroLinePath = mDrawZeroLinePath;
    zeroLinePath.reset();

    zeroLinePath.moveTo(mViewPortHandler.contentLeft(), pos.y);
    zeroLinePath.lineTo(mViewPortHandler.contentRight(), pos.y);

    // draw a path because lines don't support dashing on lower android versions
    c.drawPath(zeroLinePath, mZeroLinePaint);

    c.restore();
  }

  Path mRenderLimitLines = Path();
  List<double> mRenderLimitLinesBuffer = List(2);
  Rect mLimitLineClippingRect = Rect.zero;

  /**
   * Draws the LimitLines associated with this axis to the screen.
   *
   * @param c
   */
  @override
  void renderLimitLines(Canvas c) {
    List<LimitLine> limitLines = mYAxis.getLimitLines();

    if (limitLines == null || limitLines.length <= 0) return;

    List<double> pts = mRenderLimitLinesBuffer;
    pts[0] = 0;
    pts[1] = 0;
    Path limitLinePath = mRenderLimitLines;
    limitLinePath.reset();

    for (int i = 0; i < limitLines.length; i++) {
      LimitLine l = limitLines[i];

      if (!l.isEnabled()) continue;

      c.save();
      mLimitLineClippingRect = Rect.fromLTRB(
          mViewPortHandler.getContentRect().left,
          mViewPortHandler.getContentRect().top,
          mViewPortHandler.getContentRect().right + l.getLineWidth(),
          mViewPortHandler.getContentRect().bottom + l.getLineWidth());
      c.clipRect(mLimitLineClippingRect);

      mLimitLinePaint
        ..style = PaintingStyle.stroke
        ..strokeWidth = l.getLineWidth()
        ..color = l.getLineColor();

      pts[1] = l.getLimit();

      mTrans.pointValuesToPixel(pts);

      limitLinePath.moveTo(mViewPortHandler.contentLeft(), pts[1]);
      limitLinePath.lineTo(mViewPortHandler.contentRight(), pts[1]);

      c.drawPath(limitLinePath, mLimitLinePaint);
      limitLinePath.reset();
      // c.drawLines(pts, mLimitLinePaint);

      String label = l.getLabel();

      // if drawing the limit-value label is enabled
      if (label != null && label.isNotEmpty) {
        TextPainter painter =
            PainterUtils.create(null, null, l.getTextColor(), l.getTextSize());
        final double labelLineHeight =
            Utils.calcTextHeight(painter, label).toDouble();
        double xOffset = Utils.convertDpToPixel(4) + l.getXOffset();
        double yOffset = l.getLineWidth() + labelLineHeight + l.getYOffset();

        final LimitLabelPosition position = l.getLabelPosition();

        if (position == LimitLabelPosition.RIGHT_TOP) {
          TextPainter painter = PainterUtils.create(
              null, null, l.getTextColor(), l.getTextSize());
          painter.layout();
          painter.paint(
              c,
              Offset(mViewPortHandler.contentRight() - xOffset - painter.width,
                  pts[1] - yOffset + labelLineHeight - painter.height));
        } else if (position == LimitLabelPosition.RIGHT_BOTTOM) {
          TextPainter painter = PainterUtils.create(
              null, null, l.getTextColor(), l.getTextSize());
          painter.layout();
          painter.paint(
              c,
              Offset(mViewPortHandler.contentRight() - xOffset - painter.width,
                  pts[1] + yOffset - painter.height));
        } else if (position == LimitLabelPosition.LEFT_TOP) {
          TextPainter painter = PainterUtils.create(
              null, null, l.getTextColor(), l.getTextSize());
          painter.layout();
          painter.paint(
              c,
              Offset(mViewPortHandler.contentLeft() + xOffset - painter.width,
                  pts[1] - yOffset + labelLineHeight - painter.height));
        } else {
          TextPainter painter = PainterUtils.create(
              null, null, l.getTextColor(), l.getTextSize());
          painter.layout();
          painter.paint(
              c,
              Offset(mViewPortHandler.offsetLeft() + xOffset - painter.width,
                  pts[1] + yOffset - painter.height));
        }
      }

      c.restore();
    }
  }
}
