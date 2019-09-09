import 'package:flutter/painting.dart';
import 'package:mp_flutter_chart/chart/mp/core/axis/x_axis.dart';
import 'package:mp_flutter_chart/chart/mp/core/enums/limite_label_postion.dart';
import 'package:mp_flutter_chart/chart/mp/core/enums/x_axis_position.dart';
import 'package:mp_flutter_chart/chart/mp/core/limit_line.dart';
import 'package:mp_flutter_chart/chart/mp/core/render/axis_renderer.dart';
import 'package:mp_flutter_chart/chart/mp/core/transformer/transformer.dart';
import 'package:mp_flutter_chart/chart/mp/core/utils/color_utils.dart';
import 'package:mp_flutter_chart/chart/mp/core/view_port.dart';
import 'package:mp_flutter_chart/chart/mp/core/poolable/point.dart';
import 'package:mp_flutter_chart/chart/mp/core/poolable/size.dart';
import 'package:mp_flutter_chart/chart/mp/core/utils/utils.dart';

class XAxisRenderer extends AxisRenderer {
  XAxis mXAxis;

  XAxisRenderer(ViewPortHandler viewPortHandler, XAxis xAxis, Transformer trans)
      : super(viewPortHandler, trans, xAxis) {
    this.mXAxis = xAxis;

    mAxisLabelPaint = TextPainter(
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
        text: TextSpan(
            style: TextStyle(
                color: ColorUtils.BLACK,
                fontSize: Utils.convertDpToPixel(10))));
  }

  void setupGridPaint() {
    mGridPaint = Paint()
      ..color = mXAxis.getGridColor()
      ..style = PaintingStyle.stroke
      ..strokeWidth = mXAxis.getGridLineWidth();
  }

  @override
  void computeAxis(double min, double max, bool inverted) {
    // calculate the starting and entry point of the y-labels (depending on
    // zoom / contentrect bounds)
    if (mViewPortHandler.contentWidth() > 10 &&
        !mViewPortHandler.isFullyZoomedOutX()) {
      MPPointD p1 = mTrans.getValuesByTouchPoint1(
          mViewPortHandler.contentLeft(), mViewPortHandler.contentTop());
      MPPointD p2 = mTrans.getValuesByTouchPoint1(
          mViewPortHandler.contentRight(), mViewPortHandler.contentTop());

      if (inverted) {
        min = p2.x;
        max = p1.x;
      } else {
        min = p1.x;
        max = p2.x;
      }

      MPPointD.recycleInstance2(p1);
      MPPointD.recycleInstance2(p2);
    }

    computeAxisValues(min, max);
  }

  @override
  void computeAxisValues(double min, double max) {
    super.computeAxisValues(min, max);
    computeSize();
  }

  void computeSize() {
    String longest = mXAxis.getLongestLabel();

    mAxisLabelPaint = TextPainter(
        textDirection: mAxisLabelPaint.textDirection,
        textAlign: mAxisLabelPaint.textAlign,
        text: TextSpan(
            style: TextStyle(
                fontSize: mXAxis.getTextSize(),
                color: mAxisLabelPaint.text.style.color)));

    final FSize labelSize = Utils.calcTextSize1(mAxisLabelPaint, longest);

    final double labelWidth = labelSize.width;
    final double labelHeight =
        Utils.calcTextHeight(mAxisLabelPaint, "Q").toDouble();

    final FSize labelRotatedSize = Utils.getSizeOfRotatedRectangleByDegrees(
        labelWidth, labelHeight, mXAxis.getLabelRotationAngle());

    mXAxis.mLabelWidth = labelWidth.round();
    mXAxis.mLabelHeight = labelHeight.round();
    mXAxis.mLabelRotatedWidth = labelRotatedSize.width.round();
    mXAxis.mLabelRotatedHeight = labelRotatedSize.height.round();

    FSize.recycleInstance(labelRotatedSize);
    FSize.recycleInstance(labelSize);
  }

  @override
  void renderAxisLabels(Canvas c) {
    if (!mXAxis.isEnabled() || !mXAxis.isDrawLabelsEnabled()) return;

    mAxisLabelPaint.text = TextSpan(
        style: TextStyle(
            fontSize: mXAxis.getTextSize(), color: mXAxis.getTextColor()));

    MPPointF pointF = MPPointF.getInstance1(0, 0);
    if (mXAxis.getPosition() == XAxisPosition.TOP) {
      pointF.x = 0.5;
      pointF.y = 1.0;
      drawLabels(
          c, mViewPortHandler.contentTop(), pointF, mXAxis.getPosition());
    } else if (mXAxis.getPosition() == XAxisPosition.TOP_INSIDE) {
      pointF.x = 0.5;
      pointF.y = 1.0;
      drawLabels(c, mViewPortHandler.contentTop() + mXAxis.mLabelRotatedHeight,
          pointF, mXAxis.getPosition());
    } else if (mXAxis.getPosition() == XAxisPosition.BOTTOM) {
      pointF.x = 0.5;
      pointF.y = 0.0;
      drawLabels(
          c, mViewPortHandler.contentBottom(), pointF, mXAxis.getPosition());
    } else if (mXAxis.getPosition() == XAxisPosition.BOTTOM_INSIDE) {
      pointF.x = 0.5;
      pointF.y = 0.0;
      drawLabels(
          c,
          mViewPortHandler.contentBottom() - mXAxis.mLabelRotatedHeight,
          pointF,
          mXAxis.getPosition());
    } else {
      // BOTH SIDED
      pointF.x = 0.5;
      pointF.y = 1.0;
      drawLabels(c, mViewPortHandler.contentTop(), pointF, XAxisPosition.TOP);
      pointF.x = 0.5;
      pointF.y = 0.0;
      drawLabels(
          c, mViewPortHandler.contentBottom(), pointF, XAxisPosition.BOTTOM);
    }
    MPPointF.recycleInstance(pointF);
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
          Offset(mViewPortHandler.contentLeft(), mViewPortHandler.contentTop()),
          Offset(
              mViewPortHandler.contentRight(), mViewPortHandler.contentTop()),
          mAxisLinePaint);
    }

    if (mXAxis.getPosition() == XAxisPosition.BOTTOM ||
        mXAxis.getPosition() == XAxisPosition.BOTTOM_INSIDE ||
        mXAxis.getPosition() == XAxisPosition.BOTH_SIDED) {
      c.drawLine(
          Offset(
              mViewPortHandler.contentLeft(), mViewPortHandler.contentBottom()),
          Offset(mViewPortHandler.contentRight(),
              mViewPortHandler.contentBottom()),
          mAxisLinePaint);
    }
  }

  /**
   * draws the x-labels on the specified y-position
   *
   * @param pos
   */
  void drawLabels(
      Canvas c, double pos, MPPointF anchor, XAxisPosition position) {
    final double labelRotationAngleDegrees = mXAxis.getLabelRotationAngle();
    bool centeringEnabled = mXAxis.isCenterAxisLabelsEnabled();

    List<double> positions = List(mXAxis.mEntryCount * 2);

    for (int i = 0; i < positions.length; i += 2) {
      // only fill x values
      if (centeringEnabled) {
        positions[i] = mXAxis.mCenteredEntries[i ~/ 2];
      } else {
        positions[i] = mXAxis.mEntries[i ~/ 2];
      }
      positions[i + 1] = 0;
    }

    mTrans.pointValuesToPixel(positions);

    for (int i = 0; i < positions.length; i += 2) {
      double x = positions[i];

      if (mViewPortHandler.isInBoundsX(x)) {
        String label = mXAxis
            .getValueFormatter()
            .getAxisLabel(mXAxis.mEntries[i ~/ 2], mXAxis);

        if (mXAxis.isAvoidFirstLastClippingEnabled()) {
          // avoid clipping of the last
          if (i / 2 == mXAxis.mEntryCount - 1 && mXAxis.mEntryCount > 1) {
            double width =
                Utils.calcTextWidth(mAxisLabelPaint, label).toDouble();

            if (width > mViewPortHandler.offsetRight() * 2 &&
                x + width > mViewPortHandler.getChartWidth()) x -= width / 2;

            // avoid clipping of the first
          } else if (i == 0) {
            double width =
                Utils.calcTextWidth(mAxisLabelPaint, label).toDouble();
            x += width / 2;
          }
        }

        drawLabel(
            c, label, x, pos, anchor, labelRotationAngleDegrees, position);
      }
    }
  }

  void drawLabel(Canvas c, String formattedLabel, double x, double y,
      MPPointF anchor, double angleDegrees, XAxisPosition position) {
    Utils.drawXAxisValue(c, formattedLabel, x, y, mAxisLabelPaint, anchor,
        angleDegrees, position);
  }

  Path mRenderGridLinesPath = Path();
  List<double> mRenderGridLinesBuffer = List(2);

  @override
  void renderGridLines(Canvas c) {
    if (!mXAxis.isDrawGridLinesEnabled() || !mXAxis.isEnabled()) return;

    c.save();
    c.clipRect(getGridClippingRect());

    if (mRenderGridLinesBuffer.length != mAxis.mEntryCount * 2) {
      mRenderGridLinesBuffer = List(mXAxis.mEntryCount * 2);
    }
    List<double> positions = mRenderGridLinesBuffer;

    for (int i = 0; i < positions.length; i += 2) {
      positions[i] = mXAxis.mEntries[i ~/ 2];
      positions[i + 1] = mXAxis.mEntries[i ~/ 2];
    }
    mTrans.pointValuesToPixel(positions);

    setupGridPaint();

    Path gridLinePath = mRenderGridLinesPath;
    gridLinePath.reset();

    for (int i = 0; i < positions.length; i += 2) {
      drawGridLine(c, positions[i], positions[i + 1], gridLinePath);
    }

    c.restore();
  }

  Rect mGridClippingRect = Rect.zero;

  Rect getGridClippingRect() {
    mGridClippingRect = Rect.fromLTRB(
        mViewPortHandler.getContentRect().left - mAxis.getGridLineWidth(),
        mViewPortHandler.getContentRect().top - mAxis.getGridLineWidth(),
        mViewPortHandler.getContentRect().right,
        mViewPortHandler.getContentRect().bottom);
    return mGridClippingRect;
  }

  /**
   * Draws the grid line at the specified position using the provided path.
   *
   * @param c
   * @param x
   * @param y
   * @param gridLinePath
   */
  void drawGridLine(Canvas c, double x, double y, Path path) {
    path.moveTo(x, mViewPortHandler.contentBottom());
    path.lineTo(x, mViewPortHandler.contentTop());

    // draw a path because lines don't support dashing on lower android versions
    c.drawPath(path, mGridPaint);

    path.reset();
  }

  List<double> mRenderLimitLinesBuffer = List(2);
  Rect mLimitLineClippingRect = Rect.zero;

  /**
   * Draws the LimitLines associated with this axis to the screen.
   *
   * @param c
   */
  @override
  void renderLimitLines(Canvas c) {
    List<LimitLine> limitLines = mXAxis.getLimitLines();

    if (limitLines == null || limitLines.length <= 0) return;

    List<double> position = mRenderLimitLinesBuffer;
    position[0] = 0;
    position[1] = 0;

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

      position[0] = l.getLimit();
      position[1] = 0;

      mTrans.pointValuesToPixel(position);

      renderLimitLineLine(c, l, position);
      renderLimitLineLabel(c, l, position, 2.0 + l.getYOffset());

      c.restore();
    }
  }

  List<double> mLimitLineSegmentsBuffer = List(4);
  Path mLimitLinePath = Path();

  void renderLimitLineLine(
      Canvas c, LimitLine limitLine, List<double> position) {
    mLimitLineSegmentsBuffer[0] = position[0];
    mLimitLineSegmentsBuffer[1] = mViewPortHandler.contentTop();
    mLimitLineSegmentsBuffer[2] = position[0];
    mLimitLineSegmentsBuffer[3] = mViewPortHandler.contentBottom();

    mLimitLinePath.reset();
    mLimitLinePath.moveTo(
        mLimitLineSegmentsBuffer[0], mLimitLineSegmentsBuffer[1]);
    mLimitLinePath.lineTo(
        mLimitLineSegmentsBuffer[2], mLimitLineSegmentsBuffer[3]);

    mLimitLinePaint
      ..style = PaintingStyle.stroke
      ..color = limitLine.getLineColor()
      ..strokeWidth = limitLine.getLineWidth();

    c.drawPath(mLimitLinePath, mLimitLinePaint);
  }

  void renderLimitLineLabel(
      Canvas c, LimitLine limitLine, List<double> position, double yOffset) {
    String label = limitLine.getLabel();

    // if drawing the limit-value label is enabled
    if (label != null && label.isNotEmpty) {
      var painter = TextPainter(
          textDirection: TextDirection.ltr,
          text: TextSpan(
              text: label,
              style: TextStyle(
                  color: limitLine.getTextColor(),
                  fontSize: limitLine.getTextSize())));

      double xOffset = limitLine.getLineWidth() + limitLine.getXOffset();

      final LimitLabelPosition labelPosition = limitLine.getLabelPosition();

      if (labelPosition == LimitLabelPosition.RIGHT_TOP) {
        final double labelLineHeight =
            Utils.calcTextHeight(painter, label).toDouble();
        painter.textAlign = TextAlign.left;
        painter.layout();
        painter.paint(
            c,
            Offset(position[0] + xOffset,
                mViewPortHandler.contentTop() + yOffset + labelLineHeight));
      } else if (labelPosition == LimitLabelPosition.RIGHT_BOTTOM) {
        painter.textAlign = TextAlign.left;
        painter.layout();
        painter.paint(
            c,
            Offset(position[0] + xOffset,
                mViewPortHandler.contentBottom() - yOffset));
      } else if (labelPosition == LimitLabelPosition.LEFT_TOP) {
        painter.textAlign = TextAlign.right;
        final double labelLineHeight =
            Utils.calcTextHeight(painter, label).toDouble();
        painter.layout();
        painter.paint(
            c,
            Offset(position[0] - xOffset,
                mViewPortHandler.contentTop() + yOffset + labelLineHeight));
      } else {
        painter.textAlign = TextAlign.right;
        painter.layout();
        painter.paint(
            c,
            Offset(position[0] - xOffset,
                mViewPortHandler.contentBottom() - yOffset));
      }
    }
  }
}
