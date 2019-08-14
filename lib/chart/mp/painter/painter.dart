import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:mp_flutter_chart/chart/mp/core/axis.dart';
import 'package:mp_flutter_chart/chart/mp/core/data.dart';
import 'package:mp_flutter_chart/chart/mp/core/description.dart';
import 'package:mp_flutter_chart/chart/mp/core/format.dart';
import 'package:mp_flutter_chart/chart/mp/core/highlight.dart';
import 'package:mp_flutter_chart/chart/mp/core/interfaces.dart';
import 'package:mp_flutter_chart/chart/mp/core/legend.dart';
import 'package:mp_flutter_chart/chart/mp/poolable/point.dart';
import 'package:mp_flutter_chart/chart/mp/core/render.dart';
import 'package:mp_flutter_chart/chart/mp/util.dart';
import 'package:mp_flutter_chart/chart/mp/core/view_port.dart';

abstract class ChartPainter<T extends ChartData<IDataSet<Entry>>>
    extends CustomPainter implements ChartInterface {
  /**
   * object that holds all data that was originally set for the chart, before
   * it was modified or any filtering algorithms had been applied
   */
  T mData = null;

  /**
   * Flag that indicates if highlighting per tap (touch) is enabled
   */
  bool mHighLightPerTapEnabled = true;

  /**
   * If set to true, chart continues to scroll after touch up
   */
  bool mDragDecelerationEnabled = true;

  /**
   * Deceleration friction coefficient in [0 ; 1] interval, higher values
   * indicate that speed will decrease slowly, for example if it set to 0, it
   * will stop immediately. 1 is an invalid value, and will be converted to
   * 0.999f automatically.
   */
  double mDragDecelerationFrictionCoef = 0.9;

  /**
   * default value-formatter, number of digits depends on provided chart-data
   */
  DefaultValueFormatter mDefaultValueFormatter = new DefaultValueFormatter(0);

  /**
   * paint object used for drawing the description text in the bottom right
   * corner of the chart
   */
  TextPainter mDescPaint;

  /**
   * paint object for drawing the information text when there are no values in
   * the chart
   */
  TextPainter mInfoPaint;

  /**
   * the object representing the labels on the x-axis
   */
  XAxis mXAxis;

  /**
   * if true, touch gestures are enabled on the chart
   */
  bool mTouchEnabled = true;

  /**
   * the object responsible for representing the description text
   */
  Description mDescription;

  /**
   * the legend object containing all data associated with the legend
   */
  Legend mLegend;

  /**
   * text that is displayed when the chart is empty
   */
  String mNoDataText;

  /**
   * Gesture listener for custom callbacks when making gestures on the chart.
   */
  // todo OnChartGestureListener mGestureListener;

  LegendRenderer mLegendRenderer;

  /**
   * object responsible for rendering the data
   */
  DataRenderer mRenderer;

  Size mSize;

  IHighlighter mHighlighter;

  /**
   * object that manages the bounds and drawing constraints of the chart
   */
  ViewPortHandler mViewPortHandler;

  /**
   * object responsible for animations
   */
  //todo ChartAnimator mAnimator;

  double mExtraTopOffset = 0,
      mExtraRightOffset = 0,
      mExtraBottomOffset = 0,
      mExtraLeftOffset = 0;

  /**
   * unbind flag
   */
  bool mUnbind = false;

  ChartPainter(T data,
      {ViewPortHandler viewPortHandler = null,
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
    mViewPortHandler ??= ViewPortHandler();
    mMaxHighlightDistance = Utils.convertDpToPixel(500);
    mDescription ??= Description();
    mLegend = Legend();
    mLegendRenderer = LegendRenderer(mViewPortHandler, mLegend);
    mXAxis = XAxis();
    mDescPaint ??= TextPainter(
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
        text: TextSpan(style: TextStyle(color: ColorUtils.BLACK)));
  }

  /**
   * Clears the chart from all data (sets it to null) and refreshes it (by
   * calling invalidate()).
   */
  void clear() {
    mData = null;
    mOffsetsCalculated = false;
    mIndicesToHighlight = null;
//    mChartTouchListener.setLastHighlighted(null);
//    invalidate();
  }

  /**
   * Removes all DataSets (and thereby Entries) from the chart. Does not set the data object to null. Also refreshes the
   * chart by calling invalidate().
   */
  void clearValues() {
    mData.clearValues();
//    invalidate();
  }

  /**
   * Returns true if the chart is empty (meaning it's data object is either
   * null or contains no entries).
   *
   * @return
   */
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

  /**
   * Calculates the offsets of the chart to the border depending on the
   * position of an eventual legend or depending on the length of the y-axis
   * and x-axis labels and their position
   */
  void calculateOffsets();

  /**
   * Calculates the y-min and y-max value and the y-delta and x-delta value
   */
  void calcMinMax();

  /**
   * Calculates the required number of digits for the values that might be
   * drawn in the chart (if enabled), and creates the default-value-formatter
   */
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

  /**
   * flag that indicates if offsets calculation has already been done or not
   */
  bool mOffsetsCalculated = false;

  @override
  void paint(Canvas canvas, Size size) {
    mSize = size;

    if (mData == null) {
      bool hasText = mNoDataText.isEmpty;

      if (hasText) {
        MPPointF c = getCenter(size);
        mInfoPaint ??= TextPainter(
            text: TextSpan(
                text: mNoDataText, style: TextStyle(color: ColorUtils.BLACK)),
            textAlign: TextAlign.center,
            textDirection: TextDirection.ltr);
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

  /**
   * Draws the description text in the bottom right corner of the chart (per default)
   */
  void drawDescription(Canvas c, Size size) {
    // check if description should be drawn
    if (mDescription != null && mDescription.isEnabled()) {
      MPPointF position = mDescription.getPosition();

      mDescPaint = TextPainter(
          text: TextSpan(
              style: TextStyle(
                  fontSize: Utils.convertDpToPixel(mDescription.getTextSize()),
                  color: mDescription.getTextColor())),
          textDirection: TextDirection.ltr,
          textAlign: mDescription.getTextAlign());

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

  /**
   * array of Highlight objects that reference the highlighted slices in the
   * chart
   */
  List<Highlight> mIndicesToHighlight;

  /**
   * The maximum distance in dp away from an entry causing it to highlight.
   */
  double mMaxHighlightDistance = 0;

  @override
  double getMaxHighlightDistance() {
    return mMaxHighlightDistance;
  }

  /**
   * Returns true if there are values to highlight, false if there are no
   * values to highlight. Checks if the highlight array is null, has a length
   * of zero or if the first object is null.
   *
   * @return
   */
  bool valuesToHighlight() {
    return mIndicesToHighlight == null ||
            mIndicesToHighlight.length <= 0 ||
            mIndicesToHighlight[0] == null
        ? false
        : true;
  }

  /**
   * Sets the last highlighted value for the touchlistener.
   *
   * @param highs
   */
//  void setLastHighlighted(List<Highlight> highs) {
//  if (highs == null || highs.length <= 0 || highs[0] == null) {
//  mChartTouchListener.setLastHighlighted(null);
//  } else {
//  mChartTouchListener.setLastHighlighted(highs[0]);
//  }
//  }

  /**
   * Highlights the values at the given indices in the given DataSets. Provide
   * null or an empty array to undo all highlighting. This should be used to
   * programmatically highlight values.
   * This method *will not* call the listener.
   *
   * @param highs
   */
  void highlightValues(List<Highlight> highs) {
    // set the indices to highlight
    mIndicesToHighlight = highs;

//    setLastHighlighted(highs);

    // redraw the chart
//  invalidate();
  }

  /**
   * Highlights any y-value at the given x-value in the given DataSet.
   * Provide -1 as the dataSetIndex to undo all highlighting.
   * This method will call the listener.
   * @param x The x-value to highlight
   * @param dataSetIndex The dataset index to search in
   */
  void highlightValue1(double x, int dataSetIndex) {
    highlightValue3(x, dataSetIndex, true);
  }

  /**
   * Highlights the value at the given x-value and y-value in the given DataSet.
   * Provide -1 as the dataSetIndex to undo all highlighting.
   * This method will call the listener.
   * @param x The x-value to highlight
   * @param y The y-value to highlight. Supply `NaN` for "any"
   * @param dataSetIndex The dataset index to search in
   */
  void highlightValue2(double x, double y, int dataSetIndex) {
    highlightValue4(x, y, dataSetIndex, true);
  }

  /**
   * Highlights any y-value at the given x-value in the given DataSet.
   * Provide -1 as the dataSetIndex to undo all highlighting.
   * @param x The x-value to highlight
   * @param dataSetIndex The dataset index to search in
   * @param callListener Should the listener be called for this change
   */
  void highlightValue3(double x, int dataSetIndex, bool callListener) {
    highlightValue4(x, double.nan, dataSetIndex, callListener);
  }

  /**
   * Highlights any y-value at the given x-value in the given DataSet.
   * Provide -1 as the dataSetIndex to undo all highlighting.
   * @param x The x-value to highlight
   * @param y The y-value to highlight. Supply `NaN` for "any"
   * @param dataSetIndex The dataset index to search in
   * @param callListener Should the listener be called for this change
   */
  void highlightValue4(
      double x, double y, int dataSetIndex, bool callListener) {
    if (dataSetIndex < 0 || dataSetIndex >= mData.getDataSetCount()) {
      highlightValue6(null, callListener);
    } else {
      highlightValue6(
          Highlight(x: x, y: y, dataSetIndex: dataSetIndex), callListener);
    }
  }

  /**
   * Highlights the values represented by the provided Highlight object
   * This method *will not* call the listener.
   *
   * @param highlight contains information about which entry should be highlighted
   */
  void highlightValue5(Highlight highlight) {
    highlightValue6(highlight, false);
  }

  /**
   * Highlights the value selected by touch gesture. Unlike
   * highlightValues(...), this generates a callback to the
   * OnChartValueSelectedListener.
   *
   * @param high         - the highlight object
   * @param callListener - call the listener
   */
  void highlightValue6(Highlight high, bool callListener) {
    Entry e = null;

    if (high == null)
      mIndicesToHighlight = null;
    else {
      e = mData.getEntryForHighlight(high);
      if (e == null) {
        mIndicesToHighlight = null;
        high = null;
      } else {
        // set the indices to highlight
        mIndicesToHighlight = List()..add(high);
      }
    }

//    setLastHighlighted(mIndicesToHighlight);

//    if (callListener && mSelectionListener != null) {
//      if (!valuesToHighlight())
//        mSelectionListener.onNothingSelected();
//      else {
//        // notify the listener
//        mSelectionListener.onValueSelected(e, high);
//      }
//    }
//
//    // redraw the chart
//    invalidate();
  }

  /**
   * Returns the Highlight object (contains x-index and DataSet index) of the
   * selected value at the given touch point inside the Line-, Scatter-, or
   * CandleStick-Chart.
   *
   * @param x
   * @param y
   * @return
   */
  Highlight getHighlightByTouchPoint(double x, double y) {
    if (mData == null) {
      return null;
    } else {
      return mHighlighter.getHighlight(x, y);
    }
  }

  /**
   * Set a new (e.g. custom) ChartTouchListener NOTE: make sure to
   * setTouchEnabled(true); if you need touch gestures on the chart
   *
   * @param l
   */
//  void setOnTouchListener(ChartTouchListener l) {
//    this.mChartTouchListener = l;
//  }

  /**
   * Returns an instance of the currently active touch listener.
   *
   * @return
   */
//  ChartTouchListener getOnTouchListener() {
//    return mChartTouchListener;
//  }

  /** BELOW CODE IS FOR THE MARKER VIEW */

  /**
   * if set to true, the marker view is drawn when a value is clicked
   */
  bool mDrawMarkers = true;

  /**
   * the view that represents the marker
   */
  IMarker mMarker;

  /**
   * draws all MarkerViews on the highlighted positions
   */
  void drawMarkers(Canvas canvas) {
    if (mMarker == null || !isDrawMarkersEnabled() || !valuesToHighlight())
      return;

    for (int i = 0; i < mIndicesToHighlight.length; i++) {
      Highlight highlight = mIndicesToHighlight[i];

      IDataSet set = mData.getDataSetByIndex(highlight.getDataSetIndex());

      Entry e = mData.getEntryForHighlight(mIndicesToHighlight[i]);
//      int entryIndex = set.getEntryIndex2(e);
      // make sure entry not null
//      if (e == null || entryIndex > set.getEntryCount() * mAnimator.getPhaseX())
//        continue;
      if (e == null) continue;

      List<double> pos = getMarkerPosition(highlight);

      // check bounds
      if (!mViewPortHandler.isInBounds(pos[0], pos[1])) continue;

      // callbacks to update the content
      mMarker.refreshContent(e, highlight);

      // draw the marker
      mMarker.draw(canvas, pos[0], pos[1]);
    }
  }

  /**
   * Returns the actual position in pixels of the MarkerView for the given
   * Highlight object.
   *
   * @param high
   * @return
   */
  List<double> getMarkerPosition(Highlight high) {
    return List<double>()..add(high.getDrawX())..add(high.getDrawY());
  }

  /** CODE BELOW THIS RELATED TO ANIMATION */

  /**
   * Returns the animator responsible for animating chart values.
   *
   * @return
   */
//   ChartAnimator getAnimator() {
//    return mAnimator;
//  }

  /** CODE BELOW FOR PROVIDING EASING FUNCTIONS */

  /**
   * Animates the drawing / rendering of the chart on both x- and y-axis with
   * the specified animation time. If animate(...) is called, no further
   * calling of invalidate() is necessary to refresh the chart. ANIMATIONS
   * ONLY WORK FOR API LEVEL 11 (Android 3.0.x) AND HIGHER.
   *
   * @param durationMillisX
   * @param durationMillisY
   * @param easingX         a custom easing function to be used on the animation phase
   * @param easingY         a custom easing function to be used on the animation phase
   */
//  @RequiresApi(11)
//   void animateXY(int durationMillisX, int durationMillisY, EasingFunction easingX,
//      EasingFunction easingY) {
//    mAnimator.animateXY(durationMillisX, durationMillisY, easingX, easingY);
//  }

  /**
   * Animates the drawing / rendering of the chart on both x- and y-axis with
   * the specified animation time. If animate(...) is called, no further
   * calling of invalidate() is necessary to refresh the chart. ANIMATIONS
   * ONLY WORK FOR API LEVEL 11 (Android 3.0.x) AND HIGHER.
   *
   * @param durationMillisX
   * @param durationMillisY
   * @param easing         a custom easing function to be used on the animation phase
   */
//  @RequiresApi(11)
//   void animateXY(int durationMillisX, int durationMillisY, EasingFunction easing) {
//    mAnimator.animateXY(durationMillisX, durationMillisY, easing);
//  }

  /**
   * Animates the rendering of the chart on the x-axis with the specified
   * animation time. If animate(...) is called, no further calling of
   * invalidate() is necessary to refresh the chart. ANIMATIONS ONLY WORK FOR
   * API LEVEL 11 (Android 3.0.x) AND HIGHER.
   *
   * @param durationMillis
   * @param easing         a custom easing function to be used on the animation phase
   */
//  @RequiresApi(11)
//   void animateX(int durationMillis, EasingFunction easing) {
//    mAnimator.animateX(durationMillis, easing);
//  }

  /**
   * Animates the rendering of the chart on the y-axis with the specified
   * animation time. If animate(...) is called, no further calling of
   * invalidate() is necessary to refresh the chart. ANIMATIONS ONLY WORK FOR
   * API LEVEL 11 (Android 3.0.x) AND HIGHER.
   *
   * @param durationMillis
   * @param easing         a custom easing function to be used on the animation phase
   */
//  @RequiresApi(11)
//   void animateY(int durationMillis, EasingFunction easing) {
//    mAnimator.animateY(durationMillis, easing);
//  }

  /** CODE BELOW FOR ANIMATIONS WITHOUT EASING */

  /**
   * Animates the rendering of the chart on the x-axis with the specified
   * animation time. If animate(...) is called, no further calling of
   * invalidate() is necessary to refresh the chart. ANIMATIONS ONLY WORK FOR
   * API LEVEL 11 (Android 3.0.x) AND HIGHER.
   *
   * @param durationMillis
   */
//  @RequiresApi(11)
//   void animateX(int durationMillis) {
//    mAnimator.animateX(durationMillis);
//  }

  /**
   * Animates the rendering of the chart on the y-axis with the specified
   * animation time. If animate(...) is called, no further calling of
   * invalidate() is necessary to refresh the chart. ANIMATIONS ONLY WORK FOR
   * API LEVEL 11 (Android 3.0.x) AND HIGHER.
   *
   * @param durationMillis
   */
//  @RequiresApi(11)
//   void animateY(int durationMillis) {
//    mAnimator.animateY(durationMillis);
//  }

  /**
   * Animates the drawing / rendering of the chart on both x- and y-axis with
   * the specified animation time. If animate(...) is called, no further
   * calling of invalidate() is necessary to refresh the chart. ANIMATIONS
   * ONLY WORK FOR API LEVEL 11 (Android 3.0.x) AND HIGHER.
   *
   * @param durationMillisX
   * @param durationMillisY
   */
//  @RequiresApi(11)
//   void animateXY(int durationMillisX, int durationMillisY) {
//    mAnimator.animateXY(durationMillisX, durationMillisY);
//  }

  /** BELOW THIS ONLY GETTERS AND SETTERS */

  /**
   * set a selection listener for the chart
   *
   * @param l
   */
//   void setOnChartValueSelectedListener(OnChartValueSelectedListener l) {
//    this.mSelectionListener = l;
//  }

  /**
   * Sets a gesture-listener for the chart for custom callbacks when executing
   * gestures on the chart surface.
   *
   * @param l
   */
//   void setOnChartGestureListener(OnChartGestureListener l) {
//    this.mGestureListener = l;
//  }

  /**
   * Returns the custom gesture listener.
   *
   * @return
   */
//   OnChartGestureListener getOnChartGestureListener() {
//    return mGestureListener;
//  }

  /**
   * returns the current y-max value across all DataSets
   *
   * @return
   */
  double getYMax() {
    return mData.getYMax1();
  }

  /**
   * returns the current y-min value across all DataSets
   *
   * @return
   */
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

  /**
   * Returns a recyclable MPPointF instance.
   * Returns the center point of the chart (the whole View) in pixels.
   *
   * @return
   */
  MPPointF getCenter(Size size) {
    return MPPointF.getInstance1(size.width / 2, size.height / 2);
  }

  /**
   * Returns a recyclable MPPointF instance.
   * Returns the center of the chart taking offsets under consideration.
   * (returns the center of the content rectangle)
   *
   * @return
   */
  @override
  MPPointF getCenterOffsets() {
    return mViewPortHandler.getContentCenter();
  }

  /**
   * Returns true if log-output is enabled for the chart, fals if not.
   *
   * @return
   */
//   bool isLogEnabled() {
//    return mLogEnabled;
//  }

  /**
   * Returns the rectangle that defines the borders of the chart-value surface
   * (into which the actual values are drawn).
   *
   * @return
   */
  @override
  Rect getContentRect() {
    return mViewPortHandler.getContentRect();
  }

  /**
   * disables intercept touchevents
   */
//   void disableScroll() {
//    ViewParent parent = getParent();
//    if (parent != null)
//      parent.requestDisallowInterceptTouchEvent(true);
//  }

  /**
   * enables intercept touchevents
   */
//   void enableScroll() {
//    ViewParent parent = getParent();
//    if (parent != null)
//      parent.requestDisallowInterceptTouchEvent(false);
//  }

  /**
   * paint for the grid background (only line and barchart)
   */
  static const int PAINT_GRID_BACKGROUND = 4;

  /**
   * paint for the info text that is displayed when there are no values in the
   * chart
   */
  static const int PAINT_INFO = 7;

  /**
   * paint for the description text in the bottom right corner
   */
  static const int PAINT_DESCRIPTION = 11;

  /**
   * paint for the hole in the middle of the pie chart
   */
  static const int PAINT_HOLE = 13;

  /**
   * paint for the text in the middle of the pie chart
   */
  static const int PAINT_CENTER_TEXT = 14;

  /**
   * paint used for the legend
   */
  static const int PAINT_LEGEND_LABEL = 18;

  /**
   * returns true if drawing the marker is enabled when tapping on values
   * (use the setMarker(IMarker marker) method to specify a marker)
   *
   * @return
   */
  bool isDrawMarkersEnabled() {
    return mDrawMarkers;
  }

  /**
   * Returns the ChartData object that has been set for the chart.
   *
   * @return
   */
  T getData() {
    return mData;
  }

  /**
   * Returns a recyclable MPPointF instance.
   *
   * @return
   */
  @override
  MPPointF getCenterOfView(Size size) {
    return getCenter(size);
  }

  /**
   * Returns the bitmap that represents the chart.
   *
   * @return
   */
//   Bitmap getChartBitmap() {
//    // Define a bitmap with the same size as the view
//    Bitmap returnedBitmap = Bitmap.createBitmap(getWidth(), getHeight(), Bitmap.Config.RGB_565);
//    // Bind a canvas to it
//    Canvas canvas = new Canvas(returnedBitmap);
//    // Get the view's background
//    Drawable bgDrawable = getBackground();
//    if (bgDrawable != null)
//      // has background drawable, then draw it on the canvas
//      bgDrawable.draw(canvas);
//    else
//      // does not have background drawable, then draw white background on
//      // the canvas
//      canvas.drawColor(Color.WHITE);
//    // draw the view on the canvas
//    draw(canvas);
//    // return the bitmap
//    return returnedBitmap;
//  }

  /**
   * Saves the current chart state with the given name to the given path on
   * the sdcard leaving the path empty "" will put the saved file directly on
   * the SD card chart is saved as a PNG image, example:
   * saveToPath("myfilename", "foldername1/foldername2");
   *
   * @param title
   * @param pathOnSD e.g. "folder1/folder2/folder3"
   * @return returns true on success, false on error
   */
//   bool saveToPath(String title, String pathOnSD) {
//
//
//
//    Bitmap b = getChartBitmap();
//
//    OutputStream stream = null;
//    try {
//      stream = new FileOutputStream(Environment.getExternalStorageDirectory().getPath()
//          + pathOnSD + "/" + title
//          + ".png");
//
//      /*
//             * Write bitmap to file using JPEG or PNG and 40% quality hint for
//             * JPEG.
//             */
//      b.compress(CompressFormat.PNG, 40, stream);
//
//      stream.close();
//    } catch (Exception e) {
//    e.printStackTrace();
//    return false;
//    }
//
//    return true;
//  }

  /**
   * Saves the current state of the chart to the gallery as an image type. The
   * compression must be set for JPEG only. 0 == maximum compression, 100 = low
   * compression (high quality). NOTE: Needs permission WRITE_EXTERNAL_STORAGE
   *
   * @param fileName        e.g. "my_image"
   * @param subFolderPath   e.g. "ChartPics"
   * @param fileDescription e.g. "Chart details"
   * @param format          e.g. Bitmap.CompressFormat.PNG
   * @param quality         e.g. 50, min = 0, max = 100
   * @return returns true if saving was successful, false if not
   */
//   bool saveToGallery(String fileName, String subFolderPath, String fileDescription, Bitmap.CompressFormat
//  format, int quality) {
//    // restrain quality
//    if (quality < 0 || quality > 100)
//      quality = 50;
//
//    long currentTime = System.currentTimeMillis();
//
//    File extBaseDir = Environment.getExternalStorageDirectory();
//    File file = new File(extBaseDir.getAbsolutePath() + "/DCIM/" + subFolderPath);
//    if (!file.exists()) {
//      if (!file.mkdirs()) {
//        return false;
//      }
//    }
//
//    String mimeType = "";
//    switch (format) {
//      case PNG:
//        mimeType = "image/png";
//        if (!fileName.endsWith(".png"))
//          fileName += ".png";
//        break;
//      case WEBP:
//        mimeType = "image/webp";
//        if (!fileName.endsWith(".webp"))
//          fileName += ".webp";
//        break;
//      case JPEG:
//      default:
//        mimeType = "image/jpeg";
//        if (!(fileName.endsWith(".jpg") || fileName.endsWith(".jpeg")))
//          fileName += ".jpg";
//        break;
//    }
//
//    String filePath = file.getAbsolutePath() + "/" + fileName;
//    FileOutputStream out = null;
//    try {
//      out = new FileOutputStream(filePath);
//
//      Bitmap b = getChartBitmap();
//      b.compress(format, quality, out);
//
//      out.flush();
//      out.close();
//
//    } catch (IOException e) {
//    e.printStackTrace();
//
//    return false;
//    }
//
//    long size = new File(filePath).length();
//
//    ContentValues values = new ContentValues(8);
//
//    // store the details
//    values.put(Images.Media.TITLE, fileName);
//    values.put(Images.Media.DISPLAY_NAME, fileName);
//    values.put(Images.Media.DATE_ADDED, currentTime);
//    values.put(Images.Media.MIME_TYPE, mimeType);
//    values.put(Images.Media.DESCRIPTION, fileDescription);
//    values.put(Images.Media.ORIENTATION, 0);
//    values.put(Images.Media.DATA, filePath);
//    values.put(Images.Media.SIZE, size);
//
//    return getContext().getContentResolver().insert(Images.Media.EXTERNAL_CONTENT_URI, values) != null;
//  }

  /**
   * Saves the current state of the chart to the gallery as a JPEG image. The
   * filename and compression can be set. 0 == maximum compression, 100 = low
   * compression (high quality). NOTE: Needs permission WRITE_EXTERNAL_STORAGE
   *
   * @param fileName e.g. "my_image"
   * @param quality  e.g. 50, min = 0, max = 100
   * @return returns true if saving was successful, false if not
   */
//   bool saveToGallery(String fileName, int quality) {
//    return saveToGallery(fileName, "", "MPAndroidChart-Library Save", Bitmap.CompressFormat.PNG, quality);
//  }

  /**
   * Saves the current state of the chart to the gallery as a PNG image.
   * NOTE: Needs permission WRITE_EXTERNAL_STORAGE
   *
   * @param fileName e.g. "my_image"
   * @return returns true if saving was successful, false if not
   */
//   bool saveToGallery(String fileName) {
//    return saveToGallery(fileName, "", "MPAndroidChart-Library Save", Bitmap.CompressFormat.PNG, 40);
//  }

  /**
   * tasks to be done after the view is setup
   */
//   ArrayList<Runnable> mJobs = new ArrayList<Runnable>();
//
//   void removeViewportJob(Runnable job) {
//    mJobs.remove(job);
//  }
//
//   void clearAllViewportJobs() {
//    mJobs.clear();
//  }

  /**
   * Either posts a job immediately if the chart has already setup it's
   * dimensions or adds the job to the execution queue.
   *
   * @param job
   */
//   void addViewportJob(Runnable job) {
//
//    if (mViewPortHandler.hasChartDimens()) {
//      post(job);
//    } else {
//      mJobs.add(job);
//    }
//  }

  /**
   * Returns all jobs that are scheduled to be executed after
   * onSizeChanged(...).
   *
   * @return
   */
//   ArrayList<Runnable> getJobs() {
//    return mJobs;
//  }
//
//  @Override
//   void onLayout(bool changed, int left, int top, int right, int bottom) {
//
//    for (int i = 0; i < getChildCount(); i++) {
//      getChildAt(i).layout(left, top, right, bottom);
//    }
//  }

//  @Override
//   void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
//    super.onMeasure(widthMeasureSpec, heightMeasureSpec);
//    int size = (int) Utils.convertDpToPixel(50f);
//    setMeasuredDimension(
//        Math.max(getSuggestedMinimumWidth(),
//            resolveSize(size,
//                widthMeasureSpec)),
//        Math.max(getSuggestedMinimumHeight(),
//            resolveSize(size,
//                heightMeasureSpec)));
//  }

//  @Override
//   void onSizeChanged(int w, int h, int oldw, int oldh) {
//    if (mLogEnabled)
//      Log.i(LOG_TAG, "OnSizeChanged()");
//
//    if (w > 0 && h > 0 && w < 10000 && h < 10000) {
//      if (mLogEnabled)
//        Log.i(LOG_TAG, "Setting chart dimens, width: " + w + ", height: " + h);
//      mViewPortHandler.setChartDimens(w, h);
//    } else {
//      if (mLogEnabled)
//        Log.w(LOG_TAG, "*Avoiding* setting chart dimens! width: " + w + ", height: " + h);
//    }
//
//    // This may cause the chart view to mutate properties affecting the view port --
//    //   lets do this before we try to run any pending jobs on the view port itself
//    notifyDataSetChanged();
//
//    for (Runnable r : mJobs) {
//      post(r);
//    }
//
//    mJobs.clear();
//
//    super.onSizeChanged(w, h, oldw, oldh);
//  }

  /**
   * Unbind all drawables to avoid memory leaks.
   * Link: http://stackoverflow.com/a/6779164/1590502
   *
   * @param view
   */
//   void unbindDrawables(View view) {
//
//    if (view.getBackground() != null) {
//      view.getBackground().setCallback(null);
//    }
//    if (view instanceof ViewGroup) {
//      for (int i = 0; i < ((ViewGroup) view).getChildCount(); i++) {
//        unbindDrawables(((ViewGroup) view).getChildAt(i));
//      }
//      ((ViewGroup) view).removeAllViews();
//    }
//  }

  void reassemble();
}
