import 'dart:ui';

import 'package:mp_flutter_chart/chart/mp/core/data_interfaces/i_line_radar_data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_set/base_data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_set/line_scatter_candle_radar_data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/entry/entry.dart';
import 'package:mp_flutter_chart/chart/mp/core/utils/utils.dart';

abstract class LineRadarDataSet<T extends Entry>
    extends LineScatterCandleRadarDataSet<T> implements ILineRadarDataSet<T> {
  /**
   * the color that is used for filling the line surface
   */
  Color mFillColor = Color.fromARGB(255, 140, 234, 255);

  /**
   * the drawable to be used for filling the line surface
   */
//   Drawable mFillDrawable;

  /**
   * transparency used for filling line surface
   */
  int mFillAlpha = 85;

  /**
   * the width of the drawn data lines
   */
  double mLineWidth = 2.5;

  /**
   * if true, the data will also be drawn filled
   */
  bool mDrawFilled = false;

  LineRadarDataSet(List<T> yVals, String label) : super(yVals, label);

  @override
  Color getFillColor() {
    return mFillColor;
  }

  /**
   * Sets the color that is used for filling the area below the line.
   * Resets an eventually set "fillDrawable".
   *
   * @param color
   */
  void setFillColor(Color color) {
    mFillColor = color;
//    mFillDrawable = null;
  }

//  @override
//   Drawable getFillDrawable() {
//    return mFillDrawable;
//  }

  /**
   * Sets the drawable to be used to fill the area below the line.
   *
   * @param drawable
   */
//   void setFillDrawable(Drawable drawable) {
//    this.mFillDrawable = drawable;
//  }

  @override
  int getFillAlpha() {
    return mFillAlpha;
  }

  /**
   * sets the alpha value (transparency) that is used for filling the line
   * surface (0-255), default: 85
   *
   * @param alpha
   */
  void setFillAlpha(int alpha) {
    mFillAlpha = alpha;
  }

  /**
   * set the line width of the chart (min = 0.2f, max = 10f); default 1f NOTE:
   * thinner line == better performance, thicker line == worse performance
   *
   * @param width
   */
  void setLineWidth(double width) {
    if (width < 0.0) width = 0.0;
    if (width > 10.0) width = 10.0;
    mLineWidth = Utils.convertDpToPixel(width);
  }

  @override
  double getLineWidth() {
    return mLineWidth;
  }

  @override
  void setDrawFilled(bool filled) {
    mDrawFilled = filled;
  }

  @override
  bool isDrawFilledEnabled() {
    return mDrawFilled;
  }

  @override
  void copy(BaseDataSet baseDataSet) {
    super.copy(baseDataSet);

    if (baseDataSet is LineRadarDataSet) {
      var lineRadarDataSet = baseDataSet;
      lineRadarDataSet.mDrawFilled = mDrawFilled;
      lineRadarDataSet.mFillAlpha = mFillAlpha;
      lineRadarDataSet.mFillColor = mFillColor;
//      lineRadarDataSet.mFillDrawable = mFillDrawable;
      lineRadarDataSet.mLineWidth = mLineWidth;
    }
  }
}
