import 'package:flutter/painting.dart';
import 'package:mp_flutter_chart/chart/mp/core/axis/x_axis.dart';
import 'package:mp_flutter_chart/chart/mp/core/enums/limite_label_postion.dart';
import 'package:mp_flutter_chart/chart/mp/core/enums/x_axis_position.dart';
import 'package:mp_flutter_chart/chart/mp/core/limit_line.dart';
import 'package:mp_flutter_chart/chart/mp/core/render/x_axis_renderer.dart';
import 'package:mp_flutter_chart/chart/mp/core/transformer/transformer.dart';
import 'package:mp_flutter_chart/chart/mp/core/utils/color_utils.dart';
import 'package:mp_flutter_chart/chart/mp/core/utils/painter_utils.dart';
import 'package:mp_flutter_chart/chart/mp/core/view_port.dart';
import 'package:mp_flutter_chart/chart/mp/core/poolable/point.dart';
import 'package:mp_flutter_chart/chart/mp/core/poolable/size.dart';
import 'package:mp_flutter_chart/chart/mp/core/utils/utils.dart';

class XAxisRendererHorizontalBarChart extends XAxisRenderer {
  XAxisRendererHorizontalBarChart(
      ViewPortHandler viewPortHandler, XAxis xAxis, Transformer trans)
      : super(viewPortHandler, xAxis, trans);

  @override
  void computeAxis(double min, double max, bool inverted) {
    // calculate the starting and entry point of the y-labels (depending on
    // zoom / contentrect bounds)
    if (mViewPortHandler.contentWidth() > 10 &&
        !mViewPortHandler.isFullyZoomedOutY()) {
      MPPointD p1 = mTrans.getValuesByTouchPoint1(
          mViewPortHandler.contentLeft(), mViewPortHandler.contentBottom());
      MPPointD p2 = mTrans.getValuesByTouchPoint1(
          mViewPortHandler.contentLeft(), mViewPortHandler.contentTop());

      if (inverted) {
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

  @override
  void computeSize() {
    mAxisLabelPaint = PainterUtils.create(
        mAxisLabelPaint,
        null,
        mXAxis.getTypeface()?.color == null
            ? ColorUtils.HOLO_GREEN_DARK
            : mXAxis.getTypeface()?.color,
        mXAxis.getTextSize());

    String longest = mXAxis.getLongestLabel();

    final FSize labelSize = Utils.calcTextSize1(mAxisLabelPaint, longest);

    final double labelWidth =
        (labelSize.width + mXAxis.getXOffset() * 3.5).toInt().toDouble();
    final double labelHeight = labelSize.height;

    final FSize labelRotatedSize = Utils.getSizeOfRotatedRectangleByDegrees(
        labelSize.width, labelHeight, mXAxis.getLabelRotationAngle());

    mXAxis.mLabelWidth = labelWidth.round();
    mXAxis.mLabelHeight = labelHeight.round();
    mXAxis.mLabelRotatedWidth =
        (labelRotatedSize.width + mXAxis.getXOffset() * 3.5).toInt();
    mXAxis.mLabelRotatedHeight = labelRotatedSize.height.round();

    FSize.recycleInstance(labelRotatedSize);
  }

  @override
  void renderAxisLabels(Canvas c) {
    if (!mXAxis.isEnabled() || !mXAxis.isDrawLabelsEnabled()) return;

//    double xoffset = mXAxis.getXOffset();

    mAxisLabelPaint = PainterUtils.create(
        mAxisLabelPaint, null, mXAxis.getTextColor(), mXAxis.getTextSize());

    MPPointF pointF = MPPointF.getInstance1(0, 0);

    if (mXAxis.getPosition() == XAxisPosition.TOP) {
      pointF.x = 0.0;
      pointF.y = 0.5;
      drawLabels(
          c, mViewPortHandler.contentRight(), pointF, mXAxis.getPosition());
    } else if (mXAxis.getPosition() == XAxisPosition.TOP_INSIDE) {
      pointF.x = 1.0;
      pointF.y = 0.5;
      drawLabels(
          c, mViewPortHandler.contentRight(), pointF, mXAxis.getPosition());
    } else if (mXAxis.getPosition() == XAxisPosition.BOTTOM) {
      pointF.x = 1.0;
      pointF.y = 0.5;
      drawLabels(
          c, mViewPortHandler.contentLeft(), pointF, mXAxis.getPosition());
    } else if (mXAxis.getPosition() == XAxisPosition.BOTTOM_INSIDE) {
      pointF.x = 1.0;
      pointF.y = 0.5;
      drawLabels(
          c, mViewPortHandler.contentLeft(), pointF, mXAxis.getPosition());
    } else {
      // BOTH SIDED
      pointF.x = 0.0;
      pointF.y = 0.5;
      drawLabels(
          c, mViewPortHandler.contentRight(), pointF, mXAxis.getPosition());
      pointF.x = 1.0;
      pointF.y = 0.5;
      drawLabels(
          c, mViewPortHandler.contentLeft(), pointF, mXAxis.getPosition());
    }

    MPPointF.recycleInstance(pointF);
  }

  @override
  void drawLabels(
      Canvas c, double pos, MPPointF anchor, XAxisPosition position) {
    final double labelRotationAngleDegrees = mXAxis.getLabelRotationAngle();
    bool centeringEnabled = mXAxis.isCenterAxisLabelsEnabled();

    List<double> positions = List(mXAxis.mEntryCount * 2);

    for (int i = 0; i < positions.length; i += 2) {
      // only fill x values
      if (centeringEnabled) {
        positions[i + 1] = mXAxis.mCenteredEntries[i ~/ 2];
      } else {
        positions[i + 1] = mXAxis.mEntries[i ~/ 2];
      }
    }

    mTrans.pointValuesToPixel(positions);

    for (int i = 0; i < positions.length; i += 2) {
      double y = positions[i + 1];

      if (mViewPortHandler.isInBoundsY(y)) {
        String label = mXAxis
            .getValueFormatter()
            .getAxisLabel(mXAxis.mEntries[i ~/ 2], mXAxis);
        Utils.drawXAxisValueHorizontal(c, label, pos, y, mAxisLabelPaint,
            anchor, labelRotationAngleDegrees, position);
      }
    }
  }

  @override
  Rect getGridClippingRect() {
    mGridClippingRect = Rect.fromLTRB(
        mViewPortHandler.getContentRect().left,
        mViewPortHandler.getContentRect().top,
        mViewPortHandler.getContentRect().right + mAxis.getGridLineWidth(),
        mViewPortHandler.getContentRect().bottom + mAxis.getGridLineWidth());
    return mGridClippingRect;
  }

  @override
  void drawGridLine(Canvas c, double x, double y, Path gridLinePath) {
    gridLinePath.moveTo(mViewPortHandler.contentRight(), y);
    gridLinePath.lineTo(mViewPortHandler.contentLeft(), y);

    // draw a path because lines don't support dashing on lower android versions
    c.drawPath(gridLinePath, mGridPaint);

    gridLinePath.reset();
  }

  @override
  void renderAxisLine(Canvas c) {
    if (!mXAxis.isDrawAxisLineEnabled() || !mXAxis.isEnabled()) return;

    mAxisLinePaint = Paint()
      ..color = mXAxis.getAxisLineColor()
      ..strokeWidth = mXAxis.getAxisLineWidth();

    if (mXAxis.getPosition() == XAxisPosition.TOP ||
        mXAxis.getPosition() == XAxisPosition.TOP_INSIDE ||
        mXAxis.getPosition() == XAxisPosition.BOTH_SIDED) {
      c.drawLine(
          Offset(
              mViewPortHandler.contentRight(), mViewPortHandler.contentTop()),
          Offset(mViewPortHandler.contentRight(),
              mViewPortHandler.contentBottom()),
          mAxisLinePaint);
    }

    if (mXAxis.getPosition() == XAxisPosition.BOTTOM ||
        mXAxis.getPosition() == XAxisPosition.BOTTOM_INSIDE ||
        mXAxis.getPosition() == XAxisPosition.BOTH_SIDED) {
      c.drawLine(
          Offset(mViewPortHandler.contentLeft(), mViewPortHandler.contentTop()),
          Offset(
              mViewPortHandler.contentLeft(), mViewPortHandler.contentBottom()),
          mAxisLinePaint);
    }
  }

  Path mRenderLimitLinesPathBuffer = Path();

  /// Draws the LimitLines associated with this axis to the screen.
  /// This is the standard YAxis renderer using the XAxis limit lines.
  ///
  /// @param c
  @override
  void renderLimitLines(Canvas c) {
    List<LimitLine> limitLines = mXAxis.getLimitLines();

    if (limitLines == null || limitLines.length <= 0) return;

    List<double> pts = mRenderLimitLinesBuffer;
    pts[0] = 0;
    pts[1] = 0;

    Path limitLinePath = mRenderLimitLinesPathBuffer;
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
        ..color = l.getLineColor()
        ..strokeWidth = l.getLineWidth();
//      mLimitLinePaint.setPathEffect(l.getDashPathEffect());

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
        final double labelLineHeight =
            Utils.calcTextHeight(mAxisLabelPaint, label).toDouble();
        double xOffset = Utils.convertDpToPixel(4) + l.getXOffset();
        double yOffset = l.getLineWidth() + labelLineHeight + l.getYOffset();

        final LimitLabelPosition position = l.getLabelPosition();

        if (position == LimitLabelPosition.RIGHT_TOP) {
          mAxisLabelPaint = PainterUtils.create(
              mAxisLabelPaint, label, l.getTextColor(), l.getTextSize());
          mAxisLabelPaint.layout();
          mAxisLabelPaint.paint(
              c,
              Offset(mViewPortHandler.contentRight() - xOffset,
                  pts[1] - yOffset + labelLineHeight));
        } else if (position == LimitLabelPosition.RIGHT_BOTTOM) {
          mAxisLabelPaint = PainterUtils.create(
              mAxisLabelPaint, label, l.getTextColor(), l.getTextSize());
          mAxisLabelPaint.layout();
          mAxisLabelPaint.paint(
              c,
              Offset(
                  mViewPortHandler.contentRight() - xOffset, pts[1] + yOffset));
        } else if (position == LimitLabelPosition.LEFT_TOP) {
          mAxisLabelPaint = PainterUtils.create(
              mAxisLabelPaint, label, l.getTextColor(), l.getTextSize());
          mAxisLabelPaint.layout();
          mAxisLabelPaint.paint(
              c,
              Offset(mViewPortHandler.contentLeft() + xOffset,
                  pts[1] - yOffset + labelLineHeight));
        } else {
          mAxisLabelPaint = PainterUtils.create(
              mAxisLabelPaint, label, l.getTextColor(), l.getTextSize());
          mAxisLabelPaint.layout();
          mAxisLabelPaint.paint(
              c,
              Offset(
                  mViewPortHandler.offsetLeft() + xOffset, pts[1] + yOffset));
        }
      }

      c.restore();
    }
  }
}
