import 'dart:math';

import 'package:flutter/painting.dart';
import 'package:mp_flutter_chart/chart/mp/color.dart';
import 'package:mp_flutter_chart/chart/mp/core/component.dart';
import 'package:mp_flutter_chart/chart/mp/poolable/size.dart';
import 'package:mp_flutter_chart/chart/mp/util.dart';
import 'package:mp_flutter_chart/chart/mp/core/view_port.dart';

enum LegendForm {
  /**
   * Avoid drawing a form
   */
  NONE,

  /**
   * Do not draw the a form, but leave space for it
   */
  EMPTY,

  /**
   * Use default (default dataset's form to the legend's form)
   */
  DEFAULT,

  /**
   * Draw a square
   */
  SQUARE,

  /**
   * Draw a circle
   */
  CIRCLE,

  /**
   * Draw a horizontal line
   */
  LINE
}

enum LegendHorizontalAlignment { LEFT, CENTER, RIGHT }

enum LegendVerticalAlignment { TOP, CENTER, BOTTOM }

enum LegendOrientation { HORIZONTAL, VERTICAL }

enum LegendDirection { LEFT_TO_RIGHT, RIGHT_TO_LEFT }

class Legend extends ComponentBase {
  /**
   * The legend entries array
   */
  List<LegendEntry> mEntries = List();

  /**
   * Entries that will be appended to the end of the auto calculated entries after calculating the legend.
   * (if the legend has already been calculated, you will need to call notifyDataSetChanged() to let the changes take effect)
   */
  List<LegendEntry> mExtraEntries;

  /**
   * Are the legend labels/colors a custom value or auto calculated? If false,
   * then it's auto, if true, then custom. default false (automatic legend)
   */
  bool mIsLegendCustom = false;

  LegendHorizontalAlignment mHorizontalAlignment =
      LegendHorizontalAlignment.LEFT;
  LegendVerticalAlignment mVerticalAlignment = LegendVerticalAlignment.BOTTOM;
  LegendOrientation mOrientation = LegendOrientation.HORIZONTAL;
  bool mDrawInside = false;

  /**
   * the text direction for the legend
   */
  LegendDirection mDirection = LegendDirection.LEFT_TO_RIGHT;

  /**
   * the shape/form the legend colors are drawn in
   */
  LegendForm mShape = LegendForm.SQUARE;

  /**
   * the size of the legend forms/shapes
   */
  double mFormSize = 8;

  /**
   * the size of the legend forms/shapes
   */
  double mFormLineWidth = 3;

  /**
   * Line dash path effect used for shapes that consist of lines.
   */
//   DashPathEffect mFormLineDashEffect = null;

  /**
   * the space between the legend entries on a horizontal axis, default 6f
   */
  double mXEntrySpace = 6;

  /**
   * the space between the legend entries on a vertical axis, default 5f
   */
  double mYEntrySpace = 0;

  /**
   * the space between the legend entries on a vertical axis, default 2f
   *  double mYEntrySpace = 2f;  the space between the form and the
   * actual label/text
   */
  double mFormToTextSpace = 5;

  /**
   * the space that should be left between stacked forms
   */
  double mStackSpace = 3;

  /**
   * the maximum relative size out of the whole chart view in percent
   */
  double mMaxSizePercent = 0.95;

  /**
   * default constructor
   */
  Legend() {
    this.mTextSize = Utils.convertDpToPixel(10);
    this.mXOffset = Utils.convertDpToPixel(5);
    this.mYOffset = Utils.convertDpToPixel(3); // 2
  }

  /**
   * Constructor. Provide entries for the legend.
   *
   * @param entries
   */
  Legend.fromList(List<LegendEntry> entries) {
    this.mTextSize = Utils.convertDpToPixel(10);
    this.mXOffset = Utils.convertDpToPixel(5);
    this.mYOffset = Utils.convertDpToPixel(3);
    if (entries == null) {
      throw new Exception("entries array is NULL");
    }

    this.mEntries = entries;
  }

  /**
   * This method sets the automatically computed colors for the legend. Use setCustom(...) to set custom colors.
   *
   * @param entries
   */
  void setEntries(List<LegendEntry> entries) {
    mEntries = entries;
  }

  List<LegendEntry> getEntries() {
    return mEntries;
  }

  /**
   * returns the maximum length in pixels across all legend labels + formsize
   * + formtotextspace
   *
   * @param p the paint object used for rendering the text
   * @return
   */
  double getMaximumEntryWidth(TextPainter p) {
    double max = 0;
    double maxFormSize = 0;
    double formToTextSpace = Utils.convertDpToPixel(mFormToTextSpace);
    for (LegendEntry entry in mEntries) {
      final double formSize = Utils.convertDpToPixel(
          double.nan == entry.formSize ? mFormSize : entry.formSize);
      if (formSize > maxFormSize) maxFormSize = formSize;

      String label = entry.label;
      if (label == null) continue;

      double length = Utils.calcTextWidth(p, label).toDouble();

      if (length > max) max = length;
    }

    return max + maxFormSize + formToTextSpace;
  }

  /**
   * returns the maximum height in pixels across all legend labels
   *
   * @param p the paint object used for rendering the text
   * @return
   */
  double getMaximumEntryHeight(TextPainter p) {
    double max = 0;
    for (LegendEntry entry in mEntries) {
      String label = entry.label;
      if (label == null) continue;

      double length = Utils.calcTextHeight(p, label).toDouble();

      if (length > max) max = length;
    }

    return max;
  }

  List<LegendEntry> getExtraEntries() {
    return mExtraEntries;
  }

  void setExtra1(List<LegendEntry> entries) {
    mExtraEntries = entries;
  }

  /**
   * Entries that will be appended to the end of the auto calculated
   *   entries after calculating the legend.
   * (if the legend has already been calculated, you will need to call notifyDataSetChanged()
   *   to let the changes take effect)
   */
  void setExtra2(List<Color> colors, List<String> labels) {
    List<LegendEntry> entries = List();
    for (int i = 0; i < min(colors.length, labels.length); i++) {
      final LegendEntry entry = LegendEntry.empty();
      entry.formColor = colors[i];
      entry.label = labels[i];

      if (entry.formColor == ColorTemplate.COLOR_SKIP || entry.formColor == 0)
        entry.form = LegendForm.NONE;
      else if (entry.formColor == ColorTemplate.COLOR_NONE)
        entry.form = LegendForm.EMPTY;

      entries.add(entry);
    }

    mExtraEntries = entries;
  }

  /**
   * Sets a custom legend's entries array.
   * * A null label will start a group.
   * This will disable the feature that automatically calculates the legend
   *   entries from the datasets.
   * Call resetCustom() to re-enable automatic calculation (and then
   *   notifyDataSetChanged() is needed to auto-calculate the legend again)
   */
  void setCustom(List<LegendEntry> entries) {
    mEntries = entries;
    mIsLegendCustom = true;
  }

  /**
   * Calling this will disable the custom legend entries (set by
   * setCustom(...)). Instead, the entries will again be calculated
   * automatically (after notifyDataSetChanged() is called).
   */
  void resetCustom() {
    mIsLegendCustom = false;
  }

  /**
   * @return true if a custom legend entries has been set default
   * false (automatic legend)
   */
  bool isLegendCustom() {
    return mIsLegendCustom;
  }

  /**
   * returns the horizontal alignment of the legend
   *
   * @return
   */
  LegendHorizontalAlignment getHorizontalAlignment() {
    return mHorizontalAlignment;
  }

  /**
   * sets the horizontal alignment of the legend
   *
   * @param value
   */
  void setHorizontalAlignment(LegendHorizontalAlignment value) {
    mHorizontalAlignment = value;
  }

  /**
   * returns the vertical alignment of the legend
   *
   * @return
   */
  LegendVerticalAlignment getVerticalAlignment() {
    return mVerticalAlignment;
  }

  /**
   * sets the vertical alignment of the legend
   *
   * @param value
   */
  void setVerticalAlignment(LegendVerticalAlignment value) {
    mVerticalAlignment = value;
  }

  /**
   * returns the orientation of the legend
   *
   * @return
   */
  LegendOrientation getOrientation() {
    return mOrientation;
  }

  /**
   * sets the orientation of the legend
   *
   * @param value
   */
  void setOrientation(LegendOrientation value) {
    mOrientation = value;
  }

  /**
   * returns whether the legend will draw inside the chart or outside
   *
   * @return
   */
  bool isDrawInsideEnabled() {
    return mDrawInside;
  }

  /**
   * sets whether the legend will draw inside the chart or outside
   *
   * @param value
   */
  void setDrawInside(bool value) {
    mDrawInside = value;
  }

  /**
   * returns the text direction of the legend
   *
   * @return
   */
  LegendDirection getDirection() {
    return mDirection;
  }

  /**
   * sets the text direction of the legend
   *
   * @param pos
   */
  void setDirection(LegendDirection pos) {
    mDirection = pos;
  }

  /**
   * returns the current form/shape that is set for the legend
   *
   * @return
   */
  LegendForm getForm() {
    return mShape;
  }

  /**
   * sets the form/shape of the legend forms
   *
   * @param shape
   */
  void setForm(LegendForm shape) {
    mShape = shape;
  }

  /**
   * sets the size in dp of the legend forms, default 8f
   *
   * @param size
   */
  void setFormSize(double size) {
    mFormSize = size;
  }

  /**
   * returns the size in dp of the legend forms
   *
   * @return
   */
  double getFormSize() {
    return mFormSize;
  }

  /**
   * sets the line width in dp for forms that consist of lines, default 3f
   *
   * @param size
   */
  void setFormLineWidth(double size) {
    mFormLineWidth = size;
  }

  /**
   * returns the line width in dp for drawing forms that consist of lines
   *
   * @return
   */
  double getFormLineWidth() {
    return mFormLineWidth;
  }

  /**
   * Sets the line dash path effect used for shapes that consist of lines.
   *
   * @param dashPathEffect
   */
//   void setFormLineDashEffect(DashPathEffect dashPathEffect) {
//    mFormLineDashEffect = dashPathEffect;
//  }

  /**
   * @return The line dash path effect used for shapes that consist of lines.
   */
//   DashPathEffect getFormLineDashEffect() {
//    return mFormLineDashEffect;
//  }

  /**
   * returns the space between the legend entries on a horizontal axis in
   * pixels
   *
   * @return
   */
  double getXEntrySpace() {
    return mXEntrySpace;
  }

  /**
   * sets the space between the legend entries on a horizontal axis in pixels,
   * converts to dp internally
   *
   * @param space
   */
  void setXEntrySpace(double space) {
    mXEntrySpace = space;
  }

  /**
   * returns the space between the legend entries on a vertical axis in pixels
   *
   * @return
   */
  double getYEntrySpace() {
    return mYEntrySpace;
  }

  /**
   * sets the space between the legend entries on a vertical axis in pixels,
   * converts to dp internally
   *
   * @param space
   */
  void setYEntrySpace(double space) {
    mYEntrySpace = space;
  }

  /**
   * returns the space between the form and the actual label/text
   *
   * @return
   */
  double getFormToTextSpace() {
    return mFormToTextSpace;
  }

  /**
   * sets the space between the form and the actual label/text, converts to dp
   * internally
   *
   * @param space
   */
  void setFormToTextSpace(double space) {
    this.mFormToTextSpace = space;
  }

  /**
   * returns the space that is left out between stacked forms (with no label)
   *
   * @return
   */
  double getStackSpace() {
    return mStackSpace;
  }

  /**
   * sets the space that is left out between stacked forms (with no label)
   *
   * @param space
   */
  void setStackSpace(double space) {
    mStackSpace = space;
  }

  /**
   * the total width of the legend (needed width space)
   */
  double mNeededWidth = 0;

  /**
   * the total height of the legend (needed height space)
   */
  double mNeededHeight = 0;

  double mTextHeightMax = 0;

  double mTextWidthMax = 0;

  /**
   * flag that indicates if word wrapping is enabled
   */
  bool mWordWrapEnabled = false;

  /**
   * Should the legend word wrap? / this is currently supported only for:
   * BelowChartLeft, BelowChartRight, BelowChartCenter. / note that word
   * wrapping a legend takes a toll on performance. / you may want to set
   * maxSizePercent when word wrapping, to set the point where the text wraps.
   * / default: false
   *
   * @param enabled
   */
  void setWordWrapEnabled(bool enabled) {
    mWordWrapEnabled = enabled;
  }

  /**
   * If this is set, then word wrapping the legend is enabled. This means the
   * legend will not be cut off if too long.
   *
   * @return
   */
  bool isWordWrapEnabled() {
    return mWordWrapEnabled;
  }

  /**
   * The maximum relative size out of the whole chart view. / If the legend is
   * to the right/left of the chart, then this affects the width of the
   * legend. / If the legend is to the top/bottom of the chart, then this
   * affects the height of the legend. / If the legend is the center of the
   * piechart, then this defines the size of the rectangular bounds out of the
   * size of the "hole". / default: 0.95f (95%)
   *
   * @return
   */
  double getMaxSizePercent() {
    return mMaxSizePercent;
  }

  /**
   * The maximum relative size out of the whole chart view. / If
   * the legend is to the right/left of the chart, then this affects the width
   * of the legend. / If the legend is to the top/bottom of the chart, then
   * this affects the height of the legend. / default: 0.95f (95%)
   *
   * @param maxSize
   */
  void setMaxSizePercent(double maxSize) {
    mMaxSizePercent = maxSize;
  }

  List<FSize> mCalculatedLabelSizes = List(16);
  List<bool> mCalculatedLabelBreakPoints = List(16);
  List<FSize> mCalculatedLineSizes = List(16);

  List<FSize> getCalculatedLabelSizes() {
    return mCalculatedLabelSizes;
  }

  List<bool> getCalculatedLabelBreakPoints() {
    return mCalculatedLabelBreakPoints;
  }

  List<FSize> getCalculatedLineSizes() {
    return mCalculatedLineSizes;
  }

  /**
   * Calculates the dimensions of the Legend. This includes the maximum width
   * and height of a single entry, as well as the total width and height of
   * the Legend.
   *
   * @param labelpaint
   */
  void calculateDimensions(
      TextPainter labelpainter, ViewPortHandler viewPortHandler) {
    double defaultFormSize = Utils.convertDpToPixel(mFormSize);
    double stackSpace = Utils.convertDpToPixel(mStackSpace);
    double formToTextSpace = Utils.convertDpToPixel(mFormToTextSpace);
    double xEntrySpace = Utils.convertDpToPixel(mXEntrySpace);
    double yEntrySpace = Utils.convertDpToPixel(mYEntrySpace);
    bool wordWrapEnabled = mWordWrapEnabled;
    List<LegendEntry> entries = mEntries;
    int entryCount = entries.length;

    mTextWidthMax = getMaximumEntryWidth(labelpainter);
    mTextHeightMax = getMaximumEntryHeight(labelpainter);

    switch (mOrientation) {
      case LegendOrientation.VERTICAL:
        {
          double maxWidth = 0, maxHeight = 0, width = 0;
          double labelLineHeight = Utils.getLineHeight1(labelpainter);
          bool wasStacked = false;

          for (int i = 0; i < entryCount; i++) {
            LegendEntry e = entries[i];
            bool drawingForm = e.form != LegendForm.NONE;
            double formSize = e.formSize == double.nan
                ? defaultFormSize
                : Utils.convertDpToPixel(e.formSize);
            String label = e.label;

            if (!wasStacked) width = 0;

            if (drawingForm) {
              if (wasStacked) width += stackSpace;
              width += formSize;
            }

            // grouped forms have null labels
            if (label != null) {
              // make a step to the left
              if (drawingForm && !wasStacked)
                width += formToTextSpace;
              else if (wasStacked) {
                maxWidth = max(maxWidth, width);
                maxHeight += labelLineHeight + yEntrySpace;
                width = 0;
                wasStacked = false;
              }

              width += Utils.calcTextWidth(labelpainter, label);

              if (i < entryCount - 1)
                maxHeight += labelLineHeight + yEntrySpace;
            } else {
              wasStacked = true;
              width += formSize;
              if (i < entryCount - 1) width += stackSpace;
            }

            maxWidth = max(maxWidth, width);
          }

          mNeededWidth = maxWidth;
          mNeededHeight = maxHeight;

          break;
        }
      case LegendOrientation.HORIZONTAL:
        {
          double labelLineHeight = Utils.getLineHeight1(labelpainter);
          double labelLineSpacing =
              Utils.getLineSpacing1(labelpainter) + yEntrySpace;
          double contentWidth =
              viewPortHandler.contentWidth() * mMaxSizePercent;

          // Start calculating layout
          double maxLineWidth = 0;
          double currentLineWidth = 0;
          double requiredWidth = 0;
          int stackedStartIndex = -1;

          mCalculatedLabelBreakPoints = List();
          mCalculatedLabelSizes = List();
          mCalculatedLineSizes = List();

          for (int i = 0; i < entryCount; i++) {
            LegendEntry e = entries[i];
            bool drawingForm = e.form != LegendForm.NONE;
            double formSize = e.formSize == double.nan
                ? defaultFormSize
                : Utils.convertDpToPixel(e.formSize);
            String label = e.label;

            mCalculatedLabelBreakPoints.add(false);

            if (stackedStartIndex == -1) {
              // we are not stacking, so required width is for this label
              // only
              requiredWidth = 0;
            } else {
              // add the spacing appropriate for stacked labels/forms
              requiredWidth += stackSpace;
            }

            // grouped forms have null labels
            if (label != null) {
              mCalculatedLabelSizes
                  .add(Utils.calcTextSize1(labelpainter, label));
              requiredWidth += drawingForm ? formToTextSpace + formSize : 0;
              requiredWidth += mCalculatedLabelSizes[i].width;
            } else {
              mCalculatedLabelSizes.add(FSize.getInstance(0, 0));
              requiredWidth += drawingForm ? formSize : 0;

              if (stackedStartIndex == -1) {
                // mark this index as we might want to break here later
                stackedStartIndex = i;
              }
            }

            if (label != null || i == entryCount - 1) {
              double requiredSpacing = currentLineWidth == 0 ? 0 : xEntrySpace;

              if (!wordWrapEnabled // No word wrapping, it must fit.
                  // The line is empty, it must fit
                  ||
                  currentLineWidth == 0
                  // It simply fits
                  ||
                  (contentWidth - currentLineWidth >=
                      requiredSpacing + requiredWidth)) {
                // Expand current line
                currentLineWidth += requiredSpacing + requiredWidth;
              } else {
                // It doesn't fit, we need to wrap a line

                // Add current line size to array
                mCalculatedLineSizes
                    .add(FSize.getInstance(currentLineWidth, labelLineHeight));
                maxLineWidth = max(maxLineWidth, currentLineWidth);

                // Start a new line
                mCalculatedLabelBreakPoints.insert(
                    stackedStartIndex > -1 ? stackedStartIndex : i, true);
                currentLineWidth = requiredWidth;
              }

              if (i == entryCount - 1) {
                // Add last line size to array
                mCalculatedLineSizes
                    .add(FSize.getInstance(currentLineWidth, labelLineHeight));
                maxLineWidth = max(maxLineWidth, currentLineWidth);
              }
            }

            stackedStartIndex = label != null ? -1 : stackedStartIndex;
          }

          mNeededWidth = maxLineWidth;
          mNeededHeight =
              labelLineHeight * (mCalculatedLineSizes.length).toDouble() +
                  labelLineSpacing *
                      (mCalculatedLineSizes.length == 0
                          ? 0
                          : (mCalculatedLineSizes.length - 1));

          break;
        }
    }

    mNeededHeight += mYOffset;
    mNeededWidth += mXOffset;
  }
}

class LegendEntry {
  LegendEntry.empty();

  LegendEntry(
      String label,
      LegendForm form,
      double formSize,
      double formLineWidth,
//      DashPathEffect formLineDashEffect,
      Color formColor) {
    this.label = label;
    this.form = form;
    this.formSize = formSize;
    this.formLineWidth = formLineWidth;
//    this.formLineDashEffect = formLineDashEffect;
    this.formColor = formColor;
  }

  /**
   * The legend entry text.
   * A `null` label will start a group.
   */
  String label;

  /**
   * The form to draw for this entry.
   *
   * `NONE` will avoid drawing a form, and any related space.
   * `EMPTY` will avoid drawing a form, but keep its space.
   * `DEFAULT` will use the Legend's default.
   */
  LegendForm form = LegendForm.DEFAULT;

  /**
   * Form size will be considered except for when .None is used
   *
   * Set as NaN to use the legend's default
   */
  double formSize = double.nan;

  /**
   * Line width used for shapes that consist of lines.
   *
   * Set as NaN to use the legend's default
   */
  double formLineWidth = double.nan;

  /**
   * Line dash path effect used for shapes that consist of lines.
   *
   * Set to null to use the legend's default
   */
//   DashPathEffect formLineDashEffect = null;

  /**
   * The color for drawing the form
   */
  Color formColor = ColorTemplate.COLOR_NONE;
}
