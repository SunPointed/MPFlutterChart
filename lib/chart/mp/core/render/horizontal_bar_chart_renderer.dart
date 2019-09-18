import 'dart:math';

import 'package:flutter/painting.dart';
import 'package:mp_flutter_chart/chart/mp/core/animator.dart';
import 'package:mp_flutter_chart/chart/mp/core/buffer/bar_buffer.dart';
import 'package:mp_flutter_chart/chart/mp/core/buffer/horizontal_bar_buffer.dart';
import 'package:mp_flutter_chart/chart/mp/core/data/bar_data.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_interfaces/i_bar_data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_provider/bar_data_provider.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_provider/chart_interface.dart';
import 'package:mp_flutter_chart/chart/mp/core/entry/bar_entry.dart';
import 'package:mp_flutter_chart/chart/mp/core/highlight/highlight.dart';
import 'package:mp_flutter_chart/chart/mp/core/render/bar_chart_renderer.dart';
import 'package:mp_flutter_chart/chart/mp/core/transformer/transformer.dart';
import 'package:mp_flutter_chart/chart/mp/core/utils/canvas_utils.dart';
import 'package:mp_flutter_chart/chart/mp/core/utils/painter_utils.dart';
import 'package:mp_flutter_chart/chart/mp/core/value_formatter/value_formatter.dart';
import 'package:mp_flutter_chart/chart/mp/core/view_port.dart';
import 'package:mp_flutter_chart/chart/mp/core/poolable/point.dart';
import 'package:mp_flutter_chart/chart/mp/core/utils/utils.dart';

class HorizontalBarChartRenderer extends BarChartRenderer {
  HorizontalBarChartRenderer(BarDataProvider chart, ChartAnimator animator,
      ViewPortHandler viewPortHandler)
      : super(chart, animator, viewPortHandler);

  @override
  void initBuffers() {
    BarData barData = mChart.getBarData();
    mBarBuffers = List(barData.getDataSetCount());

    for (int i = 0; i < mBarBuffers.length; i++) {
      IBarDataSet set = barData.getDataSetByIndex(i);
      mBarBuffers[i] = HorizontalBarBuffer(
          set.getEntryCount() * 4 * (set.isStacked() ? set.getStackSize() : 1),
          barData.getDataSetCount(),
          set.isStacked());
    }
  }

  Rect mBarShadowRectBuffer = Rect.zero;

  @override
  void drawDataSet(Canvas c, IBarDataSet dataSet, int index) {
    Transformer trans = mChart.getTransformer(dataSet.getAxisDependency());

    mBarBorderPaint
      ..color = dataSet.getBarBorderColor()
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
              count = min(((dataSet.getEntryCount()) * phaseX).ceil(),
                  dataSet.getEntryCount());
          i < count;
          i++) {
        BarEntry e = dataSet.getEntryForIndex(i);

        x = e.x;

        mBarShadowRectBuffer = Rect.fromLTRB(mBarShadowRectBuffer.left,
            x - barWidthHalf, mBarShadowRectBuffer.right, x + barWidthHalf);

        trans.rectValueToPixel(mBarShadowRectBuffer);

        if (!mViewPortHandler.isInBoundsTop(mBarShadowRectBuffer.bottom))
          continue;

        if (!mViewPortHandler.isInBoundsBottom(mBarShadowRectBuffer.top)) break;

        mBarShadowRectBuffer = Rect.fromLTRB(
            mViewPortHandler.contentLeft(),
            mBarShadowRectBuffer.top,
            mViewPortHandler.contentRight(),
            mBarShadowRectBuffer.bottom);

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
      if (!mViewPortHandler.isInBoundsTop(buffer.buffer[j + 3])) break;

      if (!mViewPortHandler.isInBoundsBottom(buffer.buffer[j + 1])) continue;

      if (!isSingleColor) {
        // Set the color for the currently drawn value. If the index
        // is out of bounds, reuse colors.
        mRenderPaint..color = (dataSet.getColor2(j ~/ 4));
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

  @override
  void drawValues(Canvas c) {
    // if values are drawn
    if (!isDrawingValuesAllowed(mChart)) return;

    List<IBarDataSet> dataSets = mChart.getBarData().getDataSets();

    final double valueOffsetPlus = Utils.convertDpToPixel(5);
    double posOffset = 0;
    double negOffset = 0;
    final bool drawValueAboveBar = mChart.isDrawValueAboveBarEnabled();

    for (int i = 0; i < mChart.getBarData().getDataSetCount(); i++) {
      IBarDataSet dataSet = dataSets[i];

      if (!shouldDrawValues(dataSet)) continue;

      bool isInverted = mChart.isInverted(dataSet.getAxisDependency());

      // apply the text-styling defined by the DataSet
      applyValueTextStyle(dataSet);

      ValueFormatter formatter = dataSet.getValueFormatter();

      // get the buffer
      BarBuffer buffer = mBarBuffers[i];

      final double phaseY = mAnimator.getPhaseY();

      MPPointF iconsOffset = MPPointF.getInstance3(dataSet.getIconsOffset());
      iconsOffset.x = Utils.convertDpToPixel(iconsOffset.x);
      iconsOffset.y = Utils.convertDpToPixel(iconsOffset.y);

      // if only single values are drawn (sum)
      if (!dataSet.isStacked()) {
        for (int j = 0;
            j < buffer.buffer.length * mAnimator.getPhaseX();
            j += 4) {
          double y = (buffer.buffer[j + 1] + buffer.buffer[j + 3]) / 2;

          if (!mViewPortHandler.isInBoundsTop(buffer.buffer[j + 1])) break;

          if (!mViewPortHandler.isInBoundsX(buffer.buffer[j])) continue;

          if (!mViewPortHandler.isInBoundsBottom(buffer.buffer[j + 1]))
            continue;

          BarEntry entry = dataSet.getEntryForIndex(j ~/ 4);
          double val = entry.y;
          String formattedValue = formatter.getBarLabel(entry);

          // calculate the correct offset depending on the draw position of the value
          double valueTextWidth =
              Utils.calcTextWidth(mValuePaint, formattedValue).toDouble();
          posOffset = (drawValueAboveBar
              ? valueOffsetPlus
              : -(valueTextWidth + valueOffsetPlus));
          negOffset = (drawValueAboveBar
              ? -(valueTextWidth + valueOffsetPlus)
              : valueOffsetPlus);

          if (isInverted) {
            posOffset = -posOffset - valueTextWidth;
            negOffset = -negOffset - valueTextWidth;
          }

          if (dataSet.isDrawValuesEnabled()) {
            drawValue(
                c,
                formattedValue,
                buffer.buffer[j + 2] + (val >= 0 ? posOffset : negOffset),
                y,
                dataSet.getValueTextColor2(j ~/ 2));
          }
          if (entry.mIcon != null && dataSet.isDrawIconsEnabled()) {
            double px =
                buffer.buffer[j + 2] + (val >= 0 ? posOffset : negOffset);
            double py = y;

            px += iconsOffset.x;
            py += iconsOffset.y;

            CanvasUtils.drawImage(
                c, Offset(px, py), entry.mIcon, Size(15, 15), mDrawPaint);
          }
        }

        // if each value of a potential stack should be drawn
      } else {
        Transformer trans = mChart.getTransformer(dataSet.getAxisDependency());

        int bufferIndex = 0;
        int index = 0;

        while (index < dataSet.getEntryCount() * mAnimator.getPhaseX()) {
          BarEntry entry = dataSet.getEntryForIndex(index);

          Color color = dataSet.getValueTextColor2(index);
          List<double> vals = entry.getYVals();

          // we still draw stacked bars, but there is one
          // non-stacked
          // in between
          if (vals == null) {
            if (!mViewPortHandler.isInBoundsTop(buffer.buffer[bufferIndex + 1]))
              break;

            if (!mViewPortHandler.isInBoundsX(buffer.buffer[bufferIndex]))
              continue;

            if (!mViewPortHandler
                .isInBoundsBottom(buffer.buffer[bufferIndex + 1])) continue;

            String formattedValue = formatter.getBarLabel(entry);

            // calculate the correct offset depending on the draw position of the value
            double valueTextWidth =
                Utils.calcTextWidth(mValuePaint, formattedValue).toDouble();
            posOffset = (drawValueAboveBar
                ? valueOffsetPlus
                : -(valueTextWidth + valueOffsetPlus));
            negOffset = (drawValueAboveBar
                ? -(valueTextWidth + valueOffsetPlus)
                : valueOffsetPlus);

            if (isInverted) {
              posOffset = -posOffset - valueTextWidth;
              negOffset = -negOffset - valueTextWidth;
            }

            if (dataSet.isDrawValuesEnabled()) {
              drawValue(
                  c,
                  formattedValue,
                  buffer.buffer[bufferIndex + 2] +
                      (entry.y >= 0 ? posOffset : negOffset),
                  buffer.buffer[bufferIndex + 1],
                  color);
            }
            if (entry.mIcon != null && dataSet.isDrawIconsEnabled()) {
              double px = buffer.buffer[bufferIndex + 2] +
                  (entry.y >= 0 ? posOffset : negOffset);
              double py = buffer.buffer[bufferIndex + 1];

              px += iconsOffset.x;
              py += iconsOffset.y;

              CanvasUtils.drawImage(
                  c, Offset(px, py), entry.mIcon, Size(15, 15), mDrawPaint);
            }
          } else {
            List<double> transformed = List(vals.length * 2);

            double posY = 0;
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

              transformed[k] = y * phaseY;
            }

            trans.pointValuesToPixel(transformed);

            for (int k = 0; k < transformed.length; k += 2) {
              final double val = vals[k ~/ 2];
              String formattedValue = formatter.getBarStackedLabel(val, entry);

              // calculate the correct offset depending on the draw position of the value
              double valueTextWidth =
                  Utils.calcTextWidth(mValuePaint, formattedValue).toDouble();
              posOffset = (drawValueAboveBar
                  ? valueOffsetPlus
                  : -(valueTextWidth + valueOffsetPlus));
              negOffset = (drawValueAboveBar
                  ? -(valueTextWidth + valueOffsetPlus)
                  : valueOffsetPlus);

              if (isInverted) {
                posOffset = -posOffset - valueTextWidth;
                negOffset = -negOffset - valueTextWidth;
              }

              final bool drawBelow =
                  (val == 0.0 && negY == 0.0 && posY > 0.0) || val < 0.0;

              double x = transformed[k] + (drawBelow ? negOffset : posOffset);
              double y = (buffer.buffer[bufferIndex + 1] +
                      buffer.buffer[bufferIndex + 3]) /
                  2;

              if (!mViewPortHandler.isInBoundsTop(y)) break;

              if (!mViewPortHandler.isInBoundsX(x)) continue;

              if (!mViewPortHandler.isInBoundsBottom(y)) continue;

              if (dataSet.isDrawValuesEnabled()) {
                drawValue(c, formattedValue, x, y, color);
              }

              if (entry.mIcon != null && dataSet.isDrawIconsEnabled()) {
                CanvasUtils.drawImage(
                    c,
                    Offset(x + iconsOffset.x, y + iconsOffset.y),
                    entry.mIcon,
                    Size(15, 15),
                    mDrawPaint);
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
    mValuePaint.paint(c, Offset(x, y - mValuePaint.height / 2));
  }

  @override
  void prepareBarHighlight(
      double x, double y1, double y2, double barWidthHalf, Transformer trans) {
    double top = x - barWidthHalf;
    double bottom = x + barWidthHalf;
    double left = y1;
    double right = y2;

    mBarRect = trans.rectToPixelPhaseHorizontal(
        Rect.fromLTRB(left, top, right, bottom), mAnimator.getPhaseY());
  }

  @override
  void setHighlightDrawPos(Highlight high, Rect bar) {
    high.setDraw(bar.center.dy, bar.right);
  }

  @override
  bool isDrawingValuesAllowed(ChartInterface chart) {
    return chart.getData().getEntryCount() <
        chart.getMaxVisibleCount() * mViewPortHandler.getScaleY();
  }
}
