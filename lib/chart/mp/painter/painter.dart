import 'dart:math';

import 'package:mp_flutter_chart/chart/mp/core/common_interfaces.dart';
import 'package:flutter/widgets.dart';
import 'package:mp_flutter_chart/chart/mp/core/animator.dart';
import 'package:mp_flutter_chart/chart/mp/core/axis/x_axis.dart';
import 'package:mp_flutter_chart/chart/mp/core/data/chart_data.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_interfaces/i_data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_provider/chart_interface.dart';
import 'package:mp_flutter_chart/chart/mp/core/description.dart';
import 'package:mp_flutter_chart/chart/mp/core/entry/entry.dart';
import 'package:mp_flutter_chart/chart/mp/core/highlight/highlight.dart';
import 'package:mp_flutter_chart/chart/mp/core/highlight/i_highlighter.dart';
import 'package:mp_flutter_chart/chart/mp/core/legend/legend.dart';
import 'package:mp_flutter_chart/chart/mp/core/marker/i_marker.dart';
import 'package:mp_flutter_chart/chart/mp/core/poolable/point.dart';
import 'package:mp_flutter_chart/chart/mp/core/render/data_renderer.dart';
import 'package:mp_flutter_chart/chart/mp/core/render/legend_renderer.dart';
import 'package:mp_flutter_chart/chart/mp/core/utils/color_utils.dart';
import 'package:mp_flutter_chart/chart/mp/core/utils/painter_utils.dart';
import 'package:mp_flutter_chart/chart/mp/core/utils/utils.dart';
import 'package:mp_flutter_chart/chart/mp/core/value_formatter/default_value_formatter.dart';
import 'package:mp_flutter_chart/chart/mp/core/view_port.dart';

abstract class ChartPainter<T extends ChartData<IDataSet<Entry>>>
    extends CustomPainter implements ChartInterface, AnimatorUpdateListener {
  /// object that holds all data that was originally set for the chart, before
  /// it was modified or any filtering algorithms had been applied
  T mData = null;

  /// Flag that indicates if highlighting per tap (touch) is enabled
  bool mHighLightPerTapEnabled = true;

  /// If set to true, chart continues to scroll after touch up
  bool mDragDecelerationEnabled = true;

  /// Deceleration friction coefficient in [0 ; 1] interval, higher values
  /// indicate that speed will decrease slowly, for example if it set to 0, it
  /// will stop immediately. 1 is an invalid value, and will be converted to
  /// 0.999f automatically.
  double mDragDecelerationFrictionCoef = 0.9;

  /// default value-formatter, number of digits depends on provided chart-data
  DefaultValueFormatter mDefaultValueFormatter = new DefaultValueFormatter(0);

  /// paint object used for drawing the description text in the bottom right
  /// corner of the chart
  TextPainter mDescPaint;

  /// paint object for drawing the information text when there are no values in
  /// the chart
  TextPainter mInfoPaint;

  /// the object representing the labels on the x-axis
  XAxis mXAxis;

  /// if true, touch gestures are enabled on the chart
  bool mTouchEnabled = true;

  /// the object responsible for representing the description text
  Description mDescription;

  /// the legend object containing all data associated with the legend
  Legend mLegend;

  /// text that is displayed when the chart is empty
  String mNoDataText;

  LegendRenderer mLegendRenderer;

  /// object responsible for rendering the data
  DataRenderer mRenderer;

  Size mSize;

  IHighlighter mHighlighter;

  /// object that manages the bounds and drawing constraints of the chart
  ViewPortHandler mViewPortHandler;

  /// object responsible for animations
  ChartAnimator mAnimator;

  double mExtraTopOffset = 0,
      mExtraRightOffset = 0,
      mExtraBottomOffset = 0,
      mExtraLeftOffset = 0;

  /// unbind flag
  bool mUnbind = false;

  ChartPainter(T data,
      {ViewPortHandler viewPortHandler = null,
      ChartAnimator animator = null,
      double maxHighlightDistance = 0.0,
      bool highLightPerTapEnabled = true,
      bool dragDecelerationEnabled = true,
      double dragDecelerationFrictionCoef = 0.9,
      double extraLeftOffset = 0.0,
      double extraTopOffset = 0.0,
      double extraRightOffset = 0.0,
      double extraBottomOffset = 0.0,
      String noDataText = "No chart data available.",
      bool touchEnabled = true,
      IMarker marker = null,
      Description desc = null,
      bool drawMarkers = true,
      TextPainter infoPainter = null,
      TextPainter descPainter = null,
      IHighlighter highlighter = null,
      bool unbind = false})
      : mData = data,
        mViewPortHandler = viewPortHandler,
        mAnimator = animator,
        mMaxHighlightDistance = maxHighlightDistance,
        mHighLightPerTapEnabled = highLightPerTapEnabled,
        mDragDecelerationEnabled = dragDecelerationEnabled,
        mExtraLeftOffset = extraLeftOffset,
        mExtraTopOffset = extraTopOffset,
        mExtraRightOffset = extraRightOffset,
        mExtraBottomOffset = extraBottomOffset,
        mNoDataText = noDataText,
        mTouchEnabled = touchEnabled,
        mMarker = marker,
        mDescription = desc,
        mDrawMarkers = drawMarkers,
        mInfoPaint = infoPainter,
        mDescPaint = descPainter,
        mHighlighter = highlighter,
        mUnbind = unbind,
        super() {
    if (dragDecelerationFrictionCoef < 0) dragDecelerationFrictionCoef = 0;

    if (dragDecelerationFrictionCoef >= 1) dragDecelerationFrictionCoef = 0.999;
    mDragDecelerationFrictionCoef = dragDecelerationFrictionCoef;

    mOffsetsCalculated = false;

    if (data == null) {
      return;
    }

    // calculate how many digits are needed
    setupDefaultFormatter(data.getYMin1(), data.getYMax1());

    for (IDataSet set in mData.getDataSets()) {
      if (set.needsFormatter() ||
          set.getValueFormatter() == mDefaultValueFormatter)
        set.setValueFormatter(mDefaultValueFormatter);
    }

    init();
  }

  void init() {
    mAnimator ??= ChartAnimator(this);
    mViewPortHandler ??= ViewPortHandler();
    mMaxHighlightDistance = Utils.convertDpToPixel(500);
    mDescription ??= Description();
    mLegend = Legend();
    mLegendRenderer = LegendRenderer(mViewPortHandler, mLegend);
    mXAxis ??= XAxis();
    mDescPaint ??=
        PainterUtils.create(mDescPaint, null, ColorUtils.BLACK, null);
  }

  @override
  void onAnimationUpdate(double x, double y) {}

  /// Clears the chart from all data (sets it to null) and refreshes it (by
  /// calling invalidate()).
  void clear() {
    mData = null;
    mOffsetsCalculated = false;
    mIndicesToHighlight = null;
  }

  /// Removes all DataSets (and thereby Entries) from the chart. Does not set the data object to null. Also refreshes the
  /// chart by calling invalidate().
  void clearValues() {
    mData.clearValues();
  }

  /// Returns true if the chart is empty (meaning it's data object is either
  /// null or contains no entries).
  ///
  /// @return
  bool isEmpty() {
    if (mData == null)
      return true;
    else {
      if (mData.getEntryCount() <= 0)
        return true;
      else
        return false;
    }
  }

  /// Calculates the offsets of the chart to the border depending on the
  /// position of an eventual legend or depending on the length of the y-axis
  /// and x-axis labels and their position
  void calculateOffsets();

  /// Calculates the y-min and y-max value and the y-delta and x-delta value
  void calcMinMax();

  /// Calculates the required number of digits for the values that might be
  /// drawn in the chart (if enabled), and creates the default-value-formatter
  void setupDefaultFormatter(double min1, double max1) {
    double reference = 0;

    if (mData == null || mData.getEntryCount() < 2) {
      reference = max(min1.abs(), max1.abs());
    } else {
      reference = (max1 - min1).abs();
    }

    int digits = Utils.getDecimals(reference);

    // setup the formatter with a new number of digits
    mDefaultValueFormatter.setup(digits);
  }

  double getMeasuredHeight() {
    return mSize == null ? 0.0 : mSize.height;
  }

  double getMeasuredWidth() {
    return mSize == null ? 0.0 : mSize.width;
  }

  /// flag that indicates if offsets calculation has already been done or not
  bool mOffsetsCalculated = false;

  @override
  void paint(Canvas canvas, Size size) {
    mSize = size;

    if (mData == null) {
      bool hasText = mNoDataText.isEmpty;

      if (hasText) {
        MPPointF c = getCenter(size);
        mInfoPaint ??= PainterUtils.create(
            mInfoPaint, mNoDataText, ColorUtils.BLACK, null);

        mInfoPaint.paint(canvas, Offset(c.x, c.y));
      }

      return;
    }

    mViewPortHandler.setChartDimens(size.width, size.height);

    if (!mOffsetsCalculated) {
      calculateOffsets();
      mOffsetsCalculated = true;
    }
  }

  /// Draws the description text in the bottom right corner of the chart (per default)
  void drawDescription(Canvas c, Size size) {
    // check if description should be drawn
    if (mDescription != null && mDescription.isEnabled()) {
      MPPointF position = mDescription.getPosition();

      mDescPaint = PainterUtils.create(
          mDescPaint,
          mDescription.text,
          mDescription.getTextColor(),
          Utils.convertDpToPixel(mDescription.getTextSize()));

      double x, y;

      // if no position specified, draw on default position
      if (position == null) {
        x = size.width -
            mViewPortHandler.offsetRight() -
            mDescription.getXOffset();
        y = size.height -
            mViewPortHandler.offsetBottom() -
            mDescription.getYOffset();
      } else {
        x = position.x;
        y = position.y;
      }

      mDescPaint.paint(c, Offset(x, y));
    }
  }

  /**
   * ################ ################ ################ ################
   */
  /** BELOW THIS CODE FOR HIGHLIGHTING */

  /// array of Highlight objects that reference the highlighted slices in the
  /// chart
  List<Highlight> mIndicesToHighlight;

  /// The maximum distance in dp away from an entry causing it to highlight.
  double mMaxHighlightDistance = 0;

  @override
  double getMaxHighlightDistance() {
    return mMaxHighlightDistance;
  }

  /// Returns true if there are values to highlight, false if there are no
  /// values to highlight. Checks if the highlight array is null, has a length
  /// of zero or if the first object is null.
  ///
  /// @return
  bool valuesToHighlight() {
    var res = mIndicesToHighlight == null ||
            mIndicesToHighlight.length <= 0 ||
            mIndicesToHighlight[0] == null
        ? false
        : true;
    return res;
  }

  /// Highlights the values at the given indices in the given DataSets. Provide
  /// null or an empty array to undo all highlighting. This should be used to
  /// programmatically highlight values.
  /// This method *will not* call the listener.
  ///
  /// @param highs
  void highlightValues(List<Highlight> highs) {
    // set the indices to highlight
    mIndicesToHighlight = highs;
  }

  /// Highlights any y-value at the given x-value in the given DataSet.
  /// Provide -1 as the dataSetIndex to undo all highlighting.
  /// This method will call the listener.
  /// @param x The x-value to highlight
  /// @param dataSetIndex The dataset index to search in
  void highlightValue1(double x, int dataSetIndex) {
    highlightValue3(x, dataSetIndex, true);
  }

  /// Highlights the value at the given x-value and y-value in the given DataSet.
  /// Provide -1 as the dataSetIndex to undo all highlighting.
  /// This method will call the listener.
  /// @param x The x-value to highlight
  /// @param y The y-value to highlight. Supply `NaN` for "any"
  /// @param dataSetIndex The dataset index to search in
  void highlightValue2(double x, double y, int dataSetIndex) {
    highlightValue4(x, y, dataSetIndex, true);
  }

  /// Highlights any y-value at the given x-value in the given DataSet.
  /// Provide -1 as the dataSetIndex to undo all highlighting.
  /// @param x The x-value to highlight
  /// @param dataSetIndex The dataset index to search in
  /// @param callListener Should the listener be called for this change
  void highlightValue3(double x, int dataSetIndex, bool callListener) {
    highlightValue4(x, double.nan, dataSetIndex, callListener);
  }

  /// Highlights any y-value at the given x-value in the given DataSet.
  /// Provide -1 as the dataSetIndex to undo all highlighting.
  /// @param x The x-value to highlight
  /// @param y The y-value to highlight. Supply `NaN` for "any"
  /// @param dataSetIndex The dataset index to search in
  /// @param callListener Should the listener be called for this change
  void highlightValue4(
      double x, double y, int dataSetIndex, bool callListener) {
    if (dataSetIndex < 0 || dataSetIndex >= mData.getDataSetCount()) {
      highlightValue6(null, callListener);
    } else {
      highlightValue6(
          Highlight(x: x, y: y, dataSetIndex: dataSetIndex), callListener);
    }
  }

  /// Highlights the values represented by the provided Highlight object
  /// This method *will not* call the listener.
  ///
  /// @param highlight contains information about which entry should be highlighted
  void highlightValue5(Highlight highlight) {
    highlightValue6(highlight, false);
  }

  /// Highlights the value selected by touch gesture. Unlike
  /// highlightValues(...), this generates a callback to the
  /// OnChartValueSelectedListener.
  ///
  /// @param high         - the highlight object
  /// @param callListener - call the listener
  void highlightValue6(Highlight high, bool callListener) {
    Entry e = null;

    if (high == null) {
      mIndicesToHighlight = null;
    } else {
      e = mData.getEntryForHighlight(high);
      if (e == null) {
        mIndicesToHighlight = null;
        high = null;
      } else {
        // set the indices to highlight
        mIndicesToHighlight = List()..add(high);
      }
    }

    if (callListener && _selectionListener != null) {
      if (!valuesToHighlight())
        _selectionListener.onNothingSelected();
      else {
        // notify the listener
        _selectionListener.onValueSelected(e, high);
      }
    }
  }

  OnChartValueSelectedListener _selectionListener;

  void setOnChartValueSelectedListener(OnChartValueSelectedListener l) {
    this._selectionListener = l;
  }

  OnChartGestureListener _gestureListener;

  void setOnChartGestureListener(OnChartGestureListener l) {
    this._gestureListener = l;
  }

  OnChartGestureListener getOnChartGestureListener() {
    return _gestureListener;
  }

  /// Returns the Highlight object (contains x-index and DataSet index) of the
  /// selected value at the given touch point inside the Line-, Scatter-, or
  /// CandleStick-Chart.
  ///
  /// @param x
  /// @param y
  /// @return
  Highlight getHighlightByTouchPoint(double x, double y) {
    if (mData == null) {
      return null;
    } else {
      return mHighlighter.getHighlight(x, y);
    }
  }

  /** BELOW CODE IS FOR THE MARKER VIEW */

  /// if set to true, the marker view is drawn when a value is clicked
  bool mDrawMarkers = true;

  /// the view that represents the marker
  IMarker mMarker;

  /// draws all MarkerViews on the highlighted positions
  void drawMarkers(Canvas canvas) {
    if (mMarker == null || !isDrawMarkersEnabled() || !valuesToHighlight())
      return;

    for (int i = 0; i < mIndicesToHighlight.length; i++) {
      Highlight highlight = mIndicesToHighlight[i];

      IDataSet set = mData.getDataSetByIndex(highlight.getDataSetIndex());

      Entry e = mData.getEntryForHighlight(mIndicesToHighlight[i]);
      int entryIndex = set.getEntryIndex2(e);
      // make sure entry not null
      if (e == null || entryIndex > set.getEntryCount() * mAnimator.getPhaseX())
        continue;

      List<double> pos = getMarkerPosition(highlight);

      // check bounds
      if (!mViewPortHandler.isInBounds(pos[0], pos[1])) continue;

      // callbacks to update the content
      mMarker.refreshContent(e, highlight);

      // draw the marker
      mMarker.draw(canvas, pos[0], pos[1]);
    }
  }

  /// Returns the actual position in pixels of the MarkerView for the given
  /// Highlight object.
  ///
  /// @param high
  /// @return
  List<double> getMarkerPosition(Highlight high) {
    return List<double>()..add(high.getDrawX())..add(high.getDrawY());
  }

  /// returns the current y-max value across all DataSets
  ///
  /// @return
  double getYMax() {
    return mData.getYMax1();
  }

  /// returns the current y-min value across all DataSets
  ///
  /// @return
  double getYMin() {
    return mData.getYMin1();
  }

  @override
  double getXChartMax() {
    return mXAxis.mAxisMaximum;
  }

  @override
  double getXChartMin() {
    return mXAxis.mAxisMinimum;
  }

  @override
  double getXRange() {
    return mXAxis.mAxisRange;
  }

  /// Returns a recyclable MPPointF instance.
  /// Returns the center point of the chart (the whole View) in pixels.
  ///
  /// @return
  MPPointF getCenter(Size size) {
    return MPPointF.getInstance1(size.width / 2, size.height / 2);
  }

  /// Returns a recyclable MPPointF instance.
  /// Returns the center of the chart taking offsets under consideration.
  /// (returns the center of the content rectangle)
  ///
  /// @return
  @override
  MPPointF getCenterOffsets() {
    return mViewPortHandler.getContentCenter();
  }

  /// returns true if drawing the marker is enabled when tapping on values
  /// (use the setMarker(IMarker marker) method to specify a marker)
  ///
  /// @return
  bool isDrawMarkersEnabled() {
    return mDrawMarkers;
  }

  /// Returns the ChartData object that has been set for the chart.
  ///
  /// @return
  T getData() {
    return mData;
  }

  void reassemble();
}
