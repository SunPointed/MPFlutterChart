import 'dart:math';

import 'package:flutter/painting.dart';
import 'package:mp_flutter_chart/chart/mp/core/animator.dart';
import 'package:mp_flutter_chart/chart/mp/core/data/scatter_data.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_interfaces/i_scatter_data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_provider/scatter_data_provider.dart';
import 'package:mp_flutter_chart/chart/mp/core/entry/entry.dart';
import 'package:mp_flutter_chart/chart/mp/core/highlight/highlight.dart';
import 'package:mp_flutter_chart/chart/mp/core/render/i_shape_renderer.dart';
import 'package:mp_flutter_chart/chart/mp/core/render/line_scatter_candle_radar_renderer.dart';
import 'package:mp_flutter_chart/chart/mp/core/transformer/transformer.dart';
import 'package:mp_flutter_chart/chart/mp/core/utils/painter_utils.dart';
import 'package:mp_flutter_chart/chart/mp/core/value_formatter/value_formatter.dart';
import 'package:mp_flutter_chart/chart/mp/core/view_port.dart';
import 'package:mp_flutter_chart/chart/mp/core/poolable/point.dart';
import 'package:mp_flutter_chart/chart/mp/core/utils/utils.dart';

class ScatterChartRenderer extends LineScatterCandleRadarRenderer {
  ScatterDataProvider mChart;

  ScatterChartRenderer(ScatterDataProvider chart, ChartAnimator animator,
      ViewPortHandler viewPortHandler)
      : super(animator, viewPortHandler) {
    mChart = chart;
  }

  @override
  void initBuffers() {}

  @override
  void drawData(Canvas c) {
    ScatterData scatterData = mChart.getScatterData();

    for (IScatterDataSet set in scatterData.getDataSets()) {
      if (set.isVisible()) drawDataSet(c, set);
    }
  }

  List<double> mPixelBuffer = List(2);

  void drawDataSet(Canvas c, IScatterDataSet dataSet) {
    if (dataSet.getEntryCount() < 1) return;

    ViewPortHandler viewPortHandler = mViewPortHandler;

    Transformer trans = mChart.getTransformer(dataSet.getAxisDependency());

    double phaseY = mAnimator.getPhaseY();

    IShapeRenderer renderer = dataSet.getShapeRenderer();
    if (renderer == null) {
      return;
    }

    int max = (min((dataSet.getEntryCount() * mAnimator.getPhaseX()).ceil(),
        dataSet.getEntryCount()));

    for (int i = 0; i < max; i++) {
      Entry e = dataSet.getEntryForIndex(i);

      mPixelBuffer[0] = e.x;
      mPixelBuffer[1] = e.y * phaseY;

      trans.pointValuesToPixel(mPixelBuffer);

      if (!viewPortHandler.isInBoundsRight(mPixelBuffer[0])) break;

      if (!viewPortHandler.isInBoundsLeft(mPixelBuffer[0]) ||
          !viewPortHandler.isInBoundsY(mPixelBuffer[1])) continue;

      mRenderPaint.color = dataSet.getColor2(i ~/ 2);
      renderer.renderShape(c, dataSet, mViewPortHandler, mPixelBuffer[0],
          mPixelBuffer[1], mRenderPaint);
    }
  }

  @override
  void drawValues(Canvas c) {
    // if values are drawn
    if (isDrawingValuesAllowed(mChart)) {
      List<IScatterDataSet> dataSets = mChart.getScatterData().getDataSets();

      for (int i = 0; i < mChart.getScatterData().getDataSetCount(); i++) {
        IScatterDataSet dataSet = dataSets[i];

        if (!shouldDrawValues(dataSet) || dataSet.getEntryCount() < 1) continue;

        // apply the text-styling defined by the DataSet
        applyValueTextStyle(dataSet);

        mXBounds.set(mChart, dataSet);

        List<double> positions = mChart
            .getTransformer(dataSet.getAxisDependency())
            .generateTransformedValuesScatter(dataSet, mAnimator.getPhaseX(),
                mAnimator.getPhaseY(), mXBounds.min, mXBounds.max);

        double shapeSize =
            Utils.convertDpToPixel(dataSet.getScatterShapeSize());

        ValueFormatter formatter = dataSet.getValueFormatter();

        MPPointF iconsOffset = MPPointF.getInstance3(dataSet.getIconsOffset());
        iconsOffset.x = Utils.convertDpToPixel(iconsOffset.x);
        iconsOffset.y = Utils.convertDpToPixel(iconsOffset.y);

        for (int j = 0; j < positions.length; j += 2) {
          if (!mViewPortHandler.isInBoundsRight(positions[j])) break;

          // make sure the lines don't do shitty things outside bounds
          if ((!mViewPortHandler.isInBoundsLeft(positions[j]) ||
              !mViewPortHandler.isInBoundsY(positions[j + 1]))) continue;

          Entry entry = dataSet.getEntryForIndex(j ~/ 2 + mXBounds.min);

          if (dataSet.isDrawValuesEnabled()) {
            drawValue(
                c,
                formatter.getPointLabel(entry),
                positions[j],
                positions[j + 1] - shapeSize,
                dataSet.getValueTextColor2(j ~/ 2 + mXBounds.min));
          }

//          if (entry.getIcon() != null && dataSet.isDrawIconsEnabled()) {
//            Drawable icon = entry.getIcon();
//
//            Utils.drawImage(
//                c,
//                icon,
//                (int)(positions[j] + iconsOffset.x),
//                (int)(positions[j + 1] + iconsOffset.y),
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
  void drawExtras(Canvas c) {}

  @override
  void drawHighlighted(Canvas c, List<Highlight> indices) {
    ScatterData scatterData = mChart.getScatterData();

    for (Highlight high in indices) {
      IScatterDataSet set =
          scatterData.getDataSetByIndex(high.getDataSetIndex());

      if (set == null || !set.isHighlightEnabled()) continue;

      final Entry e = set.getEntryForXValue2(high.getX(), high.getY());

      if (!isInBoundsX(e, set)) continue;

      MPPointD pix = mChart
          .getTransformer(set.getAxisDependency())
          .getPixelForValues(e.x, e.y * mAnimator.getPhaseY());

      high.setDraw(pix.x, pix.y);

      // draw the lines
      drawHighlightLines(c, pix.x, pix.y, set);
    }
  }
}
