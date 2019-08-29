import 'package:flutter/painting.dart';
import 'package:mp_flutter_chart/chart/mp/core/adapter_android_mp.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_interfaces/i_line_data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_set/base_data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_set/data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_set/line_radar_data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/entry/entry.dart';
import 'package:mp_flutter_chart/chart/mp/core/enums/mode.dart';
import 'package:mp_flutter_chart/chart/mp/core/fill_formatter/default_fill_formatter.dart';
import 'package:mp_flutter_chart/chart/mp/core/fill_formatter/i_fill_formatter.dart';
import 'package:mp_flutter_chart/chart/mp/core/util.dart';

class LineDataSet extends LineRadarDataSet<Entry> implements ILineDataSet {
  /**
   * Drawing mode for this line dataset
   **/
  Mode mMode = Mode.LINEAR;

  /**
   * List representing all colors that are used for the circles
   */
  List<Color> mCircleColors = null;

  /**
   * the color of the inner circles
   */
  Color mCircleHoleColor = ColorUtils.WHITE;

  /**
   * the radius of the circle-shaped value indicators
   */
  double mCircleRadius = 8;

  /**
   * the hole radius of the circle-shaped value indicators
   */
  double mCircleHoleRadius = 4;

  /**
   * sets the intensity of the cubic lines
   */
  double mCubicIntensity = 0.2;

  /**
   * the path effect of this DataSet that makes dashed lines possible
   */
  DashPathEffect mDashPathEffect = null;

  /**
   * formatter for customizing the position of the fill-line
   */
  IFillFormatter mFillFormatter = DefaultFillFormatter();

  /**
   * if true, drawing circles is enabled
   */
  bool mDrawCircles = true;

  bool mDrawCircleHole = true;

  LineDataSet(List<Entry> yVals, String label) : super(yVals, label) {
    // mCircleRadius = Utils.convertDpToPixel(4f);
    // mLineWidth = Utils.convertDpToPixel(1f);

    if (mCircleColors == null) {
      mCircleColors = List();
    }
    mCircleColors.clear();

    // default colors
    // mColors.add(Color.rgb(192, 255, 140));
    // mColors.add(Color.rgb(255, 247, 140));
    mCircleColors.add(Color.fromARGB(255, 140, 234, 255));
  }

  @override
  void copy(BaseDataSet baseDataSet) {
    super.copy(baseDataSet);
    if (baseDataSet is LineDataSet) {
      var lineDataSet = baseDataSet;
      lineDataSet.mCircleColors = mCircleColors;
      lineDataSet.mCircleHoleColor = mCircleHoleColor;
      lineDataSet.mCircleHoleRadius = mCircleHoleRadius;
      lineDataSet.mCircleRadius = mCircleRadius;
      lineDataSet.mCubicIntensity = mCubicIntensity;
      lineDataSet.mDashPathEffect = mDashPathEffect;
      lineDataSet.mDrawCircleHole = mDrawCircleHole;
      lineDataSet.mDrawCircles = mDrawCircleHole;
      lineDataSet.mFillFormatter = mFillFormatter;
      lineDataSet.mMode = mMode;
    }
  }

  /**
   * Returns the drawing mode for this line dataset
   *
   * @return
   */
  @override
  Mode getMode() {
    return mMode;
  }

  /**
   * Returns the drawing mode for this LineDataSet
   *
   * @return
   */
  void setMode(Mode mode) {
    mMode = mode;
  }

  /**
   * Sets the intensity for cubic lines (if enabled). Max = 1f = very cubic,
   * Min = 0.05f = low cubic effect, Default: 0.2f
   *
   * @param intensity
   */
  void setCubicIntensity(double intensity) {
    if (intensity > 1) intensity = 1;
    if (intensity < 0.05) intensity = 0.05;

    mCubicIntensity = intensity;
  }

  @override
  double getCubicIntensity() {
    return mCubicIntensity;
  }

  /**
   * Sets the radius of the drawn circles.
   * Default radius = 4f, Min = 1f
   *
   * @param radius
   */
  void setCircleRadius(double radius) {
    if (radius >= 1) {
      mCircleRadius = Utils.convertDpToPixel(radius);
    }
//    else {
//      Log.e("LineDataSet", "Circle radius cannot be < 1");
//    }
  }

  @override
  double getCircleRadius() {
    return mCircleRadius;
  }

  /**
   * Sets the hole radius of the drawn circles.
   * Default radius = 2f, Min = 0.5f
   *
   * @param holeRadius
   */
  void setCircleHoleRadius(double holeRadius) {
    if (holeRadius >= 0.5) {
      mCircleHoleRadius = Utils.convertDpToPixel(holeRadius);
    }
//    else {
//      Log.e("LineDataSet", "Circle radius cannot be < 0.5");
//    }
  }

  @override
  double getCircleHoleRadius() {
    return mCircleHoleRadius;
  }

  /**
   * sets the size (radius) of the circle shpaed value indicators,
   * default size = 4f
   * <p/>
   * This method is deprecated because of unclarity. Use setCircleRadius instead.
   *
   * @param size
   */
  void setCircleSize(double size) {
    setCircleRadius(size);
  }

  /**
   * This function is deprecated because of unclarity. Use getCircleRadius instead.
   */
  double getCircleSize() {
    return getCircleRadius();
  }

  /**
   * Enables the line to be drawn in dashed mode, e.g. like this
   * "- - - - - -". THIS ONLY WORKS IF HARDWARE-ACCELERATION IS TURNED OFF.
   * Keep in mind that hardware acceleration boosts performance.
   *
   * @param lineLength  the length of the line pieces
   * @param spaceLength the length of space in between the pieces
   * @param phase       offset, in degrees (normally, use 0)
   */
//  void enableDashedLine(double lineLength, double spaceLength, double phase) {
//    mDashPathEffect =  DashPathEffect( double[]{
//    lineLength, spaceLength
//    }, phase);
//  }

  /**
   * Disables the line to be drawn in dashed mode.
   */
  void disableDashedLine() {
    mDashPathEffect = null;
  }

  @override
  bool isDashedLineEnabled() {
    return mDashPathEffect == null ? false : true;
  }

//  @override
//   DashPathEffect getDashPathEffect() {
//    return mDashPathEffect;
//  }

  /**
   * set this to true to enable the drawing of circle indicators for this
   * DataSet, default true
   *
   * @param enabled
   */
  void setDrawCircles(bool enabled) {
    this.mDrawCircles = enabled;
  }

  @override
  bool isDrawCirclesEnabled() {
    return mDrawCircles;
  }

  @override
  bool isDrawCubicEnabled() {
    return mMode == Mode.CUBIC_BEZIER;
  }

  @override
  bool isDrawSteppedEnabled() {
    return mMode == Mode.STEPPED;
  }

  /** ALL CODE BELOW RELATED TO CIRCLE-COLORS */

  /**
   * returns all colors specified for the circles
   *
   * @return
   */
  List<Color> getCircleColors() {
    return mCircleColors;
  }

  @override
  Color getCircleColor(int index) {
    return mCircleColors[index];
  }

  @override
  int getCircleColorCount() {
    return mCircleColors.length;
  }

  /**
   * Sets the colors that should be used for the circles of this DataSet.
   * Colors are reused as soon as the number of Entries the DataSet represents
   * is higher than the size of the colors array. Make sure that the colors
   * are already prepared (by calling getResources().getColor(...)) before
   * adding them to the DataSet.
   *
   * @param colors
   */
  void setCircleColors(List<Color> colors) {
    mCircleColors = colors;
  }

  /**
   * Sets the one and ONLY color that should be used for this DataSet.
   * Internally, this recreates the colors array and adds the specified color.
   *
   * @param color
   */
  void setCircleColor(Color color) {
    resetCircleColors();
    mCircleColors.add(color);
  }

  /**
   * resets the circle-colors array and creates a  one
   */
  void resetCircleColors() {
    if (mCircleColors == null) {
      mCircleColors = List();
    }
    mCircleColors.clear();
  }

  /**
   * Sets the color of the inner circle of the line-circles.
   *
   * @param color
   */
  void setCircleHoleColor(Color color) {
    mCircleHoleColor = color;
  }

  @override
  Color getCircleHoleColor() {
    return mCircleHoleColor;
  }

  /**
   * Set this to true to allow drawing a hole in each data circle.
   *
   * @param enabled
   */
  void setDrawCircleHole(bool enabled) {
    mDrawCircleHole = enabled;
  }

  @override
  bool isDrawCircleHoleEnabled() {
    return mDrawCircleHole;
  }

  /**
   * Sets a custom IFillFormatter to the chart that handles the position of the
   * filled-line for each DataSet. Set this to null to use the default logic.
   *
   * @param formatter
   */
  void setFillFormatter(IFillFormatter formatter) {
    if (formatter == null)
      mFillFormatter = DefaultFillFormatter();
    else
      mFillFormatter = formatter;
  }

  @override
  IFillFormatter getFillFormatter() {
    return mFillFormatter;
  }

  @override
  DataSet<Entry> copy1() {
    List<Entry> entries = List();
    for (int i = 0; i < mValues.length; i++) {
      entries.add(Entry(
          x: mValues[i].x,
          y: mValues[i].y,
          icon: mValues[i].mIcon,
          data: mValues[i].mData));
    }
    LineDataSet copied = LineDataSet(entries, getLabel());
    copy(copied);
    return copied;
  }
}
