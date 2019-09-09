import 'package:flutter/painting.dart';
import 'package:mp_flutter_chart/chart/mp/core/data/chart_data.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_interfaces/i_bar_data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_interfaces/i_candle_data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_interfaces/i_data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_interfaces/i_pie_data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/enums/legend_direction.dart';
import 'package:mp_flutter_chart/chart/mp/core/enums/legend_form.dart';
import 'package:mp_flutter_chart/chart/mp/core/enums/legend_horizontal_alignment.dart';
import 'package:mp_flutter_chart/chart/mp/core/enums/legend_orientation.dart';
import 'package:mp_flutter_chart/chart/mp/core/enums/legend_vertical_alignment.dart';
import 'package:mp_flutter_chart/chart/mp/core/legend/legend.dart';
import 'package:mp_flutter_chart/chart/mp/core/legend/legend_entry.dart';
import 'package:mp_flutter_chart/chart/mp/core/render/renderer.dart';
import 'package:mp_flutter_chart/chart/mp/core/utils/color_utils.dart';
import 'package:mp_flutter_chart/chart/mp/core/view_port.dart';
import 'package:mp_flutter_chart/chart/mp/core/poolable/size.dart';
import 'package:mp_flutter_chart/chart/mp/core/utils/utils.dart';

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
                ColorUtils.COLOR_NONE));
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
                ColorUtils.COLOR_NONE));
          }
        } else if (dataSet is ICandleDataSet &&
            (dataSet as ICandleDataSet).getDecreasingColor() !=
                ColorUtils.COLOR_NONE) {
          Color decreasingColor =
              (dataSet as ICandleDataSet).getDecreasingColor();
          Color increasingColor =
              (dataSet as ICandleDataSet).getIncreasingColor();

          computedEntries.add(LegendEntry(
              null,
              dataSet.getForm(),
              dataSet.getFormSize(),
              dataSet.getFormLineWidth(),
//  dataSet.getFormLineDashEffect(),
              decreasingColor));

          computedEntries.add(LegendEntry(
              dataSet.getLabel(),
              dataSet.getForm(),
              dataSet.getFormSize(),
              dataSet.getFormLineWidth(),
//  dataSet.getFormLineDashEffect(),
              increasingColor));
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
    if (entry.formColor == ColorUtils.COLOR_SKIP ||
        entry.formColor == ColorUtils.COLOR_NONE) return;

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
