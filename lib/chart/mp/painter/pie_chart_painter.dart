import 'dart:math';
import 'dart:ui';

import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:mp_flutter_chart/chart/mp/core/animator.dart';
import 'package:mp_flutter_chart/chart/mp/core/axis.dart';
import 'package:mp_flutter_chart/chart/mp/core/data.dart';
import 'package:mp_flutter_chart/chart/mp/core/description.dart';
import 'package:mp_flutter_chart/chart/mp/core/format.dart';
import 'package:mp_flutter_chart/chart/mp/core/highlight.dart';
import 'package:mp_flutter_chart/chart/mp/core/interfaces.dart';
import 'package:mp_flutter_chart/chart/mp/core/render.dart';
import 'package:mp_flutter_chart/chart/mp/core/view_port.dart';
import 'package:mp_flutter_chart/chart/mp/painter/pie_redar_chart_painter.dart';
import 'package:mp_flutter_chart/chart/mp/poolable/point.dart';
import 'package:mp_flutter_chart/chart/mp/util.dart';

class PieChartPainter extends PieRadarChartPainter<PieData> {
  /**
   * rect object that represents the bounds of the piechart, needed for
   * drawing the circle
   */
  Rect mCircleBox = Rect.zero;

  /**
   * flag indicating if entry labels should be drawn or not
   */
  bool mDrawEntryLabels = true;

  /**
   * array that holds the width of each pie-slice in degrees
   */
  List<double> mDrawAngles = List(1);

  /**
   * array that holds the absolute angle in degrees of each slice
   */
  List<double> mAbsoluteAngles = List(1);

  /**
   * if true, the white hole inside the chart will be drawn
   */
  bool mDrawHole = true;

  /**
   * if true, the hole will see-through to the inner tips of the slices
   */
  bool mDrawSlicesUnderHole = false;

  /**
   * if true, the values inside the piechart are drawn as percent values
   */
  bool mUsePercentValues = false;

  /**
   * if true, the slices of the piechart are rounded
   */
  bool mDrawRoundedSlices = false;

  /**
   * variable for the text that is drawn in the center of the pie-chart
   */
  String mCenterText = "";

  MPPointF mCenterTextOffset = MPPointF.getInstance1(0, 0);

  /**
   * indicates the size of the hole in the center of the piechart, default:
   * radius / 2
   */
  double mHoleRadiusPercent = 50;

  /**
   * the radius of the transparent circle next to the chart-hole in the center
   */
  double mTransparentCircleRadiusPercent = 55;

  /**
   * if enabled, centertext is drawn
   */
  bool mDrawCenterText = true;

  double mCenterTextRadiusPercent = 100.0;

  double mMaxAngle = 360;

  /**
   * Minimum angle to draw slices, this only works if there is enough room for all slices to have
   * the minimum angle, default 0f.
   */
  double mMinAngleForSlices = 0;

  PieChartPainter(PieData data,
      {Rect circleBox = Rect.zero,
      bool drawEntryLabels = true,
      bool drawHole = true,
      bool drawSlicesUnderHole = false,
      bool usePercentValues = false,
      bool drawRoundedSlices = false,
      String centerText = "",
      double holeRadiusPercent = 50,
      double transparentCircleRadiusPercent = 55,
      bool drawCenterText = true,
      double centerTextRadiusPercent = 100.0,
      double maxAngle = 360,
      double minAngleForSlices = 0,
      double rotationAngle = 270,
      double rawRotationAngle = 270,
      bool rotateEnabled = true,
      double minOffset = 0.0,
      ViewPortHandler viewPortHandler = null,
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
      : mCircleBox = circleBox,
        mDrawEntryLabels = drawEntryLabels,
        mDrawHole = drawHole,
        mDrawSlicesUnderHole = drawSlicesUnderHole,
        mUsePercentValues = usePercentValues,
        mDrawRoundedSlices = drawRoundedSlices,
        mCenterText = centerText,
        mHoleRadiusPercent = holeRadiusPercent,
        mTransparentCircleRadiusPercent = transparentCircleRadiusPercent,
        mDrawCenterText = drawCenterText,
        mCenterTextRadiusPercent = centerTextRadiusPercent,
        mMaxAngle = maxAngle,
        mMinAngleForSlices = minAngleForSlices,
        super(data,
            rotationAngle: rotationAngle,
            rawRotationAngle: rawRotationAngle,
            rotateEnabled: rotateEnabled,
            minOffset: minOffset,
            viewPortHandler: viewPortHandler,
            animator: animator,
            maxHighlightDistance: maxHighlightDistance,
            highLightPerTapEnabled: highLightPerTapEnabled,
            dragDecelerationEnabled: dragDecelerationEnabled,
            dragDecelerationFrictionCoef: dragDecelerationFrictionCoef,
            extraLeftOffset: extraLeftOffset,
            extraTopOffset: extraTopOffset,
            extraRightOffset: extraRightOffset,
            extraBottomOffset: extraBottomOffset,
            noDataText: noDataText,
            touchEnabled: touchEnabled,
            marker: marker,
            desc: desc,
            drawMarkers: drawMarkers,
            infoPainter: infoPainter,
            descPainter: descPainter,
            highlighter: highlighter,
            unbind: unbind);

  @override
  void init() {
    super.init();

    mRenderer = PieChartRenderer(this, mAnimator, mViewPortHandler);
    mXAxis = null;

    mHighlighter = PieHighlighter(this);
  }

  @override
  ValueFormatter getDefaultValueFormatter() {
    return mDefaultValueFormatter;
  }

  @override
  void reassemble() {}

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

  @override
  void paint(Canvas canvas, Size size) {
    super.paint(canvas, size);

    if (mData == null) return;

    mRenderer.drawData(canvas);

    if (valuesToHighlight()) {
      mRenderer.drawHighlighted(canvas, mIndicesToHighlight);
    }

    mRenderer.drawExtras(canvas);

    mRenderer.drawValues(canvas);

    mLegendRenderer.renderLegend(canvas);

    drawDescription(canvas, size);

    drawMarkers(canvas);
  }

  @override
  void calculateOffsets() {
    super.calculateOffsets();
    // prevent nullpointer when no data set
    if (mData == null) return;

    double diameter = getDiameter();
    double radius = diameter / 2;

    MPPointF c = getCenterOffsets();

    double shift = mData.getDataSet().getSelectionShift();

    // create the circle box that will contain the pie-chart (the bounds of
    // the pie-chart)
    mCircleBox = Rect.fromLTRB(c.x - radius + shift, c.y - radius + shift,
        c.x + radius - shift, c.y + radius - shift);

    MPPointF.recycleInstance(c);
  }

  @override
  void calcMinMax() {
    calcAngles();
  }

  @override
  List<double> getMarkerPosition(Highlight highlight) {
    MPPointF center = getCenterCircleBox();
    double r = getRadius();

    double off = r / 10 * 3.6;

    if (isDrawHoleEnabled()) {
      off = (r - (r / 100 * getHoleRadius())) / 2;
    }

    r -= off; // offset to keep things inside the chart

    double rotationAngle = getRotationAngle();

    int entryIndex = highlight.getX().toInt();

    // offset needed to center the drawn text in the slice
    double offset = mDrawAngles[entryIndex] / 2;

    // calculate the text position
    double x = (r *
            cos(((rotationAngle + mAbsoluteAngles[entryIndex] - offset) *
                    mAnimator.getPhaseY()) /
                180 *
                pi) +
        center.x);
    double y = (r *
            sin((rotationAngle + mAbsoluteAngles[entryIndex] - offset) *
                mAnimator.getPhaseY() /
                180 *
                pi) +
        center.y);

    MPPointF.recycleInstance(center);
    return List()..add(x)..add(y);
  }

  /**
   * calculates the needed angles for the chart slices
   */
  void calcAngles() {
    int entryCount = mData.getEntryCount();

    if (mDrawAngles.length != entryCount) {
      mDrawAngles = List(entryCount);
    } else {
      for (int i = 0; i < entryCount; i++) {
        mDrawAngles[i] = 0;
      }
    }
    if (mAbsoluteAngles.length != entryCount) {
      mAbsoluteAngles = List(entryCount);
    } else {
      for (int i = 0; i < entryCount; i++) {
        mAbsoluteAngles[i] = 0;
      }
    }

    double yValueSum = mData.getYValueSum();

    List<IPieDataSet> dataSets = mData.getDataSets();

    bool hasMinAngle =
        mMinAngleForSlices != 0 && entryCount * mMinAngleForSlices <= mMaxAngle;
    List<double> minAngles = List(entryCount);

    int cnt = 0;
    double offset = 0;
    double diff = 0;

    for (int i = 0; i < mData.getDataSetCount(); i++) {
      IPieDataSet set = dataSets[i];

      for (int j = 0; j < set.getEntryCount(); j++) {
        double drawAngle =
            calcAngle2(set.getEntryForIndex(j).y.abs(), yValueSum);

        if (hasMinAngle) {
          double temp = drawAngle - mMinAngleForSlices;
          if (temp <= 0) {
            minAngles[cnt] = mMinAngleForSlices;
            offset += -temp;
          } else {
            minAngles[cnt] = drawAngle;
            diff += temp;
          }
        }

        mDrawAngles[cnt] = drawAngle;

        if (cnt == 0) {
          mAbsoluteAngles[cnt] = mDrawAngles[cnt];
        } else {
          mAbsoluteAngles[cnt] = mAbsoluteAngles[cnt - 1] + mDrawAngles[cnt];
        }

        cnt++;
      }
    }

    if (hasMinAngle) {
      // Correct bigger slices by relatively reducing their angles based on the total angle needed to subtract
      // This requires that `entryCount * mMinAngleForSlices <= mMaxAngle` be true to properly work!
      for (int i = 0; i < entryCount; i++) {
        minAngles[i] -= (minAngles[i] - mMinAngleForSlices) / diff * offset;
        if (i == 0) {
          mAbsoluteAngles[0] = minAngles[0];
        } else {
          mAbsoluteAngles[i] = mAbsoluteAngles[i - 1] + minAngles[i];
        }
      }

      mDrawAngles = minAngles;
    }
  }

  /**
   * Checks if the given index is set to be highlighted.
   *
   * @param index
   * @return
   */
  bool needsHighlight(int index) {
    // no highlight
    if (!valuesToHighlight()) return false;
    for (int i = 0; i < mIndicesToHighlight.length; i++)

      // check if the xvalue for the given dataset needs highlight
      if (mIndicesToHighlight[i].getX().toInt() == index) return true;

    return false;
  }

  /**
   * calculates the needed angle for a given value
   *
   * @param value
   * @return
   */
  double calcAngle1(double value) {
    return calcAngle2(value, mData.getYValueSum());
  }

  /**
   * calculates the needed angle for a given value
   *
   * @param value
   * @param yValueSum
   * @return
   */
  double calcAngle2(double value, double yValueSum) {
    return value / yValueSum * mMaxAngle;
  }

  /**
   * This will throw an exception, PieChart has no XAxis object.
   *
   * @return
   */
  @override
  XAxis getXAxis() {
    throw Exception("PieChart has no XAxis");
  }

  @override
  int getIndexForAngle(double angle) {
    // take the current angle of the chart into consideration
    double a = Utils.getNormalizedAngle(angle - getRotationAngle());

    for (int i = 0; i < mAbsoluteAngles.length; i++) {
      if (mAbsoluteAngles[i] > a) return i;
    }

    return -1; // return -1 if no index found
  }

  /**
   * Returns the index of the DataSet this x-index belongs to.
   *
   * @param xIndex
   * @return
   */
  int getDataSetIndexForIndex(int xIndex) {
    List<IPieDataSet> dataSets = mData.getDataSets();

    for (int i = 0; i < dataSets.length; i++) {
      if (dataSets[i].getEntryForXValue2(xIndex.toDouble(), double.nan) != null)
        return i;
    }

    return -1;
  }

  /**
   * returns an integer array of all the different angles the chart slices
   * have the angles in the returned array determine how much space (of 360°)
   * each slice takes
   *
   * @return
   */
  List<double> getDrawAngles() {
    return mDrawAngles;
  }

  /**
   * returns the absolute angles of the different chart slices (where the
   * slices end)
   *
   * @return
   */
  List<double> getAbsoluteAngles() {
    return mAbsoluteAngles;
  }

  /**
   * Sets the color for the hole that is drawn in the center of the PieChart
   * (if enabled).
   *
   * @param color
   */
  void setHoleColor(Color color) {
    (mRenderer as PieChartRenderer).getPaintHole().color = color;
  }

  /**
   * Enable or disable the visibility of the inner tips of the slices behind the hole
   */
  void setDrawSlicesUnderHole(bool enable) {
    mDrawSlicesUnderHole = enable;
  }

  /**
   * Returns true if the inner tips of the slices are visible behind the hole,
   * false if not.
   *
   * @return true if slices are visible behind the hole.
   */
  bool isDrawSlicesUnderHoleEnabled() {
    return mDrawSlicesUnderHole;
  }

  /**
   * set this to true to draw the pie center empty
   *
   * @param enabled
   */
  void setDrawHoleEnabled(bool enabled) {
    this.mDrawHole = enabled;
  }

  /**
   * returns true if the hole in the center of the pie-chart is set to be
   * visible, false if not
   *
   * @return
   */
  bool isDrawHoleEnabled() {
    return mDrawHole;
  }

  /**
   * Sets the text String that is displayed in the center of the PieChart.
   *
   * @param text
   */
  void setCenterText(String text) {
    if (text == null)
      mCenterText = "";
    else
      mCenterText = text;
  }

  /**
   * returns the text that is drawn in the center of the pie-chart
   *
   * @return
   */
  String getCenterText() {
    return mCenterText;
  }

  /**
   * set this to true to draw the text that is displayed in the center of the
   * pie chart
   *
   * @param enabled
   */
  void setDrawCenterText(bool enabled) {
    this.mDrawCenterText = enabled;
  }

  /**
   * returns true if drawing the center text is enabled
   *
   * @return
   */
  bool isDrawCenterTextEnabled() {
    return mDrawCenterText;
  }

  @override
  double getRequiredLegendOffset() {
    var offset = mLegendRenderer.getLabelPaint().text?.style?.fontSize * 2.0;
    return offset == null ? Utils.convertDpToPixel(9) : offset;
  }

  @override
  double getRequiredBaseOffset() {
    return 0;
  }

  @override
  double getRadius() {
    if (mCircleBox == null)
      return 0;
    else
      return min(mCircleBox.width / 2.0, mCircleBox.height / 2.0);
  }

  /**
   * returns the circlebox, the boundingbox of the pie-chart slices
   *
   * @return
   */
  Rect getCircleBox() {
    return mCircleBox;
  }

  /**
   * returns the center of the circlebox
   *
   * @return
   */
  MPPointF getCenterCircleBox() {
    return MPPointF.getInstance1(mCircleBox.center.dx, mCircleBox.center.dy);
  }

//  /**
//   * sets the typeface for the center-text paint
//   *
//   * @param t
//   */
//  void setCenterTextTypeface(TextStyle t) {
//    (mRenderer as PieChartRenderer).getPaintCenterText().setTypeface(t);
//  }
//
//  /**
//   * Sets the size of the center text of the PieChart in dp.
//   *
//   * @param sizeDp
//   */
//  void setCenterTextSize(double sizeDp) {
//    ((PieChartRenderer) mRenderer).getPaintCenterText().setTextSize(
//        Utils.convertDpToPixel(sizeDp));
//  }
//
//  /**
//   * Sets the size of the center text of the PieChart in pixels.
//   *
//   * @param sizePixels
//   */
//  void setCenterTextSizePixels(double sizePixels) {
//    ((PieChartRenderer) mRenderer).getPaintCenterText().setTextSize(sizePixels);
//  }

//  /**
//   * Sets the offset the center text should have from it's original position in dp. Default x = 0, y = 0
//   *
//   * @param x
//   * @param y
//   */
//  public void setCenterTextOffset(float x, float y) {
//    mCenterTextOffset.x = Utils.convertDpToPixel(x);
//    mCenterTextOffset.y = Utils.convertDpToPixel(y);
//  }

  /**
   * Returns the offset on the x- and y-axis the center text has in dp.
   *
   * @return
   */
  MPPointF getCenterTextOffset() {
    return MPPointF.getInstance1(mCenterTextOffset.x, mCenterTextOffset.y);
  }

//  /**
//   * Sets the color of the center text of the PieChart.
//   *
//   * @param color
//   */
//  public void setCenterTextColor(int color) {
//    ((PieChartRenderer) mRenderer).getPaintCenterText().setColor(color);
//  }

  /**
   * sets the radius of the hole in the center of the piechart in percent of
   * the maximum radius (max = the radius of the whole chart), default 50%
   *
   * @param percent
   */
  void setHoleRadius(final double percent) {
    mHoleRadiusPercent = percent;
  }

  /**
   * Returns the size of the hole radius in percent of the total radius.
   *
   * @return
   */
  double getHoleRadius() {
    return mHoleRadiusPercent;
  }

  /**
   * Sets the color the transparent-circle should have.
   *
   * @param color
   */
  void setTransparentCircleColor(Color color) {
    Paint p = (mRenderer as PieChartRenderer).getPaintTransparentCircle();
    p.color = Color.fromARGB(p.color?.alpha == null ? 255 : p.color?.alpha,
        color.red, color.green, color.blue);
  }

  /**
   * sets the radius of the transparent circle that is drawn next to the hole
   * in the piechart in percent of the maximum radius (max = the radius of the
   * whole chart), default 55% -> means 5% larger than the center-hole by
   * default
   *
   * @param percent
   */
  void setTransparentCircleRadius(final double percent) {
    mTransparentCircleRadiusPercent = percent;
  }

  double getTransparentCircleRadius() {
    return mTransparentCircleRadiusPercent;
  }

  /**
   * Sets the amount of transparency the transparent circle should have 0 = fully transparent,
   * 255 = fully opaque.
   * Default value is 100.
   *
   * @param alpha 0-255
   */
  void setTransparentCircleAlpha(int alpha) {
    Color color =
        (mRenderer as PieChartRenderer).getPaintTransparentCircle().color;
    (mRenderer as PieChartRenderer).getPaintTransparentCircle().color =
        Color.fromARGB(alpha, color.red, color.green, color.blue);
  }

//
//  /**
//   * Set this to true to draw the entry labels into the pie slices (Provided by the getLabel() method of the PieEntry class).
//   * Deprecated -> use setDrawEntryLabels(...) instead.
//   *
//   * @param enabled
//   */
//  @Deprecated
//  public void setDrawSliceText(boolean enabled) {
//    mDrawEntryLabels = enabled;
//  }

//  /**
//   * Set this to true to draw the entry labels into the pie slices (Provided by the getLabel() method of the PieEntry class).
//   *
//   * @param enabled
//   */
//  public void setDrawEntryLabels(boolean enabled) {
//    mDrawEntryLabels = enabled;
//  }

  /**
   * Returns true if drawing the entry labels is enabled, false if not.
   *
   * @return
   */
  bool isDrawEntryLabelsEnabled() {
    return mDrawEntryLabels;
  }

  /**
   * Sets the color the entry labels are drawn with.
   *
   * @param color
   */
  void setEntryLabelColor(Color color) {
    var style = (mRenderer as PieChartRenderer).mEntryLabelsPaint.text.style;
    (mRenderer as PieChartRenderer).mEntryLabelsPaint = TextPainter(
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
        text: TextSpan(
            style: TextStyle(
                fontSize: style?.fontSize == null
                    ? Utils.convertDpToPixel(13)
                    : style?.fontSize,
                color: color)));
  }

//  /**
//   * Sets a custom Typeface for the drawing of the entry labels.
//   *
//   * @param tf
//   */
//  public void setEntryLabelTypeface(Typeface tf) {
//    ((PieChartRenderer) mRenderer).getPaintEntryLabels().setTypeface(tf);
//  }

  /**
   * Sets the size of the entry labels in dp. Default: 13dp
   *
   * @param size
   */
  void setEntryLabelTextSize(double size) {
    var style = (mRenderer as PieChartRenderer).mEntryLabelsPaint.text.style;
    (mRenderer as PieChartRenderer).mEntryLabelsPaint = TextPainter(
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
        text: TextSpan(
            style: TextStyle(
                fontSize: Utils.convertDpToPixel(size),
                color:
                    style?.color == null ? ColorUtils.WHITE : style?.color)));
  }

//  /**
//   * Sets whether to draw slices in a curved fashion, only works if drawing the hole is enabled
//   * and if the slices are not drawn under the hole.
//   *
//   * @param enabled draw curved ends of slices
//   */
//  public void setDrawRoundedSlices(boolean enabled) {
//    mDrawRoundedSlices = enabled;
//  }

  /**
   * Returns true if the chart is set to draw each end of a pie-slice
   * "rounded".
   *
   * @return
   */
  bool isDrawRoundedSlicesEnabled() {
    return mDrawRoundedSlices;
  }

//
//  /**
//   * If this is enabled, values inside the PieChart are drawn in percent and
//   * not with their original value. Values provided for the IValueFormatter to
//   * format are then provided in percent.
//   *
//   * @param enabled
//   */
//  public void setUsePercentValues(boolean enabled) {
//    mUsePercentValues = enabled;
//  }

  /**
   * Returns true if using percentage values is enabled for the chart.
   *
   * @return
   */
  bool isUsePercentValuesEnabled() {
    return mUsePercentValues;
  }

//  /**
//   * the rectangular radius of the bounding box for the center text, as a percentage of the pie
//   * hole
//   * default 1.f (100%)
//   */
//  public void setCenterTextRadiusPercent(float percent) {
//    mCenterTextRadiusPercent = percent;
//  }

  /**
   * the rectangular radius of the bounding box for the center text, as a percentage of the pie
   * hole
   * default 1.f (100%)
   */
  double getCenterTextRadiusPercent() {
    return mCenterTextRadiusPercent;
  }

//  public float getMaxAngle() {
//    return mMaxAngle;
//  }
//
//  /**
//   * Sets the max angle that is used for calculating the pie-circle. 360f means
//   * it's a full PieChart, 180f results in a half-pie-chart. Default: 360f
//   *
//   * @param maxangle min 90, max 360
//   */
//  public void setMaxAngle(float maxangle) {
//
//    if (maxangle > 360)
//      maxangle = 360f;
//
//    if (maxangle < 90)
//      maxangle = 90f;
//
//    this.mMaxAngle = maxangle;
//  }

//  /**
//   * The minimum angle slices on the chart are rendered with, default is 0f.
//   *
//   * @return minimum angle for slices
//   */
//  public float getMinAngleForSlices() {
//    return mMinAngleForSlices;
//  }
//
//  /**
//   * Set the angle to set minimum size for slices, you must call {@link #notifyDataSetChanged()}
//   * and {@link #invalidate()} when changing this, only works if there is enough room for all
//   * slices to have the minimum angle.
//   *
//   * @param minAngle minimum 0, maximum is half of {@link #setMaxAngle(float)}
//   */
//  public void setMinAngleForSlices(float minAngle) {
//
//    if (minAngle > (mMaxAngle / 2f))
//      minAngle = mMaxAngle / 2f;
//    else if (minAngle < 0)
//    minAngle = 0f;
//
//    this.mMinAngleForSlices = minAngle;
//  }

//  @Override
//  protected void onDetachedFromWindow() {
//    // releases the bitmap in the renderer to avoid oom error
//    if (mRenderer != null && mRenderer instanceof PieChartRenderer) {
//      ((PieChartRenderer) mRenderer).releaseBitmap();
//    }
//    super.onDetachedFromWindow();
//  }
}

enum ValuePosition { INSIDE_SLICE, OUTSIDE_SLICE }
