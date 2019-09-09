import 'dart:ui';

import 'package:mp_flutter_chart/chart/mp/core/data_interfaces/i_radar_data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_set/base_data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_set/data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/data_set/line_radar_data_set.dart';
import 'package:mp_flutter_chart/chart/mp/core/entry/radar_entry.dart';
import 'package:mp_flutter_chart/chart/mp/core/utils/color_utils.dart';
import 'package:mp_flutter_chart/chart/mp/core/utils/utils.dart';

class RadarDataSet extends LineRadarDataSet<RadarEntry>
    implements IRadarDataSet {
  /// flag indicating whether highlight circle should be drawn or not
  bool mDrawHighlightCircleEnabled = false;

  Color mHighlightCircleFillColor = ColorUtils.WHITE;

  /// The stroke color for highlight circle.
  /// If Utils.COLOR_NONE, the color of the dataset is taken.
  Color mHighlightCircleStrokeColor = ColorUtils.COLOR_NONE;

  int mHighlightCircleStrokeAlpha = (0.3 * 255).toInt();
  double mHighlightCircleInnerRadius = 3.0;
  double mHighlightCircleOuterRadius = 4.0;
  double mHighlightCircleStrokeWidth = 2.0;

  RadarDataSet(List<RadarEntry> yVals, String label) : super(yVals, label);

  /// Returns true if highlight circle should be drawn, false if not
  @override
  bool isDrawHighlightCircleEnabled() {
    return mDrawHighlightCircleEnabled;
  }

  /// Sets whether highlight circle should be drawn or not
  @override
  void setDrawHighlightCircleEnabled(bool enabled) {
    mDrawHighlightCircleEnabled = enabled;
  }

  @override
  Color getHighlightCircleFillColor() {
    return mHighlightCircleFillColor;
  }

  void setHighlightCircleFillColor(Color color) {
    mHighlightCircleFillColor = color;
  }

  /// Returns the stroke color for highlight circle.
  /// If Utils.COLOR_NONE, the color of the dataset is taken.
  @override
  Color getHighlightCircleStrokeColor() {
    return mHighlightCircleStrokeColor;
  }

  /// Sets the stroke color for highlight circle.
  /// Set to Utils.COLOR_NONE in order to use the color of the dataset;
  void setHighlightCircleStrokeColor(Color color) {
    mHighlightCircleStrokeColor = color;
  }

  @override
  int getHighlightCircleStrokeAlpha() {
    return mHighlightCircleStrokeAlpha;
  }

  void setHighlightCircleStrokeAlpha(int alpha) {
    mHighlightCircleStrokeAlpha = alpha;
  }

  @override
  double getHighlightCircleInnerRadius() {
    return mHighlightCircleInnerRadius;
  }

  void setHighlightCircleInnerRadius(double radius) {
    mHighlightCircleInnerRadius = radius;
  }

  @override
  double getHighlightCircleOuterRadius() {
    return mHighlightCircleOuterRadius;
  }

  void setHighlightCircleOuterRadius(double radius) {
    mHighlightCircleOuterRadius = radius;
  }

  @override
  double getHighlightCircleStrokeWidth() {
    return mHighlightCircleStrokeWidth;
  }

  void setHighlightCircleStrokeWidth(double strokeWidth) {
    mHighlightCircleStrokeWidth = strokeWidth;
  }

  @override
  DataSet<RadarEntry> copy1() {
    List<RadarEntry> entries = List<RadarEntry>();
    for (int i = 0; i < mValues.length; i++) {
      entries.add(mValues[i].copy());
    }
    RadarDataSet copied = RadarDataSet(entries, getLabel());
    copy(copied);
    return copied;
  }

  @override
  void copy(BaseDataSet baseDataSet) {
    super.copy(baseDataSet);
    if (baseDataSet is RadarDataSet) {
      var radarDataSet = baseDataSet;
      radarDataSet.mDrawHighlightCircleEnabled = mDrawHighlightCircleEnabled;
      radarDataSet.mHighlightCircleFillColor = mHighlightCircleFillColor;
      radarDataSet.mHighlightCircleInnerRadius = mHighlightCircleInnerRadius;
      radarDataSet.mHighlightCircleStrokeAlpha = mHighlightCircleStrokeAlpha;
      radarDataSet.mHighlightCircleStrokeColor = mHighlightCircleStrokeColor;
      radarDataSet.mHighlightCircleStrokeWidth = mHighlightCircleStrokeWidth;
    }
  }
}
