import 'dart:ui';

import 'package:mp_flutter_chart/chart/mp/core/data_interfaces/i_bar_data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_set/bar_line_scatter_candle_bubble_data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_set/base_data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_set/data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/entry/bar_entry.dart';
import 'package:mp_flutter_chart/chart/mp/core/util.dart';

class BarDataSet extends BarLineScatterCandleBubbleDataSet<BarEntry>
    implements IBarDataSet {
  /**
   * the maximum number of bars that are stacked upon each other, this value
   * is calculated from the Entries that are added to the DataSet
   */
  int mStackSize = 1;

  /**
   * the color used for drawing the bar shadows
   */
  Color mBarShadowColor = Color.fromARGB(255, 215, 215, 215);

  double mBarBorderWidth = 0.0;

  Color mBarBorderColor = ColorUtils.BLACK;

  /**
   * the alpha value used to draw the highlight indicator bar
   */
  int mHighLightAlpha = 120;

  /**
   * the overall entry count, including counting each stack-value individually
   */
  int mEntryCountStacks = 0;

  /**
   * array of labels used to describe the different values of the stacked bars
   */
  List<String> mStackLabels = List()..add("Stack");

  BarDataSet(List<BarEntry> yVals, String label) : super(yVals, label) {
    mHighLightColor = Color.fromARGB(255, 0, 0, 0);

    calcStackSize(yVals);
    calcEntryCountIncludingStacks(yVals);
  }

  @override
  DataSet<BarEntry> copy1() {
    List<BarEntry> entries = List();
    for (int i = 0; i < mValues.length; i++) {
      entries.add(mValues[i].copy());
    }
    BarDataSet copied = BarDataSet(entries, getLabel());
    copy(copied);
    return copied;
  }

  void copy(BaseDataSet baseDataSet) {
    super.copy(baseDataSet);
    if (baseDataSet is BarDataSet) {
      var barDataSet = baseDataSet;
      barDataSet.mStackSize = mStackSize;
      barDataSet.mBarShadowColor = mBarShadowColor;
      barDataSet.mBarBorderWidth = mBarBorderWidth;
      barDataSet.mStackLabels = mStackLabels;
      barDataSet.mHighLightAlpha = mHighLightAlpha;
    }
  }

  /**
   * Calculates the total number of entries this DataSet represents, including
   * stacks. All values belonging to a stack are calculated separately.
   */
  void calcEntryCountIncludingStacks(List<BarEntry> yVals) {
    mEntryCountStacks = 0;

    for (int i = 0; i < yVals.length; i++) {
      List<double> vals = yVals[i].getYVals();

      if (vals == null)
        mEntryCountStacks++;
      else
        mEntryCountStacks += vals.length;
    }
  }

  /**
   * calculates the maximum stacksize that occurs in the Entries array of this
   * DataSet
   */
  void calcStackSize(List<BarEntry> yVals) {
    for (int i = 0; i < yVals.length; i++) {
      List<double> vals = yVals[i].getYVals();

      if (vals != null && vals.length > mStackSize) mStackSize = vals.length;
    }
  }

  @override
  void calcMinMax1(BarEntry e) {
    if (e != null && !e.y.isNaN) {
      if (e.getYVals() == null) {
        if (e.y < mYMin) mYMin = e.y;

        if (e.y > mYMax) mYMax = e.y;
      } else {
        if (-e.getNegativeSum() < mYMin) mYMin = -e.getNegativeSum();

        if (e.getPositiveSum() > mYMax) mYMax = e.getPositiveSum();
      }

      calcMinMaxX1(e);
    }
  }

  @override
  int getStackSize() {
    return mStackSize;
  }

  @override
  bool isStacked() {
    return mStackSize > 1 ? true : false;
  }

  /**
   * returns the overall entry count, including counting each stack-value
   * individually
   *
   * @return
   */
  int getEntryCountStacks() {
    return mEntryCountStacks;
  }

  /**
   * Sets the color used for drawing the bar-shadows. The bar shadows is a
   * surface behind the bar that indicates the maximum value. Don't for get to
   * use getResources().getColor(...) to set this. Or Color.rgb(...).
   *
   * @param color
   */
  void setBarShadowColor(Color color) {
    mBarShadowColor = color;
  }

  @override
  Color getBarShadowColor() {
    return mBarShadowColor;
  }

  /**
   * Sets the width used for drawing borders around the bars.
   * If borderWidth == 0, no border will be drawn.
   *
   * @return
   */
  void setBarBorderWidth(double width) {
    mBarBorderWidth = width;
  }

  /**
   * Returns the width used for drawing borders around the bars.
   * If borderWidth == 0, no border will be drawn.
   *
   * @return
   */
  @override
  double getBarBorderWidth() {
    return mBarBorderWidth;
  }

  /**
   * Sets the color drawing borders around the bars.
   *
   * @return
   */
  void setBarBorderColor(Color color) {
    mBarBorderColor = color;
  }

  /**
   * Returns the color drawing borders around the bars.
   *
   * @return
   */
  @override
  Color getBarBorderColor() {
    return mBarBorderColor;
  }

  /**
   * Set the alpha value (transparency) that is used for drawing the highlight
   * indicator bar. min = 0 (fully transparent), max = 255 (fully opaque)
   *
   * @param alpha
   */
  void setHighLightAlpha(int alpha) {
    mHighLightAlpha = alpha;
  }

  @override
  int getHighLightAlpha() {
    return mHighLightAlpha;
  }

  /**
   * Sets labels for different values of bar-stacks, in case there are one.
   *
   * @param labels
   */
  void setStackLabels(List<String> labels) {
    mStackLabels = labels;
  }

  @override
  List<String> getStackLabels() {
    return mStackLabels;
  }
}
