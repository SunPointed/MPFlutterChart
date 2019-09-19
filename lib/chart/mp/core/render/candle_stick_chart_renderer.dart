import 'package:flutter/painting.dart';
import 'package:mp_flutter_chart/chart/mp/core/animator.dart';
import 'package:mp_flutter_chart/chart/mp/core/data/candle_data.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_interfaces/i_candle_data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_provider/candle_data_provider.dart';
import 'package:mp_flutter_chart/chart/mp/core/entry/candle_entry.dart';
import 'package:mp_flutter_chart/chart/mp/core/highlight/highlight.dart';
import 'package:mp_flutter_chart/chart/mp/core/render/line_scatter_candle_radar_renderer.dart';
import 'package:mp_flutter_chart/chart/mp/core/transformer/transformer.dart';
import 'package:mp_flutter_chart/chart/mp/core/utils/canvas_utils.dart';
import 'package:mp_flutter_chart/chart/mp/core/utils/color_utils.dart';
import 'package:mp_flutter_chart/chart/mp/core/utils/painter_utils.dart';
import 'package:mp_flutter_chart/chart/mp/core/value_formatter/value_formatter.dart';
import 'package:mp_flutter_chart/chart/mp/core/view_port.dart';
import 'package:mp_flutter_chart/chart/mp/core/poolable/point.dart';
import 'package:mp_flutter_chart/chart/mp/core/utils/utils.dart';

class CandleStickChartRenderer extends LineScatterCandleRadarRenderer {
  CandleDataProvider mChart;

  List<double> mShadowBuffers = List(8);
  List<double> mBodyBuffers = List(4);
  List<double> mRangeBuffers = List(4);
  List<double> mOpenBuffers = List(4);
  List<double> mCloseBuffers = List(4);

  CandleStickChartRenderer(CandleDataProvider chart, ChartAnimator animator,
      ViewPortHandler viewPortHandler)
      : super(animator, viewPortHandler) {
    mChart = chart;
  }

  @override
  void initBuffers() {}

  @override
  void drawData(Canvas c) {
    CandleData candleData = mChart.getCandleData();

    for (ICandleDataSet set in candleData.getDataSets()) {
      if (set.isVisible()) drawDataSet(c, set);
    }
  }

  void drawDataSet(Canvas c, ICandleDataSet dataSet) {
    Transformer trans = mChart.getTransformer(dataSet.getAxisDependency());

    double phaseY = mAnimator.getPhaseY();
    double barSpace = dataSet.getBarSpace();
    bool showCandleBar = dataSet.getShowCandleBar();

    mXBounds.set(mChart, dataSet);

    mRenderPaint.strokeWidth = dataSet.getShadowWidth();

    // draw the body
    for (int j = mXBounds.min; j <= mXBounds.range + mXBounds.min; j++) {
      // get the entry
      CandleEntry e = dataSet.getEntryForIndex(j);

      if (e == null) continue;

      final double xPos = e.x;

      final double open = e.getOpen();
      final double close = e.getClose();
      final double high = e.getHigh();
      final double low = e.getLow();

      if (showCandleBar) {
        // calculate the shadow

        mShadowBuffers[0] = xPos;
        mShadowBuffers[2] = xPos;
        mShadowBuffers[4] = xPos;
        mShadowBuffers[6] = xPos;

        if (open > close) {
          mShadowBuffers[1] = high * phaseY;
          mShadowBuffers[3] = open * phaseY;
          mShadowBuffers[5] = low * phaseY;
          mShadowBuffers[7] = close * phaseY;
        } else if (open < close) {
          mShadowBuffers[1] = high * phaseY;
          mShadowBuffers[3] = close * phaseY;
          mShadowBuffers[5] = low * phaseY;
          mShadowBuffers[7] = open * phaseY;
        } else {
          mShadowBuffers[1] = high * phaseY;
          mShadowBuffers[3] = open * phaseY;
          mShadowBuffers[5] = low * phaseY;
          mShadowBuffers[7] = mShadowBuffers[3];
        }

        trans.pointValuesToPixel(mShadowBuffers);

        // draw the shadows

        if (dataSet.getShadowColorSameAsCandle()) {
          if (open > close)
            mRenderPaint.color =
            dataSet.getDecreasingColor() == ColorUtils.COLOR_NONE
                ? dataSet.getColor2(j)
                : dataSet.getDecreasingColor();
          else if (open < close)
            mRenderPaint.color =
            dataSet.getIncreasingColor() == ColorUtils.COLOR_NONE
                ? dataSet.getColor2(j)
                : dataSet.getIncreasingColor();
          else
            mRenderPaint.color =
            dataSet.getNeutralColor() == ColorUtils.COLOR_NONE
                ? dataSet.getColor2(j)
                : dataSet.getNeutralColor();
        } else {
          mRenderPaint.color = dataSet.getShadowColor() == ColorUtils.COLOR_NONE
              ? dataSet.getColor2(j)
              : dataSet.getShadowColor();
        }

        mRenderPaint.style = PaintingStyle.stroke;

        CanvasUtils.drawLines(
            c, mShadowBuffers, 0, mShadowBuffers.length, mRenderPaint);

        // calculate the body

        mBodyBuffers[0] = xPos - 0.5 + barSpace;
        mBodyBuffers[1] = close * phaseY;
        mBodyBuffers[2] = (xPos + 0.5 - barSpace);
        mBodyBuffers[3] = open * phaseY;

        trans.pointValuesToPixel(mBodyBuffers);

        // draw body differently for increasing and decreasing entry
        if (open > close) {
          // decreasing

          if (dataSet.getDecreasingColor() == ColorUtils.COLOR_NONE) {
            mRenderPaint.color = dataSet.getColor2(j);
          } else {
            mRenderPaint.color = dataSet.getDecreasingColor();
          }

          mRenderPaint.style = PaintingStyle.fill;

          c.drawRect(
              Rect.fromLTRB(mBodyBuffers[0], mBodyBuffers[3], mBodyBuffers[2],
                  mBodyBuffers[1]),
              mRenderPaint);
        } else if (open < close) {
          if (dataSet.getIncreasingColor() == ColorUtils.COLOR_NONE) {
            mRenderPaint.color = dataSet.getColor2(j);
          } else {
            mRenderPaint.color = dataSet.getIncreasingColor();
          }

          mRenderPaint.style = PaintingStyle.fill;

          c.drawRect(
              Rect.fromLTRB(mBodyBuffers[0], mBodyBuffers[1], mBodyBuffers[2],
                  mBodyBuffers[3]),
              mRenderPaint);
        } else {
          // equal values

          if (dataSet.getNeutralColor() == ColorUtils.COLOR_NONE) {
            mRenderPaint.color = dataSet.getColor2(j);
          } else {
            mRenderPaint.color = dataSet.getNeutralColor();
          }

          c.drawLine(Offset(mBodyBuffers[0], mBodyBuffers[1]),
              Offset(mBodyBuffers[2], mBodyBuffers[3]), mRenderPaint);
        }
      } else {
        mRangeBuffers[0] = xPos;
        mRangeBuffers[1] = high * phaseY;
        mRangeBuffers[2] = xPos;
        mRangeBuffers[3] = low * phaseY;

        mOpenBuffers[0] = xPos - 0.5 + barSpace;
        mOpenBuffers[1] = open * phaseY;
        mOpenBuffers[2] = xPos;
        mOpenBuffers[3] = open * phaseY;

        mCloseBuffers[0] = xPos + 0.5 - barSpace;
        mCloseBuffers[1] = close * phaseY;
        mCloseBuffers[2] = xPos;
        mCloseBuffers[3] = close * phaseY;

        trans.pointValuesToPixel(mRangeBuffers);
        trans.pointValuesToPixel(mOpenBuffers);
        trans.pointValuesToPixel(mCloseBuffers);

        // draw the ranges
        Color barColor;

        if (open > close)
          barColor = dataSet.getDecreasingColor() == ColorUtils.COLOR_NONE
              ? dataSet.getColor2(j)
              : dataSet.getDecreasingColor();
        else if (open < close)
          barColor = dataSet.getIncreasingColor() == ColorUtils.COLOR_NONE
              ? dataSet.getColor2(j)
              : dataSet.getIncreasingColor();
        else
          barColor = dataSet.getNeutralColor() == ColorUtils.COLOR_NONE
              ? dataSet.getColor2(j)
              : dataSet.getNeutralColor();

        mRenderPaint.color = barColor;
        c.drawLine(Offset(mRangeBuffers[0], mRangeBuffers[1]),
            Offset(mRangeBuffers[2], mRangeBuffers[3]), mRenderPaint);
        c.drawLine(Offset(mOpenBuffers[0], mOpenBuffers[1]),
            Offset(mOpenBuffers[2], mOpenBuffers[3]), mRenderPaint);
        c.drawLine(Offset(mCloseBuffers[0], mCloseBuffers[1]),
            Offset(mCloseBuffers[2], mCloseBuffers[3]), mRenderPaint);
      }
    }
  }

  @override
  void drawValues(Canvas c) {
    // if values are drawn
    if (isDrawingValuesAllowed(mChart)) {
      List<ICandleDataSet> dataSets = mChart.getCandleData().getDataSets();

      for (int i = 0; i < dataSets.length; i++) {
        ICandleDataSet dataSet = dataSets[i];

        if (!shouldDrawValues(dataSet) || dataSet.getEntryCount() < 1) continue;

        // apply the text-styling defined by the DataSet
        applyValueTextStyle(dataSet);

        Transformer trans = mChart.getTransformer(dataSet.getAxisDependency());

        mXBounds.set(mChart, dataSet);

        List<double> positions = trans.generateTransformedValuesCandle(
            dataSet,
            mAnimator.getPhaseX(),
            mAnimator.getPhaseY(),
            mXBounds.min,
            mXBounds.max);

        double yOffset = Utils.convertDpToPixel(5);

        ValueFormatter formatter = dataSet.getValueFormatter();

        MPPointF iconsOffset = MPPointF.getInstance3(dataSet.getIconsOffset());
        iconsOffset.x = Utils.convertDpToPixel(iconsOffset.x);
        iconsOffset.y = Utils.convertDpToPixel(iconsOffset.y);

        for (int j = 0; j < positions.length; j += 2) {
          double x = positions[j];
          double y = positions[j + 1];

          if (!mViewPortHandler.isInBoundsRight(x)) break;

          if (!mViewPortHandler.isInBoundsLeft(x) ||
              !mViewPortHandler.isInBoundsY(y)) continue;

          CandleEntry entry = dataSet.getEntryForIndex(j ~/ 2 + mXBounds.min);

          if (dataSet.isDrawValuesEnabled()) {
            drawValue(c, formatter.getCandleLabel(entry), x, y - yOffset,
                dataSet.getValueTextColor2(j ~/ 2));
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

        MPPointF.recycleInstance(iconsOffset);
      }
    }
  }

  @override
  void drawValue(Canvas c, String valueText, double x, double y, Color color) {
    mValuePaint = PainterUtils.create(
        mValuePaint, valueText, color, mValuePaint.text.style.fontSize == null
        ? Utils.convertDpToPixel(9)
        : mValuePaint.text.style.fontSize);
    mValuePaint.layout();
    mValuePaint.paint(
        c, Offset(x - mValuePaint.width / 2, y - mValuePaint.height));
  }

  @override
  void drawExtras(Canvas c) {}

  @override
  void drawHighlighted(Canvas c, List<Highlight> indices) {
    CandleData candleData = mChart.getCandleData();

    for (Highlight high in indices) {
      ICandleDataSet set = candleData.getDataSetByIndex(high.getDataSetIndex());

      if (set == null || !set.isHighlightEnabled()) continue;

      CandleEntry e = set.getEntryForXValue2(high.getX(), high.getY());

      if (!isInBoundsX(e, set)) continue;

      double lowValue = e.getLow() * mAnimator.getPhaseY();
      double highValue = e.getHigh() * mAnimator.getPhaseY();
      double y = (lowValue + highValue) / 2;

      MPPointD pix = mChart
          .getTransformer(set.getAxisDependency())
          .getPixelForValues(e.x, y);

      high.setDraw(pix.x, pix.y);

      // draw the lines
      drawHighlightLines(c, pix.x, pix.y, set);
    }
  }
}
