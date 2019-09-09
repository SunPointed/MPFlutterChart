import 'dart:math';
import 'dart:ui';

import 'package:flutter/painting.dart';
import 'package:mp_flutter_chart/chart/mp/core/animator.dart';
import 'package:mp_flutter_chart/chart/mp/core/data/pie_data.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_interfaces/i_pie_data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/entry/entry.dart';
import 'package:mp_flutter_chart/chart/mp/core/entry/pie_entry.dart';
import 'package:mp_flutter_chart/chart/mp/core/enums/value_position.dart';
import 'package:mp_flutter_chart/chart/mp/core/highlight/highlight.dart';
import 'package:mp_flutter_chart/chart/mp/core/render/data_renderer.dart';
import 'package:mp_flutter_chart/chart/mp/core/utils/color_utils.dart';
import 'package:mp_flutter_chart/chart/mp/core/utils/painter_utils.dart';
import 'package:mp_flutter_chart/chart/mp/core/value_formatter/value_formatter.dart';
import 'package:mp_flutter_chart/chart/mp/core/view_port.dart';
import 'package:mp_flutter_chart/chart/mp/painter/pie_chart_painter.dart';
import 'package:mp_flutter_chart/chart/mp/core/poolable/point.dart';
import 'package:mp_flutter_chart/chart/mp/core/utils/utils.dart';

class PieChartRenderer extends DataRenderer {
  PieChartPainter mChart;

  /**
   * paint for the hole in the center of the pie chart and the transparent
   * circle
   */
  Paint mHolePaint;
  Paint mTransparentCirclePaint;
  Paint mValueLinePaint;

  /**
   * paint object for the text that can be displayed in the center of the
   * chart
   */
  TextPainter mCenterTextPaint;

  /**
   * paint object used for drwing the slice-text
   */
  TextPainter mEntryLabelsPaint;

//   StaticLayout mCenterTextLayout;
  String mCenterTextLastValue;
  Rect mCenterTextLastBounds = Rect.zero;
  List<Rect> mRectBuffer = List()
    ..add(Rect.zero)
    ..add(Rect.zero)
    ..add(Rect.zero);

  /**
   * Bitmap for drawing the center hole
   */
//   WeakReference<Bitmap> mDrawBitmap;

//   Canvas mBitmapCanvas;

  PieChartRenderer(PieChartPainter chart, ChartAnimator animator,
      ViewPortHandler viewPortHandler)
      : super(animator, viewPortHandler) {
    mChart = chart;

    mHolePaint = Paint()
      ..isAntiAlias = true
      ..color = ColorUtils.WHITE
      ..style = PaintingStyle.fill;

    mTransparentCirclePaint = Paint()
      ..isAntiAlias = true
      ..color = Color.fromARGB(105, ColorUtils.WHITE.red,
          ColorUtils.WHITE.green, ColorUtils.WHITE.blue)
      ..style = PaintingStyle.fill;

    mCenterTextPaint = PainterUtils.create(
        null, null, ColorUtils.BLACK, Utils.convertDpToPixel(12));

    mValuePaint = PainterUtils.create(
        null, null, ColorUtils.WHITE, Utils.convertDpToPixel(9));

    mEntryLabelsPaint = PainterUtils.create(
        null, null, ColorUtils.WHITE, Utils.convertDpToPixel(10));

    mValueLinePaint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke;
  }

  Paint getPaintHole() {
    return mHolePaint;
  }

  Paint getPaintTransparentCircle() {
    return mTransparentCirclePaint;
  }

  TextPainter getPaintCenterText() {
    return mCenterTextPaint;
  }

  TextPainter getPaintEntryLabels() {
    return mEntryLabelsPaint;
  }

  @override
  void initBuffers() {
    // TODO Auto-generated method stub
  }

  @override
  void drawData(Canvas c) {
//    int width = mViewPortHandler.getChartWidth().toInt();
//    int height = mViewPortHandler.getChartHeight().toInt();

//    Bitmap drawBitmap = mDrawBitmap == null ? null : mDrawBitmap.get();

//    if (drawBitmap == null
//        || (drawBitmap.getWidth() != width)
//        || (drawBitmap.getHeight() != height)) {
//
//      if (width > 0 && height > 0) {
//        drawBitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_4444);
//        mDrawBitmap =  WeakReference<>(drawBitmap);
//        mBitmapCanvas =  Canvas(drawBitmap);
//      } else
//        return;
//    }
//
//    drawBitmap.eraseColor(Color.TRANSPARENT);

    PieData pieData = mChart.mData;

    for (IPieDataSet set in pieData.getDataSets()) {
      if (set.isVisible() && set.getEntryCount() > 0) drawDataSet(c, set);
    }
  }

  Path mPathBuffer = Path();
  Rect mInnerRectBuffer = Rect.zero;

  double calculateMinimumRadiusForSpacedSlice(
      MPPointF center,
      double radius,
      double angle,
      double arcStartPointX,
      double arcStartPointY,
      double startAngle,
      double sweepAngle) {
    final double angleMiddle = startAngle + sweepAngle / 2.0;

    // Other point of the arc
    double arcEndPointX =
        center.x + radius * cos((startAngle + sweepAngle) * Utils.FDEG2RAD);
    double arcEndPointY =
        center.y + radius * sin((startAngle + sweepAngle) * Utils.FDEG2RAD);

    // Middle point on the arc
    double arcMidPointX = center.x + radius * cos(angleMiddle * Utils.FDEG2RAD);
    double arcMidPointY = center.y + radius * sin(angleMiddle * Utils.FDEG2RAD);

    // This is the base of the contained triangle
    double basePointsDistance = sqrt(pow(arcEndPointX - arcStartPointX, 2) +
        pow(arcEndPointY - arcStartPointY, 2));

    // After reducing space from both sides of the "slice",
    //   the angle of the contained triangle should stay the same.
    // So let's find out the height of that triangle.
    double containedTriangleHeight =
        (basePointsDistance / 2.0 * tan((180.0 - angle) / 2.0 * Utils.DEG2RAD));

    // Now we subtract that from the radius
    double spacedRadius = radius - containedTriangleHeight;

    // And now subtract the height of the arc that's between the triangle and the outer circle
    spacedRadius -= sqrt(
        pow(arcMidPointX - (arcEndPointX + arcStartPointX) / 2.0, 2) +
            pow(arcMidPointY - (arcEndPointY + arcStartPointY) / 2.0, 2));

    return spacedRadius;
  }

  /**
   * Calculates the sliceSpace to use based on visible values and their size compared to the set sliceSpace.
   *
   * @param dataSet
   * @return
   */
  double getSliceSpace(IPieDataSet dataSet) {
    if (!dataSet.isAutomaticallyDisableSliceSpacingEnabled())
      return dataSet.getSliceSpace();

    double spaceSizeRatio = dataSet.getSliceSpace() /
        mViewPortHandler.getSmallestContentExtension();
    double minValueRatio =
        dataSet.getYMin() / mChart.getData().getYValueSum() * 2;

    double sliceSpace =
        spaceSizeRatio > minValueRatio ? 0 : dataSet.getSliceSpace();

    return sliceSpace;
  }

  void drawDataSet(Canvas c, IPieDataSet dataSet) {
    double angle = 0;
    double rotationAngle = mChart.getRotationAngle();

    double phaseX = mAnimator.getPhaseX();
    double phaseY = mAnimator.getPhaseY();

    final Rect circleBox = mChart.getCircleBox();

    int entryCount = dataSet.getEntryCount();
    final List<double> drawAngles = mChart.getDrawAngles();
    final MPPointF center = mChart.getCenterCircleBox();
    final double radius = mChart.getRadius();
    bool drawInnerArc =
        mChart.isDrawHoleEnabled() && !mChart.isDrawSlicesUnderHoleEnabled();
    final double userInnerRadius =
        drawInnerArc ? radius * (mChart.getHoleRadius() / 100.0) : 0.0;
    final double roundedRadius =
        (radius - (radius * mChart.getHoleRadius() / 100)) / 2;
    Rect roundedCircleBox = Rect.zero;
    final bool drawRoundedSlices =
        drawInnerArc && mChart.isDrawRoundedSlicesEnabled();

    int visibleAngleCount = 0;
    for (int j = 0; j < entryCount; j++) {
      // draw only if the value is greater than zero
      if ((dataSet.getEntryForIndex(j).getValue().abs() >
          Utils.FLOAT_EPSILON)) {
        visibleAngleCount++;
      }
    }

    final double sliceSpace =
        visibleAngleCount <= 1 ? 0.0 : getSliceSpace(dataSet);

    for (int j = 0; j < entryCount; j++) {
      double sliceAngle = drawAngles[j];
      double innerRadius = userInnerRadius;

      Entry e = dataSet.getEntryForIndex(j);

      // draw only if the value is greater than zero
      if (!(e.y.abs() > Utils.FLOAT_EPSILON)) {
        angle += sliceAngle * phaseX;
        continue;
      }

      // Don't draw if it's highlighted, unless the chart uses rounded slices
      if (mChart.needsHighlight(j) && !drawRoundedSlices) {
        angle += sliceAngle * phaseX;
        continue;
      }

      final bool accountForSliceSpacing =
          sliceSpace > 0.0 && sliceAngle <= 180.0;

      mRenderPaint..color = dataSet.getColor2(j);

      final double sliceSpaceAngleOuter =
          visibleAngleCount == 1 ? 0.0 : sliceSpace / (Utils.FDEG2RAD * radius);
      final double startAngleOuter =
          rotationAngle + (angle + sliceSpaceAngleOuter / 2.0) * phaseY;
      double sweepAngleOuter = (sliceAngle - sliceSpaceAngleOuter) * phaseY;
      if (sweepAngleOuter < 0.0) {
        sweepAngleOuter = 0.0;
      }

      mPathBuffer.reset();

      if (drawRoundedSlices) {
        double x = center.x +
            (radius - roundedRadius) * cos(startAngleOuter * Utils.FDEG2RAD);
        double y = center.y +
            (radius - roundedRadius) * sin(startAngleOuter * Utils.FDEG2RAD);
        roundedCircleBox = Rect.fromLTRB(x - roundedRadius, y - roundedRadius,
            x + roundedRadius, y + roundedRadius);
      }

      double arcStartPointX =
          center.x + radius * cos(startAngleOuter * Utils.FDEG2RAD);
      double arcStartPointY =
          center.y + radius * sin(startAngleOuter * Utils.FDEG2RAD);

      if (sweepAngleOuter >= 360.0 &&
          sweepAngleOuter % 360 <= Utils.FLOAT_EPSILON) {
        // Android is doing "mod 360"
        mPathBuffer.addOval(Rect.fromLTRB(center.x - radius, center.y - radius,
            center.x + radius, center.y + radius));
      } else {
        if (drawRoundedSlices) {
          mPathBuffer.addArc(roundedCircleBox,
              (startAngleOuter + 180) * Utils.FDEG2RAD, -180 * Utils.FDEG2RAD);
        }

        mPathBuffer.addArc(circleBox, startAngleOuter * Utils.FDEG2RAD,
            sweepAngleOuter * Utils.FDEG2RAD);
      }

      // API < 21 does not receive doubles in addArc, but a RectF
      mInnerRectBuffer = Rect.fromLTRB(
          center.x - innerRadius,
          center.y - innerRadius,
          center.x + innerRadius,
          center.y + innerRadius);

      if (drawInnerArc && (innerRadius > 0.0 || accountForSliceSpacing)) {
        if (accountForSliceSpacing) {
          double minSpacedRadius = calculateMinimumRadiusForSpacedSlice(
              center,
              radius,
              sliceAngle * phaseY,
              arcStartPointX,
              arcStartPointY,
              startAngleOuter,
              sweepAngleOuter);

          if (minSpacedRadius < 0.0) minSpacedRadius = -minSpacedRadius;

          innerRadius = max(innerRadius, minSpacedRadius);
        }

        final double sliceSpaceAngleInner =
            visibleAngleCount == 1 || innerRadius == 0.0
                ? 0.0
                : sliceSpace / (Utils.FDEG2RAD * innerRadius);
        final double startAngleInner =
            rotationAngle + (angle + sliceSpaceAngleInner / 2.0) * phaseY;
        double sweepAngleInner = (sliceAngle - sliceSpaceAngleInner) * phaseY;
        if (sweepAngleInner < 0.0) {
          sweepAngleInner = 0.0;
        }
        final double endAngleInner = startAngleInner + sweepAngleInner;

        if (sweepAngleOuter >= 360.0 &&
            sweepAngleOuter % 360 <= Utils.FLOAT_EPSILON) {
          // Android is doing "mod 360"
          mPathBuffer.addOval(Rect.fromLTRB(
              center.x - innerRadius,
              center.y - innerRadius,
              center.x + innerRadius,
              center.y + innerRadius));
        } else {
          if (drawRoundedSlices) {
            double x = center.x +
                (radius - roundedRadius) * cos(endAngleInner * Utils.FDEG2RAD);
            double y = center.y +
                (radius - roundedRadius) * sin(endAngleInner * Utils.FDEG2RAD);
            roundedCircleBox = Rect.fromLTRB(x - roundedRadius,
                y - roundedRadius, x + roundedRadius, y + roundedRadius);
            mPathBuffer.addArc(roundedCircleBox, endAngleInner * Utils.FDEG2RAD,
                180 * Utils.FDEG2RAD);
          } else {
//            mPathBuffer.lineTo(
//                center.x + innerRadius * cos(endAngleInner * Utils.FDEG2RAD),
//                center.y + innerRadius * sin(endAngleInner * Utils.FDEG2RAD));
            double angleMiddle = startAngleOuter + sweepAngleOuter / 2.0;
            double sliceSpaceOffset = calculateMinimumRadiusForSpacedSlice(
                center,
                radius,
                sliceAngle * phaseY,
                arcStartPointX,
                arcStartPointY,
                startAngleOuter,
                sweepAngleOuter);
            mPathBuffer.lineTo(
                center.x + sliceSpaceOffset * cos(angleMiddle * Utils.FDEG2RAD),
                center.y +
                    sliceSpaceOffset * sin(angleMiddle * Utils.FDEG2RAD));
          }

          mPathBuffer.addArc(mInnerRectBuffer, endAngleInner * Utils.FDEG2RAD,
              -sweepAngleInner * Utils.FDEG2RAD);
        }
      } else {
        if (sweepAngleOuter % 360 > Utils.FLOAT_EPSILON) {
          if (accountForSliceSpacing) {
            double angleMiddle = startAngleOuter + sweepAngleOuter / 2.0;

            double sliceSpaceOffset = calculateMinimumRadiusForSpacedSlice(
                center,
                radius,
                sliceAngle * phaseY,
                arcStartPointX,
                arcStartPointY,
                startAngleOuter,
                sweepAngleOuter);

            double arcEndPointX =
                center.x + sliceSpaceOffset * cos(angleMiddle * Utils.FDEG2RAD);
            double arcEndPointY =
                center.y + sliceSpaceOffset * sin(angleMiddle * Utils.FDEG2RAD);

            mPathBuffer.lineTo(arcEndPointX, arcEndPointY);
          } else {
            mPathBuffer.lineTo(center.x, center.y);
          }
        }
      }

      mPathBuffer.close();

      c.drawPath(mPathBuffer, mRenderPaint);

      angle += sliceAngle * phaseX;
    }

    mRenderPaint..color = ColorUtils.WHITE;
    c.drawCircle(
        Offset(center.x, center.y), mInnerRectBuffer.width / 2, mRenderPaint);

    MPPointF.recycleInstance(center);
  }

  @override
  void drawValues(Canvas c) {
    MPPointF center = mChart.getCenterCircleBox();

    // get whole the radius
    double radius = mChart.getRadius();
    double rotationAngle = mChart.getRotationAngle();
    List<double> drawAngles = mChart.getDrawAngles();
    List<double> absoluteAngles = mChart.getAbsoluteAngles();

    double phaseX = mAnimator.getPhaseX();
    double phaseY = mAnimator.getPhaseY();

    final double roundedRadius =
        (radius - (radius * mChart.getHoleRadius() / 100)) / 2;
    final double holeRadiusPercent = mChart.getHoleRadius() / 100.0;
    double labelRadiusOffset = radius / 10 * 3.6;

    if (mChart.isDrawHoleEnabled()) {
      labelRadiusOffset = (radius - (radius * holeRadiusPercent)) / 2;

      if (!mChart.isDrawSlicesUnderHoleEnabled() &&
          mChart.isDrawRoundedSlicesEnabled()) {
        // Add curved circle slice and spacing to rotation angle, so that it sits nicely inside
        rotationAngle += roundedRadius * 360 / (pi * 2 * radius);
      }
    }

    final double labelRadius = radius - labelRadiusOffset;

    PieData data = mChart.getData();
    List<IPieDataSet> dataSets = data.getDataSets();

    double yValueSum = data.getYValueSum();

    bool drawEntryLabels = mChart.isDrawEntryLabelsEnabled();

    double angle;
    int xIndex = 0;

    c.save();

    double offset = Utils.convertDpToPixel(5.0);

    for (int i = 0; i < dataSets.length; i++) {
      IPieDataSet dataSet = dataSets[i];

      final bool drawValues = dataSet.isDrawValuesEnabled();

      if (!drawValues && !drawEntryLabels) continue;

      final ValuePosition xValuePosition = dataSet.getXValuePosition();
      final ValuePosition yValuePosition = dataSet.getYValuePosition();

      // apply the text-styling defined by the DataSet
      applyValueTextStyle(dataSet);

      double lineHeight =
          Utils.calcTextHeight(mValuePaint, "Q") + Utils.convertDpToPixel(4);

      ValueFormatter formatter = dataSet.getValueFormatter();

      int entryCount = dataSet.getEntryCount();

      mValueLinePaint
        ..color = dataSet.getValueLineColor()
        ..strokeWidth = Utils.convertDpToPixel(dataSet.getValueLineWidth());

      final double sliceSpace = getSliceSpace(dataSet);

      MPPointF iconsOffset = MPPointF.getInstance3(dataSet.getIconsOffset());
      iconsOffset.x = Utils.convertDpToPixel(iconsOffset.x);
      iconsOffset.y = Utils.convertDpToPixel(iconsOffset.y);

      for (int j = 0; j < entryCount; j++) {
        PieEntry entry = dataSet.getEntryForIndex(j);

        if (xIndex == 0)
          angle = 0.0;
        else
          angle = absoluteAngles[xIndex - 1] * phaseX;

        final double sliceAngle = drawAngles[xIndex];
        final double sliceSpaceMiddleAngle =
            sliceSpace / (Utils.FDEG2RAD * labelRadius);

        // offset needed to center the drawn text in the slice
        final double angleOffset =
            (sliceAngle - sliceSpaceMiddleAngle / 2.0) / 2.0;

        angle = angle + angleOffset;

        final double transformedAngle = rotationAngle + angle * phaseY;

        double value = mChart.isUsePercentValuesEnabled()
            ? entry.y / yValueSum * 100
            : entry.y;
        String formattedValue = formatter.getPieLabel(value, entry);
        String entryLabel = entry.label;

        final double sliceXBase = cos(transformedAngle * Utils.FDEG2RAD);
        final double sliceYBase = sin(transformedAngle * Utils.FDEG2RAD);

        final bool drawXOutside =
            drawEntryLabels && xValuePosition == ValuePosition.OUTSIDE_SLICE;
        final bool drawYOutside =
            drawValues && yValuePosition == ValuePosition.OUTSIDE_SLICE;
        final bool drawXInside =
            drawEntryLabels && xValuePosition == ValuePosition.INSIDE_SLICE;
        final bool drawYInside =
            drawValues && yValuePosition == ValuePosition.INSIDE_SLICE;

        if (drawXOutside || drawYOutside) {
          final double valueLineLength1 = dataSet.getValueLinePart1Length();
          final double valueLineLength2 = dataSet.getValueLinePart2Length();
          final double valueLinePart1OffsetPercentage =
              dataSet.getValueLinePart1OffsetPercentage() / 100.0;

          double pt2x, pt2y;
          double labelPtx, labelPty;

          double line1Radius;

          if (mChart.isDrawHoleEnabled())
            line1Radius = (radius - (radius * holeRadiusPercent)) *
                    valueLinePart1OffsetPercentage +
                (radius * holeRadiusPercent);
          else
            line1Radius = radius * valueLinePart1OffsetPercentage;

          final double polyline2Width = dataSet.isValueLineVariableLength()
              ? labelRadius *
                  valueLineLength2 *
                  sin(transformedAngle * Utils.FDEG2RAD).abs()
              : labelRadius * valueLineLength2;

          final double pt0x = line1Radius * sliceXBase + center.x;
          final double pt0y = line1Radius * sliceYBase + center.y;

          final double pt1x =
              labelRadius * (1 + valueLineLength1) * sliceXBase + center.x;
          final double pt1y =
              labelRadius * (1 + valueLineLength1) * sliceYBase + center.y;

          if (transformedAngle % 360.0 >= 90.0 &&
              transformedAngle % 360.0 <= 270.0) {
            pt2x = pt1x - polyline2Width;
            pt2y = pt1y;

            labelPtx = pt2x - offset;
            labelPty = pt2y;
          } else {
            pt2x = pt1x + polyline2Width;
            pt2y = pt1y;

            labelPtx = pt2x + offset;
            labelPty = pt2y;
          }

          if (dataSet.getValueLineColor() != ColorUtils.COLOR_NONE) {
            if (dataSet.isUsingSliceColorAsValueLineColor()) {
              mValueLinePaint..color = dataSet.getColor2(j);
            }

            c.drawLine(Offset(pt0x, pt0y), Offset(pt1x, pt1y), mValueLinePaint);
            c.drawLine(Offset(pt1x, pt1y), Offset(pt2x, pt2y), mValueLinePaint);
          }

          // draw everything, depending on settings
          if (drawXOutside && drawYOutside) {
            drawValue(c, formattedValue, labelPtx, labelPty,
                dataSet.getValueTextColor2(j));

            if (j < data.getEntryCount() && entryLabel != null) {
              drawEntryLabel(c, entryLabel, labelPtx, labelPty + lineHeight);
            }
          } else if (drawXOutside) {
            if (j < data.getEntryCount() && entryLabel != null) {
              drawEntryLabel(
                  c, entryLabel, labelPtx, labelPty + lineHeight / 2.0);
            }
          } else if (drawYOutside) {
            drawValueByHeight(
                c,
                formattedValue,
                labelPtx,
                labelPty + lineHeight / 2.0,
                dataSet.getValueTextColor2(j),
                false);
          }
        }

        if (drawXInside || drawYInside) {
          // calculate the text position
          double x = labelRadius * sliceXBase + center.x;
          double y = labelRadius * sliceYBase + center.y;

          // draw everything, depending on settings
          if (drawXInside && drawYInside) {
            drawValueByHeight(
                c, formattedValue, x, y, dataSet.getValueTextColor2(j), true);

            if (j < data.getEntryCount() && entryLabel != null) {
              drawEntryLabel(c, entryLabel, x, y + lineHeight);
            }
          } else if (drawXInside) {
            if (j < data.getEntryCount() && entryLabel != null) {
              drawEntryLabel(c, entryLabel, x, y + lineHeight / 2);
            }
          } else if (drawYInside) {
            drawValue(c, formattedValue, x, y + lineHeight / 2,
                dataSet.getValueTextColor2(j));
          }
        }

//        if (entry.mIcon != null && dataSet.isDrawIconsEnabled()) {
//          Image icon = entry.mIcon;
//
//          double x = (labelRadius + iconsOffset.y) * sliceXBase + center.x;
//          double y = (labelRadius + iconsOffset.y) * sliceYBase + center.y;
//          y += iconsOffset.x;

//          Utils.drawImage( todo
//              c,
//              icon,
//              (int)x,
//              (int)y,
//              icon.getIntrinsicWidth(),
//              icon.getIntrinsicHeight());
//        }

        xIndex++;
      }

      MPPointF.recycleInstance(iconsOffset);
    }
    MPPointF.recycleInstance(center);
    c.restore();
  }

  void drawValueByHeight(Canvas c, String valueText, double x, double y,
      Color color, bool useHeight) {
    mValuePaint = PainterUtils.create(
        mValuePaint,
        valueText,
        color,
        mValuePaint.text.style.fontSize == null
            ? Utils.convertDpToPixel(13)
            : mValuePaint.text.style.fontSize);
    mValuePaint.layout();
    mValuePaint.paint(
        c,
        Offset(
            x - mValuePaint.width / 2, useHeight ? y - mValuePaint.height : y));
  }

  @override
  void drawValue(Canvas c, String valueText, double x, double y, Color color) {
    mValuePaint = PainterUtils.create(
        mValuePaint,
        valueText,
        color,
        mValuePaint.text.style.fontSize == null
            ? Utils.convertDpToPixel(13)
            : mValuePaint.text.style.fontSize);
    mValuePaint.layout();
    mValuePaint.paint(
        c, Offset(x - mValuePaint.width / 2, y - mValuePaint.height));
  }

  /**
   * Draws an entry label at the specified position.
   *
   * @param c
   * @param label
   * @param x
   * @param y
   */
  void drawEntryLabel(Canvas c, String label, double x, double y) {
    mEntryLabelsPaint = PainterUtils.create(
        mEntryLabelsPaint, label, ColorUtils.WHITE, Utils.convertDpToPixel(10));
    mEntryLabelsPaint.layout();
    mEntryLabelsPaint.paint(c,
        Offset(x - mEntryLabelsPaint.width / 2, y - mEntryLabelsPaint.height));
  }

  @override
  void drawExtras(Canvas c) {
    drawHole(c);
//    c.drawBitmap(mDrawBitmap.get(), 0, 0, null);
    drawCenterText(c);
  }

  Path mHoleCirclePath = Path();

  /**
   * draws the hole in the center of the chart and the transparent circle /
   * hole
   */
  void drawHole(Canvas c) {
//    if (mChart.isDrawHoleEnabled() && mBitmapCanvas != null) {
    if (mChart.isDrawHoleEnabled()) {
      double radius = mChart.getRadius();
      double holeRadius = radius * (mChart.getHoleRadius() / 100);
      MPPointF center = mChart.getCenterCircleBox();

//      if (mHolePaint.color.alpha > 0) {
//        // draw the hole-circle
//        mBitmapCanvas.drawCircle(
//            center.x, center.y,
//            holeRadius, mHolePaint);
//      }

      // only draw the circle if it can be seen (not covered by the hole)
      if (mTransparentCirclePaint.color.alpha > 0 &&
          mChart.getTransparentCircleRadius() > mChart.getHoleRadius()) {
        int alpha = mTransparentCirclePaint.color.alpha;
        double secondHoleRadius =
            radius * (mChart.getTransparentCircleRadius() / 100);

        mTransparentCirclePaint.color = Color.fromARGB(
            (alpha * mAnimator.getPhaseX() * mAnimator.getPhaseY()).toInt(),
            mTransparentCirclePaint.color.red,
            mTransparentCirclePaint.color.green,
            mTransparentCirclePaint.color.blue);

        // draw the transparent-circle
        mHoleCirclePath.reset();
        mHoleCirclePath.addOval(Rect.fromLTRB(
            center.x - secondHoleRadius,
            center.y - secondHoleRadius,
            center.x + secondHoleRadius,
            center.y + secondHoleRadius));
        mHoleCirclePath.addOval(Rect.fromLTRB(
            center.x - holeRadius,
            center.y - holeRadius,
            center.x + holeRadius,
            center.y + holeRadius));

//        mBitmapCanvas.drawPath(mHoleCirclePath, mTransparentCirclePaint);
        c.drawPath(mHoleCirclePath, mTransparentCirclePaint);

        // reset alpha
        mTransparentCirclePaint.color = Color.fromARGB(
            alpha,
            mTransparentCirclePaint.color.red,
            mTransparentCirclePaint.color.green,
            mTransparentCirclePaint.color.blue);
      }
      MPPointF.recycleInstance(center);
    }
  }

  Path mDrawCenterTextPathBuffer = Path();

  /**
   * draws the description text in the center of the pie chart makes most
   * sense when center-hole is enabled
   */
  void drawCenterText(Canvas c) {
    String centerText = mChart.getCenterText();

    if (mChart.isDrawCenterTextEnabled() && centerText != null) {
      MPPointF center = mChart.getCenterCircleBox();
      MPPointF offset = mChart.getCenterTextOffset();

      double x = center.x + offset.x;
      double y = center.y + offset.y;

      double innerRadius =
          mChart.isDrawHoleEnabled() && !mChart.isDrawSlicesUnderHoleEnabled()
              ? mChart.getRadius() * (mChart.getHoleRadius() / 100)
              : mChart.getRadius();

      mRectBuffer[0] = Rect.fromLTRB(
          x - innerRadius, y - innerRadius, x + innerRadius, y + innerRadius);
//      Rect holeRect = mRectBuffer[0];
      mRectBuffer[1] = Rect.fromLTRB(
          x - innerRadius, y - innerRadius, x + innerRadius, y + innerRadius);
//      Rect boundingRect = mRectBuffer[1];

      double radiusPercent = mChart.getCenterTextRadiusPercent() / 100;
      if (radiusPercent > 0.0) {
        var dx =
            (mRectBuffer[1].width - mRectBuffer[1].width * radiusPercent) / 2.0;
        var dy =
            (mRectBuffer[1].height - mRectBuffer[1].height * radiusPercent) /
                2.0;
        mRectBuffer[1] = Rect.fromLTRB(
            mRectBuffer[1].left + dx,
            mRectBuffer[1].top + dx,
            mRectBuffer[1].right - dy,
            mRectBuffer[1].bottom - dy);
      }

//      if (!(centerText == mCenterTextLastValue) ||
//          !(mRectBuffer[1] == mCenterTextLastBounds)) {
//        // Next time we won't recalculate StaticLayout...
//        mCenterTextLastBounds = Rect.fromLTRB(mRectBuffer[1].left,
//            mRectBuffer[1].top, mRectBuffer[1].right, mRectBuffer[1].bottom);
//        mCenterTextLastValue = centerText;
//      }

      c.save();

      mCenterTextPaint = PainterUtils.create(mCenterTextPaint, centerText,
          ColorUtils.BLACK, Utils.convertDpToPixel(12));
      mCenterTextPaint.layout();
      mCenterTextPaint.paint(
          c,
          Offset(
              mRectBuffer[1].left +
                  mRectBuffer[1].width / 2 -
                  mCenterTextPaint.width / 2,
              mRectBuffer[1].top +
                  mRectBuffer[1].height / 2 -
                  mCenterTextPaint.height / 2));

      c.restore();

      MPPointF.recycleInstance(center);
      MPPointF.recycleInstance(offset);
    }
  }

  Rect mDrawHighlightedRectF = Rect.zero;

  @override
  void drawHighlighted(Canvas c, List<Highlight> indices) {
    /* Skip entirely if using rounded circle slices, because it doesn't make sense to highlight
         * in this way.
         * TODO: add support for changing slice color with highlighting rather than only shifting the slice
         */

    final bool drawInnerArc =
        mChart.isDrawHoleEnabled() && !mChart.isDrawSlicesUnderHoleEnabled();
    if (drawInnerArc && mChart.isDrawRoundedSlicesEnabled()) return;

    double phaseX = mAnimator.getPhaseX();
    double phaseY = mAnimator.getPhaseY();

    double angle;
    double rotationAngle = mChart.getRotationAngle();

    List<double> drawAngles = mChart.getDrawAngles();
    List<double> absoluteAngles = mChart.getAbsoluteAngles();
    final MPPointF center = mChart.getCenterCircleBox();
    final double radius = mChart.getRadius();
    final double userInnerRadius =
        drawInnerArc ? radius * (mChart.getHoleRadius() / 100.0) : 0.0;

//    final Rect highlightedCircleBox = mDrawHighlightedRectF;
    mDrawHighlightedRectF = Rect.zero;

    for (int i = 0; i < indices.length; i++) {
      // get the index to highlight
      int index = indices[i].getX().toInt();

      if (index >= drawAngles.length) continue;

      IPieDataSet set =
          mChart.getData().getDataSetByIndex(indices[i].getDataSetIndex());

      if (set == null || !set.isHighlightEnabled()) continue;

      final int entryCount = set.getEntryCount();
      int visibleAngleCount = 0;
      for (int j = 0; j < entryCount; j++) {
        // draw only if the value is greater than zero
        if ((set.getEntryForIndex(j).y.abs() > Utils.FLOAT_EPSILON)) {
          visibleAngleCount++;
        }
      }

      if (index == 0)
        angle = 0.0;
      else
        angle = absoluteAngles[index - 1] * phaseX;

      final double sliceSpace =
          visibleAngleCount <= 1 ? 0.0 : set.getSliceSpace();

      double sliceAngle = drawAngles[index];
      double innerRadius = userInnerRadius;

      double shift = set.getSelectionShift();
      final double highlightedRadius = radius + shift;
      mDrawHighlightedRectF = Rect.fromLTRB(
          mChart.getCircleBox().left - shift,
          mChart.getCircleBox().top - shift,
          mChart.getCircleBox().right + shift,
          mChart.getCircleBox().bottom + shift);

      final bool accountForSliceSpacing =
          sliceSpace > 0.0 && sliceAngle <= 180.0;

      mRenderPaint.color = set.getColor2(index);

      final double sliceSpaceAngleOuter =
          visibleAngleCount == 1 ? 0.0 : sliceSpace / (Utils.FDEG2RAD * radius);

      final double sliceSpaceAngleShifted = visibleAngleCount == 1
          ? 0.0
          : sliceSpace / (Utils.FDEG2RAD * highlightedRadius);

      final double startAngleOuter =
          rotationAngle + (angle + sliceSpaceAngleOuter / 2.0) * phaseY;
      double sweepAngleOuter = (sliceAngle - sliceSpaceAngleOuter) * phaseY;
      if (sweepAngleOuter < 0.0) {
        sweepAngleOuter = 0.0;
      }

      final double startAngleShifted =
          rotationAngle + (angle + sliceSpaceAngleShifted / 2.0) * phaseY;
      double sweepAngleShifted = (sliceAngle - sliceSpaceAngleShifted) * phaseY;
      if (sweepAngleShifted < 0.0) {
        sweepAngleShifted = 0.0;
      }

      mPathBuffer.reset();

      if (sweepAngleOuter >= 360.0 &&
          sweepAngleOuter % 360 <= Utils.FLOAT_EPSILON) {
        // Android is doing "mod 360"
        mPathBuffer.addOval(Rect.fromLTRB(
            center.x - highlightedRadius,
            center.y - highlightedRadius,
            center.x + highlightedRadius,
            center.y + highlightedRadius));
      } else {
        mPathBuffer.moveTo(
            center.x +
                highlightedRadius * cos(startAngleShifted * Utils.FDEG2RAD),
            center.y +
                highlightedRadius * sin(startAngleShifted * Utils.FDEG2RAD));

        mPathBuffer.addArc(
            mDrawHighlightedRectF,
            startAngleShifted * Utils.FDEG2RAD,
            sweepAngleShifted * Utils.FDEG2RAD);
      }

      double sliceSpaceRadius = 0.0;
      if (accountForSliceSpacing) {
        sliceSpaceRadius = calculateMinimumRadiusForSpacedSlice(
            center,
            radius,
            sliceAngle * phaseY,
            center.x + radius * cos(startAngleOuter * Utils.FDEG2RAD),
            center.y + radius * sin(startAngleOuter * Utils.FDEG2RAD),
            startAngleOuter,
            sweepAngleOuter);
      }

      // API < 21 does not receive doubles in addArc, but a RectF
      mInnerRectBuffer = Rect.fromLTRB(
          center.x - innerRadius,
          center.y - innerRadius,
          center.x + innerRadius,
          center.y + innerRadius);

      if (drawInnerArc && (innerRadius > 0.0 || accountForSliceSpacing)) {
        if (accountForSliceSpacing) {
          double minSpacedRadius = sliceSpaceRadius;

          if (minSpacedRadius < 0.0) minSpacedRadius = -minSpacedRadius;

          innerRadius = max(innerRadius, minSpacedRadius);
        }

        final double sliceSpaceAngleInner =
            visibleAngleCount == 1 || innerRadius == 0.0
                ? 0.0
                : sliceSpace / (Utils.FDEG2RAD * innerRadius);
        final double startAngleInner =
            rotationAngle + (angle + sliceSpaceAngleInner / 2.0) * phaseY;
        double sweepAngleInner = (sliceAngle - sliceSpaceAngleInner) * phaseY;
        if (sweepAngleInner < 0.0) {
          sweepAngleInner = 0.0;
        }
        final double endAngleInner = startAngleInner + sweepAngleInner;

        if (sweepAngleOuter >= 360.0 &&
            sweepAngleOuter % 360 <= Utils.FLOAT_EPSILON) {
          // Android is doing "mod 360"
          mPathBuffer.addOval(Rect.fromLTRB(
              center.x - innerRadius,
              center.y - innerRadius,
              center.x + innerRadius,
              center.y + innerRadius));
        } else {
          final double angleMiddle = startAngleOuter + sweepAngleOuter / 2.0;

          final double arcEndPointX =
              center.x + sliceSpaceRadius * cos(angleMiddle * Utils.FDEG2RAD);
          final double arcEndPointY =
              center.y + sliceSpaceRadius * sin(angleMiddle * Utils.FDEG2RAD);
          mPathBuffer.lineTo(arcEndPointX, arcEndPointY);
//          mPathBuffer.lineTo(
//              center.x + innerRadius * cos(endAngleInner * Utils.FDEG2RAD),
//              center.y + innerRadius * sin(endAngleInner * Utils.FDEG2RAD));

          mPathBuffer.addArc(mInnerRectBuffer, endAngleInner * Utils.FDEG2RAD,
              -sweepAngleInner * Utils.FDEG2RAD);
        }
      } else {
        if (sweepAngleOuter % 360 > Utils.FLOAT_EPSILON) {
          if (accountForSliceSpacing) {
            final double angleMiddle = startAngleOuter + sweepAngleOuter / 2.0;

            final double arcEndPointX =
                center.x + sliceSpaceRadius * cos(angleMiddle * Utils.FDEG2RAD);
            final double arcEndPointY =
                center.y + sliceSpaceRadius * sin(angleMiddle * Utils.FDEG2RAD);

            mPathBuffer.lineTo(arcEndPointX, arcEndPointY);
          } else {
            mPathBuffer.lineTo(center.x, center.y);
          }
        }
      }

      mPathBuffer.close();

//      mBitmapCanvas.drawPath(mPathBuffer, mRenderPaint);
      c.drawPath(mPathBuffer, mRenderPaint);
      mRenderPaint..color = ColorUtils.WHITE;
      c.drawOval(mInnerRectBuffer, mRenderPaint);
    }

    MPPointF.recycleInstance(center);
  }

  /**
   * This gives all pie-slices a rounded edge.
   *
   * @param c
   */
  void drawRoundedSlices(Canvas c) {
    if (!mChart.isDrawRoundedSlicesEnabled()) return;

    IPieDataSet dataSet = mChart.getData().getDataSet();

    if (!dataSet.isVisible()) return;

    double phaseX = mAnimator.getPhaseX();
    double phaseY = mAnimator.getPhaseY();

    MPPointF center = mChart.getCenterCircleBox();
    double r = mChart.getRadius();

    // calculate the radius of the "slice-circle"
    double circleRadius = (r - (r * mChart.getHoleRadius() / 100)) / 2;

    List<double> drawAngles = mChart.getDrawAngles();
    double angle = mChart.getRotationAngle();

    for (int j = 0; j < dataSet.getEntryCount(); j++) {
      double sliceAngle = drawAngles[j];

      Entry e = dataSet.getEntryForIndex(j);

      // draw only if the value is greater than zero
      if ((e.y.abs() > Utils.FLOAT_EPSILON)) {
        double x = ((r - circleRadius) *
                cos((angle + sliceAngle) * phaseY / 180 * pi) +
            center.x);
        double y = ((r - circleRadius) *
                sin((angle + sliceAngle) * phaseY / 180 * pi) +
            center.y);

        mRenderPaint.color = dataSet.getColor2(j);
//        mBitmapCanvas.drawCircle(x, y, circleRadius, mRenderPaint);
        c.drawCircle(Offset(x, y), circleRadius, mRenderPaint);
      }

      angle += sliceAngle * phaseX;
    }
    MPPointF.recycleInstance(center);
  }

//  /**
//   * Releases the drawing bitmap. This should be called when {@link LineChart#onDetachedFromWindow()}.
//   */
//   void releaseBitmap() {
//    if (mBitmapCanvas != null) {
//      mBitmapCanvas.setBitmap(null);
//      mBitmapCanvas = null;
//    }
//    if (mDrawBitmap != null) {
//      Bitmap drawBitmap = mDrawBitmap.get();
//      if (drawBitmap != null) {
//        drawBitmap.recycle();
//      }
//      mDrawBitmap.clear();
//      mDrawBitmap = null;
//    }
//  }
}
