import 'dart:math';
import 'dart:ui';

import 'package:flutter/rendering.dart';
import 'package:mp_flutter_chart/chart/mp/core/axis.dart';
import 'package:mp_flutter_chart/chart/mp/bounds.dart';
import 'package:mp_flutter_chart/chart/mp/color.dart';
import 'package:mp_flutter_chart/chart/mp/core/data.dart';
import 'package:mp_flutter_chart/chart/mp/core/format.dart';
import 'package:mp_flutter_chart/chart/mp/core/highlight.dart';
import 'package:mp_flutter_chart/chart/mp/core/interfaces.dart';
import 'package:mp_flutter_chart/chart/mp/core/legend.dart';
import 'package:mp_flutter_chart/chart/mp/core/limit.dart';
import 'package:mp_flutter_chart/chart/mp/mode.dart';
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

        //todo  if we have a barchart with stacked bars
//        if (dataSet is IBarDataSet && (dataSet as IBarDataSet).isStacked()) {
//          IBarDataSet bds = dataSet as IBarDataSet;
//          List<String> sLabels = bds.getStackLabels();
//
//          for (int j = 0; j < clrs.length && j < bds.getStackSize(); j++) {
//            computedEntries.add(LegendEntry(
//                sLabels[j % sLabels.length],
//                dataSet.getForm(),
//                dataSet.getFormSize(),
//                dataSet.getFormLineWidth(),
////  dataSet.getFormLineDashEffect(),
//                clrs[j]));
//          }
//
//          if (bds.getLabel() != null) {
//            // add the legend description label
//            computedEntries.add(LegendEntry(
//                dataSet.getLabel(),
//                LegendForm.NONE,
//                double.nan,
//                double.nan,
////  null,
//                ColorTemplate.COLOR_NONE));
//          }
//        } else if (dataSet is IPieDataSet) {
//          IPieDataSet pds = dataSet as IPieDataSet;
//
//          for (int j = 0; j < clrs.length && j < entryCount; j++) {
//            computedEntries.add(new LegendEntry(
//                pds.getEntryForIndex(j).getLabel(),
//                dataSet.getForm(),
//                dataSet.getFormSize(),
//                dataSet.getFormLineWidth(),
////  dataSet.getFormLineDashEffect(),
//                clrs[j]));
//          }
//
//          if (pds.getLabel() != null) {
//            // add the legend description label
//            computedEntries.add(new LegendEntry(
//                dataSet.getLabel(),
//                LegendForm.NONE,
//                double.nan,
//                double.nan,
////  null,
//                ColorTemplate.COLOR_NONE));
//          }
//        } else if (dataSet is ICandleDataSet &&
//            (dataSet as ICandleDataSet).getDecreasingColor() !=
//                ColorTemplate.COLOR_NONE) {
//          Color decreasingColor =
//              (dataSet as ICandleDataSet).getDecreasingColor();
//          Color increasingColor =
//              (dataSet as ICandleDataSet).getIncreasingColor();
//
//          computedEntries.add(new LegendEntry(
//              null,
//              dataSet.getForm(),
//              dataSet.getFormSize(),
//              dataSet.getFormLineWidth(),
////  dataSet.getFormLineDashEffect(),
//              decreasingColor));
//
//          computedEntries.add(new LegendEntry(
//              dataSet.getLabel(),
//              dataSet.getForm(),
//              dataSet.getFormSize(),
//              dataSet.getFormLineWidth(),
////  dataSet.getFormLineDashEffect(),
//              increasingColor));
//        } else {
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

          computedEntries.add(new LegendEntry(
              label,
              dataSet.getForm(),
              dataSet.getFormSize(),
              dataSet.getFormLineWidth(),
//  dataSet.getFormLineDashEffect(),
              clrs[j]));
//          }
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

  // todo Paint.FontMetrics legendFontMetrics = new Paint.FontMetrics();

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
            double formSize = e.formSize == double.nan
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
            double formSize = e.formSize == double.nan
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

  Path mLineFormPath = new Path();

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
        entry.formSize == double.nan ? legend.getFormSize() : entry.formSize);
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
              entry.formLineWidth == double.nan
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
  //ChartAnimator mAnimator;

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

  DataRenderer(
      //       ChartAnimator animator,
      ViewPortHandler viewPortHandler)
      : super(viewPortHandler) {
//     this.mAnimator = animator;

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
        text: TextSpan(style: set.getValueTypeface()),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center);
  }

  /**
   * Initializes the buffers used for rendering with a new size. Since this
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

    if (labelCount == 0 || range <= 0 || range == double.infinity) {
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

    double xoffset = mYAxis.getXOffset();
    double yoffset =
        Utils.calcTextHeight(mAxisLabelPaint, "A") / 2.5 + mYAxis.getYOffset();

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
            textAlign: TextAlign.right);
        xPos = mViewPortHandler.offsetLeft() - xoffset;
      } else {
        mAxisLabelPaint = TextPainter(
            text: TextSpan(
                style: TextStyle(
                    color: mYAxis.getTextColor(),
                    fontSize: mYAxis.getTextSize())),
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.left);
        xPos = mViewPortHandler.offsetLeft() + xoffset;
      }
    } else {
      if (labelPosition == YAxisLabelPosition.OUTSIDE_CHART) {
        mAxisLabelPaint = TextPainter(
            text: TextSpan(
                style: TextStyle(
                    color: mYAxis.getTextColor(),
                    fontSize: mYAxis.getTextSize())),
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.left);
        xPos = mViewPortHandler.contentRight() + xoffset;
      } else {
        mAxisLabelPaint = TextPainter(
            text: TextSpan(
                style: TextStyle(
                    color: mYAxis.getTextColor(),
                    fontSize: mYAxis.getTextSize())),
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.right);
        xPos = mViewPortHandler.contentRight() - xoffset;
      }
    }

    drawYLabels(c, xPos, positions, yoffset);
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
      Canvas c, double fixedPosition, List<double> positions, double offset) {
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
      mAxisLabelPaint.paint(
          c,
          Offset(fixedPosition - mAxisLabelPaint.width,
              positions[i * 2 + 1] + offset - mAxisLabelPaint.height));
    }
  }

  Path mRenderGridLinesPath = new Path();

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

  Path mDrawZeroLinePath = new Path();
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

  Path mRenderLimitLines = new Path();
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

    double yoffset = mXAxis.getYOffset();

    mAxisLabelPaint.text = TextSpan(
        style: TextStyle(
            fontSize: mXAxis.getTextSize(), color: mXAxis.getTextColor()));

    MPPointF pointF = MPPointF.getInstance1(0, 0);
    if (mXAxis.getPosition() == XAxisPosition.TOP) {
      pointF.x = 0.5;
      pointF.y = 1.0;
      drawLabels(c, mViewPortHandler.contentTop() - yoffset, pointF);
    } else if (mXAxis.getPosition() == XAxisPosition.TOP_INSIDE) {
      pointF.x = 0.5;
      pointF.y = 1.0;
      drawLabels(
          c,
          mViewPortHandler.contentTop() + yoffset + mXAxis.mLabelRotatedHeight,
          pointF);
    } else if (mXAxis.getPosition() == XAxisPosition.BOTTOM) {
      pointF.x = 0.5;
      pointF.y = 0.0;
      drawLabels(c, mViewPortHandler.contentBottom() + yoffset, pointF);
    } else if (mXAxis.getPosition() == XAxisPosition.BOTTOM_INSIDE) {
      pointF.x = 0.5;
      pointF.y = 0.0;
      drawLabels(
          c,
          mViewPortHandler.contentBottom() -
              yoffset -
              mXAxis.mLabelRotatedHeight,
          pointF);
    } else {
      // BOTH SIDED
      pointF.x = 0.5;
      pointF.y = 1.0;
      drawLabels(c, mViewPortHandler.contentTop() - yoffset, pointF);
      pointF.x = 0.5;
      pointF.y = 0.0;
      drawLabels(c, mViewPortHandler.contentBottom() + yoffset, pointF);
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
  void drawLabels(Canvas c, double pos, MPPointF anchor) {
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

        drawLabel(c, label, x, pos, anchor, labelRotationAngleDegrees);
      }
    }
  }

  void drawLabel(Canvas c, String formattedLabel, double x, double y,
      MPPointF anchor, double angleDegrees) {
    Utils.drawXAxisValue(
        c, formattedLabel, x, y, mAxisLabelPaint, anchor, angleDegrees);
  }

  Path mRenderGridLinesPath = new Path();
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
  Path mLimitLinePath = new Path();

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
  XBounds mXBounds = new XBounds();

  BarLineScatterCandleBubbleRenderer(
      //      ChartAnimator animator,
      ViewPortHandler viewPortHandler)
      : super(
//      animator,
            viewPortHandler) {
    ;
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

    if (e == null
//        || entryIndex >= set.getEntryCount() * mAnimator.getPhaseX()
        ) {
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
      //      ChartAnimator animator,
      ViewPortHandler viewPortHandler)
      : super(
//      animator,
            viewPortHandler);

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
  LineRadarRenderer(
      //      ChartAnimator animator,
      ViewPortHandler viewPortHandler)
      : super(
//      animator,
            viewPortHandler);

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

  Path cubicPath = new Path();
  Path cubicFillPath = new Path();

  LineChartRenderer(
      LineDataProvider chart,
//      ChartAnimator animator,
      ViewPortHandler viewPortHandler)
      : super(
//      animator,
            viewPortHandler) {
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
//        mDrawBitmap = new WeakReference<>(drawBitmap);
//        mBitmapCanvas = new Canvas(drawBitmap);
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
//    double phaseY = mAnimator.getPhaseY();
    double phaseY = 1.0;
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
      // create a new path, this is bad for performance
      drawCubicFill(canvas, dataSet, cubicFillPath, trans, mXBounds);
    }

    canvas.drawPath(cubicPath, mRenderPaint);

//    mRenderPaint.setPathEffect(null);
  }

  void drawCubicBezier(Canvas canvas, ILineDataSet dataSet) {
//    double phaseY = mAnimator.getPhaseY();
    double phaseY = 1.0;

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

//    double phaseY = mAnimator.getPhaseY();
    double phaseY = 1.0;

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

  Path mGenerateFilledPathBuffer = new Path();

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
//    final double phaseY = mAnimator.getPhaseY();
    final double phaseY = 1;
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

    // create a new path
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

//        double[] positions = trans.generateTransformedValuesLine(dataSet, mAnimator.getPhaseX(), mAnimator
//            .getPhaseY(), mXBounds.min, mXBounds.max);
        List<double> positions = trans.generateTransformedValuesLine(
            dataSet, 1.0, 1.0, mXBounds.min, mXBounds.max);
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
        style:
            TextStyle(color: color, fontSize: mValuePaint.text.style.fontSize));
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
//  private HashMap<IDataSet, DataSetImageCache> mImageCaches = new HashMap<>();

  /**
   * buffer for drawing the circles
   */
  List<double> mCirclesBuffer = List(2);

  void drawCircles(Canvas c) {
    mRenderPaint..style = PaintingStyle.fill;

//    double phaseY = mAnimator.getPhaseY();
    double phaseY = 1.0;

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

//      Transformer trans = mChart.getTransformer(dataSet.getAxisDependency());
      trans = mChart.getTransformer(dataSet.getAxisDependency());
      mXBounds.set(mChart, dataSet);

//      double circleRadius = dataSet.getCircleRadius();
//      double circleHoleRadius = dataSet.getCircleHoleRadius();
//      bool drawCircleHole = dataSet.isDrawCircleHoleEnabled() &&
//          circleHoleRadius < circleRadius &&
//          circleHoleRadius > 0;
//      bool drawTransparentCircleHole = drawCircleHole &&
//          dataSet.getCircleHoleColor() == ColorTemplate.COLOR_NONE;

//      DataSetImageCache imageCache;
//
//      if (mImageCaches.containsKey(dataSet)) {
//        imageCache = mImageCaches.get(dataSet);
//      } else {
//        imageCache = new DataSetImageCache();
//        mImageCaches.put(dataSet, imageCache);
//      }

//      bool changeRequired = imageCache.init(dataSet);

      // only fill the cache with new bitmaps if a change is required
//      if (changeRequired) {
//        imageCache.fill(dataSet, drawCircleHole, drawTransparentCircleHole);
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

//        Bitmap circleBitmap = imageCache.getBitmap(j);

//        if (circleBitmap != null) {
//          c.drawBitmap(circleBitmap, mCirclesBuffer[0] - circleRadius, mCirclesBuffer[1] - circleRadius, null);
//        }
      }
    }
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
          .getPixelForValues(e.x, e.y * 1.0);

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
//  public void setBitmapConfig(Bitmap.Config config) {
//    mBitmapConfig = config;
//    releaseBitmap();
//  }
//
//  /**
//   * Returns the Bitmap.Config that is used by this renderer.
//   *
//   * @return
//   */
//  public Bitmap.Config getBitmapConfig() {
//    return mBitmapConfig;
//  }
//
//  /**
//   * Releases the drawing bitmap. This should be called when {@link LineChart#onDetachedFromWindow()}.
//   */
//  public void releaseBitmap() {
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

//  private class DataSetImageCache {
//
//  private Path mCirclePathBuffer = new Path();
//
//  private Bitmap[] circleBitmaps;
//
//  /**
//   * Sets up the cache, returns true if a change of cache was required.
//   *
//   * @param set
//   * @return
//   */
//  protected boolean init(ILineDataSet set) {
//
//  int size = set.getCircleColorCount();
//  boolean changeRequired = false;
//
//  if (circleBitmaps == null) {
//  circleBitmaps = new Bitmap[size];
//  changeRequired = true;
//  } else if (circleBitmaps.length != size) {
//  circleBitmaps = new Bitmap[size];
//  changeRequired = true;
//  }
//
//  return changeRequired;
//  }
//
//  /**
//   * Fills the cache with bitmaps for the given dataset.
//   *
//   * @param set
//   * @param drawCircleHole
//   * @param drawTransparentCircleHole
//   */
//  protected void fill(ILineDataSet set, boolean drawCircleHole, boolean drawTransparentCircleHole) {
//
//  int colorCount = set.getCircleColorCount();
//  float circleRadius = set.getCircleRadius();
//  float circleHoleRadius = set.getCircleHoleRadius();
//
//  for (int i = 0; i < colorCount; i++) {
//
//  Bitmap.Config conf = Bitmap.Config.ARGB_4444;
//  Bitmap circleBitmap = Bitmap.createBitmap((int) (circleRadius * 2.1), (int) (circleRadius * 2.1), conf);
//
//  Canvas canvas = new Canvas(circleBitmap);
//  circleBitmaps[i] = circleBitmap;
//  mRenderPaint.setColor(set.getCircleColor(i));
//
//  if (drawTransparentCircleHole) {
//  // Begin path for circle with hole
//  mCirclePathBuffer.reset();
//
//  mCirclePathBuffer.addCircle(
//  circleRadius,
//  circleRadius,
//  circleRadius,
//  Path.Direction.CW);
//
//  // Cut hole in path
//  mCirclePathBuffer.addCircle(
//  circleRadius,
//  circleRadius,
//  circleHoleRadius,
//  Path.Direction.CCW);
//
//  // Fill in-between
//  canvas.drawPath(mCirclePathBuffer, mRenderPaint);
//  } else {
//
//  canvas.drawCircle(
//  circleRadius,
//  circleRadius,
//  circleRadius,
//  mRenderPaint);
//
//  if (drawCircleHole) {
//  canvas.drawCircle(
//  circleRadius,
//  circleRadius,
//  circleHoleRadius,
//  mCirclePaintInner);
//  }
//  }
//  }
//  }
//
//  /**
//   * Returns the cached Bitmap at the given index.
//   *
//   * @param index
//   * @return
//   */
//  protected Bitmap getBitmap(int index) {
//  return circleBitmaps[index % circleBitmaps.length];
//  }
//  }
}
