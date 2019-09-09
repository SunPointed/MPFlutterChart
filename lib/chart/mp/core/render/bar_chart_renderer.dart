import 'dart:math';
import 'dart:ui';

import 'package:flutter/painting.dart';
import 'package:mp_flutter_chart/chart/mp/core/animator.dart';
import 'package:mp_flutter_chart/chart/mp/core/buffer/bar_buffer.dart';
import 'package:mp_flutter_chart/chart/mp/core/color/gradient_color.dart';
import 'package:mp_flutter_chart/chart/mp/core/data/bar_data.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_interfaces/i_bar_data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_provider/bar_data_provider.dart';
import 'package:mp_flutter_chart/chart/mp/core/entry/bar_entry.dart';
import 'package:mp_flutter_chart/chart/mp/core/highlight/highlight.dart';
import 'package:mp_flutter_chart/chart/mp/core/range.dart';
import 'package:mp_flutter_chart/chart/mp/core/render/bar_line_scatter_candle_bubble_renderer.dart';
import 'package:mp_flutter_chart/chart/mp/core/transformer/transformer.dart';
import 'package:mp_flutter_chart/chart/mp/core/utils/painter_utils.dart';
import 'package:mp_flutter_chart/chart/mp/core/value_formatter/value_formatter.dart';
import 'package:mp_flutter_chart/chart/mp/core/view_port.dart';
import 'package:mp_flutter_chart/chart/mp/core/poolable/point.dart';
import 'package:mp_flutter_chart/chart/mp/core/utils/utils.dart';

class BarChartRenderer extends BarLineScatterCandleBubbleRenderer {
  BarDataProvider mChart;

  /**
   * the rect object that is used for drawing the bars
   */
  Rect mBarRect = Rect.zero;

  List<BarBuffer> mBarBuffers;

  Paint mShadowPaint;
  Paint mBarBorderPaint;

  BarChartRenderer(BarDataProvider chart, ChartAnimator animator,
      ViewPortHandler viewPortHandler)
      : super(animator, viewPortHandler) {
    this.mChart = chart;

    mHighlightPaint = Paint()
      ..isAntiAlias = true
      ..color = Color.fromARGB(120, 0, 0, 0)
      ..style = PaintingStyle.fill;

    mShadowPaint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.fill;
    mBarBorderPaint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke;
  }

  @override
  void initBuffers() {
    BarData barData = mChart.getBarData();
    mBarBuffers = List(barData.getDataSetCount());

    for (int i = 0; i < mBarBuffers.length; i++) {
      IBarDataSet set = barData.getDataSetByIndex(i);
      mBarBuffers[i] = BarBuffer(
          set.getEntryCount() * 4 * (set.isStacked() ? set.getStackSize() : 1),
          barData.getDataSetCount(),
          set.isStacked());
    }
  }

  @override
  void drawData(Canvas c) {
    BarData barData = mChart.getBarData();

    for (int i = 0; i < barData.getDataSetCount(); i++) {
      IBarDataSet set = barData.getDataSetByIndex(i);

      if (set.isVisible()) {
        drawDataSet(c, set, i);
      }
    }
  }

  void drawDataSet(Canvas c, IBarDataSet dataSet, int index) {
    Transformer trans = mChart.getTransformer(dataSet.getAxisDependency());

    mBarBorderPaint..color = dataSet.getBarBorderColor();
    mBarBorderPaint
      ..strokeWidth = Utils.convertDpToPixel(dataSet.getBarBorderWidth());

    final bool drawBorder = dataSet.getBarBorderWidth() > 0.0;

    double phaseX = mAnimator.getPhaseX();
    double phaseY = mAnimator.getPhaseY();

    // draw the bar shadow before the values
    if (mChart.isDrawBarShadowEnabled()) {
      mShadowPaint..color = dataSet.getBarShadowColor();

      BarData barData = mChart.getBarData();

      final double barWidth = barData.getBarWidth();
      final double barWidthHalf = barWidth / 2.0;
      double x;

      for (int i = 0,
              count = min((((dataSet.getEntryCount()) * phaseX).ceil()),
                  dataSet.getEntryCount());
          i < count;
          i++) {
        BarEntry e = dataSet.getEntryForIndex(i);

        x = e.x;

        mBarShadowRectBuffer =
            Rect.fromLTRB(x - barWidthHalf, 0.0, x + barWidthHalf, 0.0);

        trans.rectValueToPixel(mBarShadowRectBuffer);

        if (!mViewPortHandler.isInBoundsLeft(mBarShadowRectBuffer.right))
          continue;

        if (!mViewPortHandler.isInBoundsRight(mBarShadowRectBuffer.left)) break;

        mBarShadowRectBuffer = Rect.fromLTRB(
            mBarShadowRectBuffer.left,
            mViewPortHandler.contentTop(),
            mBarShadowRectBuffer.right,
            mViewPortHandler.contentBottom());

        c.drawRect(mBarShadowRectBuffer, mShadowPaint);
      }
    }

    // initialize the buffer
    BarBuffer buffer = mBarBuffers[index];
    buffer.setPhases(phaseX, phaseY);
    buffer.setDataSet(index);
    buffer.setInverted(mChart.isInverted(dataSet.getAxisDependency()));
    buffer.setBarWidth(mChart.getBarData().getBarWidth());

    buffer.feed(dataSet);

    trans.pointValuesToPixel(buffer.buffer);

    final bool isSingleColor = dataSet.getColors().length == 1;

    if (isSingleColor) {
      mRenderPaint..color = dataSet.getColor1();
    }

    for (int j = 0; j < buffer.size(); j += 4) {
      if (!mViewPortHandler.isInBoundsLeft(buffer.buffer[j + 2])) continue;

      if (!mViewPortHandler.isInBoundsRight(buffer.buffer[j])) break;

      if (!isSingleColor) {
        // Set the color for the currently drawn value. If the index
        // is out of bounds, reuse colors.
        mRenderPaint..color = dataSet.getColor2(j ~/ 4);
      }

      if (dataSet.getGradientColor1() != null) {
        GradientColor gradientColor = dataSet.getGradientColor1();

        mRenderPaint
          ..shader = (LinearGradient(
                  colors: List()
                    ..add(gradientColor.startColor)
                    ..add(gradientColor.endColor),
                  tileMode: TileMode.mirror))
              .createShader(Rect.fromLTRB(
                  buffer.buffer[j],
                  buffer.buffer[j + 3],
                  buffer.buffer[j],
                  buffer.buffer[j + 1]));
      }

      if (dataSet.getGradientColors() != null) {
        mRenderPaint
          ..shader = (LinearGradient(
                  colors: List()
                    ..add(dataSet.getGradientColor2(j ~/ 4).startColor)
                    ..add(dataSet.getGradientColor2(j ~/ 4).endColor),
                  tileMode: TileMode.mirror))
              .createShader(Rect.fromLTRB(
                  buffer.buffer[j],
                  buffer.buffer[j + 3],
                  buffer.buffer[j],
                  buffer.buffer[j + 1]));
      }

      c.drawRect(
          Rect.fromLTRB(buffer.buffer[j], buffer.buffer[j + 1],
              buffer.buffer[j + 2], buffer.buffer[j + 3]),
          mRenderPaint);

      if (drawBorder) {
        c.drawRect(
            Rect.fromLTRB(buffer.buffer[j], buffer.buffer[j + 1],
                buffer.buffer[j + 2], buffer.buffer[j + 3]),
            mBarBorderPaint);
      }
    }
  }

  Rect mBarShadowRectBuffer = Rect.zero;

  void prepareBarHighlight(
      double x, double y1, double y2, double barWidthHalf, Transformer trans) {
    double left = x - barWidthHalf;
    double right = x + barWidthHalf;
    double top = y1;
    double bottom = y2;

    mBarRect = trans.rectToPixelPhase(
        Rect.fromLTRB(left, top, right, bottom), mAnimator.getPhaseY());
  }

  @override
  void drawValues(Canvas c) {
    // if values are drawn
    if (isDrawingValuesAllowed(mChart)) {
      List<IBarDataSet> dataSets = mChart.getBarData().getDataSets();

      final double valueOffsetPlus = Utils.convertDpToPixel(4.5);
      double posOffset = 0.0;
      double negOffset = 0.0;
      bool drawValueAboveBar = mChart.isDrawValueAboveBarEnabled();

      for (int i = 0; i < mChart.getBarData().getDataSetCount(); i++) {
        IBarDataSet dataSet = dataSets[i];

        if (!shouldDrawValues(dataSet)) continue;

        // apply the text-styling defined by the DataSet
        applyValueTextStyle(dataSet);

        bool isInverted = mChart.isInverted(dataSet.getAxisDependency());

        // calculate the correct offset depending on the draw position of
        // the value
        double valueTextHeight =
            Utils.calcTextHeight(mValuePaint, "8").toDouble();
        posOffset = (drawValueAboveBar
            ? -valueOffsetPlus
            : valueTextHeight + valueOffsetPlus);
        negOffset = (drawValueAboveBar
            ? valueTextHeight + valueOffsetPlus
            : -valueOffsetPlus);

        if (isInverted) {
          posOffset = -posOffset - valueTextHeight;
          negOffset = -negOffset - valueTextHeight;
        }

        // get the buffer
        BarBuffer buffer = mBarBuffers[i];

        final double phaseY = mAnimator.getPhaseY();

        ValueFormatter formatter = dataSet.getValueFormatter();

        MPPointF iconsOffset = MPPointF.getInstance3(dataSet.getIconsOffset());
        iconsOffset.x = Utils.convertDpToPixel(iconsOffset.x);
        iconsOffset.y = Utils.convertDpToPixel(iconsOffset.y);

        // if only single values are drawn (sum)
        if (!dataSet.isStacked()) {
          for (int j = 0;
              j < buffer.buffer.length * mAnimator.getPhaseX();
              j += 4) {
            double x = (buffer.buffer[j] + buffer.buffer[j + 2]) / 2.0;

            if (!mViewPortHandler.isInBoundsRight(x)) break;

            if (!mViewPortHandler.isInBoundsY(buffer.buffer[j + 1]) ||
                !mViewPortHandler.isInBoundsLeft(x)) continue;

            BarEntry entry = dataSet.getEntryForIndex(j ~/ 4);
            double val = entry.y;

            if (dataSet.isDrawValuesEnabled()) {
              drawValue(
                  c,
                  formatter.getBarLabel(entry),
                  x,
                  val >= 0
                      ? (buffer.buffer[j + 1] + posOffset)
                      : (buffer.buffer[j + 3] + negOffset),
                  dataSet.getValueTextColor2(j ~/ 4));
            }

            if (entry.mIcon != null && dataSet.isDrawIconsEnabled()) {
              Image icon = entry.mIcon;

              double px = x;
              double py = val >= 0
                  ? (buffer.buffer[j + 1] + posOffset)
                  : (buffer.buffer[j + 3] + negOffset);

              px += iconsOffset.x;
              py += iconsOffset.y;
//            todo
//              Utils.drawImage(
//                  c,
//                  icon,
//                  (int)px,
//                  (int)py,
//                  icon.getIntrinsicWidth(),
//                  icon.getIntrinsicHeight());
            }
          }

          // if we have stacks
        } else {
          Transformer trans =
              mChart.getTransformer(dataSet.getAxisDependency());

          int bufferIndex = 0;
          int index = 0;
          while (index < dataSet.getEntryCount() * mAnimator.getPhaseX()) {
            BarEntry entry = dataSet.getEntryForIndex(index);

            List<double> vals = entry.getYVals();
            double x =
                (buffer.buffer[bufferIndex] + buffer.buffer[bufferIndex + 2]) /
                    2.0;

            Color color = dataSet.getValueTextColor2(index);

            // we still draw stacked bars, but there is one
            // non-stacked
            // in between
            if (vals == null) {
              if (!mViewPortHandler.isInBoundsRight(x)) break;

              if (!mViewPortHandler
                      .isInBoundsY(buffer.buffer[bufferIndex + 1]) ||
                  !mViewPortHandler.isInBoundsLeft(x)) continue;

              if (dataSet.isDrawValuesEnabled()) {
                drawValue(
                    c,
                    formatter.getBarLabel(entry),
                    x,
                    buffer.buffer[bufferIndex + 1] +
                        (entry.y >= 0 ? posOffset : negOffset),
                    color);
              }

              if (entry.mIcon != null && dataSet.isDrawIconsEnabled()) {
                Image icon = entry.mIcon;

                double px = x;
                double py = buffer.buffer[bufferIndex + 1] +
                    (entry.y >= 0 ? posOffset : negOffset);

                px += iconsOffset.x;
                py += iconsOffset.y;
//                todo
//                Utils.drawImage(
//                    c,
//                    icon,
//                    (int)px,
//                    (int)py,
//                    icon.getIntrinsicWidth(),
//                    icon.getIntrinsicHeight());
              }

              // draw stack values
            } else {
              List<double> transformed = List(vals.length * 2);

              double posY = 0.0;
              double negY = -entry.getNegativeSum();

              for (int k = 0, idx = 0; k < transformed.length; k += 2, idx++) {
                double value = vals[idx];
                double y;

                if (value == 0.0 && (posY == 0.0 || negY == 0.0)) {
                  // Take care of the situation of a 0.0 value, which overlaps a non-zero bar
                  y = value;
                } else if (value >= 0.0) {
                  posY += value;
                  y = posY;
                } else {
                  y = negY;
                  negY -= value;
                }

                transformed[k + 1] = y * phaseY;
              }

              trans.pointValuesToPixel(transformed);

              for (int k = 0; k < transformed.length; k += 2) {
                final double val = vals[k ~/ 2];
                final bool drawBelow =
                    (val == 0.0 && negY == 0.0 && posY > 0.0) || val < 0.0;
                double y =
                    transformed[k + 1] + (drawBelow ? negOffset : posOffset);

                if (!mViewPortHandler.isInBoundsRight(x)) break;

                if (!mViewPortHandler.isInBoundsY(y) ||
                    !mViewPortHandler.isInBoundsLeft(x)) continue;

                if (dataSet.isDrawValuesEnabled()) {
                  drawValue(
                      c, formatter.getBarStackedLabel(val, entry), x, y, color);
                }

                if (entry.mIcon != null && dataSet.isDrawIconsEnabled()) {
                  Image icon = entry.mIcon;
//                  todo
//                  Utils.drawImage(
//                      c,
//                      icon,
//                      (int)(x + iconsOffset.x),
//                      (int)(y + iconsOffset.y),
//                      icon.getIntrinsicWidth(),
//                      icon.getIntrinsicHeight());
                }
              }
            }

            bufferIndex =
                vals == null ? bufferIndex + 4 : bufferIndex + 4 * vals.length;
            index++;
          }
        }

        MPPointF.recycleInstance(iconsOffset);
      }
    }
  }

  @override
  void drawValue(Canvas c, String valueText, double x, double y, Color color) {
    mValuePaint = PainterUtils.create(
        mValuePaint,
        valueText,
        color,
        mValuePaint.text.style.fontSize == null
            ? Utils.convertDpToPixel(9)
            : mValuePaint.text.style.fontSize);
    mValuePaint.layout();
    mValuePaint.paint(
        c, Offset(x - mValuePaint.width / 2, y - mValuePaint.height));
  }

  @override
  void drawHighlighted(Canvas c, List<Highlight> indices) {
    BarData barData = mChart.getBarData();

    for (Highlight high in indices) {
      IBarDataSet set = barData.getDataSetByIndex(high.getDataSetIndex());

      if (set == null || !set.isHighlightEnabled()) continue;

      BarEntry e = set.getEntryForXValue2(high.getX(), high.getY());

      if (!isInBoundsX(e, set)) continue;

      Transformer trans = mChart.getTransformer(set.getAxisDependency());

      var color = set.getHighLightColor();
      mHighlightPaint.color = Color.fromARGB(
          set.getHighLightAlpha(), color.red, color.green, color.blue);

      bool isStack =
          (high.getStackIndex() >= 0 && e.isStacked()) ? true : false;

      double y1;
      double y2;

      if (isStack) {
        if (mChart.isHighlightFullBarEnabled()) {
          y1 = e.getPositiveSum();
          y2 = -e.getNegativeSum();
        } else {
          Range range = e.getRanges()[high.getStackIndex()];

          y1 = range.from;
          y2 = range.to;
        }
      } else {
        y1 = e.y;
        y2 = 0.0;
      }

      prepareBarHighlight(e.x, y1, y2, barData.getBarWidth() / 2.0, trans);

      setHighlightDrawPos(high, mBarRect);
      c.drawRect(mBarRect, mHighlightPaint);
    }
  }

  /**
   * Sets the drawing position of the highlight object based on the riven bar-rect.
   * @param high
   */
  void setHighlightDrawPos(Highlight high, Rect bar) {
    high.setDraw(bar.center.dx, bar.top);
  }

  @override
  void drawExtras(Canvas c) {}
}
