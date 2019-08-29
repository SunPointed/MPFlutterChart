import 'dart:math';
import 'dart:ui';

import 'package:flutter/painting.dart';
import 'package:mp_flutter_chart/chart/mp/core/axis/axis_base.dart';
import 'package:mp_flutter_chart/chart/mp/core/enums/axis_dependency.dart';
import 'package:mp_flutter_chart/chart/mp/core/enums/y_axis_label_position.dart';
import 'package:mp_flutter_chart/chart/mp/core/util.dart';

class YAxis extends AxisBase {
  /**
   * indicates if the bottom y-label entry is drawn or not
   */
  bool mDrawBottomYLabelEntry = true;

  /**
   * indicates if the top y-label entry is drawn or not
   */
  bool mDrawTopYLabelEntry = true;

  /**
   * flag that indicates if the axis is inverted or not
   */
  bool mInverted = false;

  /**
   * flag that indicates if the zero-line should be drawn regardless of other grid lines
   */
  bool mDrawZeroLine = false;

  /**
   * flag indicating that auto scale min restriction should be used
   */
  bool mUseAutoScaleRestrictionMin = false;

  /**
   * flag indicating that auto scale max restriction should be used
   */
  bool mUseAutoScaleRestrictionMax = false;

  /**
   * Color of the zero line
   */
  Color mZeroLineColor = ColorUtils.GRAY;

  /**
   * Width of the zero line in pixels
   */
  double mZeroLineWidth = 1;

  /**
   * axis space from the largest value to the top in percent of the total axis range
   */
  double mSpacePercentTop = 10;

  /**
   * axis space from the smallest value to the bottom in percent of the total axis range
   */
  double mSpacePercentBottom = 10;

  /**
   * the position of the y-labels relative to the chart
   */
  YAxisLabelPosition mPosition = YAxisLabelPosition.OUTSIDE_CHART;

  /**
   * the side this axis object represents
   */
  AxisDependency mAxisDependency;

  /**
   * the minimum width that the axis should take (in dp).
   * <p/>
   * default: 0.0
   */
  double mMinWidth = 0;

  /**
   * the maximum width that the axis can take (in dp).
   * use Inifinity for disabling the maximum
   * default: Float.POSITIVE_INFINITY (no maximum specified)
   */
  double mMaxWidth = double.infinity;

  YAxis({AxisDependency position = AxisDependency.LEFT}) : super() {
    this.mAxisDependency = position;
    this.mYOffset = 0;
  }

  AxisDependency getAxisDependency() {
    return mAxisDependency;
  }

  /**
   * @return the minimum width that the axis should take (in dp).
   */
  double getMinWidth() {
    return mMinWidth;
  }

  /**
   * Sets the minimum width that the axis should take (in dp).
   *
   * @param minWidth
   */
  void setMinWidth(double minWidth) {
    mMinWidth = minWidth;
  }

  /**
   * @return the maximum width that the axis can take (in dp).
   */
  double getMaxWidth() {
    return mMaxWidth;
  }

  /**
   * Sets the maximum width that the axis can take (in dp).
   *
   * @param maxWidth
   */
  void setMaxWidth(double maxWidth) {
    mMaxWidth = maxWidth;
  }

  /**
   * returns the position of the y-labels
   */
  YAxisLabelPosition getLabelPosition() {
    return mPosition;
  }

  /**
   * sets the position of the y-labels
   *
   * @param pos
   */
  void setPosition(YAxisLabelPosition pos) {
    mPosition = pos;
  }

  /**
   * returns true if drawing the top y-axis label entry is enabled
   *
   * @return
   */
  bool isDrawTopYLabelEntryEnabled() {
    return mDrawTopYLabelEntry;
  }

  /**
   * returns true if drawing the bottom y-axis label entry is enabled
   *
   * @return
   */
  bool isDrawBottomYLabelEntryEnabled() {
    return mDrawBottomYLabelEntry;
  }

  /**
   * set this to true to enable drawing the top y-label entry. Disabling this can be helpful
   * when the top y-label and
   * left x-label interfere with each other. default: true
   *
   * @param enabled
   */
  void setDrawTopYLabelEntry(bool enabled) {
    mDrawTopYLabelEntry = enabled;
  }

  /**
   * If this is set to true, the y-axis is inverted which means that low values are on top of
   * the chart, high values
   * on bottom.
   *
   * @param enabled
   */
  void setInverted(bool enabled) {
    mInverted = enabled;
  }

  /**
   * If this returns true, the y-axis is inverted.
   *
   * @return
   */
  bool isInverted() {
    return mInverted;
  }

  /**
   * This method is deprecated.
   * Use setAxisMinimum(...) / setAxisMaximum(...) instead.
   *
   * @param startAtZero
   */
  void setStartAtZero(bool startAtZero) {
    if (startAtZero)
      setAxisMinimum(0);
    else
      resetAxisMinimum();
  }

  /**
   * Sets the top axis space in percent of the full range. Default 10f
   *
   * @param percent
   */
  void setSpaceTop(double percent) {
    mSpacePercentTop = percent;
  }

  /**
   * Returns the top axis space in percent of the full range. Default 10f
   *
   * @return
   */
  double getSpaceTop() {
    return mSpacePercentTop;
  }

  /**
   * Sets the bottom axis space in percent of the full range. Default 10f
   *
   * @param percent
   */
  void setSpaceBottom(double percent) {
    mSpacePercentBottom = percent;
  }

  /**
   * Returns the bottom axis space in percent of the full range. Default 10f
   *
   * @return
   */
  double getSpaceBottom() {
    return mSpacePercentBottom;
  }

  bool isDrawZeroLineEnabled() {
    return mDrawZeroLine;
  }

  /**
   * Set this to true to draw the zero-line regardless of weather other
   * grid-lines are enabled or not. Default: false
   *
   * @param mDrawZeroLine
   */
  void setDrawZeroLine(bool mDrawZeroLine) {
    this.mDrawZeroLine = mDrawZeroLine;
  }

  Color getZeroLineColor() {
    return mZeroLineColor;
  }

  /**
   * Sets the color of the zero line
   *
   * @param color
   */
  void setZeroLineColor(Color color) {
    mZeroLineColor = color;
  }

  double getZeroLineWidth() {
    return mZeroLineWidth;
  }

  /**
   * Sets the width of the zero line in dp
   *
   * @param width
   */
  void setZeroLineWidth(double width) {
    this.mZeroLineWidth = Utils.convertDpToPixel(width);
  }

  /**
   * This is for normal (not horizontal) charts horizontal spacing.
   *
   * @param p
   * @return
   */
  double getRequiredWidthSpace(TextPainter p) {
    p = TextPainter(
        text: TextSpan(style: TextStyle(fontSize: mTextSize)),
        textDirection: p.textDirection,
        textAlign: p.textAlign);

    String label = getLongestLabel();
    double width = Utils.calcTextWidth(p, label) + getXOffset() * 2;

    double minWidth = getMinWidth();
    double maxWidth = getMaxWidth();

    if (minWidth > 0) minWidth = Utils.convertDpToPixel(minWidth);

    if (maxWidth > 0 && maxWidth != double.infinity)
      maxWidth = Utils.convertDpToPixel(maxWidth);

    width = max(minWidth, min(width, maxWidth > 0.0 ? maxWidth : width));

    return width;
  }

  /**
   * This is for HorizontalBarChart vertical spacing.
   *
   * @param p
   * @return
   */
  double getRequiredHeightSpace(TextPainter p) {
    p = TextPainter(
        text: TextSpan(style: TextStyle(fontSize: mTextSize)),
        textDirection: p.textDirection,
        textAlign: p.textAlign);

    String label = getLongestLabel();
    return Utils.calcTextHeight(p, label) + getYOffset() * 2;
  }

  /**
   * Returns true if this axis needs horizontal offset, false if no offset is needed.
   *
   * @return
   */
  bool needsOffset() {
    if (isEnabled() &&
        isDrawLabelsEnabled() &&
        getLabelPosition() == YAxisLabelPosition.OUTSIDE_CHART)
      return true;
    else
      return false;
  }

  /**
   * Returns true if autoscale restriction for axis min value is enabled
   */
  bool isUseAutoScaleMinRestriction() {
    return mUseAutoScaleRestrictionMin;
  }

  /**
   * Sets autoscale restriction for axis min value as enabled/disabled
   */
  void setUseAutoScaleMinRestriction(bool isEnabled) {
    mUseAutoScaleRestrictionMin = isEnabled;
  }

  /**
   * Returns true if autoscale restriction for axis max value is enabled
   */
  bool isUseAutoScaleMaxRestriction() {
    return mUseAutoScaleRestrictionMax;
  }

  /**
   * Sets autoscale restriction for axis max value as enabled/disabled
   */
  void setUseAutoScaleMaxRestriction(bool isEnabled) {
    mUseAutoScaleRestrictionMax = isEnabled;
  }

  @override
  void calculate(double dataMin, double dataMax) {
    double min = dataMin;
    double max = dataMax;

    double range = (max - min).abs();

    // in case all values are equal
    if (range == 0) {
      max = max + 1;
      min = min - 1;
    }

    // recalculate
    range = (max - min).abs();

    // calc extra spacing
    this.mAxisMinimum = mCustomAxisMin
        ? this.mAxisMinimum
        : min - (range / 100) * getSpaceBottom();
    this.mAxisMaximum = mCustomAxisMax
        ? this.mAxisMaximum
        : max + (range / 100) * getSpaceTop();

    this.mAxisRange = (this.mAxisMinimum - this.mAxisMaximum).abs();
  }
}
