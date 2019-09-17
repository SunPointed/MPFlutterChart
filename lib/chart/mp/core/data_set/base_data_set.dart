import 'package:flutter/painting.dart';
import 'package:mp_flutter_chart/chart/mp/core/adapter_android_mp.dart';
import 'package:mp_flutter_chart/chart/mp/core/color/gradient_color.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_interfaces/i_data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/entry/entry.dart';
import 'dart:ui' as ui;

import 'package:mp_flutter_chart/chart/mp/core/enums/axis_dependency.dart';
import 'package:mp_flutter_chart/chart/mp/core/enums/legend_form.dart';
import 'package:mp_flutter_chart/chart/mp/core/poolable/point.dart';
import 'package:mp_flutter_chart/chart/mp/core/utils/color_utils.dart';
import 'package:mp_flutter_chart/chart/mp/core/value_formatter/value_formatter.dart';
import 'package:mp_flutter_chart/chart/mp/core/utils/utils.dart';

abstract class BaseDataSet<T extends Entry> implements IDataSet<T> {
  /// List representing all colors that are used for this DataSet
  List<ui.Color> mColors = null;

  GradientColor mGradientColor = null;

  List<GradientColor> mGradientColors = null;

  /// List representing all colors that are used for drawing the actual values for this DataSet
  List<ui.Color> mValueColors = null;

  /// label that describes the DataSet or the data the DataSet represents
  String mLabel = "DataSet";

  /// this specifies which axis this DataSet should be plotted against
  AxisDependency mAxisDependency = AxisDependency.LEFT;

  /// if true, value highlightning is enabled
  bool mHighlightEnabled = true;

  /// custom formatter that is used instead of the auto-formatter if set
  ValueFormatter mValueFormatter;

  /// the typeface used for the value text
  ui.TextStyle mValueTypeface;

  LegendForm mForm = LegendForm.DEFAULT;
  double mFormSize = double.nan;
  double mFormLineWidth = double.nan;
  DashPathEffect mFormLineDashEffect = null;

  /// if true, y-values are drawn on the chart
  bool mDrawValues = true;

  /// if true, y-icons are drawn on the chart
  bool mDrawIcons = false;

  /// the offset for drawing icons (in dp)
  MPPointF mIconsOffset = MPPointF(0, 0);

  /// the size of the value-text labels
  double mValueTextSize = 17;

  /// flag that indicates if the DataSet is visible or not
  bool mVisible = true;

  /// Default constructor.
  BaseDataSet() {
    mColors = List();
    mValueColors = List();

    // default color
    mColors.add(ui.Color.fromARGB(255, 140, 234, 255));
    mValueColors.add(ColorUtils.BLACK);
  }

  /// Constructor with label.
  ///
  /// @param label
  BaseDataSet.withLabel(String label) {
    mColors = List();
    mValueColors = List();

    // default color
    mColors.add(ui.Color.fromARGB(255, 140, 234, 255));
    mValueColors.add(ColorUtils.BLACK);
    this.mLabel = label;
  }

  /// Use this method to tell the data set that the underlying data has changed.
  void notifyDataSetChanged() {
    calcMinMax();
  }

  /**
   * ###### ###### COLOR GETTING RELATED METHODS ##### ######
   */

  @override
  List<ui.Color> getColors() {
    return mColors;
  }

  List<ui.Color> getValueColors() {
    return mValueColors;
  }

  @override
  ui.Color getColor1() {
    return mColors[0];
  }

  @override
  ui.Color getColor2(int index) {
    return mColors[index % mColors.length];
  }

  @override
  GradientColor getGradientColor1() {
    return mGradientColor;
  }

  @override
  List<GradientColor> getGradientColors() {
    return mGradientColors;
  }

  @override
  GradientColor getGradientColor2(int index) {
    return mGradientColors[index % mGradientColors.length];
  }

  /**
   * ###### ###### COLOR SETTING RELATED METHODS ##### ######
   */

  /// Sets the colors that should be used fore this DataSet. Colors are reused
  /// as soon as the number of Entries the DataSet represents is higher than
  /// the size of the colors array. If you are using colors from the resources,
  /// make sure that the colors are already prepared (by calling
  /// getResources().getColor(...)) before adding them to the DataSet.
  ///
  /// @param colors
  void setColors1(List<ui.Color> colors) {
    this.mColors = colors;
  }

  /// Adds a  color to the colors array of the DataSet.
  ///
  /// @param color
  void addColor(ui.Color color) {
    if (mColors == null) mColors = List();
    mColors.add(color);
  }

  /// Sets the one and ONLY color that should be used for this DataSet.
  /// Internally, this recreates the colors array and adds the specified color.
  ///
  /// @param color
  void setColor1(ui.Color color) {
    resetColors();
    mColors.add(color);
  }

  void setColor3(ui.Color color, int alpha) {
    resetColors();
    alpha = alpha > 255 ? 255 : (alpha < 0 ? 0 : alpha);
    mColors.add(Color.fromARGB(alpha, color.red, color.green, color.blue));
  }

  /// Sets the start and end color for gradient color, ONLY color that should be used for this DataSet.
  ///
  /// @param startColor
  /// @param endColor
  void setGradientColor(ui.Color startColor, ui.Color endColor) {
    mGradientColor = GradientColor(startColor, endColor);
  }

  /// Sets the start and end color for gradient colors, ONLY color that should be used for this DataSet.
  ///
  /// @param gradientColors
  void setGradientColors(List<GradientColor> gradientColors) {
    this.mGradientColors = gradientColors;
  }

  /// Sets a color with a specific alpha value.
  ///
  /// @param color
  /// @param alpha from 0-255
  void setColor2(ui.Color color, int alpha) {
    setColor1(ui.Color.fromARGB(alpha, color.red, color.green, color.blue));
  }

  /// Sets colors with a specific alpha value.
  ///
  /// @param colors
  /// @param alpha
  void setColors2(List<ui.Color> colors, int alpha) {
    resetColors();
    for (ui.Color color in colors) {
      addColor(ui.Color.fromARGB(alpha, color.red, color.green, color.blue));
    }
  }

  /// Resets all colors of this DataSet and recreates the colors array.
  void resetColors() {
    if (mColors == null) {
      mColors = List();
    }
    mColors.clear();
  }

  /// ###### ###### OTHER STYLING RELATED METHODS ##### ######

  @override
  void setLabel(String label) {
    mLabel = label;
  }

  @override
  String getLabel() {
    return mLabel;
  }

  @override
  void setHighlightEnabled(bool enabled) {
    mHighlightEnabled = enabled;
  }

  @override
  bool isHighlightEnabled() {
    return mHighlightEnabled;
  }

  @override
  void setValueFormatter(ValueFormatter f) {
    if (f == null)
      return;
    else
      mValueFormatter = f;
  }

  @override
  ValueFormatter getValueFormatter() {
    if (needsFormatter()) return Utils.getDefaultValueFormatter();
    return mValueFormatter;
  }

  @override
  bool needsFormatter() {
    return mValueFormatter == null;
  }

  @override
  void setValueTextColor(ui.Color color) {
    mValueColors.clear();
    mValueColors.add(color);
  }

  @override
  void setValueTextColors(List<ui.Color> colors) {
    mValueColors = colors;
  }

  @override
  void setValueTypeface(ui.TextStyle tf) {
    mValueTypeface = tf;
  }

  @override
  void setValueTextSize(double size) {
    mValueTextSize = Utils.convertDpToPixel(size);
  }

  @override
  ui.Color getValueTextColor1() {
    return mValueColors[0];
  }

  @override
  ui.Color getValueTextColor2(int index) {
    return mValueColors[index % mValueColors.length];
  }

  @override
  ui.TextStyle getValueTypeface() {
    return mValueTypeface;
  }

  @override
  double getValueTextSize() {
    return mValueTextSize;
  }

  void setForm(LegendForm form) {
    mForm = form;
  }

  @override
  LegendForm getForm() {
    return mForm;
  }

  void setFormSize(double formSize) {
    mFormSize = formSize;
  }

  @override
  double getFormSize() {
    return mFormSize;
  }

  void setFormLineWidth(double formLineWidth) {
    mFormLineWidth = formLineWidth;
  }

  @override
  double getFormLineWidth() {
    return mFormLineWidth;
  }

  void setFormLineDashEffect(DashPathEffect dashPathEffect) {
    mFormLineDashEffect = dashPathEffect;
  }

  @override
  DashPathEffect getFormLineDashEffect() {
    return mFormLineDashEffect;
  }

  @override
  void setDrawValues(bool enabled) {
    this.mDrawValues = enabled;
  }

  @override
  bool isDrawValuesEnabled() {
    return mDrawValues;
  }

  @override
  void setDrawIcons(bool enabled) {
    mDrawIcons = enabled;
  }

  @override
  bool isDrawIconsEnabled() {
    return mDrawIcons;
  }

  @override
  void setIconsOffset(MPPointF offsetDp) {
    mIconsOffset.x = offsetDp.x;
    mIconsOffset.y = offsetDp.y;
  }

  @override
  MPPointF getIconsOffset() {
    return mIconsOffset;
  }

  @override
  void setVisible(bool visible) {
    mVisible = visible;
  }

  @override
  bool isVisible() {
    return mVisible;
  }

  @override
  AxisDependency getAxisDependency() {
    return mAxisDependency;
  }

  @override
  void setAxisDependency(AxisDependency dependency) {
    mAxisDependency = dependency;
  }

  /// ###### ###### DATA RELATED METHODS ###### ######

  @override
  int getIndexInEntries(int xIndex) {
    for (int i = 0; i < getEntryCount(); i++) {
      if (xIndex == getEntryForIndex(i).x) return i;
    }

    return -1;
  }

  @override
  bool removeFirst() {
    if (getEntryCount() > 0) {
      T entry = getEntryForIndex(0);
      return removeEntry1(entry);
    } else
      return false;
  }

  @override
  bool removeLast() {
    if (getEntryCount() > 0) {
      T e = getEntryForIndex(getEntryCount() - 1);
      return removeEntry1(e);
    } else
      return false;
  }

  @override
  bool removeEntryByXValue(double xValue) {
    T e = getEntryForXValue2(xValue, double.nan);
    return removeEntry1(e);
  }

  @override
  bool removeEntry2(int index) {
    T e = getEntryForIndex(index);
    return removeEntry1(e);
  }

  @override
  bool contains(T e) {
    for (int i = 0; i < getEntryCount(); i++) {
      if (getEntryForIndex(i) == e) return true;
    }

    return false;
  }

  void copy(BaseDataSet baseDataSet) {
    baseDataSet.mAxisDependency = mAxisDependency;
    baseDataSet.mColors = mColors;
    baseDataSet.mDrawIcons = mDrawIcons;
    baseDataSet.mDrawValues = mDrawValues;
    baseDataSet.mForm = mForm;
    baseDataSet.mFormLineDashEffect = mFormLineDashEffect;
    baseDataSet.mFormLineWidth = mFormLineWidth;
    baseDataSet.mFormSize = mFormSize;
    baseDataSet.mGradientColor = mGradientColor;
    baseDataSet.mGradientColors = mGradientColors;
    baseDataSet.mHighlightEnabled = mHighlightEnabled;
    baseDataSet.mIconsOffset = mIconsOffset;
    baseDataSet.mValueColors = mValueColors;
    baseDataSet.mValueFormatter = mValueFormatter;
    baseDataSet.mValueColors = mValueColors;
    baseDataSet.mValueTextSize = mValueTextSize;
    baseDataSet.mVisible = mVisible;
  }
}
