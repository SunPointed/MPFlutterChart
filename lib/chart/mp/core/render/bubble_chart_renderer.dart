import 'dart:math';

import 'package:flutter/painting.dart';
import 'package:mp_flutter_chart/chart/mp/core/animator.dart';
import 'package:mp_flutter_chart/chart/mp/core/data/bubble_data.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_interfaces/i_bubble_data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_provider/bubble_data_provider.dart';
import 'package:mp_flutter_chart/chart/mp/core/entry/bubble_entry.dart';
import 'package:mp_flutter_chart/chart/mp/core/highlight/highlight.dart';
import 'package:mp_flutter_chart/chart/mp/core/render/bar_line_scatter_candle_bubble_renderer.dart';
import 'package:mp_flutter_chart/chart/mp/core/transformer/transformer.dart';
import 'package:mp_flutter_chart/chart/mp/core/value_formatter/value_formatter.dart';
import 'package:mp_flutter_chart/chart/mp/core/view_port.dart';
import 'package:mp_flutter_chart/chart/mp/core/poolable/point.dart';
import 'package:mp_flutter_chart/chart/mp/core/util.dart';

class BubbleChartRenderer extends BarLineScatterCandleBubbleRenderer {
  BubbleDataProvider mChart;

  BubbleChartRenderer(BubbleDataProvider chart, ChartAnimator animator,
      ViewPortHandler viewPortHandler)
      : super(animator, viewPortHandler) {
    mChart = chart;

    mRenderPaint..style = PaintingStyle.fill;

    mHighlightPaint
      ..style = PaintingStyle.stroke
      ..strokeWidth = Utils.convertDpToPixel(1.5);
  }

  @override
  void initBuffers() {}

  @override
  void drawData(Canvas c) {
    BubbleData bubbleData = mChart.getBubbleData();

    for (IBubbleDataSet set in bubbleData.getDataSets()) {
      if (set.isVisible()) drawDataSet(c, set);
    }
  }

  List<double> sizeBuffer = List(4);
  List<double> pointBuffer = List(2);

  double getShapeSize(
      double entrySize, double maxSize, double reference, bool normalizeSize) {
    final double factor = normalizeSize
        ? ((maxSize == 0) ? 1 : sqrt(entrySize / maxSize))
        : entrySize;
    final double shapeSize = reference * factor;
    return shapeSize;
  }

  void drawDataSet(Canvas c, IBubbleDataSet dataSet) {
    if (dataSet.getEntryCount() < 1) return;

    Transformer trans = mChart.getTransformer(dataSet.getAxisDependency());

    double phaseY = mAnimator.getPhaseY();

    mXBounds.set(mChart, dataSet);

    sizeBuffer[0] = 0;
    sizeBuffer[2] = 1;

    trans.pointValuesToPixel(sizeBuffer);

    bool normalizeSize = dataSet.isNormalizeSizeEnabled();

    // calcualte the full width of 1 step on the x-axis
    final double maxBubbleWidth = (sizeBuffer[2] - sizeBuffer[0]).abs();
    final double maxBubbleHeight =
        (mViewPortHandler.contentBottom() - mViewPortHandler.contentTop())
            .abs();
    final double referenceSize = min(maxBubbleHeight, maxBubbleWidth);

    for (int j = mXBounds.min; j <= mXBounds.range + mXBounds.min; j++) {
      final BubbleEntry entry = dataSet.getEntryForIndex(j);

      pointBuffer[0] = entry.x;
      pointBuffer[1] = (entry.y) * phaseY;
      trans.pointValuesToPixel(pointBuffer);

      double shapeHalf = getShapeSize(entry.getSize(), dataSet.getMaxSize(),
              referenceSize, normalizeSize) /
          2;

      if (!mViewPortHandler.isInBoundsTop(pointBuffer[1] + shapeHalf) ||
          !mViewPortHandler.isInBoundsBottom(pointBuffer[1] - shapeHalf))
        continue;

      if (!mViewPortHandler.isInBoundsLeft(pointBuffer[0] + shapeHalf))
        continue;

      if (!mViewPortHandler.isInBoundsRight(pointBuffer[0] - shapeHalf)) break;

      final Color color = dataSet.getColor2(entry.x.toInt());

      mRenderPaint.color = color;
      c.drawCircle(
          Offset(pointBuffer[0], pointBuffer[1]), shapeHalf, mRenderPaint);
    }
  }

  @override
  void drawValues(Canvas c) {
    BubbleData bubbleData = mChart.getBubbleData();

    if (bubbleData == null) return;

    // if values are drawn
    if (isDrawingValuesAllowed(mChart)) {
      final List<IBubbleDataSet> dataSets = bubbleData.getDataSets();

      double lineHeight = Utils.calcTextHeight(mValuePaint, "1").toDouble();

      for (int i = 0; i < dataSets.length; i++) {
        IBubbleDataSet dataSet = dataSets[i];

        if (!shouldDrawValues(dataSet) || dataSet.getEntryCount() < 1) continue;

        // apply the text-styling defined by the DataSet
        applyValueTextStyle(dataSet);

        final double phaseX = max(0.0, min(1.0, mAnimator.getPhaseX()));
        final double phaseY = mAnimator.getPhaseY();

        mXBounds.set(mChart, dataSet);

        List<double> positions = mChart
            .getTransformer(dataSet.getAxisDependency())
            .generateTransformedValuesBubble(
                dataSet, phaseY, mXBounds.min, mXBounds.max);

        final double alpha = phaseX == 1 ? phaseY : phaseX;

        ValueFormatter formatter = dataSet.getValueFormatter();

        MPPointF iconsOffset = MPPointF.getInstance3(dataSet.getIconsOffset());
        iconsOffset.x = Utils.convertDpToPixel(iconsOffset.x);
        iconsOffset.y = Utils.convertDpToPixel(iconsOffset.y);

        for (int j = 0; j < positions.length; j += 2) {
          Color valueTextColor =
              dataSet.getValueTextColor2(j ~/ 2 + mXBounds.min);
          valueTextColor = Color.fromARGB((255.0 * alpha).round(),
              valueTextColor.red, valueTextColor.green, valueTextColor.blue);

          double x = positions[j];
          double y = positions[j + 1];

          if (!mViewPortHandler.isInBoundsRight(x)) break;

          if ((!mViewPortHandler.isInBoundsLeft(x) ||
              !mViewPortHandler.isInBoundsY(y))) continue;

          BubbleEntry entry = dataSet.getEntryForIndex(j ~/ 2 + mXBounds.min);

          if (dataSet.isDrawValuesEnabled()) {
            drawValue(c, formatter.getBubbleLabel(entry), x,
                y + (0.5 * lineHeight), valueTextColor);
          }

//          if (entry.getIcon() != null && dataSet.isDrawIconsEnabled()) {
//
//            Drawable icon = entry.getIcon();
//
//            Utils.drawImage(
//                c,
//                icon,
//                (int)(x + iconsOffset.x),
//                (int)(y + iconsOffset.y),
//                icon.getIntrinsicWidth(),
//                icon.getIntrinsicHeight());
//          }
        }

        MPPointF.recycleInstance(iconsOffset);
      }
    }
  }

  @override
  void drawValue(Canvas c, String valueText, double x, double y, Color color) {
    mValuePaint = TextPainter(
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
        text: TextSpan(
            text: valueText,
            style: TextStyle(
                color: color,
                fontSize: mValuePaint.text.style.fontSize == null
                    ? Utils.convertDpToPixel(13)
                    : mValuePaint.text.style.fontSize)));
    mValuePaint.layout();
    mValuePaint.paint(c, Offset(x, y));
  }

  @override
  void drawExtras(Canvas c) {}

  @override
  void drawHighlighted(Canvas c, List<Highlight> indices) {
    BubbleData bubbleData = mChart.getBubbleData();

    double phaseY = mAnimator.getPhaseY();

    for (Highlight high in indices) {
      IBubbleDataSet set = bubbleData.getDataSetByIndex(high.getDataSetIndex());

      if (set == null || !set.isHighlightEnabled()) continue;

      final BubbleEntry entry =
          set.getEntryForXValue2(high.getX(), high.getY());

      if (entry.y != high.getY()) continue;

      if (!isInBoundsX(entry, set)) continue;

      Transformer trans = mChart.getTransformer(set.getAxisDependency());

      sizeBuffer[0] = 0;
      sizeBuffer[2] = 1;

      trans.pointValuesToPixel(sizeBuffer);

      bool normalizeSize = set.isNormalizeSizeEnabled();

      // calcualte the full width of 1 step on the x-axis
      final double maxBubbleWidth = (sizeBuffer[2] - sizeBuffer[0]).abs();
      final double maxBubbleHeight =
          (mViewPortHandler.contentBottom() - mViewPortHandler.contentTop())
              .abs();
      final double referenceSize = min(maxBubbleHeight, maxBubbleWidth);

      pointBuffer[0] = entry.x;
      pointBuffer[1] = (entry.y) * phaseY;
      trans.pointValuesToPixel(pointBuffer);

      high.setDraw(pointBuffer[0], pointBuffer[1]);

      double shapeHalf = getShapeSize(
              entry.getSize(), set.getMaxSize(), referenceSize, normalizeSize) /
          2;

      if (!mViewPortHandler.isInBoundsTop(pointBuffer[1] + shapeHalf) ||
          !mViewPortHandler.isInBoundsBottom(pointBuffer[1] - shapeHalf))
        continue;

      if (!mViewPortHandler.isInBoundsLeft(pointBuffer[0] + shapeHalf))
        continue;

      if (!mViewPortHandler.isInBoundsRight(pointBuffer[0] - shapeHalf)) break;

      final Color originalColor = set.getColor2(entry.x.toInt());

      var hsv = HSVColor.fromColor(originalColor);
      var color = hsv.toColor();

      mHighlightPaint
        ..color = color
        ..strokeWidth = set.getHighlightCircleWidth();
      c.drawCircle(
          Offset(pointBuffer[0], pointBuffer[1]), shapeHalf, mHighlightPaint);
    }
  }
}
