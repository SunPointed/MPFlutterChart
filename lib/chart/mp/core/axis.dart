import 'dart:math';

import 'package:flutter/painting.dart';
import 'package:mp_flutter_chart/chart/mp/core/component.dart';
import 'package:mp_flutter_chart/chart/mp/core/format.dart';
import 'package:mp_flutter_chart/chart/mp/core/limit.dart';
import 'package:mp_flutter_chart/chart/mp/adapter_android_mp.dart';
import 'package:mp_flutter_chart/chart/mp/util.dart';

enum AxisDependency { LEFT, RIGHT }

abstract class AxisBase extends ComponentBase {
  /**
   * custom formatter that is used instead of the auto-formatter if set
   */
  ValueFormatter mAxisValueFormatter;

  Color mGridColor = ColorUtils.GRAY;

  double mGridLineWidth = 1;

  Color mAxisLineColor = ColorUtils.GRAY;

  double mAxisLineWidth = 1;

  List<double> mEntries = List();

  List<double> mCenteredEntries = List();

  /**
   * the number of entries the legend contains
   */
  int mEntryCount = 0;

  /**
   * the number of decimal digits to use
   */
  int mDecimals = 0;

  /**
   * the number of label entries the axis should have, default 6
   */
  int mLabelCount = 6;

  /**
   * the minimum interval between axis values
   */
  double mGranularity = 1.0;

  /**
   * When true, axis labels are controlled by the `granularity` property.
   * When false, axis values could possibly be repeated.
   * This could happen if two adjacent axis values are rounded to same value.
   * If using granularity this could be avoided by having fewer axis values visible.
   */
  bool mGranularityEnabled = false;

  /**
   * if true, the set number of y-labels will be forced
   */
  bool mForceLabels = false;

  /**
   * flag indicating if the grid lines for this axis should be drawn
   */
  bool mDrawGridLines = true;

  /**
   * flag that indicates if the line alongside the axis is drawn or not
   */
  bool mDrawAxisLine = true;

  /**
   * flag that indicates of the labels of this axis should be drawn or not
   */
  bool mDrawLabels = true;

  bool mCenterAxisLabels = false;

  /**
   * the path effect of the axis line that makes dashed lines possible
   */
  DashPathEffect mAxisLineDashPathEffect = null;

  /**
   * the path effect of the grid lines that makes dashed lines possible
   */
  DashPathEffect mGridDashPathEffect = null;

  /**
   * array of limit lines that can be set for the axis
   */
  List<LimitLine> mLimitLines;

  /**
   * flag indicating the limit lines layer depth
   */
  bool mDrawLimitLineBehindData = false;

  /**
   * flag indicating the grid lines layer depth
   */
  bool mDrawGridLinesBehindData = true;

  /**
   * Extra spacing for `axisMinimum` to be added to automatically calculated `axisMinimum`
   */
  double mSpaceMin = 0;

  /**
   * Extra spacing for `axisMaximum` to be added to automatically calculated `axisMaximum`
   */
  double mSpaceMax = 0;

  /**
   * flag indicating that the axis-min value has been customized
   */
  bool mCustomAxisMin = false;

  /**
   * flag indicating that the axis-max value has been customized
   */
  bool mCustomAxisMax = false;

  /**
   * don't touch this direclty, use setter
   */
  double mAxisMaximum = 0;

  /**
   * don't touch this directly, use setter
   */
  double mAxisMinimum = 0;

  /**
   * the total range of values this axis covers
   */
  double mAxisRange = 0;

  AxisBase() {
    this.mTextSize = Utils.convertDpToPixel(10);
    this.mXOffset = Utils.convertDpToPixel(5);
    this.mYOffset = Utils.convertDpToPixel(5);
    this.mLimitLines = List<LimitLine>();
  }

  /**
   * Set this to true to enable drawing the grid lines for this axis.
   *
   * @param enabled
   */
  void setDrawGridLines(bool enabled) {
    mDrawGridLines = enabled;
  }

  /**
   * Returns true if drawing grid lines is enabled for this axis.
   *
   * @return
   */
  bool isDrawGridLinesEnabled() {
    return mDrawGridLines;
  }

  /**
   * Set this to true if the line alongside the axis should be drawn or not.
   *
   * @param enabled
   */
  void setDrawAxisLine(bool enabled) {
    mDrawAxisLine = enabled;
  }

  /**
   * Returns true if the line alongside the axis should be drawn.
   *
   * @return
   */
  bool isDrawAxisLineEnabled() {
    return mDrawAxisLine;
  }

  /**
   * Centers the axis labels instead of drawing them at their original position.
   * This is useful especially for grouped BarChart.
   *
   * @param enabled
   */
  void setCenterAxisLabels(bool enabled) {
    mCenterAxisLabels = enabled;
  }

  bool isCenterAxisLabelsEnabled() {
    return mCenterAxisLabels && mEntryCount > 0;
  }

  /**
   * Sets the color of the grid lines for this axis (the horizontal lines
   * coming from each label).
   *
   * @param color
   */
  void setGridColor(Color color) {
    mGridColor = color;
  }

  /**
   * Returns the color of the grid lines for this axis (the horizontal lines
   * coming from each label).
   *
   * @return
   */
  Color getGridColor() {
    return mGridColor;
  }

  /**
   * Sets the width of the border surrounding the chart in dp.
   *
   * @param width
   */
  void setAxisLineWidth(double width) {
    mAxisLineWidth = Utils.convertDpToPixel(width);
  }

  /**
   * Returns the width of the axis line (line alongside the axis).
   *
   * @return
   */
  double getAxisLineWidth() {
    return mAxisLineWidth;
  }

  /**
   * Sets the width of the grid lines that are drawn away from each axis
   * label.
   *
   * @param width
   */
  void setGridLineWidth(double width) {
    mGridLineWidth = Utils.convertDpToPixel(width);
  }

  /**
   * Returns the width of the grid lines that are drawn away from each axis
   * label.
   *
   * @return
   */
  double getGridLineWidth() {
    return mGridLineWidth;
  }

  /**
   * Sets the color of the border surrounding the chart.
   *
   * @param color
   */
  void setAxisLineColor(Color color) {
    mAxisLineColor = color;
  }

  /**
   * Returns the color of the axis line (line alongside the axis).
   *
   * @return
   */
  Color getAxisLineColor() {
    return mAxisLineColor;
  }

  /**
   * Set this to true to enable drawing the labels of this axis (this will not
   * affect drawing the grid lines or axis lines).
   *
   * @param enabled
   */
  void setDrawLabels(bool enabled) {
    mDrawLabels = enabled;
  }

  /**
   * Returns true if drawing the labels is enabled for this axis.
   *
   * @return
   */
  bool isDrawLabelsEnabled() {
    return mDrawLabels;
  }

  /**
   * Sets the number of label entries for the y-axis max = 25, min = 2, default: 6, be aware
   * that this number is not fixed.
   *
   * @param count the number of y-axis labels that should be displayed
   */
  void setLabelCount1(int count) {
    if (count > 25) count = 25;
    if (count < 2) count = 2;

    mLabelCount = count;
    mForceLabels = false;
  }

  /**
   * sets the number of label entries for the y-axis max = 25, min = 2, default: 6, be aware
   * that this number is not
   * fixed (if force == false) and can only be approximated.
   *
   * @param count the number of y-axis labels that should be displayed
   * @param force if enabled, the set label count will be forced, meaning that the exact
   *              specified count of labels will
   *              be drawn and evenly distributed alongside the axis - this might cause labels
   *              to have uneven values
   */
  void setLabelCount2(int count, bool force) {
    setLabelCount1(count);
    mForceLabels = force;
  }

  /**
   * Returns true if focing the y-label count is enabled. Default: false
   *
   * @return
   */
  bool isForceLabelsEnabled() {
    return mForceLabels;
  }

  /**
   * Returns the number of label entries the y-axis should have
   *
   * @return
   */
  int getLabelCount() {
    return mLabelCount;
  }

  /**
   * @return true if granularity is enabled
   */
  bool isGranularityEnabled() {
    return mGranularityEnabled;
  }

  /**
   * Enabled/disable granularity control on axis value intervals. If enabled, the axis
   * interval is not allowed to go below a certain granularity. Default: false
   *
   * @param enabled
   */
  void setGranularityEnabled(bool enabled) {
    mGranularityEnabled = enabled;
  }

  /**
   * @return the minimum interval between axis values
   */
  double getGranularity() {
    return mGranularity;
  }

  /**
   * Set a minimum interval for the axis when zooming in. The axis is not allowed to go below
   * that limit. This can be used to avoid label duplicating when zooming in.
   *
   * @param granularity
   */
  void setGranularity(double granularity) {
    mGranularity = granularity;
    // set this to true if it was disabled, as it makes no sense to call this method with granularity disabled
    mGranularityEnabled = true;
  }

  /**
   * Adds a new LimitLine to this axis.
   *
   * @param l
   */
  void addLimitLine(LimitLine l) {
    mLimitLines.add(l);

    if (mLimitLines.length > 6) {
//      Log.e("MPAndroiChart",
//          "Warning! You have more than 6 LimitLines on your axis, do you really want " +
//              "that?");
    }
  }

  /**
   * Removes the specified LimitLine from the axis.
   *
   * @param l
   */
  void removeLimitLine(LimitLine l) {
    mLimitLines.remove(l);
  }

  /**
   * Removes all LimitLines from the axis.
   */
  void removeAllLimitLines() {
    mLimitLines.clear();
  }

  /**
   * Returns the LimitLines of this axis.
   *
   * @return
   */
  List<LimitLine> getLimitLines() {
    return mLimitLines;
  }

  /**
   * If this is set to true, the LimitLines are drawn behind the actual data,
   * otherwise on top. Default: false
   *
   * @param enabled
   */
  void setDrawLimitLinesBehindData(bool enabled) {
    mDrawLimitLineBehindData = enabled;
  }

  bool isDrawLimitLinesBehindDataEnabled() {
    return mDrawLimitLineBehindData;
  }

  /**
   * If this is set to false, the grid lines are draw on top of the actual data,
   * otherwise behind. Default: true
   *
   * @param enabled
   */
  void setDrawGridLinesBehindData(bool enabled) {
    mDrawGridLinesBehindData = enabled;
  }

  bool isDrawGridLinesBehindDataEnabled() {
    return mDrawGridLinesBehindData;
  }

  /**
   * Returns the longest formatted label (in terms of characters), this axis
   * contains.
   *
   * @return
   */
  String getLongestLabel() {
    String longest = "";

    for (int i = 0; i < mEntries.length; i++) {
      String text = getFormattedLabel(i);

      if (text != null && longest.length < text.length) longest = text;
    }

    return longest;
  }

  String getFormattedLabel(int index) {
    if (index < 0 || index >= mEntries.length)
      return "";
    else
      return getValueFormatter().getAxisLabel(mEntries[index], this);
  }

  /**
   * Sets the formatter to be used for formatting the axis labels. If no formatter is set, the
   * chart will
   * automatically determine a reasonable formatting (concerning decimals) for all the values
   * that are drawn inside
   * the chart. Use chart.getDefaultValueFormatter() to use the formatter calculated by the chart.
   *
   * @param f
   */
  void setValueFormatter(ValueFormatter f) {
    if (f == null)
      mAxisValueFormatter = new DefaultAxisValueFormatter(mDecimals);
    else
      mAxisValueFormatter = f;
  }

  /**
   * Returns the formatter used for formatting the axis labels.
   *
   * @return
   */
  ValueFormatter getValueFormatter() {
    if (mAxisValueFormatter == null ||
        (mAxisValueFormatter is DefaultAxisValueFormatter &&
            (mAxisValueFormatter as DefaultAxisValueFormatter)
                    .getDecimalDigits() !=
                mDecimals))
      mAxisValueFormatter = new DefaultAxisValueFormatter(mDecimals);

    return mAxisValueFormatter;
  }

  /**
   * Enables the grid line to be drawn in dashed mode, e.g. like this
   * "- - - - - -". THIS ONLY WORKS IF HARDWARE-ACCELERATION IS TURNED OFF.
   * Keep in mind that hardware acceleration boosts performance.
   *
   * @param lineLength  the length of the line pieces
   * @param spaceLength the length of space in between the pieces
   * @param phase       offset, in degrees (normally, use 0)
   */
  void enableGridDashedLine(
      double lineLength, double spaceLength, double phase) {
//    mGridDashPathEffect = new DashPathEffect(new double[]{
//    lineLength, spaceLength
//    }, phase);
  }

  /**
   * Enables the grid line to be drawn in dashed mode, e.g. like this
   * "- - - - - -". THIS ONLY WORKS IF HARDWARE-ACCELERATION IS TURNED OFF.
   * Keep in mind that hardware acceleration boosts performance.
   *
   * @param effect the DashPathEffect
   */
  void setGridDashedLine(DashPathEffect effect) {
    mGridDashPathEffect = effect;
  }

  /**
   * Disables the grid line to be drawn in dashed mode.
   */
  void disableGridDashedLine() {
    mGridDashPathEffect = null;
  }

  /**
   * Returns true if the grid dashed-line effect is enabled, false if not.
   *
   * @return
   */
  bool isGridDashedLineEnabled() {
    return mGridDashPathEffect == null ? false : true;
  }

  /**
   * returns the DashPathEffect that is set for grid line
   *
   * @return
   */
  DashPathEffect getGridDashPathEffect() {
    return mGridDashPathEffect;
  }

  /**
   * Enables the axis line to be drawn in dashed mode, e.g. like this
   * "- - - - - -". THIS ONLY WORKS IF HARDWARE-ACCELERATION IS TURNED OFF.
   * Keep in mind that hardware acceleration boosts performance.
   *
   * @param lineLength  the length of the line pieces
   * @param spaceLength the length of space in between the pieces
   * @param phase       offset, in degrees (normally, use 0)
   */
  void enableAxisLineDashedLine(
      double lineLength, double spaceLength, double phase) {
//    mAxisLineDashPathEffect = new DashPathEffect(new double[]{
//    lineLength, spaceLength
//    }, phase);
  }

  /**
   * Enables the axis line to be drawn in dashed mode, e.g. like this
   * "- - - - - -". THIS ONLY WORKS IF HARDWARE-ACCELERATION IS TURNED OFF.
   * Keep in mind that hardware acceleration boosts performance.
   *
   * @param effect the DashPathEffect
   */
  void setAxisLineDashedLine(DashPathEffect effect) {
    mAxisLineDashPathEffect = effect;
  }

  /**
   * Disables the axis line to be drawn in dashed mode.
   */
  void disableAxisLineDashedLine() {
    mAxisLineDashPathEffect = null;
  }

  /**
   * Returns true if the axis dashed-line effect is enabled, false if not.
   *
   * @return
   */
  bool isAxisLineDashedLineEnabled() {
    return mAxisLineDashPathEffect == null ? false : true;
  }

  /**
   * returns the DashPathEffect that is set for axis line
   *
   * @return
   */
  DashPathEffect getAxisLineDashPathEffect() {
    return mAxisLineDashPathEffect;
  }

  /**
   * ###### BELOW CODE RELATED TO CUSTOM AXIS VALUES ######
   */

  double getAxisMaximum() {
    return mAxisMaximum;
  }

  double getAxisMinimum() {
    return mAxisMinimum;
  }

  /**
   * By calling this method, any custom maximum value that has been previously set is reseted,
   * and the calculation is
   * done automatically.
   */
  void resetAxisMaximum() {
    mCustomAxisMax = false;
  }

  /**
   * Returns true if the axis max value has been customized (and is not calculated automatically)
   *
   * @return
   */
  bool isAxisMaxCustom() {
    return mCustomAxisMax;
  }

  /**
   * By calling this method, any custom minimum value that has been previously set is reseted,
   * and the calculation is
   * done automatically.
   */
  void resetAxisMinimum() {
    mCustomAxisMin = false;
  }

  /**
   * Returns true if the axis min value has been customized (and is not calculated automatically)
   *
   * @return
   */
  bool isAxisMinCustom() {
    return mCustomAxisMin;
  }

  /**
   * Set a custom minimum value for this axis. If set, this value will not be calculated
   * automatically depending on
   * the provided data. Use resetAxisMinValue() to undo this. Do not forget to call
   * setStartAtZero(false) if you use
   * this method. Otherwise, the axis-minimum value will still be forced to 0.
   *
   * @param min
   */
  void setAxisMinimum(double min) {
    mCustomAxisMin = true;
    mAxisMinimum = min;
    this.mAxisRange = (mAxisMaximum - min).abs();
  }

  /**
   * Use setAxisMinimum(...) instead.
   *
   * @param min
   */
  void setAxisMinValue(double min) {
    setAxisMinimum(min);
  }

  /**
   * Set a custom maximum value for this axis. If set, this value will not be calculated
   * automatically depending on
   * the provided data. Use resetAxisMaxValue() to undo this.
   *
   * @param max
   */
  void setAxisMaximum(double max) {
    mCustomAxisMax = true;
    mAxisMaximum = max;
    this.mAxisRange = (max - mAxisMinimum).abs();
  }

  /**
   * Use setAxisMaximum(...) instead.
   *
   * @param max
   */
  void setAxisMaxValue(double max) {
    setAxisMaximum(max);
  }

  /**
   * Calculates the minimum / maximum  and range values of the axis with the given
   * minimum and maximum values from the chart data.
   *
   * @param dataMin the min value according to chart data
   * @param dataMax the max value according to chart data
   */
  void calculate(double dataMin, double dataMax) {
    // if custom, use value as is, else use data value
    double min = mCustomAxisMin ? mAxisMinimum : (dataMin - mSpaceMin);
    double max = mCustomAxisMax ? mAxisMaximum : (dataMax + mSpaceMax);

    // temporary range (before calculations)
    double range = (max - min).abs();

    // in case all values are equal
    if (range == 0) {
      max = max + 1;
      min = min - 1;
    }

    this.mAxisMinimum = min;
    this.mAxisMaximum = max;

    // actual range
    this.mAxisRange = (max - min).abs();
  }

  /**
   * Gets extra spacing for `axisMinimum` to be added to automatically calculated `axisMinimum`
   */
  double getSpaceMin() {
    return mSpaceMin;
  }

  /**
   * Sets extra spacing for `axisMinimum` to be added to automatically calculated `axisMinimum`
   */
  void setSpaceMin(double mSpaceMin) {
    this.mSpaceMin = mSpaceMin;
  }

  /**
   * Gets extra spacing for `axisMaximum` to be added to automatically calculated `axisMaximum`
   */
  double getSpaceMax() {
    return mSpaceMax;
  }

  /**
   * Sets extra spacing for `axisMaximum` to be added to automatically calculated `axisMaximum`
   */
  void setSpaceMax(double mSpaceMax) {
    this.mSpaceMax = mSpaceMax;
  }
}

enum XAxisPosition { TOP, BOTTOM, BOTH_SIDED, TOP_INSIDE, BOTTOM_INSIDE }

enum YAxisLabelPosition { OUTSIDE_CHART, INSIDE_CHART }

class XAxis extends AxisBase {
  /**
   * width of the x-axis labels in pixels - this is automatically
   * calculated by the computeSize() methods in the renderers
   */
  int mLabelWidth = 1;

  /**
   * height of the x-axis labels in pixels - this is automatically
   * calculated by the computeSize() methods in the renderers
   */
  int mLabelHeight = 1;

  /**
   * width of the (rotated) x-axis labels in pixels - this is automatically
   * calculated by the computeSize() methods in the renderers
   */
  int mLabelRotatedWidth = 1;

  /**
   * height of the (rotated) x-axis labels in pixels - this is automatically
   * calculated by the computeSize() methods in the renderers
   */
  int mLabelRotatedHeight = 1;

  /**
   * This is the angle for drawing the X axis labels (in degrees)
   */
  double mLabelRotationAngle = 0;

  /**
   * if set to true, the chart will avoid that the first and last label entry
   * in the chart "clip" off the edge of the chart
   */
  bool mAvoidFirstLastClipping = false;

  /**
   * the position of the x-labels relative to the chart
   */
  XAxisPosition mPosition = XAxisPosition.TOP;

  XAxis() : super() {
    mYOffset = Utils.convertDpToPixel(4); // -3
  }

  /**
   * returns the position of the x-labels
   */
  XAxisPosition getPosition() {
    return mPosition;
  }

  /**
   * sets the position of the x-labels
   *
   * @param pos
   */
  void setPosition(XAxisPosition pos) {
    mPosition = pos;
  }

  /**
   * returns the angle for drawing the X axis labels (in degrees)
   */
  double getLabelRotationAngle() {
    return mLabelRotationAngle;
  }

  /**
   * sets the angle for drawing the X axis labels (in degrees)
   *
   * @param angle the angle in degrees
   */
  void setLabelRotationAngle(double angle) {
    mLabelRotationAngle = angle;
  }

  /**
   * if set to true, the chart will avoid that the first and last label entry
   * in the chart "clip" off the edge of the chart or the screen
   *
   * @param enabled
   */
  void setAvoidFirstLastClipping(bool enabled) {
    mAvoidFirstLastClipping = enabled;
  }

  /**
   * returns true if avoid-first-lastclipping is enabled, false if not
   *
   * @return
   */
  bool isAvoidFirstLastClippingEnabled() {
    return mAvoidFirstLastClipping;
  }
}

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
