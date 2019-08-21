import 'dart:math';

import 'package:mp_flutter_chart/chart/mp/core/axis.dart';
import 'package:mp_flutter_chart/chart/mp/core/data.dart';
import 'package:mp_flutter_chart/chart/mp/core/interfaces.dart';
import 'package:mp_flutter_chart/chart/mp/core/range.dart';
import 'package:mp_flutter_chart/chart/mp/painter/pie_chart_painter.dart';
import 'package:mp_flutter_chart/chart/mp/painter/pie_redar_chart_painter.dart';
import 'package:mp_flutter_chart/chart/mp/poolable/point.dart';

class Highlight {
  /**
   * the x-value of the highlighted value
   */
  double mX = double.nan;

  /**
   * the y-value of the highlighted value
   */
  double mY = double.nan;

  /**
   * the x-pixel of the highlight
   */
  double mXPx;

  /**
   * the y-pixel of the highlight
   */
  double mYPx;

  /**
   * the index of the data object - in case it refers to more than one
   */
  int mDataIndex = -1;

  /**
   * the index of the dataset the highlighted value is in
   */
  int mDataSetIndex;

  /**
   * index which value of a stacked bar entry is highlighted, default -1
   */
  int mStackIndex = -1;

  /**
   * the axis the highlighted value belongs to
   */
  AxisDependency axis;

  /**
   * the x-position (pixels) on which this highlight object was last drawn
   */
  double mDrawX;

  /**
   * the y-position (pixels) on which this highlight object was last drawn
   */
  double mDrawY;

  Highlight(
      {double x = double.nan,
      double y = double.nan,
      double xPx = 0,
      double yPx = 0,
      int dataSetIndex = 0,
      int stackIndex = -1,
      AxisDependency axis = null}) {
    this.mX = x;
    this.mY = y;
    this.mXPx = xPx;
    this.mYPx = yPx;
    this.mDataSetIndex = dataSetIndex;
    this.axis = axis;
    this.mStackIndex = stackIndex;
  }

  /**
   * returns the x-value of the highlighted value
   *
   * @return
   */
  double getX() {
    return mX;
  }

  /**
   * returns the y-value of the highlighted value
   *
   * @return
   */
  double getY() {
    return mY;
  }

  /**
   * returns the x-position of the highlight in pixels
   */
  double getXPx() {
    return mXPx;
  }

  /**
   * returns the y-position of the highlight in pixels
   */
  double getYPx() {
    return mYPx;
  }

  /**
   * the index of the data object - in case it refers to more than one
   *
   * @return
   */
  int getDataIndex() {
    return mDataIndex;
  }

  void setDataIndex(int mDataIndex) {
    this.mDataIndex = mDataIndex;
  }

  /**
   * returns the index of the DataSet the highlighted value is in
   *
   * @return
   */
  int getDataSetIndex() {
    return mDataSetIndex;
  }

  /**
   * Only needed if a stacked-barchart entry was highlighted. References the
   * selected value within the stacked-entry.
   *
   * @return
   */
  int getStackIndex() {
    return mStackIndex;
  }

  bool isStacked() {
    return mStackIndex >= 0;
  }

  /**
   * Returns the axis the highlighted value belongs to.
   *
   * @return
   */
  AxisDependency getAxis() {
    return axis;
  }

  /**
   * Sets the x- and y-position (pixels) where this highlight was last drawn.
   *
   * @param x
   * @param y
   */
  void setDraw(double x, double y) {
    this.mDrawX = x;
    this.mDrawY = y;
  }

  /**
   * Returns the x-position in pixels where this highlight object was last drawn.
   *
   * @return
   */
  double getDrawX() {
    return mDrawX;
  }

  /**
   * Returns the y-position in pixels where this highlight object was last drawn.
   *
   * @return
   */
  double getDrawY() {
    return mDrawY;
  }

  /**
   * Returns true if this highlight object is equal to the other (compares
   * xIndex and dataSetIndex)
   *
   * @param h
   * @return
   */
  bool equalTo(Highlight h) {
    if (h == null)
      return false;
    else {
      if (this.mDataSetIndex == h.mDataSetIndex &&
          this.mX == h.mX &&
          this.mStackIndex == h.mStackIndex &&
          this.mDataIndex == h.mDataIndex)
        return true;
      else
        return false;
    }
  }

  @override
  String toString() {
    return "Highlight, x: $mX, y: $mY, dataSetIndex: $mDataSetIndex, stackIndex (only stacked barentry): $mStackIndex";
  }
}

class ChartHighlighter<T extends BarLineScatterCandleBubbleDataProvider>
    implements IHighlighter {
  /**
   * instance of the data-provider
   */
  T mChart;

  /**
   * buffer for storing previously highlighted values
   */
  List<Highlight> mHighlightBuffer = List<Highlight>();

  ChartHighlighter(T chart) {
    this.mChart = chart;
  }

  @override
  Highlight getHighlight(double x, double y) {
    MPPointD pos = getValsForTouch(x, y);
    double xVal = pos.x;
    MPPointD.recycleInstance2(pos);
    Highlight high = getHighlightForX(xVal, x, y);
    return high;
  }

  /**
   * Returns a recyclable MPPointD instance.
   * Returns the corresponding xPos for a given touch-position in pixels.
   *
   * @param x
   * @param y
   * @return
   */
  MPPointD getValsForTouch(double x, double y) {
    // take any transformer to determine the x-axis value
    MPPointD pos =
        mChart.getTransformer(AxisDependency.LEFT).getValuesByTouchPoint1(x, y);
    return pos;
  }

  /**
   * Returns the corresponding Highlight for a given xVal and x- and y-touch position in pixels.
   *
   * @param xVal
   * @param x
   * @param y
   * @return
   */
  Highlight getHighlightForX(double xVal, double x, double y) {
    List<Highlight> closestValues = getHighlightsAtXValue(xVal, x, y);

    if (closestValues.isEmpty) {
      return null;
    }

    double leftAxisMinDist =
        getMinimumDistance(closestValues, y, AxisDependency.LEFT);
    double rightAxisMinDist =
        getMinimumDistance(closestValues, y, AxisDependency.RIGHT);

    AxisDependency axis = leftAxisMinDist < rightAxisMinDist
        ? AxisDependency.LEFT
        : AxisDependency.RIGHT;

    Highlight detail = getClosestHighlightByPixel(
        closestValues, x, y, axis, mChart.getMaxHighlightDistance());

    return detail;
  }

  /**
   * Returns the minimum distance from a touch value (in pixels) to the
   * closest value (in pixels) that is displayed in the chart.
   *
   * @param closestValues
   * @param pos
   * @param axis
   * @return
   */
  double getMinimumDistance(
      List<Highlight> closestValues, double pos, AxisDependency axis) {
    double distance = double.infinity;

    for (int i = 0; i < closestValues.length; i++) {
      Highlight high = closestValues[i];

      if (high.getAxis() == axis) {
        double tempDistance = (getHighlightPos(high) - pos).abs();
        if (tempDistance < distance) {
          distance = tempDistance;
        }
      }
    }

    return distance;
  }

  double getHighlightPos(Highlight h) {
    return h.getYPx();
  }

  /**
   * Returns a list of Highlight objects representing the entries closest to the given xVal.
   * The returned list contains two objects per DataSet (closest rounding up, closest rounding down).
   *
   * @param xVal the transformed x-value of the x-touch position
   * @param x    touch position
   * @param y    touch position
   * @return
   */
  List<Highlight> getHighlightsAtXValue(double xVal, double x, double y) {
    mHighlightBuffer.clear();

    BarLineScatterCandleBubbleData data = getData();

    if (data == null) return mHighlightBuffer;

    for (int i = 0, dataSetCount = data.getDataSetCount();
        i < dataSetCount;
        i++) {
      IDataSet dataSet = data.getDataSetByIndex(i);

      // don't include DataSets that cannot be highlighted
      if (!dataSet.isHighlightEnabled()) continue;

      mHighlightBuffer
          .addAll(buildHighlights(dataSet, i, xVal, Rounding.CLOSEST));
    }

    return mHighlightBuffer;
  }

  /**
   * An array of `Highlight` objects corresponding to the selected xValue and dataSetIndex.
   *
   * @param set
   * @param dataSetIndex
   * @param xVal
   * @param rounding
   * @return
   */
  List<Highlight> buildHighlights(
      IDataSet set, int dataSetIndex, double xVal, Rounding rounding) {
    List<Highlight> highlights = List();

    //noinspection unchecked
    List<Entry> entries = set.getEntriesForXValue(xVal);
    if (entries.length == 0) {
      // Try to find closest x-value and take all entries for that x-value
      final Entry closest = set.getEntryForXValue1(xVal, double.nan, rounding);
      if (closest != null) {
        //noinspection unchecked
        entries = set.getEntriesForXValue(closest.x);
      }
    }

    if (entries.length == 0) return highlights;

    for (Entry e in entries) {
      MPPointD pixels = mChart
          .getTransformer(set.getAxisDependency())
          .getPixelForValues(e.x, e.y);

      highlights.add(new Highlight(
          x: e.x,
          y: e.y,
          xPx: pixels.x,
          yPx: pixels.y,
          dataSetIndex: dataSetIndex,
          axis: set.getAxisDependency()));
    }

    return highlights;
  }

  /**
   * Returns the Highlight of the DataSet that contains the closest value on the
   * y-axis.
   *
   * @param closestValues        contains two Highlight objects per DataSet closest to the selected x-position (determined by
   *                             rounding up an down)
   * @param x
   * @param y
   * @param axis                 the closest axis
   * @param minSelectionDistance
   * @return
   */
  Highlight getClosestHighlightByPixel(List<Highlight> closestValues, double x,
      double y, AxisDependency axis, double minSelectionDistance) {
    Highlight closest = null;
    double distance = minSelectionDistance;

    for (int i = 0; i < closestValues.length; i++) {
      Highlight high = closestValues[i];

      if (axis == null || high.getAxis() == axis) {
        double cDistance = getDistance(x, y, high.getXPx(), high.getYPx());
        if (cDistance < distance) {
          closest = high;
          distance = cDistance;
        }
      }
    }

    return closest;
  }

  /**
   * Calculates the distance between the two given points.
   *
   * @param x1
   * @param y1
   * @param x2
   * @param y2
   * @return
   */
  double getDistance(double x1, double y1, double x2, double y2) {
    double x = pow((x1 - x2), 2);
    double y = pow((y1 - y2), 2);
    return sqrt(x + y);
  }

  BarLineScatterCandleBubbleData getData() {
    return mChart.getData();
  }
}

class BarHighlighter extends ChartHighlighter<BarDataProvider> {
  BarHighlighter(BarDataProvider chart) : super(chart);

  @override
  Highlight getHighlight(double x, double y) {
    Highlight high = super.getHighlight(x, y);

    if (high == null) {
      return null;
    }

    MPPointD pos = getValsForTouch(x, y);

    BarData barData = mChart.getBarData();

    IBarDataSet set = barData.getDataSetByIndex(high.getDataSetIndex());
    if (set.isStacked()) {
      return getStackedHighlight(high, set, pos.x, pos.y);
    }

    MPPointD.recycleInstance2(pos);

    return high;
  }

  /**
   * This method creates the Highlight object that also indicates which value of a stacked BarEntry has been
   * selected.
   *
   * @param high the Highlight to work with looking for stacked values
   * @param set
   * @param xVal
   * @param yVal
   * @return
   */
  Highlight getStackedHighlight(
      Highlight high, IBarDataSet set, double xVal, double yVal) {
    BarEntry entry = set.getEntryForXValue2(xVal, yVal);

    if (entry == null) return null;

    // not stacked
    if (entry.getYVals() == null) {
      return high;
    } else {
      List<Range> ranges = entry.getRanges();

      if (ranges.length > 0) {
        int stackIndex = getClosestStackIndex(ranges, yVal);

        MPPointD pixels = mChart
            .getTransformer(set.getAxisDependency())
            .getPixelForValues(high.getX(), ranges[stackIndex].to);

        Highlight stackedHigh = Highlight(
            x: entry.x,
            y: entry.y,
            xPx: pixels.x,
            yPx: pixels.y,
            dataSetIndex: high.getDataSetIndex(),
            stackIndex: stackIndex,
            axis: high.getAxis());

        MPPointD.recycleInstance2(pixels);

        return stackedHigh;
      }
    }
    return null;
  }

  /**
   * Returns the index of the closest value inside the values array / ranges (stacked barchart) to the value
   * given as
   * a parameter.
   *
   * @param ranges
   * @param value
   * @return
   */
  int getClosestStackIndex(List<Range> ranges, double value) {
    if (ranges == null || ranges.length == 0) return 0;
    int stackIndex = 0;
    for (Range range in ranges) {
      if (range.contains(value))
        return stackIndex;
      else
        stackIndex++;
    }
    int length = max(ranges.length - 1, 0);
    return (value > ranges[length].to) ? length : 0;
  }

  @override
  double getDistance(double x1, double y1, double x2, double y2) {
    return (x1 - x2).abs();
  }

  @override
  BarLineScatterCandleBubbleData getData() {
    return mChart.getBarData();
  }
}

class HorizontalBarHighlighter extends BarHighlighter {
  HorizontalBarHighlighter(BarDataProvider chart) : super(chart);

  @override
  Highlight getHighlight(double x, double y) {
    BarData barData = mChart.getBarData();

    MPPointD pos = getValsForTouch(y, x);

    Highlight high = getHighlightForX(pos.y, y, x);
    if (high == null) return null;

    IBarDataSet set = barData.getDataSetByIndex(high.getDataSetIndex());
    if (set.isStacked()) {
      return getStackedHighlight(high, set, pos.y, pos.x);
    }

    MPPointD.recycleInstance2(pos);

    return high;
  }

  @override
  List<Highlight> buildHighlights(
      IDataSet set, int dataSetIndex, double xVal, Rounding rounding) {
    List<Highlight> highlights = List();

    //noinspection unchecked
    List<Entry> entries = set.getEntriesForXValue(xVal);
    if (entries.length == 0) {
      // Try to find closest x-value and take all entries for that x-value
      final Entry closest = set.getEntryForXValue1(xVal, double.nan, rounding);
      if (closest != null) {
        //noinspection unchecked
        entries = set.getEntriesForXValue(closest.x);
      }
    }

    if (entries.length == 0) return highlights;

    for (Entry e in entries) {
      MPPointD pixels = mChart
          .getTransformer(set.getAxisDependency())
          .getPixelForValues(e.y, e.x);

      highlights.add(Highlight(
          x: e.x,
          y: e.y,
          xPx: pixels.x,
          yPx: pixels.y,
          dataSetIndex: dataSetIndex,
          axis: set.getAxisDependency()));
    }

    return highlights;
  }

  @override
  double getDistance(double x1, double y1, double x2, double y2) {
    return (y1 - y2).abs();
  }
}

abstract class PieRadarHighlighter<T extends PieRadarChartPainter>
    implements IHighlighter {
  T mChart;

  /**
   * buffer for storing previously highlighted values
   */
  List<Highlight> mHighlightBuffer = List();

  PieRadarHighlighter(T chart) {
    this.mChart = chart;
  }

  @override
  Highlight getHighlight(double x, double y) {
    double touchDistanceToCenter = mChart.distanceToCenter(x, y);

    // check if a slice was touched
    if (touchDistanceToCenter > mChart.getRadius()) {
      // if no slice was touched, highlight nothing
      return null;
    } else {
      double angle = mChart.getAngleForPoint(x, y);

      if (mChart is PieChartPainter) {
        angle /= mChart.mAnimator.getPhaseY();
      }

      int index = mChart.getIndexForAngle(angle);

      // check if the index could be found
      if (index < 0 ||
          index >= mChart.getData().getMaxEntryCountSet().getEntryCount()) {
        return null;
      } else {
        return getClosestHighlight(index, x, y);
      }
    }
  }

  /**
   * Returns the closest Highlight object of the given objects based on the touch position inside the chart.
   *
   * @param index
   * @param x
   * @param y
   * @return
   */
  Highlight getClosestHighlight(int index, double x, double y);
}

class PieHighlighter extends PieRadarHighlighter<PieChartPainter> {
  PieHighlighter(PieChartPainter chart) : super(chart);

  @override
  Highlight getClosestHighlight(int index, double x, double y) {
    IPieDataSet set = mChart.getData().getDataSet();

    final Entry entry = set.getEntryForIndex(index);

    return new Highlight(
        x: index.toDouble(),
        y: entry.y,
        xPx: x,
        yPx: y,
        dataSetIndex: 0,
        axis: set.getAxisDependency());
  }
}
