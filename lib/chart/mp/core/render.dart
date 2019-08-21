import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/rendering.dart';
import 'package:mp_flutter_chart/chart/mp/cache.dart';
import 'package:mp_flutter_chart/chart/mp/core/animator.dart';
import 'package:mp_flutter_chart/chart/mp/core/axis.dart';
import 'package:mp_flutter_chart/chart/mp/bounds.dart';
import 'package:mp_flutter_chart/chart/mp/color.dart';
import 'package:mp_flutter_chart/chart/mp/core/buffer.dart';
import 'package:mp_flutter_chart/chart/mp/core/data.dart';
import 'package:mp_flutter_chart/chart/mp/core/format.dart';
import 'package:mp_flutter_chart/chart/mp/core/highlight.dart';
import 'package:mp_flutter_chart/chart/mp/core/interfaces.dart';
import 'package:mp_flutter_chart/chart/mp/core/legend.dart';
import 'package:mp_flutter_chart/chart/mp/core/limit.dart';
import 'package:mp_flutter_chart/chart/mp/core/range.dart';
import 'package:mp_flutter_chart/chart/mp/mode.dart';
import 'package:mp_flutter_chart/chart/mp/painter/pie_chart_painter.dart';
import 'package:mp_flutter_chart/chart/mp/poolable/point.dart';
import 'package:mp_flutter_chart/chart/mp/poolable/size.dart';
import 'package:mp_flutter_chart/chart/mp/core/transformer.dart';
import 'package:mp_flutter_chart/chart/mp/util.dart';
import 'package:mp_flutter_chart/chart/mp/core/view_port.dart';

abstract class Renderer {
  /**
   * the component that handles the drawing area of the chart and it's offsets
   */
  ViewPortHandler mViewPortHandler;

  Renderer(this.mViewPortHandler);
}

class LegendRenderer extends Renderer {
  /**
   * paint for the legend labels
   */
  TextPainter mLegendLabelPaint;

  /**
   * paint used for the legend forms
   */
  Paint mLegendFormPaint;

  /**
   * the legend object this renderer renders
   */
  Legend mLegend;

  LegendRenderer(ViewPortHandler viewPortHandler, Legend legend)
      : super(viewPortHandler) {
    this.mLegend = legend;

    mLegendLabelPaint = TextPainter(
        text: TextSpan(
            style: TextStyle(
                color: ColorUtils.BLACK, fontSize: Utils.convertDpToPixel(9))),
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr);

    mLegendFormPaint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.fill;
  }

  /**
   * Returns the Paint object used for drawing the Legend labels.
   *
   * @return
   */
  TextPainter getLabelPaint() {
    return mLegendLabelPaint;
  }

  /**
   * Returns the Paint object used for drawing the Legend forms.
   *
   * @return
   */
  Paint getFormPaint() {
    return mLegendFormPaint;
  }

  List<LegendEntry> computedEntries = List(16);

  /**
   * Prepares the legend and calculates all needed forms, labels and colors.
   *
   * @param data
   */
  void computeLegend(ChartData<IDataSet> data) {
    if (!mLegend.isLegendCustom()) {
      computedEntries = List();

      // loop for building up the colors and labels used in the legend
      for (int i = 0; i < data.getDataSetCount(); i++) {
        IDataSet dataSet = data.getDataSetByIndex(i);

        List<Color> clrs = dataSet.getColors();
        int entryCount = dataSet.getEntryCount();

        if (dataSet is IBarDataSet && (dataSet as IBarDataSet).isStacked()) {
          IBarDataSet bds = dataSet as IBarDataSet;
          List<String> sLabels = bds.getStackLabels();

          for (int j = 0; j < clrs.length && j < bds.getStackSize(); j++) {
            computedEntries.add(LegendEntry(
                sLabels[j % sLabels.length],
                dataSet.getForm(),
                dataSet.getFormSize(),
                dataSet.getFormLineWidth(),
//  dataSet.getFormLineDashEffect(),
                clrs[j]));
          }

          if (bds.getLabel() != null) {
            // add the legend description label
            computedEntries.add(LegendEntry(
                dataSet.getLabel(),
                LegendForm.NONE,
                double.nan,
                double.nan,
//  null,
                ColorTemplate.COLOR_NONE));
          }
        } else if (dataSet is IPieDataSet) {
          IPieDataSet pds = dataSet as IPieDataSet;

          for (int j = 0; j < clrs.length && j < entryCount; j++) {
            computedEntries.add(LegendEntry(
                pds.getEntryForIndex(j).label,
                dataSet.getForm(),
                dataSet.getFormSize(),
                dataSet.getFormLineWidth(),
//  dataSet.getFormLineDashEffect(),
                clrs[j]));
          }

          if (pds.getLabel() != null) {
            // add the legend description label
            computedEntries.add(LegendEntry(
                dataSet.getLabel(),
                LegendForm.NONE,
                double.nan,
                double.nan,
//  null,
                ColorTemplate.COLOR_NONE));
          }
//        } else if (dataSet is ICandleDataSet &&
//            (dataSet as ICandleDataSet).getDecreasingColor() !=
//                ColorTemplate.COLOR_NONE) {
//          Color decreasingColor =
//              (dataSet as ICandleDataSet).getDecreasingColor();
//          Color increasingColor =
//              (dataSet as ICandleDataSet).getIncreasingColor();
//
//          computedEntries.add( LegendEntry(
//              null,
//              dataSet.getForm(),
//              dataSet.getFormSize(),
//              dataSet.getFormLineWidth(),
////  dataSet.getFormLineDashEffect(),
//              decreasingColor));
//
//          computedEntries.add( LegendEntry(
//              dataSet.getLabel(),
//              dataSet.getForm(),
//              dataSet.getFormSize(),
//              dataSet.getFormLineWidth(),
////  dataSet.getFormLineDashEffect(),
//              increasingColor));
        } else {
          // all others

          for (int j = 0; j < clrs.length && j < entryCount; j++) {
            String label;

            // if multiple colors are set for a DataSet, group them
            if (j < clrs.length - 1 && j < entryCount - 1) {
              label = null;
            } else {
              // add label to the last entry
              label = data.getDataSetByIndex(i).getLabel();
            }

            computedEntries.add(LegendEntry(
                label,
                dataSet.getForm(),
                dataSet.getFormSize(),
                dataSet.getFormLineWidth(),
//  dataSet.getFormLineDashEffect(),
                clrs[j]));
          }
        }
      }

      if (mLegend.getExtraEntries() != null) {
        computedEntries.addAll(mLegend.getExtraEntries());
      }

      mLegend.setEntries(computedEntries);
    }

    mLegendLabelPaint = TextPainter(
        text: TextSpan(style: getStyle()),
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr);

    // calculate all dimensions of the mLegend
    mLegend.calculateDimensions(mLegendLabelPaint, mViewPortHandler);
  }

  // todo Paint.FontMetrics legendFontMetrics =  Paint.FontMetrics();

  TextStyle getStyle() {
    return mLegend.getTypeface() != null
        ? mLegend.getTypeface()
        : mLegendLabelPaint.text.style;
  }

  void renderLegend(Canvas c) {
    if (!mLegend.isEnabled()) return;

    mLegendLabelPaint = TextPainter(
        text: TextSpan(style: getStyle()),
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr);

    double labelLineHeight = Utils.getLineHeight1(mLegendLabelPaint);
    double labelLineSpacing = Utils.getLineSpacing1(mLegendLabelPaint) +
        Utils.convertDpToPixel(mLegend.getYEntrySpace());
    double formYOffset =
        labelLineHeight - Utils.calcTextHeight(mLegendLabelPaint, "ABC") / 2;

    List<LegendEntry> entries = mLegend.getEntries();

    double formToTextSpace =
        Utils.convertDpToPixel(mLegend.getFormToTextSpace());
    double xEntrySpace = Utils.convertDpToPixel(mLegend.getXEntrySpace());
    LegendOrientation orientation = mLegend.getOrientation();
    LegendHorizontalAlignment horizontalAlignment =
        mLegend.getHorizontalAlignment();
    LegendVerticalAlignment verticalAlignment = mLegend.getVerticalAlignment();
    LegendDirection direction = mLegend.getDirection();
    double defaultFormSize = Utils.convertDpToPixel(mLegend.getFormSize());

    // space between the entries
    double stackSpace = Utils.convertDpToPixel(mLegend.getStackSpace());

    double yoffset = mLegend.getYOffset();
    double xoffset = mLegend.getXOffset();
    double originPosX = 0;

    switch (horizontalAlignment) {
      case LegendHorizontalAlignment.LEFT:
        if (orientation == LegendOrientation.VERTICAL)
          originPosX = xoffset;
        else
          originPosX = mViewPortHandler.contentLeft() + xoffset;

        if (direction == LegendDirection.RIGHT_TO_LEFT)
          originPosX += mLegend.mNeededWidth;

        break;

      case LegendHorizontalAlignment.RIGHT:
        if (orientation == LegendOrientation.VERTICAL)
          originPosX = mViewPortHandler.getChartWidth() - xoffset;
        else
          originPosX = mViewPortHandler.contentRight() - xoffset;

        if (direction == LegendDirection.LEFT_TO_RIGHT)
          originPosX -= mLegend.mNeededWidth;

        break;

      case LegendHorizontalAlignment.CENTER:
        if (orientation == LegendOrientation.VERTICAL)
          originPosX = mViewPortHandler.getChartWidth() / 2;
        else
          originPosX = mViewPortHandler.contentLeft() +
              mViewPortHandler.contentWidth() / 2;

        originPosX +=
            (direction == LegendDirection.LEFT_TO_RIGHT ? xoffset : -xoffset);

        // Horizontally layed out legends do the center offset on a line basis,
        // So here we offset the vertical ones only.
        if (orientation == LegendOrientation.VERTICAL) {
          originPosX += (direction == LegendDirection.LEFT_TO_RIGHT
              ? -mLegend.mNeededWidth / 2.0 + xoffset
              : mLegend.mNeededWidth / 2.0 - xoffset);
        }

        break;
    }

    switch (orientation) {
      case LegendOrientation.HORIZONTAL:
        {
          List<FSize> calculatedLineSizes = mLegend.getCalculatedLineSizes();
          List<FSize> calculatedLabelSizes = mLegend.getCalculatedLabelSizes();
          List<bool> calculatedLabelBreakPoints =
              mLegend.getCalculatedLabelBreakPoints();

          double posX = originPosX;
          double posY = 0;

          switch (verticalAlignment) {
            case LegendVerticalAlignment.TOP:
              posY = yoffset;
              break;

            case LegendVerticalAlignment.BOTTOM:
              posY = mViewPortHandler.getChartHeight() -
                  yoffset -
                  mLegend.mNeededHeight;
              break;

            case LegendVerticalAlignment.CENTER:
              posY =
                  (mViewPortHandler.getChartHeight() - mLegend.mNeededHeight) /
                          2 +
                      yoffset;
              break;
          }

          int lineIndex = 0;

          for (int i = 0, count = entries.length; i < count; i++) {
            LegendEntry e = entries[i];
            bool drawingForm = e.form != LegendForm.NONE;
            double formSize = e.formSize.isNaN
                ? defaultFormSize
                : Utils.convertDpToPixel(e.formSize);

            if (i < calculatedLabelBreakPoints.length &&
                calculatedLabelBreakPoints[i]) {
              posX = originPosX;
              posY += labelLineHeight + labelLineSpacing;
            }

            if (posX == originPosX &&
                horizontalAlignment == LegendHorizontalAlignment.CENTER &&
                lineIndex < calculatedLineSizes.length) {
              posX += (direction == LegendDirection.RIGHT_TO_LEFT
                      ? calculatedLineSizes[lineIndex].width
                      : -calculatedLineSizes[lineIndex].width) /
                  2;
              lineIndex++;
            }

            bool isStacked = e.label == null; // grouped forms have null labels

            if (drawingForm) {
              if (direction == LegendDirection.RIGHT_TO_LEFT) posX -= formSize;

              drawForm(c, posX, posY + formYOffset, e, mLegend);

              if (direction == LegendDirection.LEFT_TO_RIGHT) posX += formSize;
            }

            if (!isStacked) {
              if (drawingForm)
                posX += direction == LegendDirection.RIGHT_TO_LEFT
                    ? -formToTextSpace
                    : formToTextSpace;

              if (direction == LegendDirection.RIGHT_TO_LEFT)
                posX -= calculatedLabelSizes[i].width;

              drawLabel(c, posX, posY + labelLineHeight, e.label);

              if (direction == LegendDirection.LEFT_TO_RIGHT)
                posX += calculatedLabelSizes[i].width;

              posX += direction == LegendDirection.RIGHT_TO_LEFT
                  ? -xEntrySpace
                  : xEntrySpace;
            } else
              posX += direction == LegendDirection.RIGHT_TO_LEFT
                  ? -stackSpace
                  : stackSpace;
          }

          break;
        }

      case LegendOrientation.VERTICAL:
        {
          // contains the stacked legend size in pixels
          double stack = 0;
          bool wasStacked = false;
          double posY = 0;

          switch (verticalAlignment) {
            case LegendVerticalAlignment.TOP:
              posY = (horizontalAlignment == LegendHorizontalAlignment.CENTER
                  ? 0
                  : mViewPortHandler.contentTop());
              posY += yoffset;
              break;

            case LegendVerticalAlignment.BOTTOM:
              posY = (horizontalAlignment == LegendHorizontalAlignment.CENTER
                  ? mViewPortHandler.getChartHeight()
                  : mViewPortHandler.contentBottom());
              posY -= mLegend.mNeededHeight + yoffset;
              break;

            case LegendVerticalAlignment.CENTER:
              posY = mViewPortHandler.getChartHeight() / 2 -
                  mLegend.mNeededHeight / 2 +
                  mLegend.getYOffset();
              break;
          }

          for (int i = 0; i < entries.length; i++) {
            LegendEntry e = entries[i];
            bool drawingForm = e.form != LegendForm.NONE;
            double formSize = e.formSize.isNaN
                ? defaultFormSize
                : Utils.convertDpToPixel(e.formSize);

            double posX = originPosX;

            if (drawingForm) {
              if (direction == LegendDirection.LEFT_TO_RIGHT)
                posX += stack;
              else
                posX -= formSize - stack;

              drawForm(c, posX, posY + formYOffset, e, mLegend);

              if (direction == LegendDirection.LEFT_TO_RIGHT) posX += formSize;
            }

            if (e.label != null) {
              if (drawingForm && !wasStacked)
                posX += direction == LegendDirection.LEFT_TO_RIGHT
                    ? formToTextSpace
                    : -formToTextSpace;
              else if (wasStacked) posX = originPosX;

              if (direction == LegendDirection.RIGHT_TO_LEFT)
                posX -= Utils.calcTextWidth(mLegendLabelPaint, e.label);

              if (!wasStacked) {
                drawLabel(c, posX, posY + labelLineHeight, e.label);
              } else {
                posY += labelLineHeight + labelLineSpacing;
                drawLabel(c, posX, posY + labelLineHeight, e.label);
              }

              // make a step down
              posY += labelLineHeight + labelLineSpacing;
              stack = 0;
            } else {
              stack += formSize + stackSpace;
              wasStacked = true;
            }
          }
          break;
        }
    }
  }

  Path mLineFormPath = Path();

  /**
   * Draws the Legend-form at the given position with the color at the given
   * index.
   *
   * @param c      canvas to draw with
   * @param x      position
   * @param y      position
   * @param entry  the entry to render
   * @param legend the legend context
   */
  void drawForm(
      Canvas c, double x, double y, LegendEntry entry, Legend legend) {
    if (entry.formColor == ColorTemplate.COLOR_SKIP ||
        entry.formColor == ColorTemplate.COLOR_NONE) return;

    c.save();

    LegendForm form = entry.form;
    if (form == LegendForm.DEFAULT) form = legend.getForm();

    final double formSize = Utils.convertDpToPixel(
        entry.formSize.isNaN ? legend.getFormSize() : entry.formSize);
    final double half = formSize / 2;

    switch (form) {
      case LegendForm.NONE:
        // Do nothing
        break;

      case LegendForm.EMPTY:
        // Do not draw, but keep space for the form
        break;

      case LegendForm.DEFAULT:
      case LegendForm.CIRCLE:
        mLegendFormPaint = Paint()
          ..isAntiAlias = true
          ..color = entry.formColor
          ..style = PaintingStyle.fill;
        c.drawCircle(Offset(x + half, y), half, mLegendFormPaint);
        break;

      case LegendForm.SQUARE:
        mLegendFormPaint = Paint()
          ..isAntiAlias = true
          ..color = entry.formColor
          ..style = PaintingStyle.fill;
        c.drawRect(Rect.fromLTRB(x, y - half, x + formSize, y + half),
            mLegendFormPaint);
        break;

      case LegendForm.LINE:
        {
          final double formLineWidth = Utils.convertDpToPixel(
              entry.formLineWidth.isNaN
                  ? legend.getFormLineWidth()
                  : entry.formLineWidth);
//          final DashPathEffect formLineDashEffect =
//              entry.formLineDashEffect == null
//                  ? legend.getFormLineDashEffect()
//                  : entry.formLineDashEffect;
          mLegendFormPaint = Paint()
            ..isAntiAlias = true
            ..color = entry.formColor
            ..style = PaintingStyle.stroke
            ..strokeWidth = formLineWidth;
          mLineFormPath.reset();
          mLineFormPath.moveTo(x, y);
          mLineFormPath.lineTo(x + formSize, y);
          c.drawPath(mLineFormPath, mLegendFormPaint);
        }
        break;
    }
    c.restore();
  }

  void drawLabel(Canvas c, double x, double y, String label) {
    mLegendLabelPaint.text =
        TextSpan(text: label, style: mLegendLabelPaint.text.style);
    mLegendLabelPaint.layout();
    mLegendLabelPaint.paint(c, Offset(x, y - mLegendLabelPaint.height));
  }
}

abstract class DataRenderer extends Renderer {
  /**
   * the animator object used to perform animations on the chart data
   */
  ChartAnimator mAnimator;

  /**
   * main paint object used for rendering
   */
  Paint mRenderPaint;

  /**
   * paint used for highlighting values
   */
  Paint mHighlightPaint;

  Paint mDrawPaint;

  TextPainter mValuePaint;

  DataRenderer(ChartAnimator animator, ViewPortHandler viewPortHandler)
      : super(viewPortHandler) {
    this.mAnimator = animator;

    mRenderPaint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.fill;

    mDrawPaint = Paint();

    mValuePaint = TextPainter(
        text: TextSpan(
            style: TextStyle(
                color: Color.fromARGB(255, 63, 63, 63),
                fontSize: Utils.convertDpToPixel(9))),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center);

    mHighlightPaint = Paint()
      ..isAntiAlias = true
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..color = Color.fromARGB(255, 255, 187, 115);
  }

  bool isDrawingValuesAllowed(ChartInterface chart) {
    return chart.getData().getEntryCount() <
        chart.getMaxVisibleCount() * mViewPortHandler.getScaleX();
  }

  /**
   * Returns the Paint object this renderer uses for drawing the values
   * (value-text).
   *
   * @return
   */
  TextPainter getPaintValues() {
    return mValuePaint;
  }

  /**
   * Returns the Paint object this renderer uses for drawing highlight
   * indicators.
   *
   * @return
   */
  Paint getPaintHighlight() {
    return mHighlightPaint;
  }

  /**
   * Returns the Paint object used for rendering.
   *
   * @return
   */
  Paint getPaintRender() {
    return mRenderPaint;
  }

  /**
   * Applies the required styling (provided by the DataSet) to the value-paint
   * object.
   *
   * @param set
   */
  void applyValueTextStyle(IDataSet set) {
    mValuePaint = TextPainter(
        text: TextSpan(
            style: set.getValueTypeface() == null
                ? TextStyle(
                    color: Color.fromARGB(255, 63, 63, 63),
                    fontSize: Utils.convertDpToPixel(9))
                : set.getValueTypeface()),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center);
  }

  /**
   * Initializes the buffers used for rendering with a  size. Since this
   * method performs memory allocations, it should only be called if
   * necessary.
   */
  void initBuffers();

  /**
   * Draws the actual data in form of lines, bars, ... depending on Renderer subclass.
   *
   * @param c
   */
  void drawData(Canvas c);

  /**
   * Loops over all Entrys and draws their values.
   *
   * @param c
   */
  void drawValues(Canvas c);

  /**
   * Draws the value of the given entry by using the provided IValueFormatter.
   *
   * @param c         canvas
   * @param valueText label to draw
   * @param x         position
   * @param y         position
   * @param color
   */
  void drawValue(Canvas c, String valueText, double x, double y, Color color);

  /**
   * Draws any kind of additional information (e.g. line-circles).
   *
   * @param c
   */
  void drawExtras(Canvas c);

  /**
   * Draws all highlight indicators for the values that are currently highlighted.
   *
   * @param c
   * @param indices the highlighted values
   */
  void drawHighlighted(Canvas c, List<Highlight> indices);
}

abstract class AxisRenderer extends Renderer {
  /** base axis this axis renderer works with */
  AxisBase mAxis;

  /** transformer to transform values to screen pixels and return */
  Transformer mTrans;

  /**
   * paint object for the grid lines
   */
  Paint mGridPaint;

  /**
   * paint for the x-label values
   */
  TextPainter mAxisLabelPaint;

  /**
   * paint for the line surrounding the chart
   */
  Paint mAxisLinePaint;

  /**
   * paint used for the limit lines
   */
  Paint mLimitLinePaint;

  AxisRenderer(
      ViewPortHandler viewPortHandler, Transformer trans, AxisBase axis)
      : super(viewPortHandler) {
    this.mTrans = trans;
    this.mAxis = axis;
    if (mViewPortHandler != null) {
      mAxisLabelPaint = TextPainter(
          text: TextSpan(style: TextStyle()), textDirection: TextDirection.ltr);

      mGridPaint = Paint()
        ..color = Color.fromARGB(90, 160, 160, 160)
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke;

      mAxisLabelPaint = TextPainter(
          text: TextSpan(style: TextStyle(color: ColorUtils.BLACK)),
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr);

      mLimitLinePaint = Paint()
        ..isAntiAlias = true
        ..style = PaintingStyle.stroke;
    }
  }

  /**
   * Returns the Paint object used for drawing the axis (labels).
   *
   * @return
   */
  TextPainter getPaintAxisLabels() {
    return mAxisLabelPaint;
  }

  /**
   * Returns the Paint object that is used for drawing the grid-lines of the
   * axis.
   *
   * @return
   */
  Paint getPaintGrid() {
    return mGridPaint;
  }

  /**
   * Returns the Paint object that is used for drawing the axis-line that goes
   * alongside the axis.
   *
   * @return
   */
  Paint getPaintAxisLine() {
    return mAxisLinePaint;
  }

  /**
   * Returns the Transformer object used for transforming the axis values.
   *
   * @return
   */
  Transformer getTransformer() {
    return mTrans;
  }

  /**
   * Computes the axis values.
   *
   * @param min - the minimum value in the data object for this axis
   * @param max - the maximum value in the data object for this axis
   */
  void computeAxis(double min, double max, bool inverted) {
    // calculate the starting and entry point of the y-labels (depending on
    // zoom / contentrect bounds)
    if (mViewPortHandler != null &&
        mViewPortHandler.contentWidth() > 10 &&
        !mViewPortHandler.isFullyZoomedOutY()) {
      MPPointD p1 = mTrans.getValuesByTouchPoint1(
          mViewPortHandler.contentLeft(), mViewPortHandler.contentTop());
      MPPointD p2 = mTrans.getValuesByTouchPoint1(
          mViewPortHandler.contentLeft(), mViewPortHandler.contentBottom());

      if (!inverted) {
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

  /**
   * Sets up the axis values. Computes the desired number of labels between the two given extremes.
   *
   * @return
   */
  void computeAxisValues(double min, double max) {
    double yMin = min;
    double yMax = max;

    int labelCount = mAxis.getLabelCount();
    double range = (yMax - yMin).abs();

    if (labelCount == 0 || range <= 0 || range.isInfinite) {
      mAxis.mEntries = List<double>();
      mAxis.mCenteredEntries = List<double>();
      mAxis.mEntryCount = 0;
      return;
    }

    // Find out how much spacing (in y value space) between axis values
    double rawInterval = range / labelCount;
    double interval = Utils.roundToNextSignificant(rawInterval);

    // If granularity is enabled, then do not allow the interval to go below specified granularity.
    // This is used to avoid repeated values when rounding values for display.
    if (mAxis.isGranularityEnabled())
      interval =
          interval < mAxis.getGranularity() ? mAxis.getGranularity() : interval;

    // Normalize interval
    double intervalMagnitude =
        Utils.roundToNextSignificant(pow(10.0, log(interval) ~/ ln10));
    int intervalSigDigit = interval ~/ intervalMagnitude;
    if (intervalSigDigit > 5) {
      // Use one order of magnitude higher, to avoid intervals like 0.9 or
      // 90
      interval = (10 * intervalMagnitude).floorToDouble();
    }

    int n = mAxis.isCenterAxisLabelsEnabled() ? 1 : 0;

    // force label count
    if (mAxis.isForceLabelsEnabled()) {
      interval = range / (labelCount - 1);
      mAxis.mEntryCount = labelCount;

      if (mAxis.mEntries.length < labelCount) {
        // Ensure stops contains at least numStops elements.
        mAxis.mEntries = List(labelCount);
      }

      double v = min;

      for (int i = 0; i < labelCount; i++) {
        mAxis.mEntries[i] = v;
        v += interval;
      }

      n = labelCount;

      // no forced count
    } else {
      double first =
          interval == 0.0 ? 0.0 : (yMin / interval).ceil() * interval;
      if (mAxis.isCenterAxisLabelsEnabled()) {
        first -= interval;
      }

      double last = interval == 0.0
          ? 0.0
          : Utils.nextUp((yMax / interval).floor() * interval);

      double f;
      int i;

      if (interval != 0.0) {
        for (f = first; f <= last; f += interval) {
          ++n;
        }
      }

      mAxis.mEntryCount = n;

      if (mAxis.mEntries.length < n) {
        // Ensure stops contains at least numStops elements.
        mAxis.mEntries = List(n);
      }

      i = 0;
      for (f = first; i < n; f += interval, ++i) {
        if (f ==
            0.0) // Fix for negative zero case (Where value == -0.0, and 0.0 == -0.0)
          f = 0.0;

        mAxis.mEntries[i] = f;
      }
    }

    // set decimals
    if (interval < 1) {
      mAxis.mDecimals = (-log(interval) / ln10).ceil();
    } else {
      mAxis.mDecimals = 0;
    }

    if (mAxis.isCenterAxisLabelsEnabled()) {
      if (mAxis.mCenteredEntries.length < n) {
        mAxis.mCenteredEntries = List(n);
      }

      double offset = interval / 2.0;

      for (int i = 0; i < n; i++) {
        mAxis.mCenteredEntries[i] = mAxis.mEntries[i] + offset;
      }
    }
  }

  /**
   * Draws the axis labels to the screen.
   *
   * @param c
   */
  void renderAxisLabels(Canvas c);

  /**
   * Draws the grid lines belonging to the axis.
   *
   * @param c
   */
  void renderGridLines(Canvas c);

  /**
   * Draws the line that goes alongside the axis.
   *
   * @param c
   */
  void renderAxisLine(Canvas c);

  /**
   * Draws the LimitLines associated with this axis to the screen.
   *
   * @param c
   */
  void renderLimitLines(Canvas c);
}

class YAxisRenderer extends AxisRenderer {
  YAxis mYAxis;

  Paint mZeroLinePaint;

  YAxisRenderer(ViewPortHandler viewPortHandler, YAxis yAxis, Transformer trans)
      : super(viewPortHandler, trans, yAxis) {
    this.mYAxis = yAxis;

    if (mViewPortHandler != null) {
      mAxisLabelPaint = TextPainter(
          text: TextSpan(
              style: TextStyle(
                  color: ColorUtils.BLACK,
                  fontSize: Utils.convertDpToPixel(10))),
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center);

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
        mAxisLabelPaint = TextPainter(
            text: TextSpan(
                style: TextStyle(
                    color: mYAxis.getTextColor(),
                    fontSize: mYAxis.getTextSize())),
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.center);
        xPos = mViewPortHandler.offsetLeft();
      } else {
        mAxisLabelPaint = TextPainter(
            text: TextSpan(
                style: TextStyle(
                    color: mYAxis.getTextColor(),
                    fontSize: mYAxis.getTextSize())),
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.center);
        xPos = mViewPortHandler.offsetLeft();
      }
    } else {
      if (labelPosition == YAxisLabelPosition.OUTSIDE_CHART) {
        mAxisLabelPaint = TextPainter(
            text: TextSpan(
                style: TextStyle(
                    color: mYAxis.getTextColor(),
                    fontSize: mYAxis.getTextSize())),
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.center);
        xPos = mViewPortHandler.contentRight();
      } else {
        mAxisLabelPaint = TextPainter(
            text: TextSpan(
                style: TextStyle(
                    color: mYAxis.getTextColor(),
                    fontSize: mYAxis.getTextSize())),
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.center);
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
        TextPainter painter = TextPainter(
            text: TextSpan(
                style: TextStyle(
                    color: l.getTextColor(), fontSize: l.getTextSize())),
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.center);

        final double labelLineHeight =
            Utils.calcTextHeight(painter, label).toDouble();
        double xOffset = Utils.convertDpToPixel(4) + l.getXOffset();
        double yOffset = l.getLineWidth() + labelLineHeight + l.getYOffset();

        final LimitLabelPosition position = l.getLabelPosition();

        if (position == LimitLabelPosition.RIGHT_TOP) {
          painter = TextPainter(
              text: TextSpan(
                  text: label,
                  style: TextStyle(
                      color: l.getTextColor(), fontSize: l.getTextSize())),
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.right);
          painter.layout();
          painter.paint(
              c,
              Offset(mViewPortHandler.contentRight() - xOffset - painter.width,
                  pts[1] - yOffset + labelLineHeight - painter.height));
        } else if (position == LimitLabelPosition.RIGHT_BOTTOM) {
          painter = TextPainter(
              text: TextSpan(
                  text: label,
                  style: TextStyle(
                      color: l.getTextColor(), fontSize: l.getTextSize())),
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.right);
          painter.layout();
          painter.paint(
              c,
              Offset(mViewPortHandler.contentRight() - xOffset - painter.width,
                  pts[1] + yOffset - painter.height));
        } else if (position == LimitLabelPosition.LEFT_TOP) {
          painter = TextPainter(
              text: TextSpan(
                  text: label,
                  style: TextStyle(
                      color: l.getTextColor(), fontSize: l.getTextSize())),
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.left);
          painter.layout();
          painter.paint(
              c,
              Offset(mViewPortHandler.contentLeft() + xOffset - painter.width,
                  pts[1] - yOffset + labelLineHeight - painter.height));
        } else {
          painter = TextPainter(
              text: TextSpan(
                  text: label,
                  style: TextStyle(
                      color: l.getTextColor(), fontSize: l.getTextSize())),
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.left);
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

abstract class BarLineScatterCandleBubbleRenderer extends DataRenderer {
  /**
   * buffer for storing the current minimum and maximum visible x
   */
  XBounds mXBounds;

  BarLineScatterCandleBubbleRenderer(
      ChartAnimator animator, ViewPortHandler viewPortHandler)
      : super(animator, viewPortHandler) {
    mXBounds = XBounds(mAnimator);
  }

  /**
   * Returns true if the DataSet values should be drawn, false if not.
   *
   * @param set
   * @return
   */
  bool shouldDrawValues(IDataSet set) {
    return set.isVisible() &&
        (set.isDrawValuesEnabled() || set.isDrawIconsEnabled());
  }

  /**
   * Checks if the provided entry object is in bounds for drawing considering the current animation phase.
   *
   * @param e
   * @param set
   * @return
   */
  bool isInBoundsX(Entry e, IBarLineScatterCandleBubbleDataSet set) {
    if (e == null) return false;

    double entryIndex = set.getEntryIndex2(e).toDouble();

    if (e == null ||
        entryIndex >= set.getEntryCount() * mAnimator.getPhaseX()) {
      return false;
    } else {
      return true;
    }
  }
}

abstract class LineScatterCandleRadarRenderer
    extends BarLineScatterCandleBubbleRenderer {
  /**
   * path that is used for drawing highlight-lines (drawLines(...) cannot be used because of dashes)
   */
  Path mHighlightLinePath = Path();

  LineScatterCandleRadarRenderer(
      ChartAnimator animator, ViewPortHandler viewPortHandler)
      : super(animator, viewPortHandler);

  /**
   * Draws vertical & horizontal highlight-lines if enabled.
   *
   * @param c
   * @param x x-position of the highlight line intersection
   * @param y y-position of the highlight line intersection
   * @param set the currently drawn dataset
   */
  void drawHighlightLines(
      Canvas c, double x, double y, ILineScatterCandleRadarDataSet set) {
    // set color and stroke-width
    mHighlightPaint
      ..color = set.getHighLightColor()
      ..strokeWidth = set.getHighlightLineWidth();

    // draw highlighted lines (if enabled)
//    mHighlightPaint.setPathEffect(set.getDashPathEffectHighlight());

    // draw vertical highlight lines
    if (set.isVerticalHighlightIndicatorEnabled()) {
      // create vertical path
      mHighlightLinePath.reset();
      mHighlightLinePath.moveTo(x, mViewPortHandler.contentTop());
      mHighlightLinePath.lineTo(x, mViewPortHandler.contentBottom());

      c.drawPath(mHighlightLinePath, mHighlightPaint);
    }

    // draw horizontal highlight lines
    if (set.isHorizontalHighlightIndicatorEnabled()) {
      // create horizontal path
      mHighlightLinePath.reset();
      mHighlightLinePath.moveTo(mViewPortHandler.contentLeft(), y);
      mHighlightLinePath.lineTo(mViewPortHandler.contentRight(), y);

      c.drawPath(mHighlightLinePath, mHighlightPaint);
    }
  }
}

abstract class LineRadarRenderer extends LineScatterCandleRadarRenderer {
  LineRadarRenderer(ChartAnimator animator, ViewPortHandler viewPortHandler)
      : super(animator, viewPortHandler);

  /**
   * Draws the provided path in filled mode with the provided drawable.
   *
   * @param c
   * @param filledPath
   * @param drawable
   */
  void drawFilledPath1(Canvas c, Path filledPath, Image drawable) {
    if (clipPathSupported()) {
      c.save();
      c.clipPath(filledPath);
//      drawable.setBounds((int) mViewPortHandler.contentLeft(),
//    (int) mViewPortHandler.contentTop(),
//    (int) mViewPortHandler.contentRight(),
//    (int) mViewPortHandler.contentBottom());
//    drawable.draw(c);
      c.drawImage(drawable, Offset(0, 0), mDrawPaint);

      c.restore();
    }
//    else {
//    throw Exception("Fill-drawables not (yet) supported below API level 18, " +
//    "this code was run on API level " + Utils.getSDKInt() + ".");
//    }
  }

  /**
   * Draws the provided path in filled mode with the provided color and alpha.
   * Special thanks to Angelo Suzuki (https://github.com/tinsukE) for this.
   *
   * @param c
   * @param filledPath
   * @param fillColor
   * @param fillAlpha
   */
  void drawFilledPath2(
      Canvas c, Path filledPath, int fillColor, int fillAlpha) {
    int color = (fillAlpha << 24) | (fillColor & 0xffffff);

    if (clipPathSupported()) {
      c.save();
      c.clipPath(filledPath);
      c.drawColor(Color(color), BlendMode.colorBurn);
      c.restore();
    } else {
      // save
      var previous = mRenderPaint.style;
      Color previousColor = mRenderPaint.color;

      // set
      mRenderPaint
        ..style = PaintingStyle.fill
        ..color = Color(color);

      c.drawPath(filledPath, mRenderPaint);

      // restore
      mRenderPaint
        ..style = previous
        ..color = previousColor;
    }
  }

  /**
   * Clip path with hardware acceleration only working properly on API level 18 and above.
   *
   * @return
   */
  bool clipPathSupported() {
    return true;
  }
}

class LineChartRenderer extends LineRadarRenderer {
  LineDataProvider mChart;

  /**
   * paint for the inner circle of the value indicators
   */
  Paint mCirclePaintInner;

  /**
   * Bitmap object used for drawing the paths (otherwise they are too long if
   * rendered directly on the canvas)
   */
//   WeakReference<Bitmap> mDrawBitmap;

//  /**
//   * on this canvas, the paths are rendered, it is initialized with the
//   * pathBitmap
//   */
//  Canvas mBitmapCanvas;

  /**
   * the bitmap configuration to be used
   */
//   Bitmap.Config mBitmapConfig = Bitmap.Config.ARGB_8888;

  Path cubicPath = Path();
  Path cubicFillPath = Path();

  LineChartRenderer(LineDataProvider chart, ChartAnimator animator,
      ViewPortHandler viewPortHandler)
      : super(animator, viewPortHandler) {
    mChart = chart;

    mCirclePaintInner = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.fill
      ..color = ColorUtils.WHITE;
  }

  @override
  void initBuffers() {}

  @override
  void drawData(Canvas c) {
//    int width = mViewPortHandler.getChartWidth().toInt();
//    int height = mViewPortHandler.getChartHeight().toInt();

//    Bitmap drawBitmap = mDrawBitmap == null ? null : mDrawBitmap.get();
//
//    if (drawBitmap == null
//        || (drawBitmap.getWidth() != width)
//        || (drawBitmap.getHeight() != height)) {
//      if (width > 0 && height > 0) {
//        drawBitmap = Bitmap.createBitmap(width, height, mBitmapConfig);
//        mDrawBitmap =  WeakReference<>(drawBitmap);
//        mBitmapCanvas =  Canvas(drawBitmap);
//      } else
//        return;
//    }
//
//    drawBitmap.eraseColor(Color.TRANSPARENT);

    LineData lineData = mChart.getLineData();

    for (ILineDataSet set in lineData.getDataSets()) {
      if (set.isVisible()) drawDataSet(c, set);
    }
//    c.drawBitmap(drawBitmap, 0, 0, mRenderPaint);
  }

  void drawDataSet(Canvas c, ILineDataSet dataSet) {
    if (dataSet.getEntryCount() < 1) return;

    mRenderPaint..strokeWidth = dataSet.getLineWidth();

    switch (dataSet.getMode()) {
      case Mode.LINEAR:
      case Mode.STEPPED:
        drawLinear(c, dataSet);
        break;
      case Mode.CUBIC_BEZIER:
        drawCubicBezier(c, dataSet);
        break;
      case Mode.HORIZONTAL_BEZIER:
        drawHorizontalBezier(c, dataSet);
        break;
      default:
        drawLinear(c, dataSet);
    }
  }

  void drawHorizontalBezier(Canvas canvas, ILineDataSet dataSet) {
    double phaseY = mAnimator.getPhaseY();
    Transformer trans = mChart.getTransformer(dataSet.getAxisDependency());

    mXBounds.set(mChart, dataSet);

    List<double> list = List();

    if (mXBounds.range >= 1) {
      Entry prev = dataSet.getEntryForIndex(mXBounds.min);
      Entry cur = prev;
      // let the spline start
      cubicPath.moveTo(cur.x, cur.y * phaseY);
      list.add(cur.x);
      list.add(cur.y * phaseY);

      for (int j = mXBounds.min + 1; j <= mXBounds.range + mXBounds.min; j++) {
        prev = cur;
        cur = dataSet.getEntryForIndex(j);

        final double cpx = (prev.x) + (cur.x - prev.x) / 2.0;

        list.add(cpx);
        list.add(prev.y * phaseY);
        list.add(cpx);
        list.add(cur.y * phaseY);
        list.add(cur.x);
        list.add(cur.y * phaseY);
      }
    }

    mRenderPaint
      ..color = dataSet.getColor1()
      ..style = PaintingStyle.stroke;

    trans.pointValuesToPixel(list);

    cubicPath.reset();
    if (dataSet.isDrawFilledEnabled()) {
      cubicFillPath.reset();
    }
    cubicPath.moveTo(list[0], list[1]);
    if (dataSet.isDrawFilledEnabled()) {
      cubicFillPath.moveTo(list[0], list[1]);
    }

    int i = 2;
    for (int j = mXBounds.min + 1; j <= mXBounds.range + mXBounds.min; j++) {
      cubicPath.cubicTo(list[i], list[i + 1], list[i + 2], list[i + 3],
          list[i + 4], list[i + 5]);
      if (dataSet.isDrawFilledEnabled()) {
        cubicFillPath.cubicTo(list[i], list[i + 1], list[i + 2], list[i + 3],
            list[i + 4], list[i + 5]);
      }
      i += 6;
    }

    // if filled is enabled, close the path
    if (dataSet.isDrawFilledEnabled()) {
      // create a  path, this is bad for performance
      drawCubicFill(canvas, dataSet, cubicFillPath, trans, mXBounds);
    }

    canvas.drawPath(cubicPath, mRenderPaint);

//    mRenderPaint.setPathEffect(null);
  }

  void drawCubicBezier(Canvas canvas, ILineDataSet dataSet) {
    double phaseY = mAnimator.getPhaseY();

    Transformer trans = mChart.getTransformer(dataSet.getAxisDependency());

    mXBounds.set(mChart, dataSet);

    double intensity = dataSet.getCubicIntensity();

    List<double> list = List();

    double x = 0.0;
    double y = 0.0;
    if (mXBounds.range >= 1) {
      double prevDx = 0;
      double prevDy = 0;
      double curDx = 0;
      double curDy = 0;

      // Take an extra point from the left, and an extra from the right.
      // That's because we need 4 points for a cubic bezier (cubic=4), otherwise we get lines moving and doing weird stuff on the edges of the chart.
      // So in the starting `prev` and `cur`, go -2, -1
      // And in the `lastIndex`, add +1

      final int firstIndex = mXBounds.min + 1;
      final int lastIndex = mXBounds.min + mXBounds.range;

      Entry prevPrev;
      Entry prev = dataSet.getEntryForIndex(max(firstIndex - 2, 0));
      Entry cur = dataSet.getEntryForIndex(max(firstIndex - 1, 0));
      Entry next = cur;
      int nextIndex = -1;

      if (cur == null) return;

      x = cur.x;
      y = cur.y;

      // let the spline start
      list.add(cur.x);
      list.add(cur.y * phaseY);

      for (int j = mXBounds.min + 1; j <= mXBounds.range + mXBounds.min; j++) {
        prevPrev = prev;
        prev = cur;
        cur = nextIndex == j ? next : dataSet.getEntryForIndex(j);

        nextIndex = j + 1 < dataSet.getEntryCount() ? j + 1 : j;
        next = dataSet.getEntryForIndex(nextIndex);

        prevDx = (cur.x - prevPrev.x) * intensity;
        prevDy = (cur.y - prevPrev.y) * intensity;
        curDx = (next.x - prev.x) * intensity;
        curDy = (next.y - prev.y) * intensity;

        list.add(prev.x + prevDx);
        list.add((prev.y + prevDy) * phaseY);
        list.add(cur.x - curDx);
        list.add((cur.y - curDy) * phaseY);
        list.add(cur.x);
        list.add(cur.y * phaseY);
      }
    }

    if (list.length <= 0) {
      return;
    }

    mRenderPaint
      ..color = dataSet.getColor1()
      ..style = PaintingStyle.stroke;

    trans.pointValuesToPixel(list);

    cubicPath.reset();
    if (dataSet.isDrawFilledEnabled()) {
      cubicFillPath.reset();
    }
    cubicPath.moveTo(list[0], list[1]);
    if (dataSet.isDrawFilledEnabled()) {
      cubicFillPath.moveTo(list[0], list[1]);
    }

    int i = 2;
    for (int j = mXBounds.min + 1; j <= mXBounds.range + mXBounds.min; j++) {
      cubicPath.cubicTo(list[i], list[i + 1], list[i + 2], list[i + 3],
          list[i + 4], list[i + 5]);
      if (dataSet.isDrawFilledEnabled()) {
        cubicFillPath.cubicTo(list[i], list[i + 1], list[i + 2], list[i + 3],
            list[i + 4], list[i + 5]);
      }
      i += 6;
    }

    // if filled is enabled, close the path
    if (dataSet.isDrawFilledEnabled()) {
      drawCubicFill(canvas, dataSet, cubicFillPath, trans, mXBounds);
    }

    canvas.drawPath(cubicPath, mRenderPaint);

//    mRenderPaint.setPathEffect(null);
  }

  void drawCubicFill(Canvas c, ILineDataSet dataSet, Path spline,
      Transformer trans, XBounds bounds) {
    double fillMin =
        dataSet.getFillFormatter().getFillLinePosition(dataSet, mChart);

    List<double> list = List();
    list.add(dataSet.getEntryForIndex(bounds.min + bounds.range).x);
    list.add(fillMin);
    list.add(dataSet.getEntryForIndex(bounds.min).x);
    list.add(fillMin);

    trans.pointValuesToPixel(list);

    spline.lineTo(list[0], list[1]);
    spline.lineTo(list[2], list[3]);
    spline.close();

//    final Drawable drawable = dataSet.getFillDrawable();
//    if (drawable != null) {
//      drawFilledPath(c, spline, drawable);
//    } else {

    drawFilledPath2(
        c, spline, dataSet.getFillColor().value, dataSet.getFillAlpha());

//    }
  }

  List<double> mLineBuffer = List(4);

  /**
   * Draws a normal line.
   *
   * @param c
   * @param dataSet
   */
  void drawLinear(Canvas canvas, ILineDataSet dataSet) {
    int entryCount = dataSet.getEntryCount();

    final bool isDrawSteppedEnabled = dataSet.getMode() == Mode.STEPPED;
    final int pointsPerEntryPair = isDrawSteppedEnabled ? 4 : 2;

    Transformer trans = mChart.getTransformer(dataSet.getAxisDependency());

    double phaseY = mAnimator.getPhaseY();

    mRenderPaint..style = PaintingStyle.stroke;

//    Canvas canvas = null;
//
//    // if the data-set is dashed, draw on bitmap-canvas
//    if (dataSet.isDashedLineEnabled()) {
//      canvas = mBitmapCanvas;
//    } else {
//      canvas = c;
//    }

    mXBounds.set(mChart, dataSet);

    // if drawing filled is enabled
    if (dataSet.isDrawFilledEnabled() && entryCount > 0) {
      drawLinearFill(canvas, dataSet, trans, mXBounds);
    }

    // more than 1 color
    if (dataSet.getColors().length > 1) {
      if (mLineBuffer.length <= pointsPerEntryPair * 2)
        mLineBuffer = List(pointsPerEntryPair * 4);

      for (int j = mXBounds.min; j <= mXBounds.range + mXBounds.min; j++) {
        Entry e = dataSet.getEntryForIndex(j);
        if (e == null) continue;

        mLineBuffer[0] = e.x;
        mLineBuffer[1] = e.y * phaseY;

        if (j < mXBounds.max) {
          e = dataSet.getEntryForIndex(j + 1);

          if (e == null) break;

          if (isDrawSteppedEnabled) {
            mLineBuffer[2] = e.x;
            mLineBuffer[3] = mLineBuffer[1];
            mLineBuffer[4] = mLineBuffer[2];
            mLineBuffer[5] = mLineBuffer[3];
            mLineBuffer[6] = e.x;
            mLineBuffer[7] = e.y * phaseY;
          } else {
            mLineBuffer[2] = e.x;
            mLineBuffer[3] = e.y * phaseY;
          }
        } else {
          mLineBuffer[2] = mLineBuffer[0];
          mLineBuffer[3] = mLineBuffer[1];
        }

        trans.pointValuesToPixel(mLineBuffer);

        if (!mViewPortHandler.isInBoundsRight(mLineBuffer[0])) break;

        // make sure the lines don't do shitty things outside
        // bounds
        if (!mViewPortHandler.isInBoundsLeft(mLineBuffer[2]) ||
            (!mViewPortHandler.isInBoundsTop(mLineBuffer[1]) &&
                !mViewPortHandler.isInBoundsBottom(mLineBuffer[3]))) continue;

        // get the color that is set for this line-segment
        mRenderPaint..color = dataSet.getColor2(j);

        CanvasUtils.drawLines(
            canvas, mLineBuffer, 0, pointsPerEntryPair * 2, mRenderPaint);
      }
    } else {
      // only one color per dataset

      if (mLineBuffer.length <
          max((entryCount) * pointsPerEntryPair, pointsPerEntryPair) * 2)
        mLineBuffer = List(
            max((entryCount) * pointsPerEntryPair, pointsPerEntryPair) * 4);

      Entry e1, e2;

      e1 = dataSet.getEntryForIndex(mXBounds.min);

      if (e1 != null) {
        int j = 0;
        for (int x = mXBounds.min; x <= mXBounds.range + mXBounds.min; x++) {
          e1 = dataSet.getEntryForIndex(x == 0 ? 0 : (x - 1));
          e2 = dataSet.getEntryForIndex(x);

          if (e1 == null || e2 == null) continue;

          mLineBuffer[j++] = e1.x;
          mLineBuffer[j++] = e1.y * phaseY;

          if (isDrawSteppedEnabled) {
            mLineBuffer[j++] = e2.x;
            mLineBuffer[j++] = e1.y * phaseY;
            mLineBuffer[j++] = e2.x;
            mLineBuffer[j++] = e1.y * phaseY;
          }

          mLineBuffer[j++] = e2.x;
          mLineBuffer[j++] = e2.y * phaseY;
        }

        if (j > 0) {
          trans.pointValuesToPixel(mLineBuffer);

          final int size = max((mXBounds.range + 1) * pointsPerEntryPair,
                  pointsPerEntryPair) *
              2;

          mRenderPaint..color = dataSet.getColor1();

          CanvasUtils.drawLines(canvas, mLineBuffer, 0, size, mRenderPaint);
        }
      }
    }

//    mRenderPaint.setPathEffect(null);
  }

  Path mGenerateFilledPathBuffer = Path();

  /**
   * Draws a filled linear path on the canvas.
   *
   * @param c
   * @param dataSet
   * @param trans
   * @param bounds
   */
  void drawLinearFill(
      Canvas c, ILineDataSet dataSet, Transformer trans, XBounds bounds) {
    final Path filled = mGenerateFilledPathBuffer;

    final int startingIndex = bounds.min;
    final int endingIndex = bounds.range + bounds.min;
    final int indexInterval = 128;

    int currentStartIndex = 0;
    int currentEndIndex = indexInterval;
    int iterations = 0;

    // Doing this iteratively in order to avoid OutOfMemory errors that can happen on large bounds sets.
    do {
      currentStartIndex = startingIndex + (iterations * indexInterval);
      currentEndIndex = currentStartIndex + indexInterval;
      currentEndIndex =
          currentEndIndex > endingIndex ? endingIndex : currentEndIndex;

      if (currentStartIndex <= currentEndIndex) {
        generateFilledPath(
            dataSet, currentStartIndex, currentEndIndex, filled, trans);

//        trans.pathValueToPixel(filled);

//        final Drawable drawable = dataSet.getFillDrawable();
//        if (drawable != null) {
//
//          drawFilledPath(c, filled, drawable);
//        } else {

        drawFilledPath2(
            c, filled, dataSet.getFillColor().value, dataSet.getFillAlpha());
//        }
      }

      iterations++;
    } while (currentStartIndex <= currentEndIndex);
  }

  /**
   * Generates a path that is used for filled drawing.
   *
   * @param dataSet    The dataset from which to read the entries.
   * @param startIndex The index from which to start reading the dataset
   * @param endIndex   The index from which to stop reading the dataset
   * @param outputPath The path object that will be assigned the chart data.
   * @return
   */
  void generateFilledPath(final ILineDataSet dataSet, final int startIndex,
      final int endIndex, final Path outputPath, final Transformer trans) {
    final double fillMin =
        dataSet.getFillFormatter().getFillLinePosition(dataSet, mChart);
    final double phaseY = mAnimator.getPhaseY();
    final bool isDrawSteppedEnabled = dataSet.getMode() == Mode.STEPPED;

    List<double> points = List();
    final Path filled = outputPath;
    filled.reset();

    final Entry entry = dataSet.getEntryForIndex(startIndex);

    points.add(entry.x);
    points.add(fillMin);
    points.add(entry.x);
    points.add(entry.y * phaseY);
//    filled.moveTo(entry.x, fillMin);
//    filled.lineTo(entry.x, entry.y * phaseY);

    // create a  path
    Entry currentEntry = null;
    Entry previousEntry = entry;
    for (int x = startIndex + 1; x <= endIndex; x++) {
      currentEntry = dataSet.getEntryForIndex(x);

      if (isDrawSteppedEnabled) {
        points.add(currentEntry.x);
        points.add(previousEntry.y * phaseY);
//        filled.lineTo(currentEntry.x, previousEntry.y * phaseY);
      }

      points.add(currentEntry.x);
      points.add(currentEntry.y * phaseY);
//      filled.lineTo(currentEntry.x, currentEntry.y * phaseY);

      previousEntry = currentEntry;
    }

    // close up
    if (currentEntry != null) {
      points.add(currentEntry.x);
      points.add(fillMin);
//      filled.lineTo(currentEntry.x, fillMin);
    }

    trans.pointValuesToPixel(points);
    if (points.length > 2) {
      filled.moveTo(points[0], points[1]);
      for (int i = 2; i < points.length; i += 2) {
        filled.lineTo(points[i], points[i + 1]);
      }
    }

    filled.close();
  }

  @override
  void drawValues(Canvas c) {
    if (isDrawingValuesAllowed(mChart)) {
      List<ILineDataSet> dataSets = mChart.getLineData().getDataSets();

      for (int i = 0; i < dataSets.length; i++) {
        ILineDataSet dataSet = dataSets[i];

        if (!shouldDrawValues(dataSet) || dataSet.getEntryCount() < 1) continue;

        // apply the text-styling defined by the DataSet
        applyValueTextStyle(dataSet);

        Transformer trans = mChart.getTransformer(dataSet.getAxisDependency());

        // make sure the values do not interfear with the circles
        int valOffset = (dataSet.getCircleRadius() * 1.75).toInt();

        if (!dataSet.isDrawCirclesEnabled()) valOffset = valOffset ~/ 2;

        mXBounds.set(mChart, dataSet);

        List<double> positions = trans.generateTransformedValuesLine(
            dataSet,
            mAnimator.getPhaseX(),
            mAnimator.getPhaseY(),
            mXBounds.min,
            mXBounds.max);
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

          Entry entry = dataSet.getEntryForIndex(j ~/ 2 + mXBounds.min);

          if (dataSet.isDrawValuesEnabled()) {
            drawValue(c, formatter.getPointLabel(entry), x, y - valOffset,
                dataSet.getValueTextColor2(j ~/ 2));
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
    mValuePaint.text = TextSpan(
        text: valueText,
        style: TextStyle(
            color: color,
            fontSize: mValuePaint.text?.style?.fontSize == null
                ? Utils.convertDpToPixel(9)
                : mValuePaint.text.style.fontSize));
    mValuePaint.layout();
    mValuePaint.paint(
        c, Offset(x - mValuePaint.width / 2, y - mValuePaint.height));
  }

  @override
  void drawExtras(Canvas c) {
    drawCircles(c);
  }

  /**
   * cache for the circle bitmaps of all datasets
   */
//   HashMap<IDataSet, DataSetImageCache> mImageCaches =  HashMap<>();

  /**
   * buffer for drawing the circles
   */
  List<double> mCirclesBuffer = List(2);
  Map<IDataSet, DataSetImageCache> mImageCaches = Map();

  void drawCircles(Canvas c) {
    mRenderPaint..style = PaintingStyle.fill;

    double phaseY = mAnimator.getPhaseY();

    mCirclesBuffer[0] = 0;
    mCirclesBuffer[1] = 0;

    List<ILineDataSet> dataSets = mChart.getLineData().getDataSets();

    Transformer trans = null;
    for (int i = 0; i < dataSets.length; i++) {
      ILineDataSet dataSet = dataSets[i];

      if (!dataSet.isVisible() ||
          !dataSet.isDrawCirclesEnabled() ||
          dataSet.getEntryCount() == 0) continue;

      mCirclePaintInner..color = dataSet.getCircleHoleColor();

      trans = mChart.getTransformer(dataSet.getAxisDependency());
      mXBounds.set(mChart, dataSet);

      double circleRadius = dataSet.getCircleRadius();
      double circleHoleRadius = dataSet.getCircleHoleRadius();
      bool drawCircleHole = dataSet.isDrawCircleHoleEnabled() &&
          circleHoleRadius < circleRadius &&
          circleHoleRadius > 0;
      bool drawTransparentCircleHole = drawCircleHole &&
          dataSet.getCircleHoleColor() == ColorTemplate.COLOR_NONE;

      // todo for now we can't convert a ByteData to a Image
//      DataSetImageCache imageCache;
//
//      if (mImageCaches.containsKey(dataSet)) {
//        imageCache = mImageCaches[dataSet];
//      } else {
//        imageCache =  DataSetImageCache();
//        mImageCaches.putIfAbsent(dataSet, () => imageCache);
//      }

//      bool changeRequired = imageCache.init(dataSet);
//
//      // only fill the cache with  bitmaps if a change is required
//      if (changeRequired) {
//        imageCache.fill(dataSet, drawCircleHole, drawTransparentCircleHole,
//            mRenderPaint, mCirclePaintInner, () {
//          int boundsRangeCount = mXBounds.range + mXBounds.min;
//
//          for (int j = mXBounds.min; j <= boundsRangeCount; j++) {
//            Entry e = dataSet.getEntryForIndex(j);
//
//            if (e == null) break;
//
//            mCirclesBuffer[0] = e.x;
//            mCirclesBuffer[1] = e.y * phaseY;
//
//            trans.pointValuesToPixel(mCirclesBuffer);
//
//            if (!mViewPortHandler.isInBoundsRight(mCirclesBuffer[0])) break;
//
//            if (!mViewPortHandler.isInBoundsLeft(mCirclesBuffer[0]) ||
//                !mViewPortHandler.isInBoundsY(mCirclesBuffer[1])) continue;
//
//            _loadImage(imageCache.getBitmap(j)).then((codec) {
//              codec.getNextFrame().then((info) {
//                c.drawImage(
//                    info.image,
//                    Offset(mCirclesBuffer[0] - circleRadius,
//                        mCirclesBuffer[1] - circleRadius),
//                    mRenderPaint);
//              });
//            });
//          }
//        });
//      } else {
//        int boundsRangeCount = mXBounds.range + mXBounds.min;
//
//        for (int j = mXBounds.min; j <= boundsRangeCount; j++) {
//          Entry e = dataSet.getEntryForIndex(j);
//
//          if (e == null) break;
//
//          mCirclesBuffer[0] = e.x;
//          mCirclesBuffer[1] = e.y * phaseY;
//
//          trans.pointValuesToPixel(mCirclesBuffer);
//
//          if (!mViewPortHandler.isInBoundsRight(mCirclesBuffer[0])) break;
//
//          if (!mViewPortHandler.isInBoundsLeft(mCirclesBuffer[0]) ||
//              !mViewPortHandler.isInBoundsY(mCirclesBuffer[1])) continue;
//
//          _loadImage(imageCache.getBitmap(j)).then((codec) {
//            codec.getNextFrame().then((info) {
//              c.drawImage(
//                  info.image,
//                  Offset(mCirclesBuffer[0] - circleRadius,
//                      mCirclesBuffer[1] - circleRadius),
//                  mRenderPaint);
//            });
//          });
//        }
//      }

      int boundsRangeCount = mXBounds.range + mXBounds.min;

      for (int j = mXBounds.min; j <= boundsRangeCount; j++) {
        Entry e = dataSet.getEntryForIndex(j);

        if (e == null) break;

        mCirclesBuffer[0] = e.x;
        mCirclesBuffer[1] = e.y * phaseY;

        trans.pointValuesToPixel(mCirclesBuffer);

        if (!mViewPortHandler.isInBoundsRight(mCirclesBuffer[0])) break;

        if (!mViewPortHandler.isInBoundsLeft(mCirclesBuffer[0]) ||
            !mViewPortHandler.isInBoundsY(mCirclesBuffer[1])) continue;

        int colorCount = dataSet.getCircleColorCount();
        double circleRadius = dataSet.getCircleRadius();
        double circleHoleRadius = dataSet.getCircleHoleRadius();

        mRenderPaint..color = dataSet.getCircleColor(i % colorCount);

        if (drawTransparentCircleHole) {
          c.drawCircle(Offset(mCirclesBuffer[0], mCirclesBuffer[1]),
              circleRadius, mRenderPaint);

          c.drawCircle(Offset(mCirclesBuffer[0], mCirclesBuffer[1]),
              circleHoleRadius, mRenderPaint);
        } else {
          c.drawCircle(Offset(mCirclesBuffer[0], mCirclesBuffer[1]),
              circleRadius, mRenderPaint);

          if (drawCircleHole) {
            c.drawCircle(Offset(mCirclesBuffer[0], mCirclesBuffer[1]),
                circleHoleRadius, mCirclePaintInner);
          }
        }
      }
    }
  }

  Future<Codec> _loadImage(ByteData data) async {
    if (data == null) throw 'Unable to read data';
    return await instantiateImageCodec(data.buffer.asUint8List());
  }

  @override
  void drawHighlighted(Canvas c, List<Highlight> indices) {
    LineData lineData = mChart.getLineData();

    for (Highlight high in indices) {
      ILineDataSet set = lineData.getDataSetByIndex(high.getDataSetIndex());

      if (set == null || !set.isHighlightEnabled()) continue;

      Entry e = set.getEntryForXValue2(high.getX(), high.getY());

      if (!isInBoundsX(e, set)) continue;

      MPPointD pix = mChart
          .getTransformer(set.getAxisDependency())
          .getPixelForValues(e.x, e.y * mAnimator.getPhaseY());

      high.setDraw(pix.x, pix.y);

      // draw the lines
      drawHighlightLines(c, pix.x, pix.y, set);
    }
  }

//  /**
//   * Sets the Bitmap.Config to be used by this renderer.
//   * Default: Bitmap.Config.ARGB_8888
//   * Use Bitmap.Config.ARGB_4444 to consume less memory.
//   *
//   * @param config
//   */
//   void setBitmapConfig(Bitmap.Config config) {
//    mBitmapConfig = config;
//    releaseBitmap();
//  }
//
//  /**
//   * Returns the Bitmap.Config that is used by this renderer.
//   *
//   * @return
//   */
//   Bitmap.Config getBitmapConfig() {
//    return mBitmapConfig;
//  }
//
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
    mValuePaint = TextPainter(
        text: TextSpan(
            text: valueText,
            style: TextStyle(
                fontSize: mValuePaint.text.style.fontSize == null
                    ? Utils.convertDpToPixel(9)
                    : mValuePaint.text.style.fontSize,
                color: color)),
        textDirection: mValuePaint.textDirection,
        textAlign: mValuePaint.textAlign);
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
    mAxisLabelPaint = TextPainter(
        textAlign: mAxisLabelPaint.textAlign,
        textDirection: mAxisLabelPaint.textDirection,
        text: TextSpan(
            style: TextStyle(
                fontSize: mXAxis.getTextSize(),
                color: mXAxis.getTypeface()?.color == null
                    ? ColorUtils.HOLO_GREEN_DARK
                    : mXAxis.getTypeface()?.color)));

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

    mAxisLabelPaint = TextPainter(
        text: TextSpan(
            style: TextStyle(
                color: mXAxis.getTextColor(), fontSize: mXAxis.getTextSize())),
        textDirection: mAxisLabelPaint.textDirection,
        textAlign: mAxisLabelPaint.textAlign);

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

  /**
   * Draws the LimitLines associated with this axis to the screen.
   * This is the standard YAxis renderer using the XAxis limit lines.
   *
   * @param c
   */
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
          mAxisLabelPaint = TextPainter(
              textAlign: TextAlign.center,
              textDirection: TextDirection.ltr,
              text: TextSpan(
                  text: label,
                  style: TextStyle(
                      color: l.getTextColor(), fontSize: l.getTextSize())));
          mAxisLabelPaint.layout();
          mAxisLabelPaint.paint(
              c,
              Offset(mViewPortHandler.contentRight() - xOffset,
                  pts[1] - yOffset + labelLineHeight));
        } else if (position == LimitLabelPosition.RIGHT_BOTTOM) {
          mAxisLabelPaint = TextPainter(
              textAlign: TextAlign.center,
              textDirection: TextDirection.ltr,
              text: TextSpan(
                  text: label,
                  style: TextStyle(
                      color: l.getTextColor(), fontSize: l.getTextSize())));
          mAxisLabelPaint.layout();
          mAxisLabelPaint.paint(
              c,
              Offset(
                  mViewPortHandler.contentRight() - xOffset, pts[1] + yOffset));
        } else if (position == LimitLabelPosition.LEFT_TOP) {
          mAxisLabelPaint = TextPainter(
              textAlign: TextAlign.center,
              textDirection: TextDirection.ltr,
              text: TextSpan(
                  text: label,
                  style: TextStyle(
                      color: l.getTextColor(), fontSize: l.getTextSize())));
          mAxisLabelPaint.layout();
          mAxisLabelPaint.paint(
              c,
              Offset(mViewPortHandler.contentLeft() + xOffset,
                  pts[1] - yOffset + labelLineHeight));
        } else {
          mAxisLabelPaint = TextPainter(
              textAlign: TextAlign.center,
              textDirection: TextDirection.ltr,
              text: TextSpan(
                  text: label,
                  style: TextStyle(
                      color: l.getTextColor(), fontSize: l.getTextSize())));
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

class YAxisRendererHorizontalBarChart extends YAxisRenderer {
  YAxisRendererHorizontalBarChart(
      ViewPortHandler viewPortHandler, YAxis yAxis, Transformer trans)
      : super(viewPortHandler, yAxis, trans);

  /**
   * Computes the axis values.
   *
   * @param yMin - the minimum y-value in the data object for this axis
   * @param yMax - the maximum y-value in the data object for this axis
   */
  @override
  void computeAxis(double yMin, double yMax, bool inverted) {
    // calculate the starting and entry point of the y-labels (depending on
    // zoom / contentrect bounds)
    if (mViewPortHandler.contentHeight() > 10 &&
        !mViewPortHandler.isFullyZoomedOutX()) {
      MPPointD p1 = mTrans.getValuesByTouchPoint1(
          mViewPortHandler.contentLeft(), mViewPortHandler.contentTop());
      MPPointD p2 = mTrans.getValuesByTouchPoint1(
          mViewPortHandler.contentRight(), mViewPortHandler.contentTop());

      if (!inverted) {
        yMin = p1.x;
        yMax = p2.x;
      } else {
        yMin = p2.x;
        yMax = p1.x;
      }

      MPPointD.recycleInstance2(p1);
      MPPointD.recycleInstance2(p2);
    }

    computeAxisValues(yMin, yMax);
  }

  /**
   * draws the y-axis labels to the screen
   */
  @override
  void renderAxisLabels(Canvas c) {
    if (!mYAxis.isEnabled() || !mYAxis.isDrawLabelsEnabled()) return;

    List<double> positions = getTransformedPositions();

    mAxisLabelPaint = TextPainter(
        textAlign: TextAlign.center,
        textDirection: mAxisLabelPaint.textDirection,
        text: TextSpan(
            style: TextStyle(
                fontSize: mYAxis.getTextSize(), color: mYAxis.getTextColor())));

//    double baseYOffset = Utils.convertDpToPixel(2.5);
//    double textHeight = Utils.calcTextHeight(mAxisLabelPaint, "Q").toDouble();

    AxisDependency dependency = mYAxis.getAxisDependency();
    YAxisLabelPosition labelPosition = mYAxis.getLabelPosition();

    double yPos = 0;

    if (dependency == AxisDependency.LEFT) {
      if (labelPosition == YAxisLabelPosition.OUTSIDE_CHART) {
        yPos = mViewPortHandler.contentTop();
      } else {
        yPos = mViewPortHandler.contentTop();
      }
    } else {
      if (labelPosition == YAxisLabelPosition.OUTSIDE_CHART) {
        yPos = mViewPortHandler.contentBottom();
      } else {
        yPos = mViewPortHandler.contentBottom();
      }
    }

    drawYLabels(c, yPos, positions, dependency, labelPosition);
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
              mViewPortHandler.contentRight(), mViewPortHandler.contentTop()),
          mAxisLinePaint);
    } else {
      c.drawLine(
          Offset(
              mViewPortHandler.contentLeft(), mViewPortHandler.contentBottom()),
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
  @override
  void drawYLabels(Canvas c, double fixedPosition, List<double> positions,
      AxisDependency axisDependency, YAxisLabelPosition position) {
    mAxisLabelPaint = TextPainter(
        textDirection: mAxisLabelPaint.textDirection,
        textAlign: mAxisLabelPaint.textAlign,
        text: TextSpan(
            style: TextStyle(
                fontSize: mYAxis.getTextSize(), color: mYAxis.getTextColor())));

    final int from = mYAxis.isDrawBottomYLabelEntryEnabled() ? 0 : 1;
    final int to = mYAxis.isDrawTopYLabelEntryEnabled()
        ? mYAxis.mEntryCount
        : (mYAxis.mEntryCount - 1);

    for (int i = from; i < to; i++) {
      String text = mYAxis.getFormattedLabel(i);
      mAxisLabelPaint.text =
          TextSpan(text: text, style: mAxisLabelPaint.text.style);
      mAxisLabelPaint.layout();

      if (axisDependency == AxisDependency.LEFT) {
        if (position == YAxisLabelPosition.OUTSIDE_CHART) {
          mAxisLabelPaint.paint(
              c,
              Offset(positions[i * 2] - mAxisLabelPaint.width / 2,
                  fixedPosition - mAxisLabelPaint.height));
        } else {
          mAxisLabelPaint.paint(
              c,
              Offset(
                  positions[i * 2] - mAxisLabelPaint.width / 2, fixedPosition));
        }
      } else {
        if (position == YAxisLabelPosition.OUTSIDE_CHART) {
          mAxisLabelPaint.paint(
              c,
              Offset(
                  positions[i * 2] - mAxisLabelPaint.width / 2, fixedPosition));
        } else {
          mAxisLabelPaint.paint(
              c,
              Offset(positions[i * 2] - mAxisLabelPaint.width / 2,
                  fixedPosition - mAxisLabelPaint.height));
        }
      }
    }
  }

  @override
  List<double> getTransformedPositions() {
    if (mGetTransformedPositionsBuffer.length != mYAxis.mEntryCount * 2) {
      mGetTransformedPositionsBuffer = List(mYAxis.mEntryCount * 2);
    }
    List<double> positions = mGetTransformedPositionsBuffer;

    for (int i = 0; i < positions.length; i += 2) {
      // only fill x values, y values are not needed for x-labels
      positions[i] = mYAxis.mEntries[i ~/ 2];
    }

    mTrans.pointValuesToPixel(positions);
    return positions;
  }

  @override
  Rect getGridClippingRect() {
    mGridClippingRect = Rect.fromLTRB(
        mViewPortHandler.getContentRect().left - mAxis.getGridLineWidth(),
        mViewPortHandler.getContentRect().top - mAxis.getGridLineWidth(),
        mViewPortHandler.getContentRect().right,
        mViewPortHandler.getContentRect().bottom);
    return mGridClippingRect;
  }

  @override
  Path linePath(Path p, int i, List<double> positions) {
    p.moveTo(positions[i], mViewPortHandler.contentTop());
    p.lineTo(positions[i], mViewPortHandler.contentBottom());
    return p;
  }

  Path mDrawZeroLinePathBuffer = Path();

  @override
  void drawZeroLine(Canvas c) {
    c.save();
    mZeroLineClippingRect = Rect.fromLTRB(
        mViewPortHandler.getContentRect().left - mYAxis.getZeroLineWidth(),
        mViewPortHandler.getContentRect().top - mYAxis.getZeroLineWidth(),
        mViewPortHandler.getContentRect().right,
        mViewPortHandler.getContentRect().bottom);
    c.clipRect(mLimitLineClippingRect);

    // draw zero line
    MPPointD pos = mTrans.getPixelForValues(0, 0);

    mZeroLinePaint
      ..color = mYAxis.getZeroLineColor()
      ..strokeWidth = mYAxis.getZeroLineWidth();

    Path zeroLinePath = mDrawZeroLinePathBuffer;
    zeroLinePath.reset();

    zeroLinePath.moveTo(pos.x - 1, mViewPortHandler.contentTop());
    zeroLinePath.lineTo(pos.x - 1, mViewPortHandler.contentBottom());

    // draw a path because lines don't support dashing on lower android versions
    c.drawPath(zeroLinePath, mZeroLinePaint);

    c.restore();
  }

  Path mRenderLimitLinesPathBuffer = Path();
  List<double> mRenderLimitLinesBuffer = List(4);

  /**
   * Draws the LimitLines associated with this axis to the screen.
   * This is the standard XAxis renderer using the YAxis limit lines.
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
    pts[2] = 0;
    pts[3] = 0;
    Path limitLinePath = mRenderLimitLinesPathBuffer;
    limitLinePath.reset();

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

      pts[0] = l.getLimit();
      pts[2] = l.getLimit();

      mTrans.pointValuesToPixel(pts);

      pts[1] = mViewPortHandler.contentTop();
      pts[3] = mViewPortHandler.contentBottom();

      limitLinePath.moveTo(pts[0], pts[1]);
      limitLinePath.lineTo(pts[2], pts[3]);

      mLimitLinePaint
        ..style = PaintingStyle.stroke
        ..color = l.getLineColor()
        ..strokeWidth = l.getLineWidth();
//      mLimitLinePaint.setPathEffect(l.getDashPathEffect());

      c.drawPath(limitLinePath, mLimitLinePaint);
      limitLinePath.reset();

      String label = l.getLabel();

      // if drawing the limit-value label is enabled
      if (label != null && label.isNotEmpty) {
        mAxisLabelPaint = TextPainter(
            textAlign: TextAlign.center,
            textDirection: mAxisLabelPaint.textDirection,
            text: TextSpan(
                text: label,
                style: TextStyle(
                    color: l.getTextColor(), fontSize: l.getTextSize())));
        mAxisLabelPaint.layout();
//        mLimitLinePaint.setPathEffect(null);
//        mLimitLinePaint.setStrokeWidth(0.5f);

        double xOffset = l.getLineWidth() + l.getXOffset();
        double yOffset = Utils.convertDpToPixel(2) + l.getYOffset();

        final LimitLabelPosition position = l.getLabelPosition();

        if (position == LimitLabelPosition.RIGHT_TOP) {
          final double labelLineHeight =
              Utils.calcTextHeight(mAxisLabelPaint, label).toDouble();
          mAxisLabelPaint.paint(c,
              Offset(pts[0], mViewPortHandler.contentTop() + labelLineHeight));
        } else if (position == LimitLabelPosition.RIGHT_BOTTOM) {
          mAxisLabelPaint.paint(
              c, Offset(pts[0], mViewPortHandler.contentBottom()));
        } else if (position == LimitLabelPosition.LEFT_TOP) {
          final double labelLineHeight =
              Utils.calcTextHeight(mAxisLabelPaint, label).toDouble();
          mAxisLabelPaint.paint(c,
              Offset(pts[0], mViewPortHandler.contentTop() + labelLineHeight));
        } else {
          mAxisLabelPaint.paint(
              c, Offset(pts[0], mViewPortHandler.contentBottom()));
        }
      }

      c.restore();
    }
  }
}

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
//todo
//            if (entry.mIcon != null && dataSet.isDrawIconsEnabled()) {
//              Drawable icon = entry.getIcon();
//
//              double px = buffer.buffer[j + 2] +
//                  (val >= 0 ? posOffset : negOffset);
//              double py = y;
//
//              px += iconsOffset.x;
//              py += iconsOffset.y;
//
//              Utils.drawImage(
//                  c,
//                  icon,
//                  (int)px,
//                  (int)py,
//                  icon.getIntrinsicWidth(),
//                  icon.getIntrinsicHeight());
//            }
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
//todo
//              if (entry.getIcon() != null && dataSet.isDrawIconsEnabled()) {
//                Drawable icon = entry.getIcon();
//
//                double px = buffer.buffer[bufferIndex + 2]
//                    + (entry.getY() >= 0 ? posOffset : negOffset);
//                double py = buffer.buffer[bufferIndex + 1];
//
//                px += iconsOffset.x;
//                py += iconsOffset.y;
//
//                Utils.drawImage(
//                    c,
//                    icon,
//                    (int)px,
//                    (int)py,
//                    icon.getIntrinsicWidth(),
//                    icon.getIntrinsicHeight());
//              }
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
//todo
//                if (entry.getIcon() != null && dataSet.isDrawIconsEnabled()) {
//                  Drawable icon = entry.getIcon();
//
//                  Utils.drawImage(
//                      c,
//                      icon,
//                      (int)(x + iconsOffset.x),
//                      (int)(y + iconsOffset.y),
//                      icon.getIntrinsicWidth(),
//                      icon.getIntrinsicHeight());
//                }
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
    mValuePaint = TextPainter(
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
        text: TextSpan(
            text: valueText,
            style: TextStyle(
                color: color, fontSize: mValuePaint.text.style.fontSize)));
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

    mCenterTextPaint = TextPainter(
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
        text: TextSpan(
            style: TextStyle(
                color: ColorUtils.BLACK,
                fontSize: Utils.convertDpToPixel(12))));
    mValuePaint = TextPainter(
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
        text: TextSpan(
            style: TextStyle(
                color: ColorUtils.WHITE, fontSize: Utils.convertDpToPixel(9))));

    mEntryLabelsPaint = TextPainter(
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
        text: TextSpan(
            style: TextStyle(
                color: ColorUtils.WHITE,
                fontSize: Utils.convertDpToPixel(10))));

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

          if (dataSet.getValueLineColor() != ColorTemplate.COLOR_NONE) {
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
            drawValue(c, formattedValue, labelPtx, labelPty + lineHeight / 2.0,
                dataSet.getValueTextColor2(j));
          }
        }

        if (drawXInside || drawYInside) {
          // calculate the text position
          double x = labelRadius * sliceXBase + center.x;
          double y = labelRadius * sliceYBase + center.y;

          // draw everything, depending on settings
          if (drawXInside && drawYInside) {
            drawValue(c, formattedValue, x, y, dataSet.getValueTextColor2(j));

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
    mEntryLabelsPaint = TextPainter(
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
        text: TextSpan(
            text: label,
            style: TextStyle(
                color: ColorUtils.WHITE,
                fontSize: Utils.convertDpToPixel(10))));
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

  Path mDrawCenterTextPathBuffer = new Path();

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

      if (!(centerText == mCenterTextLastValue) ||
          !(mRectBuffer[1] == mCenterTextLastBounds)) {
        // Next time we won't recalculate StaticLayout...
        mCenterTextLastBounds = Rect.fromLTRB(mRectBuffer[1].left,
            mRectBuffer[1].top, mRectBuffer[1].right, mRectBuffer[1].bottom);
        mCenterTextLastValue = centerText;

        double width = mCenterTextLastBounds.width;

        // If width is 0, it will crash. Always have a minimum of 1 todo
//        mCenterTextLayout = new StaticLayout(centerText, 0, centerText.length(),
//            mCenterTextPaint,
//            (int) Math.max(Math.ceil(width), 1.f),
//    Layout.Alignment.ALIGN_CENTER, 1.f, 0.0, false);
      }

      //double layoutWidth = Utils.getStaticLayoutMaxWidth(mCenterTextLayout);
//      double layoutHeight = mCenterTextLayout.getHeight(); todo

//      c.save();
//      if (Build.VERSION.SDK_INT >= 18) {
//        Path path = mDrawCenterTextPathBuffer;
//        path.reset();
//        path.addOval(holeRect, Path.Direction.CW);
//        c.clipPath(path);
//      }

//      c.translate(mRectBuffer[1].left,
//          mRectBuffer[1].top + (mRectBuffer[1].height() - layoutHeight) / 2.0);
//      mCenterTextLayout.draw(c);
//
//      c.restore();

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
