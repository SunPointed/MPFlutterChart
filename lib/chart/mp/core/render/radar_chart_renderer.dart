import 'package:flutter/painting.dart';
import 'package:mp_flutter_chart/chart/mp/core/animator.dart';
import 'package:mp_flutter_chart/chart/mp/core/data/radar_data.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_interfaces/i_radar_data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/entry/radar_entry.dart';
import 'package:mp_flutter_chart/chart/mp/core/highlight/highlight.dart';
import 'package:mp_flutter_chart/chart/mp/core/render/line_radar_renderer.dart';
import 'package:mp_flutter_chart/chart/mp/core/utils/canvas_utils.dart';
import 'package:mp_flutter_chart/chart/mp/core/utils/color_utils.dart';
import 'package:mp_flutter_chart/chart/mp/core/utils/painter_utils.dart';
import 'package:mp_flutter_chart/chart/mp/core/value_formatter/value_formatter.dart';
import 'package:mp_flutter_chart/chart/mp/core/view_port.dart';
import 'package:mp_flutter_chart/chart/mp/painter/radar_chart_painter.dart';
import 'package:mp_flutter_chart/chart/mp/core/poolable/point.dart';
import 'package:mp_flutter_chart/chart/mp/core/utils/utils.dart';

class RadarChartRenderer extends LineRadarRenderer {
  RadarChartPainter mChart;

  /// paint for drawing the web
  Paint mWebPaint;
  Paint mHighlightCirclePaint;

  RadarChartRenderer(RadarChartPainter chart, ChartAnimator animator,
      ViewPortHandler viewPortHandler)
      : super(animator, viewPortHandler) {
    mChart = chart;

    mHighlightCirclePaint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..strokeWidth = Utils.convertDpToPixel(2)
      ..color = Color.fromARGB(255, 255, 187, 115);

    mWebPaint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke;

    mHighlightCirclePaint = Paint()
      ..isAntiAlias = true
      ..style;
  }

  Paint getWebPaint() {
    return mWebPaint;
  }

  @override
  void initBuffers() {}

  @override
  void drawData(Canvas c) {
    RadarData radarData = mChart.getData();

    int mostEntries = radarData.getMaxEntryCountSet().getEntryCount();

    for (IRadarDataSet set in radarData.getDataSets()) {
      if (set.isVisible()) {
        drawDataSet(c, set, mostEntries);
      }
    }
  }

  Path mDrawDataSetSurfacePathBuffer = new Path();

  /// Draws the RadarDataSet
  ///
  /// @param c
  /// @param dataSet
  /// @param mostEntries the entry count of the dataset with the most entries
  void drawDataSet(Canvas c, IRadarDataSet dataSet, int mostEntries) {
    double phaseX = mAnimator.getPhaseX();
    double phaseY = mAnimator.getPhaseY();

    double sliceangle = mChart.getSliceAngle();

    // calculate the factor that is needed for transforming the value to
    // pixels
    double factor = mChart.getFactor();

    MPPointF center = mChart.getCenterOffsets();
    MPPointF pOut = MPPointF.getInstance1(0, 0);
    Path surface = mDrawDataSetSurfacePathBuffer;
    surface.reset();

    bool hasMovedToPoint = false;

    for (int j = 0; j < dataSet.getEntryCount(); j++) {
      mRenderPaint.color = dataSet.getColor2(j);

      RadarEntry e = dataSet.getEntryForIndex(j);

      Utils.getPosition(center, (e.y - mChart.getYChartMin()) * factor * phaseY,
          sliceangle * j * phaseX + mChart.getRotationAngle(), pOut);

      if (pOut.x.isNaN) continue;

      if (!hasMovedToPoint) {
        surface.moveTo(pOut.x, pOut.y);
        hasMovedToPoint = true;
      } else
        surface.lineTo(pOut.x, pOut.y);
    }

    if (dataSet.getEntryCount() > mostEntries) {
      // if this is not the largest set, draw a line to the center before closing
      surface.lineTo(center.x, center.y);
    }

    surface.close();

    if (dataSet.isDrawFilledEnabled()) {
//      final Drawable drawable = dataSet.getFillDrawable();
//      if (drawable != null) {
//
//        drawFilledPath(c, surface, drawable);
//      } else {

      drawFilledPath2(
          c, surface, dataSet.getFillColor().value, dataSet.getFillAlpha());
//      }
    }

    mRenderPaint
      ..strokeWidth = dataSet.getLineWidth()
      ..style = PaintingStyle.stroke;

    // draw the line (only if filled is disabled or alpha is below 255)
    if (!dataSet.isDrawFilledEnabled() || dataSet.getFillAlpha() < 255)
      c.drawPath(surface, mRenderPaint);

    MPPointF.recycleInstance(center);
    MPPointF.recycleInstance(pOut);
  }

  @override
  void drawValues(Canvas c) {
    double phaseX = mAnimator.getPhaseX();
    double phaseY = mAnimator.getPhaseY();

    double sliceangle = mChart.getSliceAngle();

    // calculate the factor that is needed for transforming the value to
    // pixels
    double factor = mChart.getFactor();

    MPPointF center = mChart.getCenterOffsets();
    MPPointF pOut = MPPointF.getInstance1(0, 0);
    MPPointF pIcon = MPPointF.getInstance1(0, 0);

    double yoffset = Utils.convertDpToPixel(5);

    for (int i = 0; i < mChart.getData().getDataSetCount(); i++) {
      IRadarDataSet dataSet = mChart.getData().getDataSetByIndex(i);

      if (!shouldDrawValues(dataSet)) continue;

      // apply the text-styling defined by the DataSet
      applyValueTextStyle(dataSet);

      ValueFormatter formatter = dataSet.getValueFormatter();

      MPPointF iconsOffset = MPPointF.getInstance3(dataSet.getIconsOffset());
      iconsOffset.x = Utils.convertDpToPixel(iconsOffset.x);
      iconsOffset.y = Utils.convertDpToPixel(iconsOffset.y);

      for (int j = 0; j < dataSet.getEntryCount(); j++) {
        RadarEntry entry = dataSet.getEntryForIndex(j);

        Utils.getPosition(
            center,
            (entry.y - mChart.getYChartMin()) * factor * phaseY,
            sliceangle * j * phaseX + mChart.getRotationAngle(),
            pOut);

        if (dataSet.isDrawValuesEnabled()) {
          drawValue(c, formatter.getRadarLabel(entry), pOut.x, pOut.y - yoffset,
              dataSet.getValueTextColor2(j));
        }

        if (entry.mIcon != null && dataSet.isDrawIconsEnabled()) {
          Utils.getPosition(center, entry.y * factor * phaseY + iconsOffset.y,
              sliceangle * j * phaseX + mChart.getRotationAngle(), pIcon);

          //noinspection SuspiciousNameCombination
          pIcon.y += iconsOffset.x;

          CanvasUtils.drawImage(c, Offset(pIcon.x, pIcon.y), entry.mIcon,
              Size(15, 15), mDrawPaint);
        }
      }

      MPPointF.recycleInstance(iconsOffset);
    }

    MPPointF.recycleInstance(center);
    MPPointF.recycleInstance(pOut);
    MPPointF.recycleInstance(pIcon);
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
  void drawExtras(Canvas c) {
    drawWeb(c);
  }

  void drawWeb(Canvas c) {
    double sliceangle = mChart.getSliceAngle();

    // calculate the factor that is needed for transforming the value to
    // pixels
    double factor = mChart.getFactor();
    double rotationangle = mChart.getRotationAngle();

    MPPointF center = mChart.getCenterOffsets();

    // draw the web lines that come from the center
    var color = mChart.getWebColor();
    mWebPaint
      ..strokeWidth = mChart.getWebLineWidth()
      ..color = Color.fromARGB(
          mChart.getWebAlpha(), color.red, color.green, color.blue);

    final int xIncrements = 1 + mChart.getSkipWebLineCount();
    int maxEntryCount = mChart.getData().getMaxEntryCountSet().getEntryCount();

    MPPointF p = MPPointF.getInstance1(0, 0);
    for (int i = 0; i < maxEntryCount; i += xIncrements) {
      Utils.getPosition(center, mChart.getYRange() * factor,
          sliceangle * i + rotationangle, p);

      c.drawLine(Offset(center.x, center.y), Offset(p.x, p.y), mWebPaint);
    }
    MPPointF.recycleInstance(p);

    // draw the inner-web
    color = mChart.getWebColorInner();
    mWebPaint
      ..strokeWidth = mChart.getWebLineWidthInner()
      ..color = Color.fromARGB(
          mChart.getWebAlpha(), color.red, color.green, color.blue);

    int labelCount = mChart.getYAxis().mEntryCount;

    MPPointF p1out = MPPointF.getInstance1(0, 0);
    MPPointF p2out = MPPointF.getInstance1(0, 0);
    for (int j = 0; j < labelCount; j++) {
      for (int i = 0; i < mChart.getData().getEntryCount(); i++) {
        double r =
            (mChart.getYAxis().mEntries[j] - mChart.getYChartMin()) * factor;

        Utils.getPosition(center, r, sliceangle * i + rotationangle, p1out);
        Utils.getPosition(
            center, r, sliceangle * (i + 1) + rotationangle, p2out);

        c.drawLine(
            Offset(p1out.x, p1out.y), Offset(p2out.x, p2out.y), mWebPaint);
      }
    }
    MPPointF.recycleInstance(p1out);
    MPPointF.recycleInstance(p2out);
  }

  @override
  void drawHighlighted(Canvas c, List<Highlight> indices) {
    double sliceangle = mChart.getSliceAngle();

    // calculate the factor that is needed for transforming the value to
    // pixels
    double factor = mChart.getFactor();

    MPPointF center = mChart.getCenterOffsets();
    MPPointF pOut = MPPointF.getInstance1(0, 0);

    RadarData radarData = mChart.getData();

    for (Highlight high in indices) {
      IRadarDataSet set = radarData.getDataSetByIndex(high.getDataSetIndex());

      if (set == null || !set.isHighlightEnabled()) continue;

      RadarEntry e = set.getEntryForIndex(high.getX().toInt());

      if (!isInBoundsX(e, set)) continue;

      double y = (e.y - mChart.getYChartMin());

      Utils.getPosition(
          center,
          y * factor * mAnimator.getPhaseY(),
          sliceangle * high.getX() * mAnimator.getPhaseX() +
              mChart.getRotationAngle(),
          pOut);

      high.setDraw(pOut.x, pOut.y);

      // draw the lines
      drawHighlightLines(c, pOut.x, pOut.y, set);

      if (set.isDrawHighlightCircleEnabled()) {
        if (!pOut.x.isNaN && !pOut.y.isNaN) {
          Color strokeColor = set.getHighlightCircleStrokeColor();
          if (strokeColor == ColorUtils.COLOR_NONE) {
            strokeColor = set.getColor2(0);
          }

          if (set.getHighlightCircleStrokeAlpha() < 255) {
            strokeColor = ColorUtils.colorWithAlpha(
                strokeColor, set.getHighlightCircleStrokeAlpha());
          }

          drawHighlightCircle(
              c,
              pOut,
              set.getHighlightCircleInnerRadius(),
              set.getHighlightCircleOuterRadius(),
              set.getHighlightCircleFillColor(),
              strokeColor,
              set.getHighlightCircleStrokeWidth());
        }
      }
    }

    MPPointF.recycleInstance(center);
    MPPointF.recycleInstance(pOut);
  }

  Path mDrawHighlightCirclePathBuffer = new Path();

  void drawHighlightCircle(
      Canvas c,
      MPPointF point,
      double innerRadius,
      double outerRadius,
      Color fillColor,
      Color strokeColor,
      double strokeWidth) {
    c.save();

    outerRadius = Utils.convertDpToPixel(outerRadius);
    innerRadius = Utils.convertDpToPixel(innerRadius);

    if (fillColor != ColorUtils.COLOR_NONE) {
      Path p = mDrawHighlightCirclePathBuffer;
      p.reset();
      p.addOval(Rect.fromLTRB(point.x - outerRadius, point.y - outerRadius,
          point.x + outerRadius, point.y + outerRadius));
//      p.addCircle(point.x, point.y, outerRadius, Path.Direction.CW);
      if (innerRadius > 0.0) {
        p.addOval(Rect.fromLTRB(point.x - innerRadius, point.y - innerRadius,
            point.x + innerRadius, point.y + innerRadius));
//        p.addCircle(point.x, point.y, innerRadius, Path.Direction.CCW);
      }
      mHighlightCirclePaint
        ..color = fillColor
        ..style = PaintingStyle.fill;
      c.drawPath(p, mHighlightCirclePaint);
    }

    if (strokeColor != ColorUtils.COLOR_NONE) {
      mHighlightCirclePaint
        ..color = strokeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = Utils.convertDpToPixel(strokeWidth);
      c.drawCircle(
          Offset(point.x, point.y), outerRadius, mHighlightCirclePaint);
    }

    c.restore();
  }
}
